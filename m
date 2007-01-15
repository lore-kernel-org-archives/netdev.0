From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2: transmit timed out...
Date: Mon, 15 Jan 2007 10:19:18 -0800
Message-ID: <20070115101918.61f8d5b9@freekitty>
References: <6278d2220701150903i23be8327if102006b3cee0f2f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:33912 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbXAOSTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 13:19:53 -0500
To: "Daniel J Blueman" <daniel.blueman@gmail.com>
In-Reply-To: <6278d2220701150903i23be8327if102006b3cee0f2f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please reproduce problem with this patch, then do:
	cat /proc/sys/net/sky2/lan0

This patch (which shouldn't go into the mainline driver), adds a debug
interface to sky2 driver to dump the receive and transmit rings.
The file /proc/net/sky2/ethX will show the status of transmits in process,
status responses not handled, and receives pending.

---
 drivers/net/sky2.c |  158 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/sky2.h |    4 +
 2 files changed, 157 insertions(+), 5 deletions(-)

--- sky2-2.6.orig/drivers/net/sky2.c	2007-01-11 10:05:09.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2007-01-11 10:23:01.000000000 -0800
@@ -38,6 +38,7 @@
 #include <linux/workqueue.h>
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
+#include <linux/proc_fs.h>
 #include <linux/mii.h>
 
 #include <asm/irq.h>
@@ -866,10 +867,11 @@
 
 /* Build description to hardware for one possibly fragmented skb */
 static void sky2_rx_submit(struct sky2_port *sky2,
-			   const struct rx_ring_info *re)
+			   struct rx_ring_info *re)
 {
 	int i;
 
+	re->idx = sky2->rx_put;
 	sky2_rx_add(sky2, OP_PACKET, re->data_addr, sky2->rx_data_size);
 
 	for (i = 0; i < skb_shinfo(re->skb)->nr_frags; i++)
@@ -1462,6 +1464,7 @@
 	}
 
 	le->ctrl |= EOP;
+	re->idx = le - sky2->tx_le;	/* debug */
 
 	if (tx_avail(sky2) <= MAX_SKB_TX_LE)
 		netif_stop_queue(dev);
@@ -3296,6 +3299,139 @@
 	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
+
+static struct proc_dir_entry *sky2_proc;
+
+static int sky2_seq_show(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	const struct sky2_port *sky2 = netdev_priv(dev);
+	const struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	unsigned idx, ridx, rend, last;
+
+	last = sky2_read16(hw, STAT_PUT_IDX);
+
+	if (hw->st_idx == last)
+		seq_puts(seq, "Status ring (empty)\n");
+	else {
+		seq_puts(seq, "Status ring\n");
+		for (idx = hw->st_idx; idx != last;
+		     idx = RING_NEXT(idx, STATUS_RING_SIZE)) {
+			const struct sky2_status_le *le = hw->st_le + idx;
+			seq_printf(seq, "[%d] %#x %d %#x\n",
+				   idx, le->opcode, le->length, le->status);
+		}
+	}
+
+	if (sky2->tx_cons == sky2->tx_prod)
+		seq_puts(seq, "\nTx ring (empty)\n");
+	else {
+		seq_puts(seq, "\nTx ring\n");
+		idx = sky2->tx_cons;
+		while (idx != sky2->tx_prod) {
+			const struct tx_ring_info *re = sky2->tx_ring + idx;
+
+			seq_printf(seq, "[%d] %p\n", idx, re->skb);
+			do {
+				const struct sky2_tx_le *le = sky2->tx_le + idx;
+				seq_printf(seq, "\t%#x %d", le->opcode, le->addr);
+				idx = RING_NEXT(idx, TX_RING_SIZE);
+			} while (idx != re->idx || idx != sky2->tx_prod);
+			seq_putc(seq, '\n');
+		}
+	}
+
+	seq_printf(seq, "\nRx pending hw get=%d put=%d last=%d\n",
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_GET_IDX)),
+		   last = sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_LAST_IDX)));
+
+	ridx = sky2->rx_next;
+	do {
+		const struct rx_ring_info *re = sky2->rx_ring + ridx;
+		seq_printf(seq, "[%d] %p |", ridx, re->skb);
+
+		idx = re->idx;
+		ridx = (ridx + 1) % sky2->rx_pending;
+
+		if (ridx == sky2->rx_next)
+			rend = last;
+		else
+			rend = sky2->rx_ring[ridx].idx;
+
+		do {
+			const struct sky2_rx_le *le = sky2->rx_le + idx;
+
+			switch (le->opcode & ~HW_OWNER) {
+			case OP_PACKET:
+			case OP_BUFFER:
+				seq_printf(seq, " %#x(%d)", le->addr, le->length);
+				break;
+			case OP_ADDR64:
+				seq_printf(seq, " %#x:", le->addr);
+				break;
+			default:
+				seq_printf(seq, " {%x} %#x(%d)",
+					   le->opcode, le->addr, le->length);
+			}
+
+		} while ((idx = RING_NEXT(idx, RX_LE_SIZE)) != rend);
+
+		seq_puts(seq, "\n");
+	} while (ridx != sky2->rx_next);
+
+	return 0;
+}
+
+static int sky2_proc_open(struct inode *inode, struct file  *file)
+{
+	return single_open(file, sky2_seq_show, PDE(inode)->data);
+}
+
+static const struct file_operations sky2_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= sky2_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static void sky2_add_proc(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+	struct proc_dir_entry *res;
+
+	if (!sky2_proc)
+		return;
+
+	strncpy(sky2->orig_name, dev->name, IFNAMSIZ);
+	res = create_proc_entry(dev->name, S_IRUGO, sky2_proc);
+	if (res) {
+		res->proc_fops = &sky2_proc_fops;
+		res->data = dev;
+	}
+}
+
+static int sky2_device_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	if (sky2_proc && dev->open == sky2_up && event == NETDEV_CHANGENAME) {
+		struct sky2_port *sky2 = netdev_priv(dev);
+
+		remove_proc_entry(sky2->orig_name, sky2_proc);
+		sky2_add_proc(dev);
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block sky2_notifier = {
+	.notifier_call = sky2_device_event,
+};
+
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 						     unsigned port, int highmem)
@@ -3563,11 +3699,13 @@
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 
 	sky2_show_addr(dev);
+	sky2_add_proc(dev);
 
 	if (hw->ports > 1 && (dev1 = sky2_init_netdev(hw, 1, using_dac))) {
-		if (register_netdev(dev1) == 0)
+		if (register_netdev(dev1) == 0) {
 			sky2_show_addr(dev1);
-		else {
+			sky2_add_proc(dev);
+		} else {
 			/* Failure to register second port need not be fatal */
 			printk(KERN_WARNING PFX
 			       "register of second port failed\n");
@@ -3618,8 +3756,11 @@
 
 	dev0 = hw->dev[0];
 	dev1 = hw->dev[1];
-	if (dev1)
+	if (dev1) {
+		remove_proc_entry(dev1->name, sky2_proc);
 		unregister_netdev(dev1);
+	}
+	remove_proc_entry(dev0->name, sky2_proc);
 	unregister_netdev(dev0);
 
 	sky2_power_aux(hw);
@@ -3788,12 +3929,21 @@
 
 static int __init sky2_init_module(void)
 {
+	sky2_proc = proc_mkdir("sky2", proc_net);
+	if (sky2_proc)
+		register_netdevice_notifier(&sky2_notifier);
+
 	return pci_register_driver(&sky2_driver);
 }
 
 static void __exit sky2_cleanup_module(void)
 {
 	pci_unregister_driver(&sky2_driver);
+	if (sky2_proc) {
+		proc_net_remove("sky2");
+		unregister_netdevice_notifier(&sky2_notifier);
+	}
+
 }
 
 module_init(sky2_init_module);
--- sky2-2.6.orig/drivers/net/sky2.h	2007-01-11 10:05:30.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.h	2007-01-11 10:22:00.000000000 -0800
@@ -1807,12 +1807,14 @@
 
 struct tx_ring_info {
 	struct sk_buff	*skb;
+	unsigned	idx;	/* debug */
 	DECLARE_PCI_UNMAP_ADDR(mapaddr);
 	DECLARE_PCI_UNMAP_ADDR(maplen);
 };
 
 struct rx_ring_info {
 	struct sk_buff	*skb;
+	unsigned	idx;	/* debug */
 	dma_addr_t	data_addr;
 	DECLARE_PCI_UNMAP_ADDR(data_size);
 	dma_addr_t	frag_addr[ETH_JUMBO_MTU >> PAGE_SHIFT];
@@ -1867,7 +1869,7 @@
  	enum flow_control    flow_status;
 
 	struct net_device_stats net_stats;
-
+	char		     orig_name[IFNAMSIZ];
 };
 
 struct sky2_hw {
