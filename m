From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: e100 "Lucky 13" release
Date: Wed, 20 Aug 2003 19:44:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308201939580.19939-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


More NAPI updates from jchapman@katalix.com.

	http://sf.net/projects/e1000, e100-3.0.0_dev13.tar.gz

He's getting respectable NAPI perf numbers with this.  Note the polling 
exit condition.

-scott



--- e100-3.0.0_dev12/src/e100.c	2003-08-04 20:20:42.000000000 -0700
+++ e100-3.0.0_dev13/src/e100.c	2003-08-20 18:28:56.000000000 -0700
@@ -150,11 +150,12 @@
 #include <linux/ethtool.h>
 #include <asm/unaligned.h>
 #include <asm/uaccess.h>
+#include <asm/io.h>
 
 #include "kcompat.h"
 
 #define DRV_NAME		"e100"
-#define DRV_VERSION		"3.0.0_dev12"
+#define DRV_VERSION		"3.0.0_dev13"
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2003 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -1171,7 +1172,7 @@ static void e100_watchdog(unsigned long 
 	mod_timer(&nic->watchdog, jiffies + 2 * HZ);
 }
 
-static void e100_xmit_prepare(struct nic *nic, struct cb *cb,
+static inline void e100_xmit_prepare(struct nic *nic, struct cb *cb,
 	struct sk_buff *skb)
 {
 	cb->command = nic->tx_command;
@@ -1200,7 +1201,7 @@ static int e100_xmit_frame(struct sk_buf
 	return 0;
 }
 
-static inline void e100_tx_clean(struct nic *nic)
+static inline int e100_tx_clean(struct nic *nic)
 {
 	struct cb *cb;
 	int tx_cleaned = 0;
@@ -1234,6 +1235,8 @@ static inline void e100_tx_clean(struct 
 	/* Recover from running out of Tx resources in xmit_frame */
 	if(unlikely(tx_cleaned && netif_queue_stopped(nic->netdev)))
 		netif_wake_queue(nic->netdev);
+
+	return tx_cleaned;
 }
 
 static void e100_clean_cbs(struct nic *nic, int free_mem)
@@ -1334,9 +1337,9 @@ static inline void e100_rx_rfa_add_tail(
 		struct rx_list *prev = (struct rx_list *)curr->list.prev;
 		if(likely(prev->skb != NULL)) {
 			struct rfd *prev_rfd = (struct rfd *)prev->skb->data;
-			prev_rfd->command = 0;
 			put_unaligned(cpu_to_le32(curr->dma_addr),
 				(u32 *)&prev_rfd->link);
+			prev_rfd->command = 0;
 			pci_dma_sync_single(nic->pdev, prev->dma_addr, 
 				sizeof(struct rfd), PCI_DMA_TODEVICE);
 		}
@@ -1384,7 +1387,7 @@ static inline int e100_rx_indicate(struc
 	if(unlikely(!(rfd_status & cb_ok)) ||
 	   actual_size > nic->netdev->mtu + VLAN_ETH_HLEN) {
 		/* Don't indicate if errors */
-		dev_kfree_skb_irq(skb);
+		dev_kfree_skb_any(skb);
 	} else {
 		nic->net_stats.rx_packets++;
 		nic->net_stats.rx_bytes += actual_size;
@@ -1494,14 +1497,12 @@ static irqreturn_t e100_intr(int irq, vo
 	e100_write_flush(nic);
 
 #ifdef CONFIG_E100_NAPI
-	if(likely(netif_rx_schedule_prep(netdev))) {
-		e100_disable_irq(nic);
-		__netif_rx_schedule(netdev);
-	}
+	e100_disable_irq(nic);
+	netif_rx_schedule(netdev);
 #else
-	if(likely(stat_ack & stat_ack_rx))
+	if(stat_ack & stat_ack_rx)
 		e100_rx_clean(nic, NULL, 0);
-	if(likely(stat_ack & stat_ack_tx))
+	if(stat_ack & stat_ack_tx)
 		e100_tx_clean(nic);
 #endif
 
@@ -1514,19 +1515,21 @@ static int e100_poll(struct net_device *
 	struct nic *nic = netdev->priv;
 	unsigned int work_to_do = min(netdev->quota, *budget);
 	unsigned int work_done = 0;
+	int tx_cleaned;
 
 	e100_rx_clean(nic, &work_done, work_to_do);
-	e100_tx_clean(nic);
+	tx_cleaned = e100_tx_clean(nic);
 
-	*budget -= work_done;
-	netdev->quota -= work_done;
-
-	if(likely(work_done < work_to_do)) {
+	/* If no Rx and Tx cleanup work was done, exit polling mode. */
+	if(!tx_cleaned && (work_done == 0)) {
 		netif_rx_complete(netdev);
 		e100_enable_irq(nic);
 		return 0;
 	}
 
+	*budget -= work_done;
+	netdev->quota -= work_done;
+
 	return 1;
 }
 #endif
