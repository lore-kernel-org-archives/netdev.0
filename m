From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH net-next 1/2] asix: Rework reading from EEPROM
Date: Thu, 19 Jul 2012 12:23:06 +0200
Message-ID: <1342693387-17945-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Allan Chou <allan@asix.com.tw>, Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:48637 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752386Ab2GSKXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 06:23:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code for reading the EEPROM via ethtool in the asix
driver has a few issues. It cannot handle odd length values
(accesses must be aligned at 16 bit boundaries) and interprets the
offset provided by ethtool as 16 bit word offset instead as byte offset.

The new code for asix_get_eeprom() introduced by this patch is
modeled after the code in
drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
and provides read access to the entire EEPROM with arbitrary
offsets and lengths.

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
 drivers/net/usb/asix.h         |    5 ++---
 drivers/net/usb/asix_common.c  |   39 ++++++++++++++++++++++-----------------
 drivers/net/usb/asix_devices.c |    9 ---------
 drivers/net/usb/ax88172a.c     |    3 ---
 4 files changed, 24 insertions(+), 32 deletions(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index 77d9e4c..fbff177 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -156,8 +156,7 @@
 #define AX_GPIO_RSE		0x80	/* Reload serial EEPROM */
 
 #define AX_EEPROM_MAGIC		0xdeadbeef
-#define AX88172_EEPROM_LEN	0x40
-#define AX88772_EEPROM_LEN	0xff
+#define AX_EEPROM_LEN		0x200
 
 /* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
 struct asix_data {
@@ -165,7 +164,7 @@ struct asix_data {
 	u8 mac_addr[ETH_ALEN];
 	u8 phymode;
 	u8 ledmode;
-	u8 eeprom_len;
+	u8 res;
 };
 
 int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 336f755..0b5b2d3 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -478,46 +478,51 @@ int asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
 
 int asix_get_eeprom_len(struct net_device *net)
 {
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
-	return data->eeprom_len;
+	return AX_EEPROM_LEN;
 }
 
 int asix_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
 		    u8 *data)
 {
 	struct usbnet *dev = netdev_priv(net);
-	__le16 *ebuf = (__le16 *)data;
+	u16 *eeprom_buff;
+	int first_word, last_word;
 	int i;
 
-	/* Crude hack to ensure that we don't overwrite memory
-	 * if an odd length is supplied
-	 */
-	if (eeprom->len % 2)
+	if (eeprom->len == 0)
 		return -EINVAL;
 
 	eeprom->magic = AX_EEPROM_MAGIC;
 
+	first_word = eeprom->offset >> 1;
+	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
+
+	eeprom_buff = kmalloc(sizeof(u16) * (last_word - first_word + 1),
+			      GFP_KERNEL);
+	if (!eeprom_buff)
+		return -ENOMEM;
+
 	/* ax8817x returns 2 bytes from eeprom on read */
-	for (i=0; i < eeprom->len / 2; i++) {
-		if (asix_read_cmd(dev, AX_CMD_READ_EEPROM,
-			eeprom->offset + i, 0, 2, &ebuf[i]) < 0)
-			return -EINVAL;
+	for (i = first_word; i <= last_word; i++) {
+		if (asix_read_cmd(dev, AX_CMD_READ_EEPROM, i, 0, 2,
+				  &(eeprom_buff[i - first_word])) < 0) {
+			kfree(eeprom_buff);
+			return -EIO;
+		}
 	}
+
+	memcpy(data, (u8 *)eeprom_buff + (eeprom->offset & 1), eeprom->len);
+	kfree(eeprom_buff);
 	return 0;
 }
 
 void asix_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
 {
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
 	/* Inherit standard device info */
 	usbnet_get_drvinfo(net, info);
 	strncpy (info->driver, DRIVER_NAME, sizeof info->driver);
 	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
-	info->eedump_len = data->eeprom_len;
+	info->eedump_len = AX_EEPROM_LEN;
 }
 
 int asix_set_mac_address(struct net_device *net, void *p)
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index ed9403b..658c08f 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -201,9 +201,6 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 	u8 buf[ETH_ALEN];
 	int i;
 	unsigned long gpio_bits = dev->driver_info->data;
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
-	data->eeprom_len = AX88172_EEPROM_LEN;
 
 	usbnet_get_endpoints(dev,intf);
 
@@ -409,12 +406,9 @@ static const struct net_device_ops ax88772_netdev_ops = {
 static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret, embd_phy;
-	struct asix_data *data = (struct asix_data *)&dev->data;
 	u8 buf[ETH_ALEN];
 	u32 phyid;
 
-	data->eeprom_len = AX88772_EEPROM_LEN;
-
 	usbnet_get_endpoints(dev,intf);
 
 	/* Get the MAC address */
@@ -767,9 +761,6 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret;
 	u8 buf[ETH_ALEN];
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
-	data->eeprom_len = AX88772_EEPROM_LEN;
 
 	usbnet_get_endpoints(dev,intf);
 
diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index 3d0f8fa..97dce0f 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -228,12 +228,9 @@ err:
 static int ax88172a_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret;
-	struct asix_data *data = (struct asix_data *)&dev->data;
 	u8 buf[ETH_ALEN];
 	struct ax88172a_private *priv;
 
-	data->eeprom_len = AX88772_EEPROM_LEN;
-
 	usbnet_get_endpoints(dev, intf);
 
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-- 
1.7.0.4
