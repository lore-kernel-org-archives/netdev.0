From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH 2/3] NET: fix phy init for Asix AX88178 USB (GigE)
Date: Tue,  4 Oct 2011 12:55:17 -0700
Message-ID: <1317758118-24052-2-git-send-email-grundler@chromium.org>
References: <1317758118-24052-1-git-send-email-grundler@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw, Grant Grundler <grundler@chromium.org>,
	"Freddy Xin" <freddy@asix.com.tw>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317758118-24052-1-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Asix provided this patch and I've confirmed "Plugable USB2-E1000" and
"Shenzhen Winstars NWU220G" USB dongles can get a link and TX/RX data.

Signed-off-by: "Freddy Xin" <freddy@asix.com.tw>
Signed-off-by: Grant Grundler <grundler@chromium.org>
---
 drivers/net/usb/asix.c |  163 ++++++++++++++++++++++++++++++------------------
 1 files changed, 101 insertions(+), 62 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index a035aa9..23ee22d 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -164,6 +164,8 @@ static const char driver_name [] = "asix";
 #define MARVELL_CTRL_TXDELAY	0x0002
 #define MARVELL_CTRL_RXDELAY	0x0080
 
+#define	PHY_MODE_RTL8211CL	0x0004
+
 /* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
 struct asix_data {
 	u8 multi_filter[AX_MCAST_FILTER_SIZE];
@@ -1151,6 +1153,27 @@ static int marvell_phy_init(struct usbnet *dev)
 	return 0;
 }
 
+static int rtl8211cl_phy_init(struct usbnet *dev)
+{
+	struct asix_data *data = (struct asix_data *)&dev->data;
+
+	netdev_dbg(dev->net, "rtl8211cl_phy_init()\n");
+
+	asix_mdio_write (dev->net, dev->mii.phy_id, 0x1f, 0x0005);
+	asix_mdio_write (dev->net, dev->mii.phy_id, 0x0c, 0);
+	asix_mdio_write (dev->net, dev->mii.phy_id, 0x01,
+		asix_mdio_read (dev->net, dev->mii.phy_id, 0x01) | 0x0080);
+	asix_mdio_write (dev->net, dev->mii.phy_id, 0x1f, 0);
+
+	if (data->ledmode == 12) {
+		asix_mdio_write (dev->net, dev->mii.phy_id, 0x1f, 0x0002);
+		asix_mdio_write (dev->net, dev->mii.phy_id, 0x1a, 0x00cb);
+		asix_mdio_write (dev->net, dev->mii.phy_id, 0x1f, 0);
+	}
+
+	return 0;
+}
+
 static int marvell_led_status(struct usbnet *dev, u16 speed)
 {
 	u16 reg = asix_mdio_read(dev->net, dev->mii.phy_id, MARVELL_LED_MANUAL);
@@ -1177,6 +1200,81 @@ static int marvell_led_status(struct usbnet *dev, u16 speed)
 	return 0;
 }
 
+static int ax88178_reset(struct usbnet *dev)
+{
+	struct asix_data *data = (struct asix_data *)&dev->data;
+	int ret;
+	__le16 eeprom;
+	u8 status;
+	int gpio0 = 0;
+
+	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &status);
+	dbg("GPIO Status: 0x%04x", status);
+
+	asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0, 0, 0, NULL);
+	asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, &eeprom);
+	asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0, 0, 0, NULL);
+
+	dbg("EEPROM index 0x17 is 0x%04x", eeprom);
+
+	if (eeprom == cpu_to_le16(0xffff)) {
+		data->phymode = PHY_MODE_MARVELL;
+		data->ledmode = 0;
+		gpio0 = 1;
+	} else {
+		data->phymode = le16_to_cpu(eeprom) & 7;
+		data->ledmode = le16_to_cpu(eeprom) >> 8;
+		gpio0 = (le16_to_cpu(eeprom) & 0x80) ? 0 : 1;
+	}
+	dbg("GPIO0: %d, PhyMode: %d", gpio0, data->phymode);
+
+	asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 | AX_GPIO_GPO1EN, 40);
+	if ((le16_to_cpu(eeprom) >> 8) != 1) {
+		asix_write_gpio(dev, 0x003c, 30);
+		asix_write_gpio(dev, 0x001c, 300);
+		asix_write_gpio(dev, 0x003c, 30);
+	} else {
+		dbg("gpio phymode == 1 path");
+		asix_write_gpio(dev, AX_GPIO_GPO1EN, 30);
+		asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1, 30);
+	}
+
+	asix_sw_reset(dev, 0);
+	msleep(150);
+
+	asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
+	msleep(150);
+
+	asix_write_rx_ctl(dev, 0);
+
+	if (data->phymode == PHY_MODE_MARVELL) {
+		marvell_phy_init(dev);
+		msleep(60);
+	} else if (data->phymode == PHY_MODE_RTL8211CL)
+		rtl8211cl_phy_init(dev);
+
+	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR,
+			BMCR_RESET | BMCR_ANENABLE);
+	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+	asix_mdio_write(dev->net, dev->mii.phy_id, MII_CTRL1000,
+			ADVERTISE_1000FULL);
+
+	mii_nway_restart(&dev->mii);
+
+	if ((ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT)) < 0)
+		goto out;
+
+	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
+		goto out;
+
+	return 0;
+
+out:
+	return ret;
+
+}
+
 static int ax88178_link_reset(struct usbnet *dev)
 {
 	u16 mode;
@@ -1285,55 +1383,12 @@ static const struct net_device_ops ax88178_netdev_ops = {
 
 static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 {
-	struct asix_data *data = (struct asix_data *)&dev->data;
 	int ret;
 	u8 buf[ETH_ALEN];
-	__le16 eeprom;
-	u8 status;
-	int gpio0 = 0;
 	u32 phyid;
 
 	usbnet_get_endpoints(dev,intf);
 
-	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &status);
-	dbg("GPIO Status: 0x%04x", status);
-
-	asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0, 0, 0, NULL);
-	asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, &eeprom);
-	asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0, 0, 0, NULL);
-
-	dbg("EEPROM index 0x17 is 0x%04x", eeprom);
-
-	if (eeprom == cpu_to_le16(0xffff)) {
-		data->phymode = PHY_MODE_MARVELL;
-		data->ledmode = 0;
-		gpio0 = 1;
-	} else {
-		data->phymode = le16_to_cpu(eeprom) & 7;
-		data->ledmode = le16_to_cpu(eeprom) >> 8;
-		gpio0 = (le16_to_cpu(eeprom) & 0x80) ? 0 : 1;
-	}
-	dbg("GPIO0: %d, PhyMode: %d", gpio0, data->phymode);
-
-	asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 | AX_GPIO_GPO1EN, 40);
-	if ((le16_to_cpu(eeprom) >> 8) != 1) {
-		asix_write_gpio(dev, 0x003c, 30);
-		asix_write_gpio(dev, 0x001c, 300);
-		asix_write_gpio(dev, 0x003c, 30);
-	} else {
-		dbg("gpio phymode == 1 path");
-		asix_write_gpio(dev, AX_GPIO_GPO1EN, 30);
-		asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1, 30);
-	}
-
-	asix_sw_reset(dev, 0);
-	msleep(150);
-
-	asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
-	msleep(150);
-
-	asix_write_rx_ctl(dev, 0);
-
 	/* Get the MAC address */
 	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
 				0, 0, ETH_ALEN, buf)) < 0) {
@@ -1357,24 +1412,8 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 	phyid = asix_get_phyid(dev);
 	dbg("PHYID=0x%08x", phyid);
 
-	if (data->phymode == PHY_MODE_MARVELL) {
-		marvell_phy_init(dev);
-		msleep(60);
-	}
-
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR,
-			BMCR_RESET | BMCR_ANENABLE);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
-			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_CTRL1000,
-			ADVERTISE_1000FULL);
-
-	mii_nway_restart(&dev->mii);
-
-	if ((ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT)) < 0)
-		goto out;
-
-	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
+	ret = ax88178_reset(dev);
+	if (ret < 0)
 		goto out;
 
 	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
@@ -1445,7 +1484,7 @@ static const struct driver_info ax88178_info = {
 	.bind = ax88178_bind,
 	.status = asix_status,
 	.link_reset = ax88178_link_reset,
-	.reset = ax88178_link_reset,
+	.reset = ax88178_reset,
 	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
 	.rx_fixup = asix_rx_fixup,
 	.tx_fixup = asix_tx_fixup,
-- 
1.7.2.3
