From: Sebastien Jan <s-jan@ti.com>
Subject: [RFC PATCH 1/2] ks8851: Support MAC address write to companion EEPROM
Date: Mon, 29 Mar 2010 20:17:17 +0200
Message-ID: <1269886638-11025-2-git-send-email-s-jan@ti.com>
References: <1269886638-11025-1-git-send-email-s-jan@ti.com>
Cc: Abraham Arce <x0066660@ti.com>, Sebastien Jan <s-jan@ti.com>
To: netdev@vger.kernel.org, Ben Dooks <ben@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:54512 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab0C2SSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 14:18:16 -0400
In-Reply-To: <1269886638-11025-1-git-send-email-s-jan@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ks8851_write_mac_addr() function upates the MAC address
stored in the ks8851 controler and used for ethernet traffic,
but does not store the MAC address to the companion EEPROM.

This patch implements a debugfs entry for writing the MAC address
to the ks8851 companion EEPROM (if there is any): ks8851/mac_eeprom
echo "01:23:45:67:89:AB" > <debugfs path>/ks8851/mac_eeprom
=> writes the MAC address.

The companion EEPROM size can be configured through another debug-fs
entry: ks8851/eeprom_size (has an impact on the protocol to access the
EEPROM).

Signed-off-by: Sebastien Jan <s-jan@ti.com>
---
 drivers/net/ks8851.c |  282 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ks8851.h |   14 +++-
 2 files changed, 295 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 71eee3e..4708598 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -22,6 +22,11 @@
 
 #include <linux/spi/spi.h>
 
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+#include <linux/ctype.h>
+#endif
+
 #include "ks8851.h"
 
 /**
@@ -1237,6 +1242,280 @@ static int ks8851_read_selftest(struct ks8851_net *ks)
 	return 0;
 }
 
+#ifdef CONFIG_DEBUG_FS
+static struct dentry *ks8851_dir;
+
+static int ks8851_mac_eeprom_open(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static int ks8851_mac_eeprom_release(struct inode *inode, struct file *file)
+{
+	return 0;
+}
+
+static loff_t ks8851_mac_eeprom_seek(struct file *file, loff_t off, int whence)
+{
+	return 0;
+}
+
+int ks8851_eeprom_size; /* EEPROM size in kB: 1, 2 or 4 */
+
+enum {	/* EEPROM programming states */
+	EEPROM_CONTROL,
+	EEPROM_ADDRESS,
+	EEPROM_DATA,
+	EEPROM_COMPLETE
+};
+
+/**
+ * ks8851_eeprom_write - write a 16bits word in ks8851 companion EEPROM
+ * @dev: The network device the PHY is on.
+ * op: operand (can be WRITE, EWEN, EWDS)
+ * addr: EEPROM address to write
+ * data: data to write
+ *
+ * ks8851_eeprom_size: used to define the data coding length. Can be changed
+ * through debug-fs.
+ *
+ * Programs a write on the EEPROM using ks8851 EEPROM SW access feature.
+ *
+ * Note that a write enable is required before writing data.
+ *
+ * Rough programming model:
+ *  - on period start: set clock high
+ *  - on period / 2: set clock low and program value on bus
+ *  - start on period / 2
+ */
+void ks8851_eeprom_write(struct net_device *dev, unsigned int op,
+					unsigned int addr, unsigned int data)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	int eepcr;
+	int state = EEPROM_CONTROL;
+	int bit_count = EEPROM_OP_LEN - 1;
+	unsigned int addr_len;
+
+	addr_len = (ks8851_eeprom_size == 1) ? 6 : 8;
+
+	switch (op) {
+	case EEPROM_OP_EWEN:
+		addr = 0x30;
+	break;
+	case EEPROM_OP_EWDS:
+		addr = 0;
+		break;
+	}
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
+			eepcr |= ((op >> bit_count) & 1) << 2;
+			if (bit_count-- <= 0) {
+				bit_count = addr_len - 1;
+				state = EEPROM_ADDRESS;
+			}
+			break;
+		case EEPROM_ADDRESS:
+			eepcr |= ((addr >> bit_count) & 1) << 2;
+			if (bit_count-- <= 0) {
+				if (op == EEPROM_OP_WRITE) {
+					bit_count = EEPROM_DATA_LEN - 1;
+					state = EEPROM_DATA;
+				} else {
+					state = EEPROM_COMPLETE;
+				}
+			}
+			break;
+		case EEPROM_DATA:
+			eepcr |= ((data >> bit_count) & 1) << 2;
+			if (bit_count-- <= 0)
+				state = EEPROM_COMPLETE;
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
+		/* wait period / 2 */
+		udelay(EEPROM_SK_PERIOD / 2);
+
+		/* rising clock period starts... */
+
+		/* raise clock */
+		eepcr |= EEPCR_EESCK;
+		mutex_lock(&ks->lock);
+		ks8851_wrreg16(ks, KS_EEPCR, eepcr);
+		mutex_unlock(&ks->lock);
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
+}
+
+/*
+ * Split the buffer `buf' into ':'-separated words.
+ * Return the number of words or <0 on error.
+ */
+#define isdelimiter(c)	((c) == ':')
+static int ks8851_debug_tokenize(char *buf, char *words[], int maxwords)
+{
+	int nwords = 0;
+
+	while (*buf) {
+		char *end;
+
+		/* Skip leading whitespace */
+		while (*buf && isspace(*buf))
+			buf++;
+		if (!*buf)
+			break;	/* oh, it was trailing whitespace */
+
+		/* Run `end' over a word */
+		for (end = buf ; *end && !isdelimiter(*end) ; end++)
+			;
+		/* `buf' is the start of the word, `end' is one past the end */
+
+		if (nwords == maxwords)
+			return -EINVAL;	/* ran out of words[] before bytes */
+		if (*end)
+			*end++ = '\0';	/* terminate the word */
+		words[nwords++] = buf;
+		buf = end;
+	}
+	return nwords;
+}
+
+/**
+ * ks8851_mac_eeprom_write - Write a MAC address in ks8851 companion EEPROM
+ *
+ */
+static ssize_t ks8851_mac_eeprom_write(struct file *filep,
+			const char __user *buff, size_t count, loff_t *offp)
+{
+	struct net_device *dev = filep->private_data;
+	ssize_t ret;
+#define MAXWORDS 6
+	int nwords, i;
+	char *words[MAXWORDS];
+	char tmpbuf[256];
+	unsigned long mac_addr[6];
+
+	if (count == 0)
+		return 0;
+	if (count > sizeof(tmpbuf)-1)
+		return -E2BIG;
+	if (copy_from_user(tmpbuf, buff, count))
+		return -EFAULT;
+	tmpbuf[count] = '\0';
+	dev_dbg(&dev->dev, "%s: read %d bytes from userspace\n",
+			__func__, (int)count);
+
+	nwords = ks8851_debug_tokenize(tmpbuf, words, MAXWORDS);
+	if (nwords != 6) {
+		dev_warn(&dev->dev,
+		"ks8851 MAC address write to EEPROM requires a MAC address " \
+						"like 01:23:45:67:89:AB\n");
+		return -EINVAL;
+	}
+
+	for (i = 0; i < 6; i++)
+		strict_strtoul(words[i], 16, &mac_addr[i]);
+
+	ks8851_eeprom_write(dev, EEPROM_OP_EWEN, 0, 0);
+
+	ks8851_eeprom_write(dev, EEPROM_OP_WRITE, 1,
+						mac_addr[4] << 8 | mac_addr[5]);
+	mdelay(EEPROM_WRITE_TIME);
+	ks8851_eeprom_write(dev, EEPROM_OP_WRITE, 2,
+						mac_addr[2] << 8 | mac_addr[3]);
+	mdelay(EEPROM_WRITE_TIME);
+	ks8851_eeprom_write(dev, EEPROM_OP_WRITE, 3,
+						mac_addr[0] << 8 | mac_addr[1]);
+	mdelay(EEPROM_WRITE_TIME);
+
+	ks8851_eeprom_write(dev, EEPROM_OP_EWDS, 0, 0);
+
+	dev_dbg(&dev->dev, "MAC address %02lx.%02lx.%02lx.%02lx.%02lx.%02lx "\
+			"written to EEPROM\n", mac_addr[0], mac_addr[1],
+			mac_addr[2], mac_addr[3], mac_addr[4], mac_addr[5]);
+
+	ret = count;
+	*offp += count;
+	return ret;
+}
+
+static const struct file_operations ks8851_mac_eeprom_fops = {
+	.open		= ks8851_mac_eeprom_open,
+	.read		= NULL,
+	.write		= ks8851_mac_eeprom_write,
+	.llseek		= ks8851_mac_eeprom_seek,
+	.release	= ks8851_mac_eeprom_release,
+};
+
+int __init ks8851_debug_init(struct net_device *dev)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+
+	if (ks->rc_ccr & CCR_EEPROM) {
+		ks8851_dir = debugfs_create_dir("ks8851", NULL);
+		if (IS_ERR(ks8851_dir))
+			return PTR_ERR(ks8851_dir);
+
+		debugfs_create_file("mac_eeprom", S_IWUGO, ks8851_dir, dev,
+						&ks8851_mac_eeprom_fops);
+		debugfs_create_u32("eeprom_size", S_IRUGO | S_IWUGO,
+					ks8851_dir, &ks8851_eeprom_size);
+		ks8851_eeprom_size = 1;
+	} else {
+		ks8851_dir = NULL;
+	}
+	return 0;
+}
+
+void ks8851_debug_exit(void)
+{
+	if (ks8851_dir)
+		debugfs_remove_recursive(ks8851_dir);
+}
+#else
+int __init ks8851_debug_init(struct net_device *dev)
+{
+	return 0;
+};
+
+void ks8851_debug_exit(void)
+{
+};
+#endif /* CONFIG_DEBUG_FS */
+
+
 /* driver bus management functions */
 
 static int __devinit ks8851_probe(struct spi_device *spi)
@@ -1333,6 +1612,8 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 		goto err_netdev;
 	}
 
+	ks8851_debug_init(ndev);
+
 	dev_info(&spi->dev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
 		 CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
 		 ndev->dev_addr, ndev->irq,
@@ -1357,6 +1638,7 @@ static int __devexit ks8851_remove(struct spi_device *spi)
 	if (netif_msg_drv(priv))
 		dev_info(&spi->dev, "remove");
 
+	ks8851_debug_exit();
 	unregister_netdev(priv->netdev);
 	free_irq(spi->irq, priv);
 	free_netdev(priv->netdev);
diff --git a/drivers/net/ks8851.h b/drivers/net/ks8851.h
index f52c312..f18146d 100644
--- a/drivers/net/ks8851.h
+++ b/drivers/net/ks8851.h
@@ -25,12 +25,24 @@
 #define OBCR_ODS_16mA				(1 << 6)
 
 #define KS_EEPCR				0x22
+#define EEPCR_EESRWA				(1 << 5)
 #define EEPCR_EESA				(1 << 4)
-#define EEPCR_EESB				(1 << 3)
+#define EEPCR_EESB_OFFSET			3
+#define EEPCR_EESB				(1 << EEPCR_EESB_OFFSET)
 #define EEPCR_EEDO				(1 << 2)
 #define EEPCR_EESCK				(1 << 1)
 #define EEPCR_EECS				(1 << 0)
 
+#define EEPROM_OP_LEN				3	/* bits:*/
+#define EEPROM_OP_READ				0x06
+#define EEPROM_OP_EWEN				0x04
+#define EEPROM_OP_WRITE				0x05
+#define EEPROM_OP_EWDS				0x14
+
+#define EEPROM_DATA_LEN				16	/* 16 bits EEPROM */
+#define EEPROM_WRITE_TIME			3	/* wrt ack time in ms */
+#define EEPROM_SK_PERIOD			400	/* in us */
+
 #define KS_MBIR					0x24
 #define MBIR_TXMBF				(1 << 12)
 #define MBIR_TXMBFA				(1 << 11)
-- 
1.6.3.3

