From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH] xen-netback: Turn off the carrier if the guest is not able to receive
Date: Wed, 30 Jul 2014 20:50:49 +0100
Message-ID: <1406749849-4356-2-git-send-email-zoltan.kiss@citrix.com>
References: <1406749849-4356-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406749849-4356-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently when the guest is not able to receive more packets, qdisc layer starts
a timer, and when it goes off, qdisc is started again to deliver a packet again.
This is a very slow way to drain the queues, consumes unnecessary resources and
slows down other guests shutdown.
This patch change the behaviour by turning the carrier off when that timer
fires, so all the packets are freed up which were stucked waiting for that vif.
Instead of the rx_queue_purge bool it uses the VIF_STATUS_RX_PURGE_EVENT bit to
signal the thread that either the timout happened or an RX interrupt arrived, so
the thread can check what it should do. It also disables NAPI, so the guest
can't transmit, but leaves the interrupts on, so it can resurrect.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org 
diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 7231359..66b4bef 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -176,9 +176,9 @@ struct xenvif_queue { /* Per-queue data for xenvif */
 	struct xen_netif_rx_back_ring rx;
 	struct sk_buff_head rx_queue;
 	RING_IDX rx_last_skb_slots;
-	bool rx_queue_purge;
+	unsigned long status;
 
-	struct timer_list wake_queue;
+	struct timer_list rx_stalled;
 
 	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
 
@@ -198,9 +198,17 @@ struct xenvif_queue { /* Per-queue data for xenvif */
 	struct xenvif_stats stats;
 };
 
-enum vif_state_bit_shift {
+enum state_bit_shift {
 	/* This bit marks that the vif is connected */
-	VIF_STATUS_CONNECTED
+	VIF_STATUS_CONNECTED,
+	/* This bit signals to the RX thread that queuing was stopped
+	 * (in start_xmit), and either the timer fired or an RX interrupt came
+	 */
+	QUEUE_STATUS_RX_PURGE_EVENT,
+	/* This bit tells to the interrupt handler that this queue was the
+	 * reason for the carrier off, so it should kick the thread
+	 */
+	QUEUE_STATUS_RX_STALLED
 };
 
 struct xenvif {
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index fa7d8ac..d2e61f4 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -79,7 +79,8 @@ int xenvif_poll(struct napi_struct *napi, int budget)
 	 * for this vif to deschedule it from NAPI. But this interface
 	 * will be turned off in thread context later.
 	 */
-	if (unlikely(queue->vif->disabled)) {
+	if (unlikely(queue->vif->disabled ||
+		     !netif_carrier_ok(queue->vif->dev))) {
 		napi_complete(napi);
 		return 0;
 	}
@@ -97,7 +98,13 @@ int xenvif_poll(struct napi_struct *napi, int budget)
 static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
 {
 	struct xenvif_queue *queue = dev_id;
+	struct netdev_queue *net_queue =
+		netdev_get_tx_queue(queue->vif->dev, queue->id);
 
+	if (unlikely((netif_tx_queue_stopped(net_queue) ||
+		      !netif_carrier_ok(queue->vif->dev)) &&
+		     test_bit(QUEUE_STATUS_RX_STALLED, &queue->status)))
+		set_bit(QUEUE_STATUS_RX_PURGE_EVENT, &queue->status);
 	xenvif_kick_thread(queue);
 
 	return IRQ_HANDLED;
@@ -126,15 +133,13 @@ void xenvif_wake_queue(struct xenvif_queue *queue)
 }
 
 /* Callback to wake the queue and drain it on timeout */
-static void xenvif_wake_queue_callback(unsigned long data)
+static void xenvif_rx_stalled(unsigned long data)
 {
 	struct xenvif_queue *queue = (struct xenvif_queue *)data;
 
 	if (xenvif_queue_stopped(queue)) {
-		netdev_err(queue->vif->dev, "draining TX queue\n");
-		queue->rx_queue_purge = true;
+		set_bit(QUEUE_STATUS_RX_PURGE_EVENT, &queue->status);
 		xenvif_kick_thread(queue);
-		xenvif_wake_queue(queue);
 	}
 }
 
@@ -183,11 +188,11 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * drain.
 	 */
 	if (!xenvif_rx_ring_slots_available(queue, min_slots_needed)) {
-		queue->wake_queue.function = xenvif_wake_queue_callback;
-		queue->wake_queue.data = (unsigned long)queue;
+		queue->rx_stalled.function = xenvif_rx_stalled;
+		queue->rx_stalled.data = (unsigned long)queue;
 		xenvif_stop_queue(queue);
-		mod_timer(&queue->wake_queue,
-			jiffies + rx_drain_timeout_jiffies);
+		mod_timer(&queue->rx_stalled,
+			  jiffies + rx_drain_timeout_jiffies);
 	}
 
 	skb_queue_tail(&queue->rx_queue, skb);
@@ -515,7 +520,7 @@ int xenvif_init_queue(struct xenvif_queue *queue)
 		queue->grant_tx_handle[i] = NETBACK_INVALID_HANDLE;
 	}
 
-	init_timer(&queue->wake_queue);
+	init_timer(&queue->rx_stalled);
 
 	netif_napi_add(queue->vif->dev, &queue->napi, xenvif_poll,
 			XENVIF_NAPI_WEIGHT);
@@ -666,7 +671,7 @@ void xenvif_disconnect(struct xenvif *vif)
 		queue = &vif->queues[queue_index];
 
 		if (queue->task) {
-			del_timer_sync(&queue->wake_queue);
+			del_timer_sync(&queue->rx_stalled);
 			kthread_stop(queue->task);
 			queue->task = NULL;
 		}
@@ -708,16 +713,12 @@ void xenvif_free(struct xenvif *vif)
 	/* Here we want to avoid timeout messages if an skb can be legitimately
 	 * stuck somewhere else. Realistically this could be an another vif's
 	 * internal or QDisc queue. That another vif also has this
-	 * rx_drain_timeout_msecs timeout, but the timer only ditches the
-	 * internal queue. After that, the QDisc queue can put in worst case
-	 * XEN_NETIF_RX_RING_SIZE / MAX_SKB_FRAGS skbs into that another vif's
-	 * internal queue, so we need several rounds of such timeouts until we
-	 * can be sure that no another vif should have skb's from us. We are
-	 * not sending more skb's, so newly stuck packets are not interesting
-	 * for us here.
+	 * rx_drain_timeout_msecs timeout, so give it time to drain out.
+	 * Although if that other guest wakes up just before its timeout happens
+	 * and takes only one skb from QDisc, it can hold onto other skbs for a
+	 * longer period.
 	 */
-	unsigned int worst_case_skb_lifetime = (rx_drain_timeout_msecs/1000) *
-		DIV_ROUND_UP(XENVIF_QUEUE_LENGTH, (XEN_NETIF_RX_RING_SIZE / MAX_SKB_FRAGS));
+	unsigned int worst_case_skb_lifetime = (rx_drain_timeout_msecs/1000);
 
 	unregister_netdev(vif->dev);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 6c4cc0f..7dac833 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1869,8 +1869,7 @@ void xenvif_idx_unmap(struct xenvif_queue *queue, u16 pending_idx)
 static inline int rx_work_todo(struct xenvif_queue *queue)
 {
 	return (!skb_queue_empty(&queue->rx_queue) &&
-	       xenvif_rx_ring_slots_available(queue, queue->rx_last_skb_slots)) ||
-	       queue->rx_queue_purge;
+	       xenvif_rx_ring_slots_available(queue, queue->rx_last_skb_slots));
 }
 
 static inline int tx_work_todo(struct xenvif_queue *queue)
@@ -1944,6 +1943,7 @@ int xenvif_kthread_guest_rx(void *data)
 		wait_event_interruptible(queue->wq,
 					 rx_work_todo(queue) ||
 					 queue->vif->disabled ||
+					 test_bit(QUEUE_STATUS_RX_PURGE_EVENT, &queue->status) ||
 					 kthread_should_stop());
 
 		/* This frontend is found to be rogue, disable it in
@@ -1955,24 +1955,78 @@ int xenvif_kthread_guest_rx(void *data)
 		 */
 		if (unlikely(queue->vif->disabled && queue->id == 0))
 			xenvif_carrier_off(queue->vif);
+		else if (unlikely(test_and_clear_bit(QUEUE_STATUS_RX_PURGE_EVENT,
+						     &queue->status))) {
+			/* Either the last unsuccesful skb or at least 1 slot
+			 * should fit
+			 */
+			int needed = queue->rx_last_skb_slots ?
+				     queue->rx_last_skb_slots : 1;
 
-		if (kthread_should_stop())
-			break;
-
-		if (queue->rx_queue_purge) {
+			/* It is assumed that if the guest post new
+			 * slots after this, the RX interrupt will set
+			 * the bit and wake up the thread again
+			 */
+			set_bit(QUEUE_STATUS_RX_STALLED, &queue->status);
+			if (!xenvif_rx_ring_slots_available(queue, needed)) {
+				rtnl_lock();
+				if (netif_carrier_ok(queue->vif->dev)) {
+					/* Timer fired and there are still no
+					 * slots. Turn off everything except the
+					 * interrupts
+					 */
+					netif_carrier_off(queue->vif->dev);
+					skb_queue_purge(&queue->rx_queue);
+					queue->rx_last_skb_slots = 0;
+					if (net_ratelimit())
+						netdev_err(queue->vif->dev, "Carrier off due to lack of guest response on queue %d\n", queue->id);
+				}
+				rtnl_unlock();
+			} else if (!netif_carrier_ok(queue->vif->dev)) {
+				unsigned int num_queues = queue->vif->num_queues;
+				unsigned int i;
+				/* The carrier was down, but an interrupt kicked
+				 * the thread again after new requests were
+				 * posted
+				 */
+				clear_bit(QUEUE_STATUS_RX_STALLED,
+					  &queue->status);
+				rtnl_lock();
+				netif_carrier_on(queue->vif->dev);
+				netif_tx_wake_all_queues(queue->vif->dev);
+				rtnl_unlock();
+
+				for (i = 0; i < num_queues; ++i) {
+					struct xenvif_queue *temp = &queue->vif->queues[i];
+					xenvif_napi_schedule_or_enable_events(temp);
+				}
+				if (net_ratelimit())
+					netdev_err(queue->vif->dev, "Carrier on again\n");
+				continue;
+			} else {
+				/* Queuing were stopped, but the guest posted
+				 * new requests
+				 */
+				clear_bit(QUEUE_STATUS_RX_STALLED,
+					  &queue->status);
+				del_timer_sync(&queue->rx_stalled);
+				xenvif_start_queue(queue);
+				continue;
+			}
+		} else if (!netif_carrier_ok(queue->vif->dev)) {
+			/* Another queue stalled and turned the carrier off, so
+			 * purge our internal queue
+			 */
 			skb_queue_purge(&queue->rx_queue);
-			queue->rx_queue_purge = false;
+			queue->rx_last_skb_slots = 0;
 		}
 
+		if (kthread_should_stop())
+			break;
+
 		if (!skb_queue_empty(&queue->rx_queue))
 			xenvif_rx_action(queue);
 
-		if (skb_queue_empty(&queue->rx_queue) &&
-		    xenvif_queue_stopped(queue)) {
-			del_timer_sync(&queue->wake_queue);
-			xenvif_start_queue(queue);
-		}
-
 		cond_resched();
 	}
 
