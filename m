From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 4/7] Staging: Octeon Ethernet: Rewrite transmit code.
Date: Thu,  7 Jan 2010 11:05:03 -0800
Message-ID: <1262891106-32146-4-git-send-email-ddaney@caviumnetworks.com>
References: <4B463005.8060505@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:17193 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563Ab0AGTGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:06:06 -0500
In-Reply-To: <4B463005.8060505@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stop the queue if too many packets are queued.  Restart it from a high
resolution timer.

Rearrange and simplify locking and SKB freeing code

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/Kconfig           |    1 +
 drivers/staging/octeon/ethernet-tx.c     |  172 +++++++++++++++++++-----------
 drivers/staging/octeon/ethernet-tx.h     |   27 +-----
 drivers/staging/octeon/ethernet.c        |   69 ++++++-------
 drivers/staging/octeon/octeon-ethernet.h |    4 +
 5 files changed, 150 insertions(+), 123 deletions(-)

diff --git a/drivers/staging/octeon/Kconfig b/drivers/staging/octeon/Kconfig
index 638ad6b..579b8f1 100644
--- a/drivers/staging/octeon/Kconfig
+++ b/drivers/staging/octeon/Kconfig
@@ -3,6 +3,7 @@ config OCTEON_ETHERNET
 	depends on CPU_CAVIUM_OCTEON
 	select PHYLIB
 	select MDIO_OCTEON
+	select HIGH_RES_TIMERS
 	help
 	  This driver supports the builtin ethernet ports on Cavium
 	  Networks' products in the Octeon family. This driver supports the
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index e5695d9..05b58f8 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -64,6 +64,49 @@
 #define GET_SKBUFF_QOS(skb) 0
 #endif
 
+
+static inline int32_t cvm_oct_adjust_skb_to_free(int32_t skb_to_free, int fau)
+{
+	int32_t undo;
+	undo = skb_to_free > 0 ? MAX_SKB_TO_FREE : skb_to_free + MAX_SKB_TO_FREE;
+	if (undo > 0)
+		cvmx_fau_atomic_add32(fau, -undo);
+	skb_to_free = -skb_to_free > MAX_SKB_TO_FREE ? MAX_SKB_TO_FREE : -skb_to_free;
+	return skb_to_free;
+}
+
+void cvm_oct_free_tx_skbs(struct octeon_ethernet *priv)
+{
+	int32_t skb_to_free;
+	int qos, queues_per_port;
+	queues_per_port = cvmx_pko_get_num_queues(priv->port);
+	/* Drain any pending packets in the free list */
+	for (qos = 0; qos < queues_per_port; qos++) {
+		if (skb_queue_len(&priv->tx_free_list[qos]) == 0)
+			continue;
+		skb_to_free = cvmx_fau_fetch_and_add32(priv->fau+qos*4, MAX_SKB_TO_FREE);
+		skb_to_free = cvm_oct_adjust_skb_to_free(skb_to_free, priv->fau+qos*4);
+
+		while (skb_to_free > 0) {
+			dev_kfree_skb_any(skb_dequeue(&priv->tx_free_list[qos]));
+			skb_to_free--;
+		}
+	}
+}
+
+enum hrtimer_restart cvm_oct_restart_tx(struct hrtimer *timer)
+{
+	struct octeon_ethernet *priv = container_of(timer, struct octeon_ethernet, tx_restart_timer);
+	struct net_device *dev = cvm_oct_device[priv->port];
+
+	cvm_oct_free_tx_skbs(priv);
+
+	if (netif_queue_stopped(dev))
+		netif_wake_queue(dev);
+
+	return HRTIMER_NORESTART;
+}
+
 /**
  * Packet transmit
  *
@@ -77,13 +120,13 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	union cvmx_buf_ptr hw_buffer;
 	uint64_t old_scratch;
 	uint64_t old_scratch2;
-	int dropped;
 	int qos;
-	int queue_it_up;
+	enum {QUEUE_CORE, QUEUE_HW, QUEUE_DROP} queue_type;
 	struct octeon_ethernet *priv = netdev_priv(dev);
+	struct sk_buff *to_free_list;
 	int32_t skb_to_free;
-	int32_t undo;
 	int32_t buffers_to_free;
+	unsigned long flags;
 #if REUSE_SKBUFFS_WITHOUT_FREE
 	unsigned char *fpa_head;
 #endif
@@ -94,9 +137,6 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	prefetch(priv);
 
-	/* Start off assuming no drop */
-	dropped = 0;
-
 	/*
 	 * The check on CVMX_PKO_QUEUES_PER_PORT_* is designed to
 	 * completely remove "qos" in the event neither interface
@@ -268,9 +308,9 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb->tc_verd = 0;
 #endif /* CONFIG_NET_CLS_ACT */
 #endif /* CONFIG_NET_SCHED */
+#endif /* REUSE_SKBUFFS_WITHOUT_FREE */
 
 dont_put_skbuff_in_hw:
-#endif /* REUSE_SKBUFFS_WITHOUT_FREE */
 
 	/* Check if we can use the hardware checksumming */
 	if (USE_HW_TCPUDP_CHECKSUM && (skb->protocol == htons(ETH_P_IP)) &&
@@ -295,18 +335,7 @@ dont_put_skbuff_in_hw:
 		    cvmx_fau_fetch_and_add32(FAU_NUM_PACKET_BUFFERS_TO_FREE, 0);
 	}
 
-	/*
-	 * We try to claim MAX_SKB_TO_FREE buffers.  If there were not
-	 * that many available, we have to un-claim (undo) any that
-	 * were in excess.  If skb_to_free is positive we will free
-	 * that many buffers.
-	 */
-	undo = skb_to_free > 0 ?
-		MAX_SKB_TO_FREE : skb_to_free + MAX_SKB_TO_FREE;
-	if (undo > 0)
-		cvmx_fau_atomic_add32(priv->fau+qos*4, -undo);
-	skb_to_free = -skb_to_free > MAX_SKB_TO_FREE ?
-		MAX_SKB_TO_FREE : -skb_to_free;
+	skb_to_free = cvm_oct_adjust_skb_to_free(skb_to_free, priv->fau+qos*4);
 
 	/*
 	 * If we're sending faster than the receive can free them then
@@ -317,60 +346,83 @@ dont_put_skbuff_in_hw:
 		pko_command.s.reg0 = priv->fau + qos * 4;
 	}
 
-	cvmx_pko_send_packet_prepare(priv->port, priv->queue + qos,
-				     CVMX_PKO_LOCK_CMD_QUEUE);
+	if (pko_command.s.dontfree)
+		queue_type = QUEUE_CORE;
+	else
+		queue_type = QUEUE_HW;
+
+	spin_lock_irqsave(&priv->tx_free_list[qos].lock, flags);
 
 	/* Drop this packet if we have too many already queued to the HW */
-	if (unlikely
-	    (skb_queue_len(&priv->tx_free_list[qos]) >= MAX_OUT_QUEUE_DEPTH)) {
-		/*
-		   DEBUGPRINT("%s: Tx dropped. Too many queued\n", dev->name);
-		 */
-		dropped = 1;
+	if (unlikely(skb_queue_len(&priv->tx_free_list[qos]) >= MAX_OUT_QUEUE_DEPTH)) {
+		if (dev->tx_queue_len != 0) {
+			/* Drop the lock when notifying the core.  */
+			spin_unlock_irqrestore(&priv->tx_free_list[qos].lock, flags);
+			netif_stop_queue(dev);
+			hrtimer_start(&priv->tx_restart_timer,
+				      priv->tx_restart_interval, HRTIMER_MODE_REL);
+			spin_lock_irqsave(&priv->tx_free_list[qos].lock, flags);
+
+		} else {
+			/* If not using normal queueing.  */
+			queue_type = QUEUE_DROP;
+			goto skip_xmit;
+		}
 	}
+
+	cvmx_pko_send_packet_prepare(priv->port, priv->queue + qos,
+				     CVMX_PKO_LOCK_NONE);
+
 	/* Send the packet to the output queue */
-	else if (unlikely
-		 (cvmx_pko_send_packet_finish
-		  (priv->port, priv->queue + qos, pko_command, hw_buffer,
-		   CVMX_PKO_LOCK_CMD_QUEUE))) {
+	if (unlikely(cvmx_pko_send_packet_finish(priv->port,
+						 priv->queue + qos,
+						 pko_command, hw_buffer,
+						 CVMX_PKO_LOCK_NONE))) {
 		DEBUGPRINT("%s: Failed to send the packet\n", dev->name);
-		dropped = 1;
+		queue_type = QUEUE_DROP;
 	}
+skip_xmit:
+	to_free_list = NULL;
 
-	if (USE_ASYNC_IOBDMA) {
-		/* Restore the scratch area */
-		cvmx_scratch_write64(CVMX_SCR_SCRATCH, old_scratch);
-		cvmx_scratch_write64(CVMX_SCR_SCRATCH + 8, old_scratch2);
+	switch (queue_type) {
+	case QUEUE_DROP:
+		skb->next = to_free_list;
+		to_free_list = skb;
+		priv->stats.tx_dropped++;
+		break;
+	case QUEUE_HW:
+		cvmx_fau_atomic_add32(FAU_NUM_PACKET_BUFFERS_TO_FREE, -1);
+		break;
+	case QUEUE_CORE:
+		__skb_queue_tail(&priv->tx_free_list[qos], skb);
+		break;
+	default:
+		BUG();
 	}
 
-	queue_it_up = 0;
-	if (unlikely(dropped)) {
-		dev_kfree_skb_any(skb);
-		priv->stats.tx_dropped++;
-	} else {
-		if (USE_SKBUFFS_IN_HW) {
-			/* Put this packet on the queue to be freed later */
-			if (pko_command.s.dontfree)
-				queue_it_up = 1;
-			else
-				cvmx_fau_atomic_add32
-				    (FAU_NUM_PACKET_BUFFERS_TO_FREE, -1);
-		} else {
-			/* Put this packet on the queue to be freed later */
-			queue_it_up = 1;
-		}
+	while (skb_to_free > 0) {
+		struct sk_buff *t = __skb_dequeue(&priv->tx_free_list[qos]);
+		t->next = to_free_list;
+		to_free_list = t;
+		skb_to_free--;
 	}
 
-	if (queue_it_up) {
-		spin_lock(&priv->tx_free_list[qos].lock);
-		__skb_queue_tail(&priv->tx_free_list[qos], skb);
-		cvm_oct_free_tx_skbs(priv, skb_to_free, qos, 0);
-		spin_unlock(&priv->tx_free_list[qos].lock);
-	} else {
-		cvm_oct_free_tx_skbs(priv, skb_to_free, qos, 1);
+	spin_unlock_irqrestore(&priv->tx_free_list[qos].lock, flags);
+
+	/* Do the actual freeing outside of the lock. */
+	while (to_free_list) {
+		struct sk_buff *t = to_free_list;
+		to_free_list = to_free_list->next;
+		dev_kfree_skb_any(t);
 	}
 
-	return 0;
+	if (USE_ASYNC_IOBDMA) {
+		/* Restore the scratch area */
+		cvmx_scratch_write64(CVMX_SCR_SCRATCH, old_scratch);
+		cvmx_scratch_write64(CVMX_SCR_SCRATCH + 8, old_scratch2);
+	}
+
+	return NETDEV_TX_OK;
 }
 
 /**
diff --git a/drivers/staging/octeon/ethernet-tx.h b/drivers/staging/octeon/ethernet-tx.h
index c0bebf7..b628d8c 100644
--- a/drivers/staging/octeon/ethernet-tx.h
+++ b/drivers/staging/octeon/ethernet-tx.h
@@ -30,28 +30,5 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev);
 int cvm_oct_transmit_qos(struct net_device *dev, void *work_queue_entry,
 			 int do_free, int qos);
 void cvm_oct_tx_shutdown(struct net_device *dev);
-
-/**
- * Free dead transmit skbs.
- *
- * @priv:		The driver data
- * @skb_to_free:	The number of SKBs to free (free none if negative).
- * @qos:		The queue to free from.
- * @take_lock:		If true, acquire the skb list lock.
- */
-static inline void cvm_oct_free_tx_skbs(struct octeon_ethernet *priv,
-					int skb_to_free,
-					int qos, int take_lock)
-{
-	/* Free skbuffs not in use by the hardware.  */
-	if (skb_to_free > 0) {
-		if (take_lock)
-			spin_lock(&priv->tx_free_list[qos].lock);
-		while (skb_to_free > 0) {
-			dev_kfree_skb(__skb_dequeue(&priv->tx_free_list[qos]));
-			skb_to_free--;
-		}
-		if (take_lock)
-			spin_unlock(&priv->tx_free_list[qos].lock);
-	}
-}
+void cvm_oct_free_tx_skbs(struct octeon_ethernet *priv);
+enum hrtimer_restart cvm_oct_restart_tx(struct hrtimer *timer);
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 4e05426..973178a 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -131,50 +131,29 @@ struct net_device *cvm_oct_device[TOTAL_NUMBER_OF_PORTS];
  */
 static void cvm_do_timer(unsigned long arg)
 {
-	int32_t skb_to_free, undo;
-	int queues_per_port;
-	int qos;
-	struct octeon_ethernet *priv;
 	static int port;
-
-	if (port >= CVMX_PIP_NUM_INPUT_PORTS) {
+	if (port < CVMX_PIP_NUM_INPUT_PORTS) {
+		if (cvm_oct_device[port]) {
+			struct octeon_ethernet *priv = netdev_priv(cvm_oct_device[port]);
+			if (priv->poll)
+				priv->poll(cvm_oct_device[port]);
+			cvm_oct_free_tx_skbs(priv);
+			cvm_oct_device[port]->netdev_ops->ndo_get_stats(cvm_oct_device[port]);
+		}
+		port++;
 		/*
-		 * All ports have been polled. Start the next
-		 * iteration through the ports in one second.
+		 * Poll the next port in a 50th of a second.  This
+		 * spreads the polling of ports out a little bit.
 		 */
+		mod_timer(&cvm_oct_poll_timer, jiffies + HZ/50);
+	} else {
 		port = 0;
+		/*
+		 * All ports have been polled. Start the next iteration through
+		 * the ports in one second.
+		 */
 		mod_timer(&cvm_oct_poll_timer, jiffies + HZ);
-		return;
 	}
-	if (!cvm_oct_device[port])
-		goto out;
-
-	priv = netdev_priv(cvm_oct_device[port]);
-	if (priv->poll)
-		priv->poll(cvm_oct_device[port]);
-
-	queues_per_port = cvmx_pko_get_num_queues(port);
-	/* Drain any pending packets in the free list */
-	for (qos = 0; qos < queues_per_port; qos++) {
-		if (skb_queue_len(&priv->tx_free_list[qos]) == 0)
-			continue;
-		skb_to_free = cvmx_fau_fetch_and_add32(priv->fau + qos * 4,
-						       MAX_SKB_TO_FREE);
-		undo = skb_to_free > 0 ?
-			MAX_SKB_TO_FREE : skb_to_free + MAX_SKB_TO_FREE;
-		if (undo > 0)
-			cvmx_fau_atomic_add32(priv->fau+qos*4, -undo);
-		skb_to_free = -skb_to_free > MAX_SKB_TO_FREE ?
-			MAX_SKB_TO_FREE : -skb_to_free;
-		cvm_oct_free_tx_skbs(priv, skb_to_free, qos, 1);
-	}
-	cvm_oct_device[port]->netdev_ops->ndo_get_stats(cvm_oct_device[port]);
-
-out:
-	port++;
-	/* Poll the next port in a 50th of a second.
-	   This spreads the polling of ports out a little bit */
-	mod_timer(&cvm_oct_poll_timer, jiffies + HZ / 50);
 }
 
 /**
@@ -678,6 +657,18 @@ static int __init cvm_oct_init_module(void)
 			/* Initialize the device private structure. */
 			struct octeon_ethernet *priv = netdev_priv(dev);
 
+			hrtimer_init(&priv->tx_restart_timer,
+				     CLOCK_MONOTONIC,
+				     HRTIMER_MODE_REL);
+			priv->tx_restart_timer.function = cvm_oct_restart_tx;
+
+			/*
+			 * Default for 10GE 5000nS enough time to
+			 * transmit about 100 64byte packtes.  1GE
+			 * interfaces will get 50000nS below.
+			 */
+			priv->tx_restart_interval = ktime_set(0, 5000);
+
 			dev->netdev_ops = &cvm_oct_pow_netdev_ops;
 			priv->imode = CVMX_HELPER_INTERFACE_MODE_DISABLED;
 			priv->port = CVMX_PIP_NUM_INPUT_PORTS;
@@ -757,6 +748,7 @@ static int __init cvm_oct_init_module(void)
 
 			case CVMX_HELPER_INTERFACE_MODE_SGMII:
 				dev->netdev_ops = &cvm_oct_sgmii_netdev_ops;
+				priv->tx_restart_interval = ktime_set(0, 50000);
 				strcpy(dev->name, "eth%d");
 				break;
 
@@ -768,6 +760,7 @@ static int __init cvm_oct_init_module(void)
 			case CVMX_HELPER_INTERFACE_MODE_RGMII:
 			case CVMX_HELPER_INTERFACE_MODE_GMII:
 				dev->netdev_ops = &cvm_oct_rgmii_netdev_ops;
+				priv->tx_restart_interval = ktime_set(0, 50000);
 				strcpy(dev->name, "eth%d");
 				break;
 			}
diff --git a/drivers/staging/octeon/octeon-ethernet.h b/drivers/staging/octeon/octeon-ethernet.h
index 208da27..203c6a9 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -31,6 +31,8 @@
 #ifndef OCTEON_ETHERNET_H
 #define OCTEON_ETHERNET_H
 
+#include <linux/hrtimer.h>
+
 /**
  * This is the definition of the Ethernet driver's private
  * driver state stored in netdev_priv(dev).
@@ -57,6 +59,8 @@ struct octeon_ethernet {
 	uint64_t link_info;
 	/* Called periodically to check link status */
 	void (*poll) (struct net_device *dev);
+	struct hrtimer		tx_restart_timer;
+	ktime_t			tx_restart_interval;
 };
 
 /**
-- 
1.6.0.6

