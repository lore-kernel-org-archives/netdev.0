From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] pktgen: better scheduler friendliness
Date: Tue, 22 Sep 2009 22:41:43 -0700
Message-ID: <20090923054201.520300835@vyatta.com>
References: <20090923054141.932043798@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:56727 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbZIWFno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 01:43:44 -0400
Content-Disposition: inline; filename=pktgen-fix.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous update did not resched in inner loop causing watchdogs.
Rewrite inner loop to:
  * account for delays better with less clock calls
  * more accurate timing of delay:
    - only delay if packet was successfully sent
    - if delay is 100ns and it takes 10ns to build packet then
      account for that
  * use wait_event_interruptible_timeout rather than open coding it.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/pktgen.c	2009-09-21 20:36:03.349310985 -0700
+++ b/net/core/pktgen.c	2009-09-21 20:49:53.647508802 -0700
@@ -2104,7 +2104,7 @@ static void pktgen_setup_inject(struct p
 
 static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 {
-	ktime_t start;
+	ktime_t start_time, end_time;
 	s32 remaining;
 	struct hrtimer_sleeper t;
 
@@ -2115,7 +2115,7 @@ static void spin(struct pktgen_dev *pkt_
 	if (remaining <= 0)
 		return;
 
-	start = ktime_now();
+	start_time = ktime_now();
 	if (remaining < 100)
 		udelay(remaining); 	/* really small just spin */
 	else {
@@ -2134,7 +2134,10 @@ static void spin(struct pktgen_dev *pkt_
 		} while (t.task && pkt_dev->running && !signal_pending(current));
 		__set_current_state(TASK_RUNNING);
 	}
-	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(), start));
+	end_time = ktime_now();
+
+	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(end_time, start_time));
+	pkt_dev->next_tx = ktime_add_ns(end_time, pkt_dev->delay);
 }
 
 static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
@@ -3364,19 +3367,29 @@ static void pktgen_rem_thread(struct pkt
 	mutex_unlock(&pktgen_thread_lock);
 }
 
-static void idle(struct pktgen_dev *pkt_dev)
+static void pktgen_resched(struct pktgen_dev *pkt_dev)
 {
 	ktime_t idle_start = ktime_now();
+	schedule();
+	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(), idle_start));
+}
 
-	if (need_resched())
-		schedule();
-	else
-		cpu_relax();
+static void pktgen_wait_for_skb(struct pktgen_dev *pkt_dev)
+{
+	ktime_t idle_start = ktime_now();
 
+	while (atomic_read(&(pkt_dev->skb->users)) != 1) {
+		if (signal_pending(current))
+			break;
+
+		if (need_resched())
+			pktgen_resched(pkt_dev);
+		else
+			cpu_relax();
+	}
 	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(), idle_start));
 }
 
-
 static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = pkt_dev->odev;
@@ -3386,36 +3399,21 @@ static void pktgen_xmit(struct pktgen_de
 	u16 queue_map;
 	int ret;
 
-	if (pkt_dev->delay) {
-		spin(pkt_dev, pkt_dev->next_tx);
-
-		/* This is max DELAY, this has special meaning of
-		 * "never transmit"
-		 */
-		if (pkt_dev->delay == ULLONG_MAX) {
-			pkt_dev->next_tx = ktime_add_ns(ktime_now(), ULONG_MAX);
-			return;
-		}
-	}
-
-	if (!pkt_dev->skb) {
-		set_cur_queue_map(pkt_dev);
-		queue_map = pkt_dev->cur_queue_map;
-	} else {
-		queue_map = skb_get_queue_mapping(pkt_dev->skb);
+	/* If device is offline, then don't send */
+	if (unlikely(!netif_running(odev) || !netif_carrier_ok(odev))) {
+		pktgen_stop_device(pkt_dev);
+		return;
 	}
 
-	txq = netdev_get_tx_queue(odev, queue_map);
-	/* Did we saturate the queue already? */
-	if (netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)) {
-		/* If device is down, then all queues are permnantly frozen */
-		if (netif_running(odev))
-			idle(pkt_dev);
-		else
-			pktgen_stop_device(pkt_dev);
+	/* This is max DELAY, this has special meaning of
+	 * "never transmit"
+	 */
+	if (unlikely(pkt_dev->delay == ULLONG_MAX)) {
+		pkt_dev->next_tx = ktime_add_ns(ktime_now(), ULONG_MAX);
 		return;
 	}
 
+	/* If no skb or clone count exhausted then get new one */
 	if (!pkt_dev->skb || (pkt_dev->last_ok &&
 			      ++pkt_dev->clone_count >= pkt_dev->clone_skb)) {
 		/* build a new pkt */
@@ -3434,54 +3432,45 @@ static void pktgen_xmit(struct pktgen_de
 		pkt_dev->clone_count = 0;	/* reset counter */
 	}
 
-	/* fill_packet() might have changed the queue */
+	if (pkt_dev->delay && pkt_dev->last_ok)
+		spin(pkt_dev, pkt_dev->next_tx);
+
 	queue_map = skb_get_queue_mapping(pkt_dev->skb);
 	txq = netdev_get_tx_queue(odev, queue_map);
 
 	__netif_tx_lock_bh(txq);
-	if (unlikely(netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)))
-		pkt_dev->last_ok = 0;
-	else {
-		atomic_inc(&(pkt_dev->skb->users));
+	atomic_inc(&(pkt_dev->skb->users));
 
-	retry_now:
+	if (unlikely(netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)))
+		ret = NETDEV_TX_BUSY;
+	else
 		ret = (*xmit)(pkt_dev->skb, odev);
-		switch (ret) {
-		case NETDEV_TX_OK:
-			txq_trans_update(txq);
-			pkt_dev->last_ok = 1;
-			pkt_dev->sofar++;
-			pkt_dev->seq_num++;
-			pkt_dev->tx_bytes += pkt_dev->cur_pkt_size;
-			break;
-		case NETDEV_TX_LOCKED:
-			cpu_relax();
-			goto retry_now;
-		default: /* Drivers are not supposed to return other values! */
-			if (net_ratelimit())
-				pr_info("pktgen: %s xmit error: %d\n",
-					odev->name, ret);
-			pkt_dev->errors++;
-			/* fallthru */
-		case NETDEV_TX_BUSY:
-			/* Retry it next time */
-			atomic_dec(&(pkt_dev->skb->users));
-			pkt_dev->last_ok = 0;
-		}
-
-		if (pkt_dev->delay)
-			pkt_dev->next_tx = ktime_add_ns(ktime_now(),
-							pkt_dev->delay);
+
+	switch (ret) {
+	case NETDEV_TX_OK:
+		txq_trans_update(txq);
+		pkt_dev->last_ok = 1;
+		pkt_dev->sofar++;
+		pkt_dev->seq_num++;
+		pkt_dev->tx_bytes += pkt_dev->cur_pkt_size;
+		break;
+	default: /* Drivers are not supposed to return other values! */
+		if (net_ratelimit())
+			pr_info("pktgen: %s xmit error: %d\n",
+				odev->name, ret);
+		pkt_dev->errors++;
+		/* fallthru */
+	case NETDEV_TX_LOCKED:
+	case NETDEV_TX_BUSY:
+		/* Retry it next time */
+		atomic_dec(&(pkt_dev->skb->users));
+		pkt_dev->last_ok = 0;
 	}
 	__netif_tx_unlock_bh(txq);
 
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
-		while (atomic_read(&(pkt_dev->skb->users)) != 1) {
-			if (signal_pending(current))
-				break;
-			idle(pkt_dev);
-		}
+		pktgen_wait_for_skb(pkt_dev);
 
 		/* Done with this */
 		pktgen_stop_device(pkt_dev);
@@ -3514,20 +3503,24 @@ static int pktgen_thread_worker(void *ar
 	while (!kthread_should_stop()) {
 		pkt_dev = next_to_run(t);
 
-		if (!pkt_dev &&
-		    (t->control & (T_STOP | T_RUN | T_REMDEVALL | T_REMDEV))
-		    == 0) {
-			prepare_to_wait(&(t->queue), &wait,
-					TASK_INTERRUPTIBLE);
-			schedule_timeout(HZ / 10);
-			finish_wait(&(t->queue), &wait);
+		if (unlikely(!pkt_dev && t->control == 0)) {
+			wait_event_interruptible_timeout(t->queue,
+							 t->control != 0,
+							 HZ/10);
+			continue;
 		}
 
 		__set_current_state(TASK_RUNNING);
 
-		if (pkt_dev)
+		if (likely(pkt_dev)) {
 			pktgen_xmit(pkt_dev);
 
+			if (need_resched())
+				pktgen_resched(pkt_dev);
+			else
+				cpu_relax();
+		}
+
 		if (t->control & T_STOP) {
 			pktgen_stop(t);
 			t->control &= ~(T_STOP);

-- 

