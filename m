From: Robert Olsson <robert@robur.slu.se>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 21:52:08 +0200
Message-ID: <18595.15208.734736.864386@robur.slu.se>
References: <48A23137.2010107@myri.com>
	<20080812.181549.229367205.davem@davemloft.net>
	<48A30834.4090802@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:50990 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752729AbYHMTwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 15:52:10 -0400
In-Reply-To: <48A30834.4090802@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Andrew Gallatin writes:
 > 
 > Excellent!  This completely fixes the increased CPU
 > utilization I observed on both 10GbE and 1GbE interfaces,
 > and CPU utilization is now reduced back to 2.6.26 levels.


 > > Robert, this could explain some of the things in the
 > > multiqueue testing profile you sent me a week or so
 > > ago.

I've just rerun the virtual 10g router experiment with the current
git including the pkt_sched patch. The full experiment is below. In this 
case the profile looks the same as before. No improvement due to this
patch here.

In this case we have not any old numbers to compare with as we're 
testing new functionality. I'm not to unhappy about the performance 
and there must be some functions the in profile... 

Virtual IP forwarding experiment. We're splitting an incoming flow
load (10g) among 4 CPU's and keep the incoming flows per-CPU including
TX and also skb clearing 


Network flow load into (eth0) 10G 82598. Total 295+293+293+220 kpps 
4 * (4096 concurrent flows at 30 pkts)

eth0   1500   0 3996889      0   1280      0      19      0      0      0 BMRU
eth1   1500   0       1      0      0      0 3998236      0      0      0 BMRU

I've configured RSS with ixgbe so all 4 CPU's are used and hacked driver 
so skb gets tagged with incoming CPU. The 2:nd col in softnet_stat is used 
to verify tagging and affinity is correct until hard_xmit and even for TX-skb 
cleaning to avoid all cache misses and true per-CPU forwarding. The ixgbe driver
1.3.31.5 from Intel's site is needed for RSS etc and bit modified for this test.

softnet_stat
000f3236 001e63f8 00000872 00000000 00000000 00000000 00000000 00000000 00000000
000f52df 001ea58c 000008b8 00000000 00000000 00000000 00000000 00000000 00000000
000f3d90 001e7af8 00000a3b 00000000 00000000 00000000 00000000 00000000 00000000
000f4174 001e82c2 00000a17 00000000 00000000 00000000 00000000 00000000 00000000

eth0 (incoming)
214:          4          0          0       6623   PCI-MSI-edge      eth0:v3-Rx
215:          0          5       6635          0   PCI-MSI-edge      eth0:v2-Rx
216:          0       7152          5          0   PCI-MSI-edge      eth0:v1-Rx
217:       7115          0          0          5   PCI-MSI-edge      eth0:v0-Rx

eth1 (outgoing)
201:          3          0          0       3738   PCI-MSI-edge      eth1:v7-Tx
202:          0          4       3743          0   PCI-MSI-edge      eth1:v6-Tx
203:          0       3743          4          0   PCI-MSI-edge      eth1:v5-Tx
204:       3746          0          0          6   PCI-MSI-edge      eth1:v4-Tx

CPU: AMD64 processors, speed 3000 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit mask of 0x00 (No unit mask) count 3000
samples  %        image name               app name                 symbol name
407896    8.7211  vmlinux                  vmlinux                  cache_alloc_refill
339524    7.2592  vmlinux                  vmlinux                  __qdisc_run
243352    5.2030  vmlinux                  vmlinux                  dev_queue_xmit
227855    4.8717  vmlinux                  vmlinux                  kfree
214975    4.5963  vmlinux                  vmlinux                  __alloc_skb
172008    3.6776  vmlinux                  vmlinux                  cache_flusharray
168307    3.5985  vmlinux                  vmlinux                  ip_route_input
160995    3.4422  vmlinux                  vmlinux                  dev_kfree_skb_irq
146116    3.1240  vmlinux                  vmlinux                  netif_receive_skb
137763    2.9455  vmlinux                  vmlinux                  free_block
133732    2.8593  vmlinux                  vmlinux                  eth_type_trans
124262    2.6568  vmlinux                  vmlinux                  ip_rcv
110170    2.3555  vmlinux                  vmlinux                  list_del
100508    2.1489  vmlinux                  vmlinux                  ip_finish_output
96777     2.0691  vmlinux                  vmlinux                  ip_forward
89212     1.9074  vmlinux                  vmlinux                  check_addr


diff --git a/net/core/dev.c b/net/core/dev.c
index 8d13a9b..6fdf427 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1714,6 +1714,9 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 {
 	u16 queue_index = 0;
 
+	if (dev->real_num_tx_queues > 1) 
+		return netdev_get_tx_queue(dev, skb->queue_mapping);
+
 	if (dev->select_queue)
 		queue_index = dev->select_queue(dev, skb);
 	else if (dev->real_num_tx_queues > 1)
@@ -4872,3 +4875,4 @@ EXPORT_SYMBOL(dev_load);
 #endif
 
 EXPORT_PER_CPU_SYMBOL(softnet_data);
+EXPORT_PER_CPU_SYMBOL(netdev_rx_stat);

--- ixgbe.h.orig	2008-07-30 13:11:46.000000000 +0200
+++ ixgbe.h	2008-07-30 17:42:59.000000000 +0200
@@ -28,6 +28,8 @@
 #ifndef _IXGBE_H_
 #define _IXGBE_H_
 
+#define CONFIG_NETDEVICES_MULTIQUEUE
+
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
@@ -106,6 +108,10 @@
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK	0x0000e000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
 
+#define IXGBE_NO_LRO
+#define IXGBE_NAPI
+#define CONFIG_IXGBE_NAPI
+
 #ifndef IXGBE_NO_LRO
 #define IXGBE_LRO_MAX 32	/*Maximum number of LRO descriptors*/
 #define IXGBE_LRO_GLOBAL 10
--- ixgbe_main.c.orig	2008-07-30 13:12:02.000000000 +0200
+++ ixgbe_main.c	2008-07-30 19:26:07.000000000 +0200
@@ -71,7 +71,7 @@
 #endif
 
 
-#define BASE_VERSION "1.3.31.5"
+#define BASE_VERSION "1.3.31.5-080730"
 #define DRV_VERSION BASE_VERSION LRO DRIVERNAPI DRV_HW_PERF
 
 char ixgbe_driver_version[] = DRV_VERSION;
@@ -257,6 +257,9 @@
 				total_packets++;
 				total_bytes += skb->len;
 #endif
+				if(skb->queue_mapping == smp_processor_id()) 
+					__get_cpu_var(netdev_rx_stat).dropped++;
+
 			}
 
 			ixgbe_unmap_and_free_tx_resource(adapter,
@@ -426,6 +429,9 @@
 			      struct sk_buff *skb, bool is_vlan, u16 tag)
 {
 	int ret;
+
+	skb->queue_mapping = smp_processor_id();
+	
 #ifdef CONFIG_IXGBE_NAPI
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
 #ifdef NETIF_F_HW_VLAN_TX
@@ -2875,7 +2881,11 @@
 			rss_i = min(4, rss_i);
 			rss_m = 0x3;
 			nrq = dcb_i * vmdq_i * rss_i;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			ntq = nrq;
+#else
 			ntq = dcb_i * vmdq_i;
+#endif
 			break;
 		case (IXGBE_FLAG_VMDQ_ENABLED | IXGBE_FLAG_DCB_ENABLED):
 			dcb_m = 0x7 << 3;
@@ -3242,7 +3252,7 @@
 out:
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
-	adapter->netdev->egress_subqueue_count = adapter->num_tx_queues;
+	// adapter->netdev->egress_subqueue_count = adapter->num_tx_queues;
 #endif
 
 	return err;
@@ -3794,6 +3804,8 @@
 }
 #endif /* CONFIG_PM */
 
+extern DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
+
 static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -4402,6 +4414,9 @@
 
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	r_idx = (adapter->num_tx_queues - 1) & skb->queue_mapping;
+
+	if(skb->queue_mapping == smp_processor_id()) 
+		__get_cpu_var(netdev_rx_stat).dropped++;
 #endif
 	tx_ring = &adapter->tx_ring[r_idx];
 
 
Cheers.
					--ro
