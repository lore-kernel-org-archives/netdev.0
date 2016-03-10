From: Joseph CHANG <josright123@gmail.com>
Subject: [PATCH 3/3] dm9601: add support ethtool style utility
Date: Thu, 10 Mar 2016 19:24:27 +0800
Message-ID: <1457609067-3674-1-git-send-email-josright123@gmail.com>
Cc: Joseph Chang <joseph_chang@davicom.com.tw>
To: Peter Korsgaard <jacmet@sunsite.dk>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joseph CHANG <josright123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add function dm9601_set_eeprom which tested good with ethtool
utility, include the eeprom words dump and the eeprom byte write.

Signed-off-by: Joseph CHANG <josright123@gmail.com>
---
 drivers/net/usb/dm9601.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 50095df..a6904f4 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -61,6 +61,7 @@
 #define DM_RX_OVERHEAD	7	/* 3 byte header + 4 byte crc tail */
 #define DM_TIMEOUT	1000
 #define	DM_EP3I_VAL	0x07
+#define	MD96XX_EEPROM_MAGIC	0x9620
 
 static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
@@ -289,6 +290,43 @@ static int dm9601_get_eeprom(struct net_device *net,
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
+			dm_write_eeprom_word(dev, offset / 2,
+					     tmp[0] | tmp[1] << 8);
+			mdelay(10);
+			done = 1;
+		} else {
+			dm_write_eeprom_word(dev, offset / 2,
+					     data[0] | data[1] << 8);
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
@@ -354,6 +392,7 @@ static const struct ethtool_ops dm9601_ethtool_ops = {
 	.set_msglevel	= usbnet_set_msglevel,
 	.get_eeprom_len	= dm9601_get_eeprom_len,
 	.get_eeprom	= dm9601_get_eeprom,
+	.set_eeprom	= dm9601_set_eeprom,
 	.get_settings	= usbnet_get_settings,
 	.set_settings	= usbnet_set_settings,
 	.nway_reset	= usbnet_nway_reset,
-- 
2.1.4
