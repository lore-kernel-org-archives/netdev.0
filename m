From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH v3 3/3] asix: Add a new driver for the AX88172A
Date: Fri, 13 Jul 2012 17:26:31 +0200
Message-ID: <1342193191-18822-4-git-send-email-christian.riesch@omicron.at>
References: <1342193191-18822-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Joe Perches <joe@perches.com>,
	Michael Riesch <michael@riesch.at>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:49884 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756667Ab2GMPZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 11:25:34 -0400
In-Reply-To: <1342193191-18822-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Asix AX88172A is a USB 2.0 Ethernet interface that supports both an
internal PHY as well as an external PHY (connected via MII).

This patch adds a driver for the AX88172A and provides support for
both modes and the phylib.

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
 drivers/net/usb/Makefile       |    2 +-
 drivers/net/usb/asix.h         |    5 +
 drivers/net/usb/asix_common.c  |   12 +-
 drivers/net/usb/asix_devices.c |    6 +
 drivers/net/usb/ax88172a.c     |  415 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 437 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/usb/ax88172a.c

diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index a9490d9..bf06300 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -8,7 +8,7 @@ obj-$(CONFIG_USB_PEGASUS)	+= pegasus.o
 obj-$(CONFIG_USB_RTL8150)	+= rtl8150.o
 obj-$(CONFIG_USB_HSO)		+= hso.o
 obj-$(CONFIG_USB_NET_AX8817X)	+= asix.o
-asix-y := asix_devices.o asix_common.o
+asix-y := asix_devices.o asix_common.o ax88172a.o
 obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
 obj-$(CONFIG_USB_NET_CDC_EEM)	+= cdc_eem.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index 790af24..77d9e4c 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -74,6 +74,10 @@
 #define AX_CMD_SW_PHY_STATUS		0x21
 #define AX_CMD_SW_PHY_SELECT		0x22
 
+#define AX_PHY_SELECT_MASK		(BIT(3) | BIT(2))
+#define AX_PHY_SELECT_INTERNAL		0
+#define AX_PHY_SELECT_EXTERNAL		BIT(2)
+
 #define AX_MONITOR_MODE			0x01
 #define AX_MONITOR_LINK			0x02
 #define AX_MONITOR_MAGIC		0x04
@@ -181,6 +185,7 @@ struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 int asix_set_sw_mii(struct usbnet *dev);
 int asix_set_hw_mii(struct usbnet *dev);
 
+int asix_read_phy_addr(struct usbnet *dev, int internal);
 int asix_get_phy_addr(struct usbnet *dev);
 
 int asix_sw_reset(struct usbnet *dev, u8 flags);
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 3c1429a..336f755 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -258,8 +258,9 @@ int asix_set_hw_mii(struct usbnet *dev)
 	return ret;
 }
 
-int asix_get_phy_addr(struct usbnet *dev)
+int asix_read_phy_addr(struct usbnet *dev, int internal)
 {
+	int offset = (internal ? 1 : 0);
 	u8 buf[2];
 	int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
 
@@ -271,12 +272,19 @@ int asix_get_phy_addr(struct usbnet *dev)
 	}
 	netdev_dbg(dev->net, "asix_get_phy_addr() returning 0x%04x\n",
 		   *((__le16 *)buf));
-	ret = buf[1];
+	ret = buf[offset];
 
 out:
 	return ret;
 }
 
+int asix_get_phy_addr(struct usbnet *dev)
+{
+	/* return the address of the internal phy */
+	return asix_read_phy_addr(dev, 1);
+}
+
+
 int asix_sw_reset(struct usbnet *dev, u8 flags)
 {
 	int ret;
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 8c513f7..ed9403b 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -872,6 +872,8 @@ static const struct driver_info ax88178_info = {
 	.tx_fixup = asix_tx_fixup,
 };
 
+extern const struct driver_info ax88172a_info;
+
 static const struct usb_device_id	products [] = {
 {
 	// Linksys USB200M
@@ -997,6 +999,10 @@ static const struct usb_device_id	products [] = {
 	// Asus USB Ethernet Adapter
 	USB_DEVICE (0x0b95, 0x7e2b),
 	.driver_info = (unsigned long) &ax88772_info,
+}, {
+	/* ASIX 88172a demo board */
+	USB_DEVICE(0x0b95, 0x172a),
+	.driver_info = (unsigned long) &ax88172a_info,
 },
 	{ },		// END
 };
diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
new file mode 100644
index 0000000..534a144
--- /dev/null
+++ b/drivers/net/usb/ax88172a.c
@@ -0,0 +1,415 @@
+/*
+ * ASIX AX88172A based USB 2.0 Ethernet Devices
+ * Copyright (C) 2012 OMICRON electronics GmbH
+ *
+ * Supports external PHYs via phylib. Based on the driver for the
+ * AX88772. Original copyrights follow:
+ *
+ * Copyright (C) 2003-2006 David Hollis <dhollis@davehollis.com>
+ * Copyright (C) 2005 Phil Chang <pchang23@sbcglobal.net>
+ * Copyright (C) 2006 James Painter <jamie.painter@iname.com>
+ * Copyright (c) 2002-2003 TiVo Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "asix.h"
+#include <linux/phy.h>
+
+struct ax88172a_private {
+	struct mii_bus *mdio;
+	struct phy_device *phydev;
+	char phy_name[20];
+	u16 phy_addr;
+	u16 oldmode;
+	int use_embdphy;
+};
+
+/* MDIO read and write wrappers for phylib */
+static int asix_mdio_bus_read(struct mii_bus *bus, int phy_id, int regnum)
+{
+	return asix_mdio_read(((struct usbnet *)bus->priv)->net, phy_id,
+			      regnum);
+}
+
+static int asix_mdio_bus_write(struct mii_bus *bus, int phy_id, int regnum,
+			       u16 val)
+{
+	asix_mdio_write(((struct usbnet *)bus->priv)->net, phy_id, regnum, val);
+	return 0;
+}
+
+static int ax88172a_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
+{
+	if (!netif_running(net))
+		return -EINVAL;
+
+	if (!net->phydev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(net->phydev, rq, cmd);
+}
+
+/* set MAC link settings according to information from phylib */
+static void ax88172a_adjust_link(struct net_device *netdev)
+{
+	struct phy_device *phydev = netdev->phydev;
+	struct usbnet *dev = netdev_priv(netdev);
+	struct ax88172a_private *priv = dev->driver_priv;
+	u16 mode = 0;
+
+	if (phydev->link) {
+		mode = AX88772_MEDIUM_DEFAULT;
+
+		if (phydev->duplex == DUPLEX_HALF)
+			mode &= ~AX_MEDIUM_FD;
+
+		if (phydev->speed != SPEED_100)
+			mode &= ~AX_MEDIUM_PS;
+	}
+
+	if (mode != priv->oldmode) {
+		asix_write_medium_mode(dev, mode);
+		priv->oldmode = mode;
+		netdev_dbg(netdev, "speed %u duplex %d, setting mode to 0x%04x\n",
+			   phydev->speed, phydev->duplex, mode);
+		phy_print_status(phydev);
+	}
+}
+
+static void ax88172a_status(struct usbnet *dev, struct urb *urb)
+{
+	/* link changes are detected by polling the phy */
+}
+
+/* use phylib infrastructure */
+static int ax88172a_init_mdio(struct usbnet *dev)
+{
+	struct ax88172a_private *priv = dev->driver_priv;
+	int ret, i;
+
+	priv->mdio = mdiobus_alloc();
+	if (!priv->mdio) {
+		netdev_err(dev->net, "Could not allocate MDIO bus\n");
+		return -ENOMEM;
+	}
+
+	priv->mdio->priv = (void *)dev;
+	priv->mdio->read = &asix_mdio_bus_read;
+	priv->mdio->write = &asix_mdio_bus_write;
+	priv->mdio->name = "Asix MDIO Bus";
+	/* mii bus name is usb-<usb bus number>-<usb device number> */
+	snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "usb-%03d:%03d",
+		 dev->udev->bus->busnum, dev->udev->devnum);
+
+	priv->mdio->irq = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!priv->mdio->irq) {
+		netdev_err(dev->net, "Could not allocate mdio->irq\n");
+		ret = -ENOMEM;
+		goto mfree;
+	}
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		priv->mdio->irq[i] = PHY_POLL;
+
+	ret = mdiobus_register(priv->mdio);
+	if (ret) {
+		netdev_err(dev->net, "Could not register MDIO bus\n");
+		goto ifree;
+	}
+
+	netdev_info(dev->net, "registered mdio bus %s\n", priv->mdio->id);
+	return 0;
+
+ifree:
+	kfree(priv->mdio->irq);
+mfree:
+	mdiobus_free(priv->mdio);
+	return ret;
+}
+
+static void ax88172a_remove_mdio(struct usbnet *dev)
+{
+	struct ax88172a_private *priv = dev->driver_priv;
+
+	netdev_info(dev->net, "deregistering mdio bus %s\n", priv->mdio->id);
+	mdiobus_unregister(priv->mdio);
+	kfree(priv->mdio->irq);
+	mdiobus_free(priv->mdio);
+}
+
+static const struct net_device_ops ax88172a_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_set_mac_address	= asix_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= ax88172a_ioctl,
+	.ndo_set_rx_mode        = asix_set_multicast,
+};
+
+int ax88172a_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
+{
+	if (!net->phydev)
+		return -ENODEV;
+
+	return phy_ethtool_gset(net->phydev, cmd);
+}
+
+int ax88172a_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
+{
+	if (!net->phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(net->phydev, cmd);
+}
+
+int ax88172a_nway_reset(struct net_device *net)
+{
+	if (!net->phydev)
+		return -ENODEV;
+
+	return phy_start_aneg(net->phydev);
+}
+
+static const struct ethtool_ops ax88172a_ethtool_ops = {
+	.get_drvinfo		= asix_get_drvinfo,
+	.get_link		= usbnet_get_link,
+	.get_msglevel		= usbnet_get_msglevel,
+	.set_msglevel		= usbnet_set_msglevel,
+	.get_wol		= asix_get_wol,
+	.set_wol		= asix_set_wol,
+	.get_eeprom_len		= asix_get_eeprom_len,
+	.get_eeprom		= asix_get_eeprom,
+	.get_settings		= ax88172a_get_settings,
+	.set_settings		= ax88172a_set_settings,
+	.nway_reset		= ax88172a_nway_reset,
+};
+
+static int ax88172a_reset_phy(struct usbnet *dev, int embd_phy)
+{
+	int ret;
+
+	ret = asix_sw_reset(dev, AX_SWRESET_IPPD);
+	if (ret < 0)
+		goto err;
+
+	msleep(150);
+	ret = asix_sw_reset(dev, AX_SWRESET_CLEAR);
+	if (ret < 0)
+		goto err;
+
+	msleep(150);
+
+	ret = asix_sw_reset(dev, embd_phy ? AX_SWRESET_IPRL : AX_SWRESET_IPPD);
+	if (ret < 0)
+		goto err;
+
+	return 0;
+
+err:
+	return ret;
+}
+
+
+static int ax88172a_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+	struct asix_data *data = (struct asix_data *)&dev->data;
+	u8 buf[ETH_ALEN];
+	struct ax88172a_private *priv;
+
+	data->eeprom_len = AX88772_EEPROM_LEN;
+
+	usbnet_get_endpoints(dev, intf);
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		netdev_err(dev->net, "Could not allocate memory for private data\n");
+		return -ENOMEM;
+	}
+	dev->driver_priv = priv;
+
+	/* Get the MAC address */
+	ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
+	if (ret < 0) {
+		netdev_err(dev->net, "Failed to read MAC address: %d\n", ret);
+		goto free;
+	}
+	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+
+	dev->net->netdev_ops = &ax88172a_netdev_ops;
+	dev->net->ethtool_ops = &ax88172a_ethtool_ops;
+
+	/* are we using the internal or the external phy? */
+	ret = asix_read_cmd(dev, AX_CMD_SW_PHY_STATUS, 0, 0, 1, buf);
+	if (ret < 0) {
+		netdev_err(dev->net, "Failed to read software interface selection register: %d\n",
+			   ret);
+		goto free;
+	}
+
+	netdev_dbg(dev->net, "AX_CMD_SW_PHY_STATUS = 0x%02x\n", buf[0]);
+	switch (buf[0] & AX_PHY_SELECT_MASK) {
+	case AX_PHY_SELECT_INTERNAL:
+		netdev_dbg(dev->net, "use internal phy\n");
+		priv->use_embdphy = 1;
+		break;
+	case AX_PHY_SELECT_EXTERNAL:
+		netdev_dbg(dev->net, "use external phy\n");
+		priv->use_embdphy = 0;
+		break;
+	default:
+		netdev_err(dev->net, "Interface mode not supported by driver\n");
+		goto free;
+	}
+
+	priv->phy_addr = asix_read_phy_addr(dev, priv->use_embdphy);
+	ax88172a_reset_phy(dev, priv->use_embdphy);
+
+	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
+	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
+		/* hard_mtu  is still the default - the device does not support
+		   jumbo eth frames */
+		dev->rx_urb_size = 2048;
+	}
+
+	/* init MDIO bus */
+	ret = ax88172a_init_mdio(dev);
+	if (ret)
+		goto free;
+
+	return 0;
+
+free:
+	kfree(priv);
+	return ret;
+}
+
+static int ax88172a_stop(struct usbnet *dev)
+{
+	struct ax88172a_private *priv = dev->driver_priv;
+
+	netdev_dbg(dev->net, "Stopping interface\n");
+
+	if (priv->phydev) {
+		netdev_info(dev->net, "Disconnecting from phy %s\n",
+			    priv->phy_name);
+		phy_stop(priv->phydev);
+		phy_disconnect(priv->phydev);
+	}
+
+	return 0;
+}
+
+static void ax88172a_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct ax88172a_private *priv = dev->driver_priv;
+
+	ax88172a_remove_mdio(dev);
+	kfree(priv);
+}
+
+static int ax88172a_reset(struct usbnet *dev)
+{
+	struct asix_data *data = (struct asix_data *)&dev->data;
+	struct ax88172a_private *priv = dev->driver_priv;
+	int ret;
+	u16 rx_ctl;
+
+	ax88172a_reset_phy(dev, priv->use_embdphy);
+
+	msleep(150);
+	rx_ctl = asix_read_rx_ctl(dev);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x after software reset\n", rx_ctl);
+	ret = asix_write_rx_ctl(dev, 0x0000);
+	if (ret < 0)
+		goto out;
+
+	rx_ctl = asix_read_rx_ctl(dev);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x setting to 0x0000\n", rx_ctl);
+
+	msleep(150);
+
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			     AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
+			     AX88772_IPG2_DEFAULT, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "Write IPG,IPG1,IPG2 failed: %d\n", ret);
+		goto out;
+	}
+
+	/* Rewrite MAC address */
+	memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
+			     data->mac_addr);
+	if (ret < 0)
+		goto out;
+
+	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
+	ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
+	if (ret < 0)
+		goto out;
+
+	rx_ctl = asix_read_rx_ctl(dev);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x after all initializations\n",
+		   rx_ctl);
+
+	rx_ctl = asix_read_medium_status(dev);
+	netdev_dbg(dev->net, "Medium Status is 0x%04x after all initializations\n",
+		   rx_ctl);
+
+	/* Connect to PHY */
+	snprintf(priv->phy_name, 20, PHY_ID_FMT,
+		 priv->mdio->id, priv->phy_addr);
+
+	priv->phydev = phy_connect(dev->net, priv->phy_name,
+				   &ax88172a_adjust_link,
+				   0, PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(priv->phydev)) {
+		netdev_err(dev->net, "Could not connect to PHY device %s\n",
+			   priv->phy_name);
+		ret = PTR_ERR(priv->phydev);
+		goto out;
+	}
+
+	netdev_info(dev->net, "Connected to phy %s\n", priv->phy_name);
+
+	/* During power-up, the AX88172A set the power down (BMCR_PDOWN)
+	 * bit of the PHY. Bring the PHY up again.
+	 */
+	genphy_resume(priv->phydev);
+	phy_start(priv->phydev);
+
+	return 0;
+
+out:
+	return ret;
+
+}
+
+const struct driver_info ax88172a_info = {
+	.description = "ASIX AX88172A USB 2.0 Ethernet",
+	.bind = ax88172a_bind,
+	.reset = ax88172a_reset,
+	.stop = ax88172a_stop,
+	.unbind = ax88172a_unbind,
+	.status = ax88172a_status,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
+		 FLAG_MULTI_PACKET,
+	.rx_fixup = asix_rx_fixup,
+	.tx_fixup = asix_tx_fixup,
+};
-- 
1.7.0.4
