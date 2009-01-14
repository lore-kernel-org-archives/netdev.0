From: David Hollis <dhollis@davehollis.com>
Subject: [PATCH - REPOST] asix.c - Add support for AX88772A devices -
Date: Wed, 14 Jan 2009 11:12:00 -0500
Message-ID: <1231949520.4105.97.camel@dhollis-lnx>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ENMr1avd7GupDyV2NRgL"
Cc: netdev@vger.kernel.org
To: jeff@garzik.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173003pub.verizon.net ([206.46.173.3]:44916 "EHLO
	vms173003pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761668AbZANQTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 11:19:11 -0500
Received: from smtp.davehollis.com ([96.243.190.12]) by vms173003.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0KDG00EG4YC40YV2@vms173003.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 14 Jan 2009 10:12:09 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ENMr1avd7GupDyV2NRgL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


The attached patch adds support for ASIX AX88772A devices, which is used
in some netbooks, notebooks and embedded devices.  It's largely
compatible with the AX88772 family.

This re-post does not include changes to the ax88772_link_reset()
function that removed the use of the generic MII calls in favor of more
explicit register reads.  Those changes were not required for AX88772A
support.

Thanks to Louis <louis@asix.com.tw> for the initial patch.

Signed-off-by: David Hollis <dhollis@davehollis.com>



--=-ENMr1avd7GupDyV2NRgL
Content-Disposition: inline; filename="asix.c-ax88772a-support-take2.patch"
Content-Type: text/x-patch; name="asix.c-ax88772a-support-take2.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

--- a/drivers/net/usb/asix.c	2009-01-02 01:06:26.000000000 -0500
+++ b/drivers/net/usb/asix.c	2009-01-14 10:35:11.000000000 -0500
@@ -35,7 +35,7 @@
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
 
-#define DRIVER_VERSION "14-Jun-2006"
+#define DRIVER_VERSION "8-Jan-2009"
 static const char driver_name [] = "asix";
 
 /* ASIX AX8817X based USB 2.0 Ethernet Devices */
@@ -93,8 +93,8 @@ static const char driver_name [] = "asix
 #define AX_SWRESET_IPPD			0x40
 
 #define AX88772_IPG0_DEFAULT		0x15
-#define AX88772_IPG1_DEFAULT		0x0c
-#define AX88772_IPG2_DEFAULT		0x12
+#define AX88772_IPG1_DEFAULT		0x16
+#define AX88772_IPG2_DEFAULT		0x1A
 
 /* AX88772 & AX88178 Medium Mode Register */
 #define AX_MEDIUM_PF		0x0080
@@ -136,6 +136,13 @@ static const char driver_name [] = "asix
 #define AX_DEFAULT_RX_CTL	\
 	(AX_RX_CTL_SO | AX_RX_CTL_AB )
 
+#define AX_PHYSELECT_PSEL	0x01
+#define AX_PHYSELECT_ASEL	0x02
+#define AX_PHYSELECT_SSMII	0x04
+#define AX_PHYSELECT_SSRMII	0x08
+#define AX_PHYSELECT_SSRRMII	0x0C
+#define AX_PHYSELECT_SSEN	0x10
+
 /* GPIO 0 .. 2 toggles */
 #define AX_GPIO_GPO0EN		0x01	/* GPIO0 Output enable */
 #define AX_GPIO_GPO_0		0x02	/* GPIO0 Output value */
@@ -891,7 +898,11 @@ static int ax88772_link_reset(struct usb
 	if (ecmd.duplex != DUPLEX_FULL)
 		mode &= ~AX_MEDIUM_FD;
 
-	devdbg(dev, "ax88772_link_reset() speed: %d duplex: %d setting mode to 0x%04x", ecmd.speed, ecmd.duplex, mode);
+	devdbg(dev,
+	"ax88772_link_reset() speed: %d duplex: %d setting mode to 0x%04x",
+		ecmd.speed,
+		ecmd.duplex,
+		mode);
 
 	asix_write_medium_mode(dev, mode);
 
@@ -1018,6 +1029,121 @@ out:
 	return ret;
 }
 
+static int ax88772a_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+	u16 rx_ctl;
+	struct asix_data *data = (struct asix_data *)&dev->data;
+	u8 buf[ETH_ALEN];
+	u32 phyid;
+
+	data->eeprom_len = AX88772_EEPROM_LEN;
+
+	usbnet_get_endpoints(dev,intf);
+
+	/* Power up the embedded PHY */
+	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
+		goto out;
+
+	/* Select the embedded PHY as the active PHY */
+	if ((ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT,
+				AX_PHYSELECT_SSEN | AX_PHYSELECT_PSEL,
+				0, 0, NULL)) < 0) {
+		dbg("Select PHY #1 failed: %d", ret);
+		goto out;
+	}
+
+	/* Reload the EEPROM and configure the GPIO pins */
+	if ((ret = asix_write_gpio(dev,
+		AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_GPIO_GPO2EN, 5)) < 0)
+	goto out;
+
+	/* Set embedded PHY in power down state */
+	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_IPPD)) < 0)
+		goto out;
+
+	msleep(10);
+
+	/* Set embedded PHY in power up state */
+	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
+		goto out;
+
+	msleep(60);
+
+	/* Set embedded PHY in reset state */
+	if ((ret = asix_sw_reset(dev, AX_SWRESET_CLEAR)) < 0)
+		goto out;
+
+	/* Set embedded PHY in operating state */
+	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
+		goto out;
+
+	/* Stop RX operation */
+	if ((ret = asix_write_rx_ctl(dev, 0)) < 0)
+		goto out;	
+
+	/* Get the MAC address */
+	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
+				0, 0, ETH_ALEN, buf)) < 0) {
+		dbg("Failed to read MAC address: %d", ret);
+		goto out;
+	}
+	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = asix_mdio_read;
+	dev->mii.mdio_write = asix_mdio_write;
+	dev->mii.phy_id_mask = 0x1f;
+	dev->mii.reg_num_mask = 0x1f;
+	dev->net->do_ioctl = asix_ioctl;
+	dev->mii.phy_id = asix_get_phy_addr(dev);
+
+	phyid = asix_get_phyid(dev);
+	dbg("PHYID=0x%08x", phyid);
+
+	dev->net->set_multicast_list = asix_set_multicast;
+	dev->net->ethtool_ops = &ax88772_ethtool_ops;
+
+	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+			ADVERTISE_ALL | ADVERTISE_CSMA);
+	mii_nway_restart(&dev->mii);
+
+	if ((ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT)) < 0)
+		goto out;
+
+	if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
+				AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
+				AX88772_IPG2_DEFAULT, 0, NULL)) < 0) {
+		dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
+		goto out;
+	}
+
+	msleep(1);
+
+	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
+	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
+		goto out;
+
+	rx_ctl = asix_read_rx_ctl(dev);
+	dbg("RX_CTL is 0x%04x after all initializations", rx_ctl);
+
+	rx_ctl = asix_read_medium_status(dev);
+	dbg("Medium Status is 0x%04x after all initializations", rx_ctl);
+
+	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
+	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
+		/* hard_mtu  is still the default - the device does not support
+		   jumbo eth frames */
+		dev->rx_urb_size = 2048;
+	}
+	return 0;
+
+out:
+	return ret;
+}
+
 static struct ethtool_ops ax88178_ethtool_ops = {
 	.get_drvinfo		= asix_get_drvinfo,
 	.get_link		= asix_get_link,
@@ -1339,6 +1465,17 @@ static const struct driver_info ax88772_
 	.tx_fixup = asix_tx_fixup,
 };
 
+static const struct driver_info ax88772a_info = {
+	.description = "ASIX AX88772A USB 2.0 Ethernet",
+	.bind = ax88772a_bind,
+	.status = asix_status,
+	.link_reset = ax88772_link_reset,
+	.reset = ax88772_link_reset,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = asix_rx_fixup,
+	.tx_fixup = asix_tx_fixup,
+};
+
 static const struct driver_info ax88178_info = {
 	.description = "ASIX AX88178 USB 2.0 Ethernet",
 	.bind = ax88178_bind,
@@ -1451,6 +1588,10 @@ static const struct usb_device_id	produc
 	// Cables-to-Go USB Ethernet Adapter
 	USB_DEVICE(0x0b95, 0x772a),
 	.driver_info = (unsigned long) &ax88772_info,
+}, {
+	// ASIX AX88772A
+	USB_DEVICE(0x0b95, 0x772a),
+	.driver_info = (unsigned long) &ax88772a_info,
 },
 	{ },		// END
 };

--=-ENMr1avd7GupDyV2NRgL--

