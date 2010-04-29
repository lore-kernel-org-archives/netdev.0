From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 09/13] KSZ8851-SNL: Add debugfs export for driver state
Date: Fri, 30 Apr 2010 00:16:30 +0100
Message-ID: <20100429231740.476832615@fluff.org.uk>
References: <20100429231621.015936077@fluff.org.uk>
Cc: tristram.ha@micrel.com, support@tincantools.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:27351 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932415Ab0D3Vs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:48:29 -0400
Content-Disposition: inline; filename=ks8851-add-debugfs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ability to export the state of each network chip via debugfs
to show the cached register state and some of the network device state
information.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---
 drivers/net/ks8851.c |   94 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 94 insertions(+)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2010-04-29 01:22:47.779528264 +0900
+++ b/drivers/net/ks8851.c	2010-04-29 01:25:54.217027162 +0900
@@ -21,6 +21,9 @@
 #include <linux/mii.h>
 #include <linux/eeprom_93cx6.h>
 
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
+
 #include <linux/spi/spi.h>
 
 #include "ks8851.h"
@@ -128,6 +131,9 @@ struct ks8851_net {
 	struct spi_transfer	spi_xfer1;
 	struct spi_transfer	spi_xfer2[2];
 
+	struct dentry		*debug_root;
+	struct dentry		*debug_file;
+
 	struct eeprom_93cx6	eeprom;
 };
 
@@ -1411,6 +1417,91 @@ static int ks8851_read_selftest(struct k
 	return 0;
 }
 
+/* debugfs code */
+static int state_show(struct seq_file *seq, void *v)
+{
+	struct ks8851_net *ks = seq->private;
+	struct net_device *ndev = ks->netdev;
+
+	seq_printf(seq, "Register cache:\n");
+	seq_printf(seq, "IEQ\t 0x%04x\n", ks->rc_ier);
+	seq_printf(seq, "RXQCR\t 0x%04x\n", ks->rc_rxqcr);
+	seq_printf(seq, "CCR\t 0x%04x\n", ks->rc_ccr);
+	seq_printf(seq, "RXCR1\t 0x%04x\n", ks->rxctrl.rxcr1);
+	seq_printf(seq, "RXCR2\t 0x%04x\n", ks->rxctrl.rxcr2);
+	seq_printf(seq, "MCHASH\t 0=0x%04x, 1=%04x, 2=0x%04x, 3=0x%04x\n",
+		   ks->rxctrl.mchash[0], ks->rxctrl.mchash[1],
+		   ks->rxctrl.mchash[2], ks->rxctrl.mchash[3]);
+
+	seq_printf(seq, "\n");
+
+	seq_printf(seq, "tx_space = 0x%04x\n", ks->tx_space);
+	seq_printf(seq, "tx fid\t= 0x%02x\n", ks->fid);
+
+	seq_printf(seq, "\n");
+
+	if (ndev->flags & IFF_MULTICAST) {
+		struct dev_mc_list *mcptr = ndev->mc_list;
+		int i;
+
+		seq_printf(seq, "MC list is %d entries\n", ndev->mc_count);
+
+		for (i = 0; i < ndev->mc_count; i++) {
+			seq_printf(seq, "\t%d: %pM\n", i, mcptr->dmi_addr);
+			mcptr = mcptr->next;
+		}
+	} else
+		seq_printf(seq, "No multicast list set\n");
+
+	return 0;
+}
+
+static int state_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, state_show, inode->i_private);
+}
+
+static const struct file_operations state_fops = {
+	.owner	= THIS_MODULE,
+	.open	= state_open,
+	.read	= seq_read,
+	.llseek	= seq_lseek,
+	.release = single_release,
+};
+
+/**
+ * ks8851_create_debugfs - create debugfs directory and files
+ * @ks: The driver state
+ *
+ * Create the debugfs entries for the specific device.
+ */
+static void __devinit ks8851_create_debugfs(struct ks8851_net *ks)
+{
+	struct dentry *root;
+	char root_name[32];
+
+	snprintf(root_name, sizeof(root_name), "ks8851_%s",
+		 dev_name(&ks->spidev->dev));
+
+	root = debugfs_create_dir(root_name, NULL);
+	if (IS_ERR(root)) {
+		ks_err(ks, "cannot create debugfs root\n");
+		return;
+	}
+
+	ks->debug_root = root;
+	ks->debug_file = debugfs_create_file("state", 0444, root,
+					     ks, &state_fops);
+	if (IS_ERR(ks->debug_file))
+		ks_err(ks, "cannot create debugfs state file\n");
+}
+
+static void __devexit ks8851_delete_debugfs(struct ks8851_net *ks)
+{
+	debugfs_remove(ks->debug_file);
+	debugfs_remove(ks->debug_root);
+}
+
 /* driver bus management functions */
 
 static int __devinit ks8851_probe(struct spi_device *spi)
@@ -1518,6 +1609,8 @@ static int __devinit ks8851_probe(struct
 		 ndev->dev_addr, ndev->irq,
 		 ks->rc_ccr & CCR_EEPROM ? "has" : "no");
 
+	ks8851_create_debugfs(ks);
+
 	return 0;
 
 
@@ -1537,6 +1630,7 @@ static int __devexit ks8851_remove(struc
 	if (netif_msg_drv(priv))
 		dev_info(&spi->dev, "remove");
 
+	ks8851_delete_debugfs(priv);
 	unregister_netdev(priv->netdev);
 	free_irq(spi->irq, priv);
 	free_netdev(priv->netdev);

