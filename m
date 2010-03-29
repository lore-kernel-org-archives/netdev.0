From: Sebastien Jan <s-jan@ti.com>
Subject: [RFC PATCH 2/2] ks8851: Support MAC address read from companion EEPROM
Date: Mon, 29 Mar 2010 20:17:18 +0200
Message-ID: <1269886638-11025-3-git-send-email-s-jan@ti.com>
References: <1269886638-11025-1-git-send-email-s-jan@ti.com>
Cc: Abraham Arce <x0066660@ti.com>, Sebastien Jan <s-jan@ti.com>
To: netdev@vger.kernel.org, Ben Dooks <ben@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:42748 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754938Ab0C2SST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 14:18:19 -0400
In-Reply-To: <1269886638-11025-1-git-send-email-s-jan@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds the capability to read the MAC address stored in the
ks8851 companion EEPROM (if any) through debugfs.
cat <debugfs path>/ks8851/mac_eeprom
=> will output the MAC address stored in EEPROM

Note that this feature is supported from ks8851 controller revisions
greater than 0.

Signed-off-by: Sebastien Jan <s-jan@ti.com>
---
 drivers/net/ks8851.c |  167 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 165 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 4708598..187fb70 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -1271,6 +1271,116 @@ enum {	/* EEPROM programming states */
 };
 
 /**
+ * ks8851_eeprom_read - read a 16bits word in ks8851 companion EEPROM
+ * @dev: The network device the PHY is on.
+ * addr: EEPROM address to read
+ *
+ * ks8851_eeprom_size: used to define the data coding length. Can be changed
+ * through debug-fs.
+ *
+ * Programs a read on the EEPROM using ks8851 EEPROM SW access feature.
+ * Warning: The READ feature is is not supported on ks8851 revision 0.
+ *
+ * Rough programming model:
+ *  - on period start: set clock high and read value on bus
+ *  - on period / 2: set clock low and program value on bus
+ *  - start on period / 2
+ */
+unsigned int ks8851_eeprom_read(struct net_device *dev, unsigned int addr)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	int eepcr;
+	int ctrl = EEPROM_OP_READ;
+	int state = EEPROM_CONTROL;
+	int bit_count = EEPROM_OP_LEN - 1;
+	unsigned int data = 0;
+	int dummy;
+	unsigned int addr_len;
+
+	addr_len = (ks8851_eeprom_size == 1) ? 6 : 8;
+
+	/* start transaction: chip select high, authorize write */
+	mutex_lock(&ks->lock);
+	eepcr = EEPCR_EESA | EEPCR_EESRWA;
+	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
+	eepcr |= EEPCR_EECS;
+	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
+	mutex_unlock(&ks->lock);
+
+	while (state != EEPROM_COMPLETE) {
+		/* falling clock period starts... */
+		/* set EED_IO pin for control and address */
+		eepcr &= ~EEPCR_EEDO;
+		switch (state) {
+		case EEPROM_CONTROL:
+			eepcr |= ((ctrl >> bit_count) & 1) << 2;
+			if (bit_count-- <= 0) {
+				bit_count = addr_len - 1;
+				state = EEPROM_ADDRESS;
+			}
+			break;
+		case EEPROM_ADDRESS:
+			eepcr |= ((addr >> bit_count) & 1) << 2;
+			bit_count--;
+			break;
+		case EEPROM_DATA:
+			/* Change to receive mode */
+			eepcr &= ~EEPCR_EESRWA;
+			break;
+		}
+
+		/* lower clock  */
+		eepcr &= ~EEPCR_EESCK;
+
+		mutex_lock(&ks->lock);
+		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
+		mutex_unlock(&ks->lock);
+
+		/* waitread period / 2 */
+		udelay(EEPROM_SK_PERIOD / 2);
+
+		/* rising clock period starts... */
+
+		/* raise clock */
+		mutex_lock(&ks->lock);
+		eepcr |= EEPCR_EESCK;
+		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
+		mutex_unlock(&ks->lock);
+
+		/* Manage read */
+		switch (state) {
+		case EEPROM_ADDRESS:
+			if (bit_count < 0) {
+				bit_count = EEPROM_DATA_LEN - 1;
+				state = EEPROM_DATA;
+			}
+			break;
+		case EEPROM_DATA:
+			mutex_lock(&ks->lock);
+			dummy = ks8851_rdreg16(ks, KS_EEPCR);
+			mutex_unlock(&ks->lock);
+			data |= ((dummy >> EEPCR_EESB_OFFSET) & 1) << bit_count;
+			if (bit_count-- <= 0)
+				state = EEPROM_COMPLETE;
+			break;
+		}
+
+		/* wait period / 2 */
+		udelay(EEPROM_SK_PERIOD / 2);
+	}
+
+	/* close transaction */
+	mutex_lock(&ks->lock);
+	eepcr &= ~EEPCR_EECS;
+	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
+	eepcr = 0;
+	ks8851_wrreg16(ks, KS_EEPCR, eepcr);
+	mutex_unlock(&ks->lock);
+
+	return data;
+}
+
+/**
  * ks8851_eeprom_write - write a 16bits word in ks8851 companion EEPROM
  * @dev: The network device the PHY is on.
  * op: operand (can be WRITE, EWEN, EWDS)
@@ -1379,6 +1489,52 @@ void ks8851_eeprom_write(struct net_device *dev, unsigned int op,
 
 }
 
+/**
+ * ks8851_mac_eeprom_read - Read a MAC address in ks8851 companion EEPROM
+ *
+ * Warning: The READ feature is is not supported on ks8851 revision 0.
+ */
+static ssize_t ks8851_mac_eeprom_read(struct file *filep, char __user *buff,
+						size_t count, loff_t *offp)
+{
+	ssize_t ret;
+	struct net_device *dev = filep->private_data;
+	char str[50];
+	unsigned int data;
+	unsigned char mac_addr[6];
+
+	if (*offp > 0) {
+		ret = 0;
+		goto ks8851_cnt_rd_bk;
+	}
+
+	data = ks8851_eeprom_read(dev, 1);
+	mac_addr[5] = data & 0xFF;
+	mac_addr[4] = (data >> 8) & 0xFF;
+	data = ks8851_eeprom_read(dev, 2);
+	mac_addr[3] = data & 0xFF;
+	mac_addr[2] = (data >> 8) & 0xFF;
+	data = ks8851_eeprom_read(dev, 3);
+	mac_addr[1] = data & 0xFF;
+	mac_addr[0] = (data >> 8) & 0xFF;
+
+	sprintf(str, "%02x:%02x:%02x:%02x:%02x:%02x\n", mac_addr[0],
+			mac_addr[1], mac_addr[2], mac_addr[3], mac_addr[4],
+								mac_addr[5]);
+
+	ret = strlen(str);
+
+	if (copy_to_user((void __user *)buff, str, ret)) {
+		dev_err(&dev->dev, "ks8851 - copy_to_user failed\n");
+		ret = 0;
+	} else {
+		*offp = ret;
+	}
+
+ks8851_cnt_rd_bk:
+	return ret;
+}
+
 /*
  * Split the buffer `buf' into ':'-separated words.
  * Return the number of words or <0 on error.
@@ -1473,7 +1629,7 @@ static ssize_t ks8851_mac_eeprom_write(struct file *filep,
 
 static const struct file_operations ks8851_mac_eeprom_fops = {
 	.open		= ks8851_mac_eeprom_open,
-	.read		= NULL,
+	.read		= ks8851_mac_eeprom_read,
 	.write		= ks8851_mac_eeprom_write,
 	.llseek		= ks8851_mac_eeprom_seek,
 	.release	= ks8851_mac_eeprom_release,
@@ -1482,13 +1638,20 @@ static const struct file_operations ks8851_mac_eeprom_fops = {
 int __init ks8851_debug_init(struct net_device *dev)
 {
 	struct ks8851_net *ks = netdev_priv(dev);
+	mode_t mac_access = S_IWUGO;
 
 	if (ks->rc_ccr & CCR_EEPROM) {
 		ks8851_dir = debugfs_create_dir("ks8851", NULL);
 		if (IS_ERR(ks8851_dir))
 			return PTR_ERR(ks8851_dir);
 
-		debugfs_create_file("mac_eeprom", S_IWUGO, ks8851_dir, dev,
+		/* Check ks8851 version and features */
+		mutex_lock(&ks->lock);
+		if (CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)) > 0)
+			mac_access |= S_IRUGO;
+		mutex_unlock(&ks->lock);
+
+		debugfs_create_file("mac_eeprom", mac_access, ks8851_dir, dev,
 						&ks8851_mac_eeprom_fops);
 		debugfs_create_u32("eeprom_size", S_IRUGO | S_IWUGO,
 					ks8851_dir, &ks8851_eeprom_size);
-- 
1.6.3.3

