From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 03/12] sky2: debug interface
Date: Mon, 09 Jul 2007 15:33:35 -0700
Message-ID: <20070709223453.182094731@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58077 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755921AbXGIWhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:37:22 -0400
Content-Disposition: inline; filename=sky2-debugfs.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an optional debug interface for displaying state of transmit/receive
rings. Creates a file debugfs/sky2/ethX for each device that is up.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/net/Kconfig |   10 ++
 drivers/net/sky2.c  |  176 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/sky2.h  |    4 +
 3 files changed, 188 insertions(+), 2 deletions(-)

--- a/drivers/net/Kconfig	2007-07-09 15:30:04.000000000 -0700
+++ b/drivers/net/Kconfig	2007-07-09 15:30:09.000000000 -0700
@@ -2133,6 +2133,16 @@ config SKY2
 	  To compile this driver as a module, choose M here: the module
 	  will be called sky2.  This is recommended.
 
+config SKY2_DEBUG
+       bool "Debugging interface"
+       depends on SKY2 && DEBUG_FS
+       help
+	 This option adds the ability to dump driver state for debugging.
+	 The file debugfs/sky2/ethX displays the state of the internal
+	 transmit and receive rings.
+
+	 If unsure, say N.
+
 config SK98LIN
 	tristate "Marvell Yukon Chipset / SysKonnect SK-98xx Support (DEPRECATED)"
 	depends on PCI
--- a/drivers/net/sky2.c	2007-07-09 15:30:09.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-09 15:30:09.000000000 -0700
@@ -39,6 +39,7 @@
 #include <linux/workqueue.h>
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
+#include <linux/debugfs.h>
 #include <linux/mii.h>
 
 #include <asm/irq.h>
@@ -1574,13 +1575,13 @@ static void sky2_tx_complete(struct sky2
 			if (unlikely(netif_msg_tx_done(sky2)))
 				printk(KERN_DEBUG "%s: tx done %u\n",
 				       dev->name, idx);
+
 			sky2->net_stats.tx_packets++;
 			sky2->net_stats.tx_bytes += re->skb->len;
 
 			dev_kfree_skb_any(re->skb);
+			sky2->tx_next = RING_NEXT(idx, TX_RING_SIZE);
 		}
-
-		le->opcode = 0;	/* paranoia */
 	}
 
 	sky2->tx_cons = idx;
@@ -3470,6 +3471,195 @@ static const struct ethtool_ops sky2_eth
 	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
+#ifdef CONFIG_SKY2_DEBUG
+
+static struct dentry *sky2_debug;
+
+static int sky2_debug_show(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	const struct sky2_port *sky2 = netdev_priv(dev);
+	const struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	unsigned idx, last;
+	int sop;
+
+	if (!netif_running(dev))
+		return -ENETDOWN;
+
+	seq_printf(seq, "IRQ src=%x mask=%x control=%x\n",
+		   sky2_read32(hw, B0_ISRC),
+		   sky2_read32(hw, B0_IMSK),
+		   sky2_read32(hw, B0_Y2_SP_ICR));
+
+	netif_poll_disable(hw->dev[0]);
+	last = sky2_read16(hw, STAT_PUT_IDX);
+
+	if (hw->st_idx == last)
+		seq_puts(seq, "Status ring (empty)\n");
+	else {
+		seq_puts(seq, "Status ring\n");
+		for (idx = hw->st_idx; idx != last && idx < STATUS_RING_SIZE;
+		     idx = RING_NEXT(idx, STATUS_RING_SIZE)) {
+			const struct sky2_status_le *le = hw->st_le + idx;
+			seq_printf(seq, "[%d] %#x %d %#x\n",
+				   idx, le->opcode, le->length, le->status);
+		}
+		seq_puts(seq, "\n");
+	}
+
+	seq_printf(seq, "Tx ring pending=%u...%u report=%d done=%d\n",
+		   sky2->tx_cons, sky2->tx_prod,
+		   sky2_read16(hw, port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX),
+		   sky2_read16(hw, Q_ADDR(txqaddr[port], Q_DONE)));
+
+	/* Dump contents of tx ring */
+	sop = 1;
+	for (idx = sky2->tx_next; idx != sky2->tx_prod && idx < TX_RING_SIZE;
+	     idx = RING_NEXT(idx, TX_RING_SIZE)) {
+		const struct sky2_tx_le *le = sky2->tx_le + idx;
+		u32 a = le32_to_cpu(le->addr);
+
+		if (sop)
+			seq_printf(seq, "%u:", idx);
+		sop = 0;
+
+		switch(le->opcode & ~HW_OWNER) {
+		case OP_ADDR64:
+			seq_printf(seq, " %#x:", a);
+			break;
+		case OP_LRGLEN:
+			seq_printf(seq, " mtu=%d", a);
+			break;
+		case OP_VLAN:
+			seq_printf(seq, " vlan=%d", be16_to_cpu(le->length));
+			break;
+		case OP_TCPLISW:
+			seq_printf(seq, " csum=%#x", a);
+			break;
+		case OP_LARGESEND:
+			seq_printf(seq, " tso=%#x(%d)", a, le16_to_cpu(le->length));
+			break;
+		case OP_PACKET:
+			seq_printf(seq, " %#x(%d)", a, le16_to_cpu(le->length));
+			break;
+		case OP_BUFFER:
+			seq_printf(seq, " frag=%#x(%d)", a, le16_to_cpu(le->length));
+			break;
+		default:
+			seq_printf(seq, " op=%#x,%#x(%d)", le->opcode,
+				   a, le16_to_cpu(le->length));
+		}
+
+		if (le->ctrl & EOP) {
+			seq_putc(seq, '\n');
+			sop = 1;
+		}
+	}
+
+	seq_printf(seq, "\nRx ring hw get=%d put=%d last=%d\n",
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_GET_IDX)),
+		   last = sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_LAST_IDX)));
+
+	netif_poll_enable(hw->dev[0]);
+	return 0;
+}
+
+static int sky2_debug_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, sky2_debug_show, inode->i_private);
+}
+
+static const struct file_operations sky2_debug_fops = {
+	.owner		= THIS_MODULE,
+	.open		= sky2_debug_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+/*
+ * Use network device events to create/remove/rename
+ * debugfs file entries
+ */
+static int sky2_device_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	if (dev->open == sky2_up) {
+		struct sky2_port *sky2 = netdev_priv(dev);
+
+		switch(event) {
+		case NETDEV_CHANGENAME:
+			if (!netif_running(dev))
+				break;
+			/* fallthrough */
+		case NETDEV_DOWN:
+		case NETDEV_GOING_DOWN:
+			if (sky2->debugfs) {
+				printk(KERN_DEBUG PFX "%s: remove debugfs\n",
+				       dev->name);
+				debugfs_remove(sky2->debugfs);
+				sky2->debugfs = NULL;
+			}
+
+			if (event != NETDEV_CHANGENAME)
+				break;
+			/* fallthrough for changename */
+		case NETDEV_UP:
+			if (sky2_debug) {
+				struct dentry *d;
+				d = debugfs_create_file(dev->name, S_IRUGO,
+							sky2_debug, dev,
+							&sky2_debug_fops);
+				if (d == NULL || IS_ERR(d))
+					printk(KERN_INFO PFX
+					       "%s: debugfs create failed\n",
+					       dev->name);
+				else
+					sky2->debugfs = d;
+			}
+			break;
+		}
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block sky2_notifier = {
+	.notifier_call = sky2_device_event,
+};
+
+
+static __init void sky2_debug_init(void)
+{
+	struct dentry *ent;
+
+	ent = debugfs_create_dir("sky2", NULL);
+	if (!ent || IS_ERR(ent))
+		return;
+
+	sky2_debug = ent;
+	register_netdevice_notifier(&sky2_notifier);
+}
+
+static __exit void sky2_debug_cleanup(void)
+{
+	if (sky2_debug) {
+		unregister_netdevice_notifier(&sky2_notifier);
+		debugfs_remove(sky2_debug);
+		sky2_debug = NULL;
+	}
+}
+
+#else
+#define sky2_debug_init()
+#define sky2_debug_cleanup()
+#endif
+
+
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 						     unsigned port,
@@ -3960,12 +4150,14 @@ static struct pci_driver sky2_driver = {
 
 static int __init sky2_init_module(void)
 {
+	sky2_debug_init();
 	return pci_register_driver(&sky2_driver);
 }
 
 static void __exit sky2_cleanup_module(void)
 {
 	pci_unregister_driver(&sky2_driver);
+	sky2_debug_cleanup();
 }
 
 module_init(sky2_init_module);
--- a/drivers/net/sky2.h	2007-07-09 15:30:04.000000000 -0700
+++ b/drivers/net/sky2.h	2007-07-09 15:30:09.000000000 -0700
@@ -1998,6 +1998,7 @@ struct sky2_port {
 	struct sky2_tx_le    *tx_le;
 	u16		     tx_cons;		/* next le to check */
 	u16		     tx_prod;		/* next le to use */
+	u16		     tx_next;		/* debug only */
 	u32		     tx_addr64;
 	u16		     tx_pending;
 	u16		     tx_last_mss;
@@ -2028,6 +2029,9 @@ struct sky2_port {
  	enum flow_control    flow_mode;
  	enum flow_control    flow_status;
 
+#ifdef CONFIG_SKY2_DEBUG
+	struct dentry	     *debugfs;
+#endif
 	struct net_device_stats net_stats;
 
 };

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

