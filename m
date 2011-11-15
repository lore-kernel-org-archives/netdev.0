From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH 3/5] net-next:asix: reduce AX88772 init time by about 2 seconds
Date: Tue, 15 Nov 2011 09:12:41 -0800
Message-ID: <1321377163-26308-3-git-send-email-grundler@chromium.org>
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

ax88772_reset takes about 2 seconds and is called twice.
Once from ax88772_bind() directly and again indirectly from usbnet_open().
Reset the USB FW/Phy enough to blink the LEDs when inserted.

Signed-off-by: Allan Chou <allan@asix.com.tw>
Signed-off-by: Grant Grundler <grundler@chromium.org>
---
 drivers/net/usb/asix.c |   30 +++++++++++++++++++++++++-----
 1 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index b4675e8..8462be5 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1083,7 +1083,7 @@ static const struct net_device_ops ax88772_netdev_ops = {
 
 static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 {
-	int ret;
+	int ret, embd_phy;
 	struct asix_data *data = (struct asix_data *)&dev->data;
 	u8 buf[ETH_ALEN];
 	u32 phyid;
@@ -1108,16 +1108,36 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->mii.reg_num_mask = 0x1f;
 	dev->mii.phy_id = asix_get_phy_addr(dev);
 
-	phyid = asix_get_phyid(dev);
-	dbg("PHYID=0x%08x", phyid);
-
 	dev->net->netdev_ops = &ax88772_netdev_ops;
 	dev->net->ethtool_ops = &ax88772_ethtool_ops;
 
-	ret = ax88772_reset(dev);
+	embd_phy = ((dev->mii.phy_id & 0x1f) == 0x10 ? 1 : 0);
+
+	/* Reset the PHY to normal operation mode */
+	ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, embd_phy, 0, 0, NULL);
+	if (ret < 0) {
+		dbg("Select PHY #1 failed: %d", ret);
+		return ret;
+	}
+
+	ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL);
 	if (ret < 0)
 		return ret;
 
+	msleep(150);
+
+	ret = asix_sw_reset(dev, AX_SWRESET_CLEAR);
+	if (ret < 0)
+		return ret;
+
+	msleep(150);
+
+	ret = asix_sw_reset(dev, embd_phy ? AX_SWRESET_IPRL : AX_SWRESET_PRTE);
+
+	/* Read PHYID register *AFTER* the PHY was reset properly */
+	phyid = asix_get_phyid(dev);
+	dbg("PHYID=0x%08x", phyid);
+
 	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
 	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
 		/* hard_mtu  is still the default - the device does not support
-- 
1.7.3.1
