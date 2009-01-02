From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH] can: update can-bcm for hrtimer hardirq callbacks
Date: Fri, 02 Jan 2009 14:49:25 +0100
Message-ID: <495E1B65.4070504@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020400050505030707030603"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:9629 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757345AbZABNtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 08:49:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020400050505030707030603
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Since commit ca109491f612aab5c8152207631c0444f63da97f the hrtimer 
callbacks are processed only in hardirq context.

This patch moves some functionality into tasklets to run in softirq context.

Additionally some duplicated code was removed in bcm_rx_thr_flush() and 
an avoidable memcpy was removed from bcm_rx_handler().

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>



--------------020400050505030707030603
Content-Type: text/x-patch;
 name="bcm_hrtimer_hardirq.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bcm_hrtimer_hardirq.patch"

diff --git a/net/can/bcm.c b/net/can/bcm.c
index da0d426..6248ae2 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -70,7 +70,7 @@
 
 #define CAN_BCM_VERSION CAN_VERSION
 static __initdata const char banner[] = KERN_INFO
-	"can: broadcast manager protocol (rev " CAN_BCM_VERSION ")\n";
+	"can: broadcast manager protocol (rev " CAN_BCM_VERSION " t)\n";
 
 MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -90,6 +90,7 @@ struct bcm_op {
 	unsigned long frames_abs, frames_filtered;
 	struct timeval ival1, ival2;
 	struct hrtimer timer, thrtimer;
+	struct tasklet_struct tsklet, thrtsklet;
 	ktime_t rx_stamp, kt_ival1, kt_ival2, kt_lastmsg;
 	int rx_ifindex;
 	int count;
@@ -341,6 +342,23 @@ static void bcm_send_to_user(struct bcm_op *op, struct bcm_msg_head *head,
 	}
 }
 
+static void bcm_tx_timeout_tsklet(unsigned long data)
+{
+	struct bcm_op *op = (struct bcm_op *)data;
+	struct bcm_msg_head msg_head;
+
+	/* create notification to user */
+	msg_head.opcode  = TX_EXPIRED;
+	msg_head.flags   = op->flags;
+	msg_head.count   = op->count;
+	msg_head.ival1   = op->ival1;
+	msg_head.ival2   = op->ival2;
+	msg_head.can_id  = op->can_id;
+	msg_head.nframes = 0;
+
+	bcm_send_to_user(op, &msg_head, NULL, 0);
+}
+
 /*
  * bcm_tx_timeout_handler - performes cyclic CAN frame transmissions
  */
@@ -352,20 +370,8 @@ static enum hrtimer_restart bcm_tx_timeout_handler(struct hrtimer *hrtimer)
 	if (op->kt_ival1.tv64 && (op->count > 0)) {
 
 		op->count--;
-		if (!op->count && (op->flags & TX_COUNTEVT)) {
-			struct bcm_msg_head msg_head;
-
-			/* create notification to user */
-			msg_head.opcode  = TX_EXPIRED;
-			msg_head.flags   = op->flags;
-			msg_head.count   = op->count;
-			msg_head.ival1   = op->ival1;
-			msg_head.ival2   = op->ival2;
-			msg_head.can_id  = op->can_id;
-			msg_head.nframes = 0;
-
-			bcm_send_to_user(op, &msg_head, NULL, 0);
-		}
+		if (!op->count && (op->flags & TX_COUNTEVT))
+			tasklet_schedule(&op->tsklet);
 	}
 
 	if (op->kt_ival1.tv64 && (op->count > 0)) {
@@ -402,6 +408,9 @@ static void bcm_rx_changed(struct bcm_op *op, struct can_frame *data)
 	if (op->frames_filtered > ULONG_MAX/100)
 		op->frames_filtered = op->frames_abs = 0;
 
+	/* this element is not throttled anymore */
+	data->can_dlc &= (BCM_CAN_DLC_MASK|RX_RECV);
+
 	head.opcode  = RX_CHANGED;
 	head.flags   = op->flags;
 	head.count   = op->count;
@@ -420,37 +429,32 @@ static void bcm_rx_changed(struct bcm_op *op, struct can_frame *data)
  */
 static void bcm_rx_update_and_send(struct bcm_op *op,
 				   struct can_frame *lastdata,
-				   struct can_frame *rxdata)
+				   const struct can_frame *rxdata)
 {
 	memcpy(lastdata, rxdata, CFSIZ);
 
-	/* mark as used */
-	lastdata->can_dlc |= RX_RECV;
+	/* mark as used and throttled by default */
+	lastdata->can_dlc |= (RX_RECV|RX_THR);
 
-	/* throtteling mode inactive OR data update already on the run ? */
-	if (!op->kt_ival2.tv64 || hrtimer_callback_running(&op->thrtimer)) {
+	/* throtteling mode inactive ? */
+	if (!op->kt_ival2.tv64) {
 		/* send RX_CHANGED to the user immediately */
-		bcm_rx_changed(op, rxdata);
+		bcm_rx_changed(op, lastdata);
 		return;
 	}
 
-	if (hrtimer_active(&op->thrtimer)) {
-		/* mark as 'throttled' */
-		lastdata->can_dlc |= RX_THR;
+	/* with active throttling timer we are just done here */
+	if (hrtimer_active(&op->thrtimer))
 		return;
-	}
 
-	if (!op->kt_lastmsg.tv64) {
-		/* send first RX_CHANGED to the user immediately */
-		bcm_rx_changed(op, rxdata);
-		op->kt_lastmsg = ktime_get();
-		return;
-	}
+	/* first receiption with enabled throttling mode */
+	if (!op->kt_lastmsg.tv64)
+		goto rx_changed_settime;
 
+	/* got a second frame inside a potential throttle period? */
 	if (ktime_us_delta(ktime_get(), op->kt_lastmsg) <
 	    ktime_to_us(op->kt_ival2)) {
-		/* mark as 'throttled' and start timer */
-		lastdata->can_dlc |= RX_THR;
+		/* do not send the saved data - only start throttle timer */
 		hrtimer_start(&op->thrtimer,
 			      ktime_add(op->kt_lastmsg, op->kt_ival2),
 			      HRTIMER_MODE_ABS);
@@ -458,7 +462,8 @@ static void bcm_rx_update_and_send(struct bcm_op *op,
 	}
 
 	/* the gap was that big, that throttling was not needed here */
-	bcm_rx_changed(op, rxdata);
+rx_changed_settime:
+	bcm_rx_changed(op, lastdata);
 	op->kt_lastmsg = ktime_get();
 }
 
@@ -467,7 +472,7 @@ static void bcm_rx_update_and_send(struct bcm_op *op,
  *                       received data stored in op->last_frames[]
  */
 static void bcm_rx_cmp_to_index(struct bcm_op *op, int index,
-				struct can_frame *rxdata)
+				const struct can_frame *rxdata)
 {
 	/*
 	 * no one uses the MSBs of can_dlc for comparation,
@@ -511,14 +516,12 @@ static void bcm_rx_starttimer(struct bcm_op *op)
 		hrtimer_start(&op->timer, op->kt_ival1, HRTIMER_MODE_REL);
 }
 
-/*
- * bcm_rx_timeout_handler - when the (cyclic) CAN frame receiption timed out
- */
-static enum hrtimer_restart bcm_rx_timeout_handler(struct hrtimer *hrtimer)
+static void bcm_rx_timeout_tsklet(unsigned long data)
 {
-	struct bcm_op *op = container_of(hrtimer, struct bcm_op, timer);
+	struct bcm_op *op = (struct bcm_op *)data;
 	struct bcm_msg_head msg_head;
 
+	/* create notification to user */
 	msg_head.opcode  = RX_TIMEOUT;
 	msg_head.flags   = op->flags;
 	msg_head.count   = op->count;
@@ -528,6 +531,17 @@ static enum hrtimer_restart bcm_rx_timeout_handler(struct hrtimer *hrtimer)
 	msg_head.nframes = 0;
 
 	bcm_send_to_user(op, &msg_head, NULL, 0);
+}
+
+/*
+ * bcm_rx_timeout_handler - when the (cyclic) CAN frame receiption timed out
+ */
+static enum hrtimer_restart bcm_rx_timeout_handler(struct hrtimer *hrtimer)
+{
+	struct bcm_op *op = container_of(hrtimer, struct bcm_op, timer);
+
+	/* schedule before NET_RX_SOFTIRQ */
+	tasklet_hi_schedule(&op->tsklet);
 
 	/* no restart of the timer is done here! */
 
@@ -541,9 +555,25 @@ static enum hrtimer_restart bcm_rx_timeout_handler(struct hrtimer *hrtimer)
 }
 
 /*
+ * bcm_rx_do_flush - helper for bcm_rx_thr_flush
+ */
+static inline int bcm_rx_do_flush(struct bcm_op *op, int update, int index)
+{
+	if ((op->last_frames) && (op->last_frames[index].can_dlc & RX_THR)) {
+		if (update)
+			bcm_rx_changed(op, &op->last_frames[index]);
+		return 1;
+	}
+	return 0;
+}
+
+/*
  * bcm_rx_thr_flush - Check for throttled data and send it to the userspace
+ *
+ * update == 0 : just check if throttled data is available  (any irq context)
+ * update == 1 : check and send throttled data to userspace (soft_irq context)
  */
-static int bcm_rx_thr_flush(struct bcm_op *op)
+static int bcm_rx_thr_flush(struct bcm_op *op, int update)
 {
 	int updated = 0;
 
@@ -551,27 +581,25 @@ static int bcm_rx_thr_flush(struct bcm_op *op)
 		int i;
 
 		/* for MUX filter we start at index 1 */
-		for (i = 1; i < op->nframes; i++) {
-			if ((op->last_frames) &&
-			    (op->last_frames[i].can_dlc & RX_THR)) {
-				op->last_frames[i].can_dlc &= ~RX_THR;
-				bcm_rx_changed(op, &op->last_frames[i]);
-				updated++;
-			}
-		}
+		for (i = 1; i < op->nframes; i++)
+			updated += bcm_rx_do_flush(op, update, i);
 
 	} else {
 		/* for RX_FILTER_ID and simple filter */
-		if (op->last_frames && (op->last_frames[0].can_dlc & RX_THR)) {
-			op->last_frames[0].can_dlc &= ~RX_THR;
-			bcm_rx_changed(op, &op->last_frames[0]);
-			updated++;
-		}
+		updated += bcm_rx_do_flush(op, update, 0);
 	}
 
 	return updated;
 }
 
+static void bcm_rx_thr_tsklet(unsigned long data)
+{
+	struct bcm_op *op = (struct bcm_op *)data;
+
+	/* push the changed data to the userspace */
+	bcm_rx_thr_flush(op, 1);
+}
+
 /*
  * bcm_rx_thr_handler - the time for blocked content updates is over now:
  *                      Check for throttled data and send it to the userspace
@@ -580,7 +608,9 @@ static enum hrtimer_restart bcm_rx_thr_handler(struct hrtimer *hrtimer)
 {
 	struct bcm_op *op = container_of(hrtimer, struct bcm_op, thrtimer);
 
-	if (bcm_rx_thr_flush(op)) {
+	tasklet_schedule(&op->thrtsklet);
+
+	if (bcm_rx_thr_flush(op, 0)) {
 		hrtimer_forward(hrtimer, ktime_get(), op->kt_ival2);
 		return HRTIMER_RESTART;
 	} else {
@@ -596,48 +626,38 @@ static enum hrtimer_restart bcm_rx_thr_handler(struct hrtimer *hrtimer)
 static void bcm_rx_handler(struct sk_buff *skb, void *data)
 {
 	struct bcm_op *op = (struct bcm_op *)data;
-	struct can_frame rxframe;
+	const struct can_frame *rxframe = (struct can_frame *)skb->data;
 	int i;
 
 	/* disable timeout */
 	hrtimer_cancel(&op->timer);
 
-	if (skb->len == sizeof(rxframe)) {
-		memcpy(&rxframe, skb->data, sizeof(rxframe));
-		/* save rx timestamp */
-		op->rx_stamp = skb->tstamp;
-		/* save originator for recvfrom() */
-		op->rx_ifindex = skb->dev->ifindex;
-		/* update statistics */
-		op->frames_abs++;
-		kfree_skb(skb);
+	if (op->can_id != rxframe->can_id)
+		goto rx_freeskb;
 
-	} else {
-		kfree_skb(skb);
-		return;
-	}
-
-	if (op->can_id != rxframe.can_id)
-		return;
+	/* save rx timestamp */
+	op->rx_stamp = skb->tstamp;
+	/* save originator for recvfrom() */
+	op->rx_ifindex = skb->dev->ifindex;
+	/* update statistics */
+	op->frames_abs++;
 
 	if (op->flags & RX_RTR_FRAME) {
 		/* send reply for RTR-request (placed in op->frames[0]) */
 		bcm_can_tx(op);
-		return;
+		goto rx_freeskb;
 	}
 
 	if (op->flags & RX_FILTER_ID) {
 		/* the easiest case */
-		bcm_rx_update_and_send(op, &op->last_frames[0], &rxframe);
-		bcm_rx_starttimer(op);
-		return;
+		bcm_rx_update_and_send(op, &op->last_frames[0], rxframe);
+		goto rx_freeskb_starttimer;
 	}
 
 	if (op->nframes == 1) {
 		/* simple compare with index 0 */
-		bcm_rx_cmp_to_index(op, 0, &rxframe);
-		bcm_rx_starttimer(op);
-		return;
+		bcm_rx_cmp_to_index(op, 0, rxframe);
+		goto rx_freeskb_starttimer;
 	}
 
 	if (op->nframes > 1) {
@@ -649,15 +669,19 @@ static void bcm_rx_handler(struct sk_buff *skb, void *data)
 		 */
 
 		for (i = 1; i < op->nframes; i++) {
-			if ((GET_U64(&op->frames[0]) & GET_U64(&rxframe)) ==
+			if ((GET_U64(&op->frames[0]) & GET_U64(rxframe)) ==
 			    (GET_U64(&op->frames[0]) &
 			     GET_U64(&op->frames[i]))) {
-				bcm_rx_cmp_to_index(op, i, &rxframe);
+				bcm_rx_cmp_to_index(op, i, rxframe);
 				break;
 			}
 		}
-		bcm_rx_starttimer(op);
 	}
+
+rx_freeskb_starttimer:
+	bcm_rx_starttimer(op);
+rx_freeskb:
+	kfree_skb(skb);
 }
 
 /*
@@ -681,6 +705,12 @@ static void bcm_remove_op(struct bcm_op *op)
 	hrtimer_cancel(&op->timer);
 	hrtimer_cancel(&op->thrtimer);
 
+	if (op->tsklet.func)
+		tasklet_kill(&op->tsklet);
+
+	if (op->thrtsklet.func)
+		tasklet_kill(&op->thrtsklet);
+
 	if ((op->frames) && (op->frames != &op->sframe))
 		kfree(op->frames);
 
@@ -891,6 +921,10 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		hrtimer_init(&op->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 		op->timer.function = bcm_tx_timeout_handler;
 
+		/* initialize tasklet for tx countevent notification */
+		tasklet_init(&op->tsklet, bcm_tx_timeout_tsklet,
+			     (unsigned long) op);
+
 		/* currently unused in tx_ops */
 		hrtimer_init(&op->thrtimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 
@@ -1054,9 +1088,17 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		hrtimer_init(&op->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 		op->timer.function = bcm_rx_timeout_handler;
 
+		/* initialize tasklet for rx timeout notification */
+		tasklet_init(&op->tsklet, bcm_rx_timeout_tsklet,
+			     (unsigned long) op);
+
 		hrtimer_init(&op->thrtimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 		op->thrtimer.function = bcm_rx_thr_handler;
 
+		/* initialize tasklet for rx throttle handling */
+		tasklet_init(&op->thrtsklet, bcm_rx_thr_tsklet,
+			     (unsigned long) op);
+
 		/* add this bcm_op to the list of the rx_ops */
 		list_add(&op->list, &bo->rx_ops);
 
@@ -1102,7 +1144,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 			 */
 			op->kt_lastmsg = ktime_set(0, 0);
 			hrtimer_cancel(&op->thrtimer);
-			bcm_rx_thr_flush(op);
+			bcm_rx_thr_flush(op, 1);
 		}
 
 		if ((op->flags & STARTTIMER) && op->kt_ival1.tv64)

--------------020400050505030707030603--
