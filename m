From: Joseph CHANG <josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/3] dm9601: manage eeprom to assure the chip for correct operation
Date: Thu, 10 Mar 2016 19:23:58 +0800
Message-ID: <1457609038-3636-1-git-send-email-josright123@gmail.com>
Cc: Joseph Chang <joseph_chang-Ubu6M+hUeUGoECsaD+WFmw@public.gmane.org>
To: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Joseph CHANG <josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add to maintain variant eeprom adapters which may have not right
dm962x's format.

Signed-off-by: Joseph CHANG <josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/dm9601.c | 72 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 72 insertions(+)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 520de4f..50095df 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -60,6 +60,7 @@
 #define DM_TX_OVERHEAD	2	/* 2 byte header */
 #define DM_RX_OVERHEAD	7	/* 3 byte header + 4 byte crc tail */
 #define DM_TIMEOUT	1000
+#define	DM_EP3I_VAL	0x07
 
 static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
@@ -193,6 +194,75 @@ static int dm_read_eeprom_word(struct usbnet *dev, u8 offset, void *value)
 	return dm_read_shared_word(dev, 0, offset, value);
 }
 
+static void dm_write_eeprom_word(struct usbnet *dev, u8 offset, __le16 data)
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
+	dm_write_eeprom_word(dev, wordoffset, srom);
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
+}
+
 
 
 static int dm9601_get_eeprom_len(struct net_device *dev)
@@ -420,6 +490,8 @@ static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 
 		/* Always return 8-bytes data to host per interrupt-interval */
 		dm_write_reg(dev, DM_USB_CTRL, USB_CTRL_EP3ACK);
+
+		dm_render_begin(dev);
 	}
 
 	/* power up phy */
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
