From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 or acpi problem ?
Date: Thu, 1 Feb 2007 10:07:13 -0800
Message-ID: <20070201100713.503dddae@freekitty>
References: <1170352795.5299.17.camel@cocoduo>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_9YaZe3H8Ki=sMmxbocqPhx9"
Cc: netdev@vger.kernel.org
To: Lionel Landwerlin <landwer@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53091 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422740AbXBASKA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 13:10:00 -0500
In-Reply-To: <1170352795.5299.17.camel@cocoduo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--MP_9YaZe3H8Ki=sMmxbocqPhx9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thu, 01 Feb 2007 18:59:55 +0100
Lionel Landwerlin <landwer@free.fr> wrote:

> Hi,
> we already had words on lkml about this bug with sky2 driver.
> 
> I was having problems, and you told me to use the disable_msi=1
> parameter to see what happens. After a couple of hours of testing with
> heavly ethernet load, I answered you it had fixed the problem. I was
> wrong. Now, it takes much more time to crash. Most of time, I can't even
> see what happens beacause the box is completly frozen. But after several
> crashs, I only had my keyboard locked, usb unpowered, and ethernet
> interface down, I finally had the possibility see that :
> 
> Feb  1 18:35:06 cocoduo kernel: [59723.468000] NETDEV WATCHDOG: eth0: transmit time

Transmit recovery logic is screwed up, I have a better version
but working on testing it. See attachment 1

> 
> It's exactly the same error than before. What do you think of this
> trace ? Is it related to sky2 driver or acpi ? Did you add debug output
> since 2.6.19.2 (version of the kernel I'm using) that would help to fix
> that bug ? What can I do to help to fix the bug ?
> 

The problem is that some part of the transmit path (probably the
DMA engine) is getting hung.  There is a test patch to dump
tx ring (cat /proc/net/sky2/eth0). See attachment 2

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

--MP_9YaZe3H8Ki=sMmxbocqPhx9
Content-Type: text/x-patch; name=sky2-tx-recover.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=sky2-tx-recover.patch

---
 drivers/net/sky2.c |   54 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 34 insertions(+), 20 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2007-01-31 14:52:16.000000000 -0800
+++ sky2/drivers/net/sky2.c	2007-01-31 14:52:21.000000000 -0800
@@ -1840,15 +1840,18 @@
 }
 
 
-/* Transmit timeout is only called if we are running, carries is up
+/* Transmit timeout is only called if we are running, carrier is up
  * and tx queue is full (stopped).
+ * netif_tx_lock is already held.
  */
 static void sky2_tx_timeout(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
-	unsigned txq = txqaddr[sky2->port];
-	u16 report, done;
+	unsigned port = sky2->port;
+	unsigned txq = txqaddr[port];
+	u32 imask;
+	u16 report, done, ctrl;
 
 	if (netif_msg_timer(sky2))
 		printk(KERN_ERR PFX "%s: tx timeout\n", dev->name);
@@ -1860,28 +1863,39 @@
 	       dev->name,
 	       sky2->tx_cons, sky2->tx_prod, report, done);
 
-	if (report != done) {
-		printk(KERN_INFO PFX "status burst pending (irq moderation?)\n");
+	imask = sky2_read32(hw, B0_IMSK);
+	sky2_write32(hw, B0_IMSK, 0);
 
-		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
-		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
-	} else if (report != sky2->tx_cons) {
-		printk(KERN_INFO PFX "status report lost?\n");
+	/* don't reschedule when clean creates space */
+	netif_start_queue(dev);
 
-		netif_tx_lock_bh(dev);
-		sky2_tx_complete(sky2, report);
-		netif_tx_unlock_bh(dev);
-	} else {
-		printk(KERN_INFO PFX "hardware hung? flushing\n");
+	/* stop tx port */
+	sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_STOP);
+	ctrl = gma_read16(hw, port, GM_GP_CTRL);
+	gma_write16(hw, port, GM_GP_CTRL, ctrl & ~GM_GPCR_TX_ENA);
 
-		sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_STOP);
-		sky2_write32(hw, Y2_QADDR(txq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
+	sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_RST_SET | BMU_FIFO_RST);
+	sky2_write32(hw, Y2_QADDR(txq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
+	sky2_write32(hw, RB_ADDR(txq, RB_CTRL), RB_RST_SET);
 
-		sky2_tx_clean(dev);
+	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
+	sky2_read8(hw, SK_REG(port, TX_GMF_CTRL_T));
 
-		sky2_qset(hw, txq);
-		sky2_prefetch_init(hw, txq, sky2->tx_le_map, TX_RING_SIZE - 1);
-	}
+	sky2_tx_complete(sky2, sky2->tx_prod);
+
+	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_CLR);
+	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
+
+	sky2_write8(hw, RB_ADDR(txq, RB_CTRL), RB_RST_CLR);
+	sky2_write32(hw, Y2_QADDR(txq, PREF_UNIT_CTRL), PREF_UNIT_RST_CLR);
+	sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_CLR_RESET);
+	sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_OPER_INIT);
+	sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_FIFO_OP_ON);
+
+	gma_write16(hw, port, GM_GP_CTRL, ctrl);
+	netif_poll_enable(hw->dev[0]);
+	sky2_write32(hw, B0_IMSK, imask);
+	sky2_read32(hw, B0_IMSK);
 }
 
 static int sky2_change_mtu(struct net_device *dev, int new_mtu)

--MP_9YaZe3H8Ki=sMmxbocqPhx9
Content-Type: text/x-patch; name=sky2-proc-debug.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=sky2-proc-debug.patch

This patch (which shouldn't go into the mainline driver), adds a debug
interface to sky2 driver to dump the receive and transmit rings.
The file /proc/net/sky2/ethX will show the status of transmits in process,
status responses not handled, and receives pending.

---
 drivers/net/sky2.c |  157 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/sky2.h |    8 ++
 2 files changed, 162 insertions(+), 3 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2007-01-31 15:21:09.000000000 -0800
+++ sky2/drivers/net/sky2.c	2007-02-01 09:44:16.000000000 -0800
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
@@ -1510,6 +1513,9 @@
 			if (unlikely(netif_msg_tx_done(sky2)))
 				printk(KERN_DEBUG "%s: tx done %u\n",
 				       dev->name, idx);
+			sky2->tx_last = sky2->tx_cur;
+			sky2->tx_cur = RING_NEXT(idx, TX_RING_SIZE);
+
 			sky2->net_stats.tx_packets++;
 			sky2->net_stats.tx_bytes += re->skb->len;
 
@@ -3303,6 +3309,138 @@
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
+	unsigned idx, last;
+
+	if (!netif_running(dev))
+		return -ENETDOWN;
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
+		seq_puts(seq, "\n");
+	}
+
+	seq_printf(seq, "Tx ring pending=%u...%u report=%d done=%d\n",
+		   sky2->tx_cons, sky2->tx_prod,
+		   sky2_read16(hw, port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX),
+		   sky2_read16(hw, Q_ADDR(txqaddr[port], Q_DONE)));
+
+	/* Backup until start of last Tx frame */
+	idx = sky2->tx_last;
+	seq_printf(seq, "%u:", idx);
+	while (idx != sky2->tx_prod) {
+		const struct sky2_tx_le *le = sky2->tx_le + idx;
+		u32 a = le32_to_cpu(le->addr);
+
+		switch(le->opcode & ~HW_OWNER) {
+		case OP_ADDR64:
+			seq_printf(seq, " %#x:", a);
+			break;
+		case OP_LRGLEN:
+			seq_printf(seq, " mtu=%d\n", a);
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
+		idx = RING_NEXT(idx, TX_RING_SIZE);
+		if (le->ctrl & EOP) {
+			seq_putc(seq, '\n');
+			if (idx != sky2->tx_prod)
+				seq_printf(seq, "%u:", idx);
+		}
+	}
+
+	seq_printf(seq, "\nRx ring hw get=%d put=%d last=%d\n",
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_GET_IDX)),
+		   last = sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_LAST_IDX)));
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
+		printk(KERN_DEBUG PFX "%s renamed to %s\n",
+		       sky2->orig_name, dev->name);
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
 						     unsigned port,
@@ -3396,6 +3534,8 @@
 		       dev->name,
 		       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
 		       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+
+	sky2_add_proc(dev);
 }
 
 /* Handle software interrupt used during MSI test */
@@ -3594,6 +3734,7 @@
 			free_netdev(dev1);
 		} else
 			sky2_show_addr(dev1);
+
 	}
 
 	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
@@ -3638,8 +3779,11 @@
 
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
@@ -3780,12 +3924,21 @@
 
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
--- sky2.orig/drivers/net/sky2.h	2007-01-31 15:21:09.000000000 -0800
+++ sky2/drivers/net/sky2.h	2007-01-31 15:21:12.000000000 -0800
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
@@ -1834,6 +1836,9 @@
 
 	struct tx_ring_info  *tx_ring;
 	struct sky2_tx_le    *tx_le;
+	u16		     tx_last;		/* debug last complete */
+	u16		     tx_cur;		/* debug current frame */
+
 	u16		     tx_cons;		/* next le to check */
 	u16		     tx_prod;		/* next le to use */
 	u32		     tx_addr64;
@@ -1845,6 +1850,7 @@
 	struct sky2_rx_le    *rx_le;
 	u32		     rx_addr64;
 	u16		     rx_next;		/* next re to check */
+	u16		     rx_free;		/* next re to reuse */
 	u16		     rx_put;		/* next le index to use */
 	u16		     rx_pending;
 	u16		     rx_data_size;
@@ -1867,7 +1873,7 @@
  	enum flow_control    flow_status;
 
 	struct net_device_stats net_stats;
-
+	char		     orig_name[IFNAMSIZ];
 };
 
 struct sky2_hw {

--MP_9YaZe3H8Ki=sMmxbocqPhx9--
