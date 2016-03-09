From: Joseph CHANG <josright123@gmail.com>
Subject: [PATCH 1/1] dm9601: enable EP3 interrupt and enhance eeprom functions
Date: Wed,  9 Mar 2016 16:37:37 +0800
Message-ID: <1457512657-15352-1-git-send-email-josright123@gmail.com>
Cc: Joseph CHANG <josright123@gmail.com>
To: Peter Korsgaard <jacmet@sunsite.dk>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable chip's EP3 interrupt to get the link-up notify soon
immediately.

Add to maintain variant eeprom adapters which may have not right
dm9620x's format.

Add function dm9601_set_eeprom which tested good with ethtool
utility.

Signed-off-by: Joseph CHANG <josright123@gmail.com>
---
 drivers/net/usb/dm9601.c | 127 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 123 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 0b4bdd3..3027a60 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -46,6 +46,9 @@
 #define DM_GPR_DATA	0x1f
 #define DM_CHIP_ID	0x2c
 #define DM_MODE_CTRL	0x91	/* only on dm9620 */
+#define	DM_USB_CTRL	0xf4
+
+#define	USB_CTRL_EP3ACK	0x20
 
 /* chip id values */
 #define ID_DM9601	0
@@ -57,6 +60,9 @@
 #define DM_TX_OVERHEAD	2	/* 2 byte header */
 #define DM_RX_OVERHEAD	7	/* 3 byte header + 4 byte crc tail */
 #define DM_TIMEOUT	1000
+#define	DM_EP3I_VAL	0x07
+#define	DM_CONF_INC	126
+#define	MD96XX_EEPROM_MAGIC	0x9620
 
 static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
@@ -146,13 +152,14 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *valu
 	return ret;
 }
 
-static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 value)
+static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg,
+				__le16 *value)
 {
 	int ret, i;
 
 	mutex_lock(&dev->phy_mutex);
 
-	ret = dm_write(dev, DM_SHARED_DATA, 2, &value);
+	ret = dm_write(dev, DM_SHARED_DATA, 2, value);
 	if (ret < 0)
 		goto out;
 
@@ -190,6 +197,77 @@ static int dm_read_eeprom_word(struct usbnet *dev, u8 offset, void *value)
 	return dm_read_shared_word(dev, 0, offset, value);
 }
 
+static void dm_write_eeprom_word(struct usbnet *dev, u8 offset, void *data)
+{
+	dm_write_shared_word(dev, 0, offset, data);
+}
+
+static int dm_render_write(struct usbnet *dev, u8 wordoffset, u16 mask_word,
+			   u16 orset_word, u16 *pmd)
+{
+	u16 srom;
+
+	dm_read_eeprom_word(dev, wordoffset, &srom);
+	if ((srom & mask_word) == orset_word)
+		return 0;
+
+	srom &= ~mask_word;
+	srom |= orset_word;
+
+	dm_write_eeprom_word(dev, wordoffset, &srom);
+	*pmd = srom;
+	return 1;
+}
+
+static void dm_render_report(struct usbnet *dev, u8 wordoffset, u16 md)
+{
+	int i = 0;
+	u16 srom;
+
+	do {
+		i++;
+		usleep_range(100, 200);
+		dm_read_eeprom_word(dev, wordoffset, &srom);
+		if (i == 8)
+			break;
+	} while (srom != md);
+
+	if (srom == md) {
+		netdev_info(dev->net, "set eeprom word%d 0x%04x\n",
+			    wordoffset, md);
+	} else {
+		netdev_info(dev->net, "warning - set eeprom word%d 0x%04x\n",
+			    wordoffset, md);
+		netdev_info(dev->net, "warning - fail as eeprom word%d 0x%04x\n",
+			    wordoffset, srom);
+	}
+}
+
+static void dm_eeprom_render(struct usbnet *dev, u8 wordoffset,
+			     u16 orset_word, u16 mask_word)
+{
+	u16 m;
+
+	if (!dm_render_write(dev, wordoffset, mask_word, orset_word, &m))
+		return;
+
+	dm_render_report(dev, wordoffset, m);
+}
+
+static void dm_render_begin(struct usbnet *dev)
+{
+	/* Render eeprom if need, WORD3 render, set D[15:14] 01b */
+	dm_eeprom_render(dev, 3, 0x4000, 0xc000);
+	/* Render eeprom if need, WORD7 render, clear D[10] */
+	dm_eeprom_render(dev, 7, 0x0000, 0x0400);
+	/* Render eeprom if need, WORD11 render, need 0x005a */
+	dm_eeprom_render(dev, 11, 0x005a, 0xffff);
+	/* Render eeprom if need, WORD12 render, need 0x0007 */
+	dm_eeprom_render(dev, 12, DM_EP3I_VAL, 0xffff);
+	/* Render eeprom if need, WORD15 render, need E.g.126 (0x007e) */
+	dm_eeprom_render(dev, 15, (u16)(DM_CONF_INC << 8), 0xffff);
+}
+
 
 
 static int dm9601_get_eeprom_len(struct net_device *dev)
@@ -216,6 +294,41 @@ static int dm9601_get_eeprom(struct net_device *net,
 	return 0;
 }
 
+static int dm9601_set_eeprom(struct net_device *net,
+			     struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct usbnet *dev = netdev_priv(net);
+	int offset = eeprom->offset;
+	int len = eeprom->len;
+	int done;
+
+	if (eeprom->magic != MD96XX_EEPROM_MAGIC) {
+		netdev_dbg(dev->net, "EEPROM: magic value mismatch, magic = 0x%x",
+			   eeprom->magic);
+		return -EINVAL;
+	}
+
+	while (len > 0) {
+		if (len & 1 || offset & 1) {
+			int which = offset & 1;
+			u8 tmp[2];
+
+			dm_read_eeprom_word(dev, offset / 2, tmp);
+			tmp[which] = *data;
+			dm_write_eeprom_word(dev, offset / 2, tmp);
+			mdelay(10);
+			done = 1;
+		} else {
+			dm_write_eeprom_word(dev, offset / 2, data);
+			done = 2;
+		}
+		data += done;
+		offset += done;
+		len -= done;
+	}
+	return 0;
+}
+
 static int dm9601_mdio_read(struct net_device *netdev, int phy_id, int loc)
 {
 	struct usbnet *dev = netdev_priv(netdev);
@@ -250,7 +363,7 @@ static void dm9601_mdio_write(struct net_device *netdev, int phy_id, int loc,
 	netdev_dbg(dev->net, "dm9601_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
 		   phy_id, loc, val);
 
-	dm_write_shared_word(dev, 1, loc, res);
+	dm_write_shared_word(dev, 1, loc, &res);
 }
 
 static void dm9601_get_drvinfo(struct net_device *net,
@@ -281,6 +394,7 @@ static const struct ethtool_ops dm9601_ethtool_ops = {
 	.set_msglevel	= usbnet_set_msglevel,
 	.get_eeprom_len	= dm9601_get_eeprom_len,
 	.get_eeprom	= dm9601_get_eeprom,
+	.set_eeprom	= dm9601_set_eeprom,
 	.get_settings	= usbnet_get_settings,
 	.set_settings	= usbnet_set_settings,
 	.nway_reset	= usbnet_nway_reset,
@@ -344,7 +458,7 @@ static const struct net_device_ops dm9601_netdev_ops = {
 	.ndo_tx_timeout		= usbnet_tx_timeout,
 	.ndo_change_mtu		= usbnet_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_do_ioctl 		= dm9601_ioctl,
+	.ndo_do_ioctl		= dm9601_ioctl,
 	.ndo_set_rx_mode	= dm9601_set_multicast,
 	.ndo_set_mac_address	= dm9601_set_mac_address,
 };
@@ -414,6 +528,11 @@ static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 			goto out;
 		}
 		dm_write_reg(dev, DM_MODE_CTRL, mode & 0x7f);
+
+		/* Always return 8-bytes data to host per interrupt-interval */
+		dm_write_reg(dev, DM_USB_CTRL, USB_CTRL_EP3ACK);
+
+		dm_render_begin(dev);
 	}
 
 	/* power up phy */
-- 
2.1.4
