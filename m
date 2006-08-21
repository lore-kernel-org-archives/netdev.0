From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 driver - large files upload problem
Date: Mon, 21 Aug 2006 09:51:16 -0700
Message-ID: <20060821095116.1b7f725d@localhost.localdomain>
References: <44E9A9E0.20106@cheetah.uio.no>
	<44E9B28C.9050207@gentoo.org>
	<44E9C153.1010300@cheetah.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11398 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422702AbWHUQv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 12:51:27 -0400
To: Jon Wikne <wikne@cheetah.uio.no>
In-Reply-To: <44E9C153.1010300@cheetah.uio.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 16:21:07 +0200
Jon Wikne <wikne@cheetah.uio.no> wrote:

> Daniel Drake wrote:
> > 
> > Jon Wikne wrote:
> > 
> >> What happens is typically this: After transeferring some
> >> data, ranging from less than 100kB to 10MB, the upload freezes,
> >> i.e. gets no further. Use of ping shows the connection is
> >> effectively dead. If I do a sequence /sbin/ifdown eth0
> >> /sbin/ifup eth0 the upload might resume, but stops again
> >> shortly. The phenomenon seems to occur sooner if the path
> >> to the remote system is _fast_ (low ping times).
> > 
> > You can try applying this patch:
> > http://developer.osdl.org/shemminger/prototypes/sky2-proc-debug.patch
> > 
> > It will add a /proc/net/sky2/ethX file, which lists the status of the TX 
> > and status rings. You should compare the contents of this file during 
> > normal operation to when the interface has hung.
> 
> Thanks, Daniel. I applied the patch.
> 
> The output of 'cat /proc/net/sky2/eth0' under normal circumstances
> is here:
> 
> http://puma.uio.no/sky2/sky2-status-normal.txt
> 
> After the interface hangs, 'cat /proc/net/sky2/eth0' causes the
> whole computer to hang completely. No kernel oops or other
> messages in the console window. Power down is the only
> solution.... :-[ No log entries after reboot.
> 

It could be the code in the debug patch is walking off into space.
The smaller version of the same patch, doesn't walk but just reports
the index values.

--- sky2.orig/drivers/net/sky2.c	2006-08-16 15:17:53.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-16 15:19:42.000000000 -0700
@@ -38,6 +38,7 @@
 #include <linux/delay.h>
 #include <linux/workqueue.h>
 #include <linux/if_vlan.h>
+#include <linux/proc_fs.h>
 #include <linux/prefetch.h>
 #include <linux/mii.h>
 
@@ -1005,6 +1006,7 @@
 
 		re->mapaddr = pci_map_single(hw->pdev, re->skb->data,
 					     sky2->rx_bufsize, PCI_DMA_FROMDEVICE);
+		re->ridx = sky2->rx_put;
 		sky2_rx_add(sky2, re->mapaddr);
 	}
 
@@ -1890,6 +1892,7 @@
 	skb_put(skb, length);
 resubmit:
 	re->skb->ip_summed = CHECKSUM_NONE;
+	re->ridx = sky2->rx_put;
 	sky2_rx_add(sky2, re->mapaddr);
 
 	return skb;
@@ -3088,6 +3091,49 @@
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
+	unsigned last;
+
+	last = sky2_read16(hw, STAT_PUT_IDX);
+
+	if (hw->st_idx == last)
+		seq_puts(seq, "Status ring (empty)\n");
+	else
+		seq_printf(seq, "Status ring %d...%d\n", last, hw->st_idx);
+
+	if (sky2->tx_cons == sky2->tx_prod)
+		seq_puts(seq, "Tx ring (empty)\n");
+	else
+		seq_printf(seq, "Tx ring %d..%d\n", sky2->tx_cons, sky2->tx_prod);
+
+	seq_printf(seq, "Rx pending hw get=%d put=%d last=%d\n",
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[sky2->port], PREF_UNIT_GET_IDX)),
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[sky2->port], PREF_UNIT_PUT_IDX)),
+		   sky2_read16(hw, Y2_QADDR(rxqaddr[sky2->port], PREF_UNIT_LAST_IDX)));
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
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 						     unsigned port, int highmem)
@@ -3178,6 +3224,15 @@
 		       dev->name,
 		       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
 		       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+
+	if (sky2_proc) {
+		struct proc_dir_entry *res;
+		res = create_proc_entry(dev->name, S_IRUGO, sky2_proc);
+		if (res) {
+			res->proc_fops = &sky2_proc_fops;
+			res->data = dev;
+		}
+	}
 }
 
 /* Handle software interrupt used during MSI test */
@@ -3417,8 +3472,11 @@
 
 	dev0 = hw->dev[0];
 	dev1 = hw->dev[1];
-	if (dev1)
+	if (dev1) {
+		remove_proc_entry(dev1->name, sky2_proc);
 		unregister_netdev(dev1);
+	}
+	remove_proc_entry(dev0->name, sky2_proc);
 	unregister_netdev(dev0);
 
 	sky2_set_power_state(hw, PCI_D3hot);
@@ -3519,12 +3577,14 @@
 
 static int __init sky2_init_module(void)
 {
+	sky2_proc = proc_mkdir("sky2", proc_net);
 	return pci_register_driver(&sky2_driver);
 }
 
 static void __exit sky2_cleanup_module(void)
 {
 	pci_unregister_driver(&sky2_driver);
+	proc_net_remove("sky2");
 }
 
 module_init(sky2_init_module);
--- sky2.orig/drivers/net/sky2.h	2006-08-16 15:19:29.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-08-16 15:19:42.000000000 -0700
@@ -1827,6 +1827,7 @@
 struct ring_info {
 	struct sk_buff	*skb;
 	dma_addr_t	mapaddr;
+	u16		ridx;
 };
 
 struct sky2_port {
