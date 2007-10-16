From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/7] skge: add a debug interface
Date: Tue, 16 Oct 2007 12:15:54 -0700
Message-ID: <20071016191734.177427432@linux-foundation.org>
References: <20071016191548.447710749@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59218 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934531AbXJPTTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 15:19:37 -0400
Content-Disposition: inline; filename=skge-debug.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a debugfs interface to look at internal ring state.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/net/Kconfig |   10 +++
 drivers/net/skge.c  |  143 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/skge.h  |    3 +
 3 files changed, 156 insertions(+)

--- a/drivers/net/Kconfig	2007-10-16 10:55:13.000000000 -0700
+++ b/drivers/net/Kconfig	2007-10-16 10:57:42.000000000 -0700
@@ -2173,6 +2173,16 @@ config SKGE
 	  To compile this driver as a module, choose M here: the module
 	  will be called skge.  This is recommended.
 
+config SKGE_DEBUG
+       bool "Debugging interface"
+       depends on SKGE && DEBUG_FS
+       help
+	 This option adds the ability to dump driver state for debugging.
+	 The file debugfs/skge/ethX displays the state of the internal
+	 transmit and receive rings.
+
+	 If unsure, say N.
+
 config SKY2
 	tristate "SysKonnect Yukon2 support"
 	depends on PCI
--- a/drivers/net/skge.c	2007-10-16 10:57:37.000000000 -0700
+++ b/drivers/net/skge.c	2007-10-16 10:57:42.000000000 -0700
@@ -36,6 +36,8 @@
 #include <linux/delay.h>
 #include <linux/crc32.h>
 #include <linux/dma-mapping.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <linux/mii.h>
 #include <asm/irq.h>
 
@@ -3676,6 +3678,145 @@ static int skge_reset(struct skge_hw *hw
 	return 0;
 }
 
+
+#ifdef CONFIG_SKGE_DEBUG
+
+static struct dentry *skge_debug;
+
+static int skge_debug_show(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	const struct skge_port *skge = netdev_priv(dev);
+	const struct skge_hw *hw = skge->hw;
+	const struct skge_element *e;
+
+	if (!netif_running(dev))
+		return -ENETDOWN;
+
+	seq_printf(seq, "IRQ src=%x mask=%x\n", skge_read32(hw, B0_ISRC),
+		   skge_read32(hw, B0_IMSK));
+
+	seq_printf(seq, "Tx Ring: (%d)\n", skge_avail(&skge->tx_ring));
+	for (e = skge->tx_ring.to_clean; e != skge->tx_ring.to_use; e = e->next) {
+		const struct skge_tx_desc *t = e->desc;
+		seq_printf(seq, "%#x dma=%#x%08x %#x csum=%#x/%x/%x\n",
+			   t->control, t->dma_hi, t->dma_lo, t->status,
+			   t->csum_offs, t->csum_write, t->csum_start);
+	}
+
+	seq_printf(seq, "\nRx Ring: \n");
+	for (e = skge->rx_ring.to_clean; ; e = e->next) {
+		const struct skge_rx_desc *r = e->desc;
+
+		if (r->control & BMU_OWN)
+			break;
+
+		seq_printf(seq, "%#x dma=%#x%08x %#x %#x csum=%#x/%x\n",
+			   r->control, r->dma_hi, r->dma_lo, r->status,
+			   r->timestamp, r->csum1, r->csum1_start);
+	}
+
+	return 0;
+}
+
+static int skge_debug_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, skge_debug_show, inode->i_private);
+}
+
+static const struct file_operations skge_debug_fops = {
+	.owner		= THIS_MODULE,
+	.open		= skge_debug_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+/*
+ * Use network device events to create/remove/rename
+ * debugfs file entries
+ */
+static int skge_device_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct skge_port *skge;
+	struct dentry *d;
+
+	if (dev->open != &skge_up || !skge_debug)
+		goto done;
+
+	skge = netdev_priv(dev);
+	switch(event) {
+	case NETDEV_CHANGENAME:
+		if (skge->debugfs) {
+			d = debugfs_rename(skge_debug, skge->debugfs,
+					   skge_debug, dev->name);
+			if (d)
+				skge->debugfs = d;
+			else {
+				pr_info(PFX "%s: rename failed\n", dev->name);
+				debugfs_remove(skge->debugfs);
+			}
+		}
+		break;
+
+	case NETDEV_GOING_DOWN:
+		if (skge->debugfs) {
+			debugfs_remove(skge->debugfs);
+			skge->debugfs = NULL;
+		}
+		break;
+
+	case NETDEV_UP:
+		d = debugfs_create_file(dev->name, S_IRUGO,
+					skge_debug, dev,
+					&skge_debug_fops);
+		if (!d || IS_ERR(d))
+			pr_info(PFX "%s: debugfs create failed\n",
+			       dev->name);
+		else
+			skge->debugfs = d;
+		break;
+	}
+
+done:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block skge_notifier = {
+	.notifier_call = skge_device_event,
+};
+
+
+static __init void skge_debug_init(void)
+{
+	struct dentry *ent;
+
+	ent = debugfs_create_dir("skge", NULL);
+	if (!ent || IS_ERR(ent)) {
+		pr_info(PFX "debugfs create directory failed\n");
+		return;
+	}
+
+	skge_debug = ent;
+	register_netdevice_notifier(&skge_notifier);
+}
+
+static __exit void skge_debug_cleanup(void)
+{
+	if (skge_debug) {
+		unregister_netdevice_notifier(&skge_notifier);
+		debugfs_remove(skge_debug);
+		skge_debug = NULL;
+	}
+}
+
+#else
+#define skge_debug_init()
+#define skge_debug_cleanup()
+#endif
+
 /* Initialize network device */
 static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 				       int highmem)
@@ -4040,12 +4181,14 @@ static struct pci_driver skge_driver = {
 
 static int __init skge_init_module(void)
 {
+	skge_debug_init();
 	return pci_register_driver(&skge_driver);
 }
 
 static void __exit skge_cleanup_module(void)
 {
 	pci_unregister_driver(&skge_driver);
+	skge_debug_cleanup();
 }
 
 module_init(skge_init_module);
--- a/drivers/net/skge.h	2007-10-16 10:57:37.000000000 -0700
+++ b/drivers/net/skge.h	2007-10-16 10:57:42.000000000 -0700
@@ -2469,6 +2469,9 @@ struct skge_port {
 	void		     *mem;	/* PCI memory for rings */
 	dma_addr_t	     dma;
 	unsigned long	     mem_size;
+#ifdef CONFIG_SKGE_DEBUG
+	struct dentry	     *debugfs;
+#endif
 };
 
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

