From: Sebastien Jan <s-jan@ti.com>
Subject: [PATCH 4/4 v2] ks8851: read/write MAC address on companion eeprom through debugfs
Date: Wed,  5 May 2010 20:45:55 +0200
Message-ID: <1273085155-1260-5-git-send-email-s-jan@ti.com>
References: <1273085155-1260-1-git-send-email-s-jan@ti.com>
Cc: linux-omap@vger.kernel.org, Abraham Arce <x0066660@ti.com>,
	Ben Dooks <ben-linux@fluff.org>, Tristram.Ha@micrel.com,
	Sebastien Jan <s-jan@ti.com>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1273085155-1260-1-git-send-email-s-jan@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A more elegant alternative to ethtool for updating the ks8851
MAC address stored on its companion eeprom.
Using this debugfs interface does not require any knowledge on the
ks8851 companion eeprom organization to update the MAC address.

Example to write 01:23:45:67:89:AB MAC address to the companion
eeprom (assuming debugfs is mounted in /sys/kernel/debug):
$ echo "01:23:45:67:89:AB" > /sys/kernel/debug/ks8851/mac_eeprom

Signed-off-by: Sebastien Jan <s-jan@ti.com>
---
 drivers/net/ks8851.c |  216 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 216 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 8e38c36..1b62ec5 100644
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
@@ -1550,6 +1555,214 @@ static int ks8851_read_selftest(struct ks8851_net *ks)
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
+/**
+ * ks8851_mac_eeprom_read - Read a MAC address in ks8851 companion EEPROM
+ *
+ * Warning: The READ feature is not supported on ks8851 revision 0.
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
+	.read		= ks8851_mac_eeprom_read,
+	.write		= ks8851_mac_eeprom_write,
+	.llseek		= ks8851_mac_eeprom_seek,
+	.release	= ks8851_mac_eeprom_release,
+};
+
+int __init ks8851_debug_init(struct net_device *dev)
+{
+	struct ks8851_net *ks = netdev_priv(dev);
+	mode_t mac_access = S_IWUGO;
+
+	if (ks->rc_ccr & CCR_EEPROM) {
+		ks8851_dir = debugfs_create_dir("ks8851", NULL);
+		if (IS_ERR(ks8851_dir))
+			return PTR_ERR(ks8851_dir);
+
+		/* Check ks8851 version and features */
+		mutex_lock(&ks->lock);
+		if (CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)) > 0)
+			mac_access |= S_IRUGO;
+		mutex_unlock(&ks->lock);
+
+		debugfs_create_file("mac_eeprom", mac_access, ks8851_dir, dev,
+						&ks8851_mac_eeprom_fops);
+		debugfs_create_u32("eeprom_size", S_IRUGO | S_IWUGO,
+					ks8851_dir, (u32 *) &(ks->eeprom_size));
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
@@ -1649,6 +1862,8 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 		goto err_netdev;
 	}
 
+	ks8851_debug_init(ndev);
+
 	dev_info(&spi->dev, "revision %d, MAC %pM, IRQ %d\n",
 		 CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
 		 ndev->dev_addr, ndev->irq);
@@ -1672,6 +1887,7 @@ static int __devexit ks8851_remove(struct spi_device *spi)
 	if (netif_msg_drv(priv))
 		dev_info(&spi->dev, "remove");
 
+	ks8851_debug_exit();
 	unregister_netdev(priv->netdev);
 	free_irq(spi->irq, priv);
 	free_netdev(priv->netdev);
-- 
1.6.3.3

