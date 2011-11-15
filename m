From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH 4/5] net-next:asix: V2 more fixes for ax88178 phy init sequence
Date: Tue, 15 Nov 2011 09:12:42 -0800
Message-ID: <1321377163-26308-4-git-send-email-grundler@chromium.org>
References: <1321377163-26308-1-git-send-email-grundler@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Allan Chou <allan@asix.com.tw>,
	Freddy Xin <freddy@asix.com.tw>,
	Grant Grundler <grundler@google.com>,
	Grant Grundler <grundler@chromium.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321377163-26308-1-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@google.com>

Now works on Samsung Series 5 (chromebook)

Two fixes here:
o use 0x7F mask for phymode
o read phyid *AFTER* phy is powered up (via GPIOs)

Signed-off-by: Allan Chou <allan@asix.com.tw>
Signed-off-by: Grant Grundler <grundler@chromium.org>
---
Dave,
Apologies again for botching this patch (not compiling).
I had failed to s/ax88178_reset/asix_sw_reset/ and gave a blend of the two.
I've reviewed and compile tested all 5 patches.

 drivers/net/usb/asix.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 8462be5..f870ab9 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1248,6 +1248,7 @@ static int ax88178_reset(struct usbnet *dev)
 	__le16 eeprom;
 	u8 status;
 	int gpio0 = 0;
+	u32 phyid;
 
 	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &status);
 	dbg("GPIO Status: 0x%04x", status);
@@ -1263,12 +1264,13 @@ static int ax88178_reset(struct usbnet *dev)
 		data->ledmode = 0;
 		gpio0 = 1;
 	} else {
-		data->phymode = le16_to_cpu(eeprom) & 7;
+		data->phymode = le16_to_cpu(eeprom) & 0x7F;
 		data->ledmode = le16_to_cpu(eeprom) >> 8;
 		gpio0 = (le16_to_cpu(eeprom) & 0x80) ? 0 : 1;
 	}
 	dbg("GPIO0: %d, PhyMode: %d", gpio0, data->phymode);
 
+	/* Power up external GigaPHY through AX88178 GPIO pin */
 	asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 | AX_GPIO_GPO1EN, 40);
 	if ((le16_to_cpu(eeprom) >> 8) != 1) {
 		asix_write_gpio(dev, 0x003c, 30);
@@ -1280,6 +1282,13 @@ static int ax88178_reset(struct usbnet *dev)
 		asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1, 30);
 	}
 
+	/* Read PHYID register *AFTER* powering up PHY */
+	phyid = asix_get_phyid(dev);
+	dbg("PHYID=0x%08x", phyid);
+
+	/* Set AX88178 to enable MII/GMII/RGMII interface for external PHY */
+	asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0, 0, 0, NULL);
+
 	asix_sw_reset(dev, 0);
 	msleep(150);
 
@@ -1424,7 +1433,6 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret;
 	u8 buf[ETH_ALEN];
-	u32 phyid;
 	struct asix_data *data = (struct asix_data *)&dev->data;
 
 	data->eeprom_len = AX88772_EEPROM_LEN;
@@ -1451,12 +1459,12 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->netdev_ops = &ax88178_netdev_ops;
 	dev->net->ethtool_ops = &ax88178_ethtool_ops;
 
-	phyid = asix_get_phyid(dev);
-	dbg("PHYID=0x%08x", phyid);
+	/* Blink LEDS so users know driver saw dongle */
+	asix_sw_reset(dev, 0);
+	msleep(150);
 
-	ret = ax88178_reset(dev);
-	if (ret < 0)
-		return ret;
+	asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
+	msleep(150);
 
 	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
 	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
-- 
1.7.3.1
