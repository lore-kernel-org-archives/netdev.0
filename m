From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-2.6.26] CAN: use hrtimers in can-bcm protocol
Date: Tue, 15 Apr 2008 22:29:30 +0200
Message-ID: <4805102A.8030707@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000105050400060509000504"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Patrick McHardy <kaber@trash.net>,
	Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:35982 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932134AbYDOU3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 16:29:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000105050400060509000504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

From: Oliver Hartkopp <oliver@hartkopp.net>

Make use of hrtimers to support high resolution capabilities, when 
provided by the system clocksource.

The conversion to hrtimers additionally discovered and solved an 
unlikely race condition that has been reproduced under (unrealistic) 
massive receive load, which can only be produced on vcan software devices.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

---
 net/can/bcm.c |  249 
+++++++++++++++++++++++++++++++++---------------------------------
 1 file changed, 128 insertions(+), 121 deletions(-)





--------------000105050400060509000504
Content-Type: text/x-diff;
 name="bcm-hrtimer.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bcm-hrtimer.patch"

diff --git a/net/can/bcm.c b/net/can/bcm.c
index e9f99b2..a41ac3d 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -43,6 +43,7 @@
 
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/hrtimer.h>
 #include <linux/list.h>
 #include <linux/proc_fs.h>
 #include <linux/uio.h>
@@ -66,7 +67,7 @@
 #define REGMASK(id) ((id & CAN_RTR_FLAG) | ((id & CAN_EFF_FLAG) ? \
 			(CAN_EFF_MASK | CAN_EFF_FLAG) : CAN_SFF_MASK))
 
-#define CAN_BCM_VERSION CAN_VERSION
+#define CAN_BCM_VERSION "20080415"
 static __initdata const char banner[] = KERN_INFO
 	"can: broadcast manager protocol (rev " CAN_BCM_VERSION ")\n";
 
@@ -85,11 +86,10 @@ struct bcm_op {
 	int ifindex;
 	canid_t can_id;
 	int flags;
-	unsigned long j_ival1, j_ival2, j_lastmsg;
 	unsigned long frames_abs, frames_filtered;
-	struct timer_list timer, thrtimer;
 	struct timeval ival1, ival2;
-	ktime_t rx_stamp;
+	struct hrtimer timer, thrtimer;
+	ktime_t rx_stamp, kt_ival1, kt_ival2, kt_lastmsg;
 	int rx_ifindex;
 	int count;
 	int nframes;
@@ -126,39 +126,6 @@ static inline struct bcm_sock *bcm_sk(const struct sock *sk)
 #define MHSIZ sizeof(struct bcm_msg_head)
 
 /*
- * rounded_tv2jif - calculate jiffies from timeval including optional up
- * @tv: pointer to timeval
- *
- * Description:
- * Unlike timeval_to_jiffies() provided in include/linux/jiffies.h, this
- * function is intentionally more relaxed on precise timer ticks to get
- * exact one jiffy for requested 1000us on a 1000HZ machine.
- * This code is to be removed when upgrading to kernel hrtimer.
- *
- * Return:
- *  calculated jiffies (max: ULONG_MAX)
- */
-static unsigned long rounded_tv2jif(const struct timeval *tv)
-{
-	unsigned long sec  = tv->tv_sec;
-	unsigned long usec = tv->tv_usec;
-	unsigned long jif;
-
-	if (sec > ULONG_MAX / HZ)
-		return ULONG_MAX;
-
-	/* round up to get at least the requested time */
-	usec += 1000000 / HZ - 1;
-
-	jif  = usec / (1000000 / HZ);
-
-	if (sec * HZ > ULONG_MAX - jif)
-		return ULONG_MAX;
-
-	return jif + sec * HZ;
-}
-
-/*
  * procfs functions
  */
 static char *bcm_proc_getifname(int ifindex)
@@ -208,13 +175,15 @@ static int bcm_read_proc(char *page, char **start, off_t off,
 		len += snprintf(page + len, PAGE_SIZE - len, "[%d]%c ",
 				op->nframes,
 				(op->flags & RX_CHECK_DLC)?'d':' ');
-		if (op->j_ival1)
+		if (op->kt_ival1.tv64)
 			len += snprintf(page + len, PAGE_SIZE - len,
-					"timeo=%ld ", op->j_ival1);
+					"timeo=%lld ",
+					ktime_to_us(op->kt_ival1));
 
-		if (op->j_ival2)
+		if (op->kt_ival2.tv64)
 			len += snprintf(page + len, PAGE_SIZE - len,
-					"thr=%ld ", op->j_ival2);
+					"thr=%lld ",
+					ktime_to_us(op->kt_ival2));
 
 		len += snprintf(page + len, PAGE_SIZE - len,
 				"# recv %ld (%ld) => reduction: ",
@@ -238,13 +207,14 @@ static int bcm_read_proc(char *page, char **start, off_t off,
 				"tx_op: %03X %s [%d] ",
 				op->can_id, bcm_proc_getifname(op->ifindex),
 				op->nframes);
-		if (op->j_ival1)
-			len += snprintf(page + len, PAGE_SIZE - len, "t1=%ld ",
-					op->j_ival1);
 
-		if (op->j_ival2)
-			len += snprintf(page + len, PAGE_SIZE - len, "t2=%ld ",
-					op->j_ival2);
+		if (op->kt_ival1.tv64)
+			len += snprintf(page + len, PAGE_SIZE - len, "t1=%lld ",
+					ktime_to_us(op->kt_ival1));
+
+		if (op->kt_ival2.tv64)
+			len += snprintf(page + len, PAGE_SIZE - len, "t2=%lld ",
+					ktime_to_us(op->kt_ival2));
 
 		len += snprintf(page + len, PAGE_SIZE - len, "# sent %ld\n",
 				op->frames_abs);
@@ -371,11 +341,12 @@ static void bcm_send_to_user(struct bcm_op *op, struct bcm_msg_head *head,
 /*
  * bcm_tx_timeout_handler - performes cyclic CAN frame transmissions
  */
-static void bcm_tx_timeout_handler(unsigned long data)
+static enum hrtimer_restart bcm_tx_timeout_handler(struct hrtimer *hrtimer)
 {
-	struct bcm_op *op = (struct bcm_op *)data;
+	struct bcm_op *op = container_of(hrtimer, struct bcm_op, timer);
+	enum hrtimer_restart ret = HRTIMER_NORESTART;
 
-	if (op->j_ival1 && (op->count > 0)) {
+	if (op->kt_ival1.tv64 && (op->count > 0)) {
 
 		op->count--;
 		if (!op->count && (op->flags & TX_COUNTEVT)) {
@@ -394,22 +365,24 @@ static void bcm_tx_timeout_handler(unsigned long data)
 		}
 	}
 
-	if (op->j_ival1 && (op->count > 0)) {
+	if (op->kt_ival1.tv64 && (op->count > 0)) {
 
 		/* send (next) frame */
 		bcm_can_tx(op);
-		mod_timer(&op->timer, jiffies + op->j_ival1);
+		hrtimer_forward(hrtimer, ktime_get(), op->kt_ival1);
+		ret = HRTIMER_RESTART;
 
 	} else {
-		if (op->j_ival2) {
+		if (op->kt_ival2.tv64) {
 
 			/* send (next) frame */
 			bcm_can_tx(op);
-			mod_timer(&op->timer, jiffies + op->j_ival2);
+			hrtimer_forward(hrtimer, ktime_get(), op->kt_ival2);
+			ret = HRTIMER_RESTART;
 		}
 	}
 
-	return;
+	return ret;
 }
 
 /*
@@ -419,8 +392,6 @@ static void bcm_rx_changed(struct bcm_op *op, struct can_frame *data)
 {
 	struct bcm_msg_head head;
 
-	op->j_lastmsg = jiffies;
-
 	/* update statistics */
 	op->frames_filtered++;
 
@@ -439,6 +410,12 @@ static void bcm_rx_changed(struct bcm_op *op, struct can_frame *data)
 	bcm_send_to_user(op, &head, data, 1);
 }
 
+/* TODO: move to linux/hrtimer.h */
+static inline int hrtimer_callback_running(struct hrtimer *timer)
+{
+        return timer->state & HRTIMER_STATE_CALLBACK;
+}
+
 /*
  * bcm_rx_update_and_send - process a detected relevant receive content change
  *                          1. update the last received data
@@ -448,30 +425,44 @@ static void bcm_rx_update_and_send(struct bcm_op *op,
 				   struct can_frame *lastdata,
 				   struct can_frame *rxdata)
 {
-	unsigned long nexttx = op->j_lastmsg + op->j_ival2;
-
 	memcpy(lastdata, rxdata, CFSIZ);
 
 	/* mark as used */
 	lastdata->can_dlc |= RX_RECV;
 
-	/* throttle bcm_rx_changed ? */
-	if ((op->thrtimer.expires) ||
-	    ((op->j_ival2) && (nexttx > jiffies))) {
-		/* we are already waiting OR we have to start waiting */
+	/* throtteling mode inactive OR data update already on the run ? */
+	if (!op->kt_ival2.tv64 || hrtimer_callback_running(&op->thrtimer)) {
+		/* send RX_CHANGED to the user immediately */
+		bcm_rx_changed(op, rxdata);
+		return;
+	}
 
+	if (hrtimer_active(&op->thrtimer)) {
 		/* mark as 'throttled' */
 		lastdata->can_dlc |= RX_THR;
+		return;
+	}
 
-		if (!(op->thrtimer.expires)) {
-			/* start the timer only the first time */
-			mod_timer(&op->thrtimer, nexttx);
-		}
-
-	} else {
-		/* send RX_CHANGED to the user immediately */
+	if (!op->kt_lastmsg.tv64) {
+		/* send first RX_CHANGED to the user immediately */
 		bcm_rx_changed(op, rxdata);
+		op->kt_lastmsg = ktime_get();
+		return;
+	}
+
+	if (ktime_us_delta(ktime_get(), op->kt_lastmsg) <
+	    ktime_to_us(op->kt_ival2)) {
+		/* mark as 'throttled' and start timer */
+		lastdata->can_dlc |= RX_THR;
+		hrtimer_start(&op->thrtimer,
+			      ktime_add(op->kt_lastmsg, op->kt_ival2),
+			      HRTIMER_MODE_ABS);
+		return;
 	}
+
+	/* the gap was that big, that throttling was not needed here */
+	bcm_rx_changed(op, rxdata);
+	op->kt_lastmsg = ktime_get();
 }
 
 /*
@@ -519,16 +510,16 @@ static void bcm_rx_starttimer(struct bcm_op *op)
 	if (op->flags & RX_NO_AUTOTIMER)
 		return;
 
-	if (op->j_ival1)
-		mod_timer(&op->timer, jiffies + op->j_ival1);
+	if (op->kt_ival1.tv64)
+		hrtimer_start(&op->timer, op->kt_ival1, HRTIMER_MODE_REL);
 }
 
 /*
  * bcm_rx_timeout_handler - when the (cyclic) CAN frame receiption timed out
  */
-static void bcm_rx_timeout_handler(unsigned long data)
+static enum hrtimer_restart bcm_rx_timeout_handler(struct hrtimer *hrtimer)
 {
-	struct bcm_op *op = (struct bcm_op *)data;
+	struct bcm_op *op = container_of(hrtimer, struct bcm_op, timer);
 	struct bcm_msg_head msg_head;
 
 	msg_head.opcode  = RX_TIMEOUT;
@@ -548,27 +539,27 @@ static void bcm_rx_timeout_handler(unsigned long data)
 		/* clear received can_frames to indicate 'nothing received' */
 		memset(op->last_frames, 0, op->nframes * CFSIZ);
 	}
+
+	return HRTIMER_NORESTART;
 }
 
 /*
- * bcm_rx_thr_handler - the time for blocked content updates is over now:
- *                      Check for throttled data and send it to the userspace
+ * bcm_rx_thr_flush - Check for throttled data and send it to the userspace
  */
-static void bcm_rx_thr_handler(unsigned long data)
+static int bcm_rx_thr_flush(struct bcm_op *op)
 {
-	struct bcm_op *op = (struct bcm_op *)data;
-	int i = 0;
-
-	/* mark disabled / consumed timer */
-	op->thrtimer.expires = 0;
+	int updated = 0;
 
 	if (op->nframes > 1) {
+		int i;
+
 		/* for MUX filter we start at index 1 */
 		for (i = 1; i < op->nframes; i++) {
 			if ((op->last_frames) &&
 			    (op->last_frames[i].can_dlc & RX_THR)) {
 				op->last_frames[i].can_dlc &= ~RX_THR;
 				bcm_rx_changed(op, &op->last_frames[i]);
+				updated++;
 			}
 		}
 
@@ -577,8 +568,29 @@ static void bcm_rx_thr_handler(unsigned long data)
 		if (op->last_frames && (op->last_frames[0].can_dlc & RX_THR)) {
 			op->last_frames[0].can_dlc &= ~RX_THR;
 			bcm_rx_changed(op, &op->last_frames[0]);
+			updated++;
 		}
 	}
+
+	return updated;
+}
+
+/*
+ * bcm_rx_thr_handler - the time for blocked content updates is over now:
+ *                      Check for throttled data and send it to the userspace
+ */
+static enum hrtimer_restart bcm_rx_thr_handler(struct hrtimer *hrtimer)
+{
+	struct bcm_op *op = container_of(hrtimer, struct bcm_op, thrtimer);
+
+	if (bcm_rx_thr_flush(op)) {
+		hrtimer_forward(hrtimer, ktime_get(), op->kt_ival2);
+		return HRTIMER_RESTART;
+	} else {
+		/* rearm throttle handling */
+		op->kt_lastmsg = ktime_set(0, 0);
+		return HRTIMER_NORESTART;
+	}
 }
 
 /*
@@ -591,7 +603,7 @@ static void bcm_rx_handler(struct sk_buff *skb, void *data)
 	int i;
 
 	/* disable timeout */
-	del_timer(&op->timer);
+	hrtimer_cancel(&op->timer);
 
 	if (skb->len == sizeof(rxframe)) {
 		memcpy(&rxframe, skb->data, sizeof(rxframe));
@@ -669,8 +681,8 @@ static struct bcm_op *bcm_find_op(struct list_head *ops, canid_t can_id,
 
 static void bcm_remove_op(struct bcm_op *op)
 {
-	del_timer(&op->timer);
-	del_timer(&op->thrtimer);
+	hrtimer_cancel(&op->timer);
+	hrtimer_cancel(&op->thrtimer);
 
 	if ((op->frames) && (op->frames != &op->sframe))
 		kfree(op->frames);
@@ -871,11 +883,11 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		op->ifindex = ifindex;
 
 		/* initialize uninitialized (kzalloc) structure */
-		setup_timer(&op->timer, bcm_tx_timeout_handler,
-			    (unsigned long)op);
+		hrtimer_init(&op->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+		op->timer.function = bcm_tx_timeout_handler;
 
 		/* currently unused in tx_ops */
-		init_timer(&op->thrtimer);
+		hrtimer_init(&op->thrtimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
 
 		/* add this bcm_op to the list of the tx_ops */
 		list_add(&op->list, &bo->tx_ops);
@@ -902,25 +914,27 @@ static int bcm_tx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		op->count = msg_head->count;
 		op->ival1 = msg_head->ival1;
 		op->ival2 = msg_head->ival2;
-		op->j_ival1 = rounded_tv2jif(&msg_head->ival1);
-		op->j_ival2 = rounded_tv2jif(&msg_head->ival2);
+		op->kt_ival1 = timeval_to_ktime(msg_head->ival1);
+		op->kt_ival2 = timeval_to_ktime(msg_head->ival2);
 
 		/* disable an active timer due to zero values? */
-		if (!op->j_ival1 && !op->j_ival2)
-			del_timer(&op->timer);
+		if (!op->kt_ival1.tv64 && !op->kt_ival2.tv64)
+			hrtimer_cancel(&op->timer);
 	}
 
 	if ((op->flags & STARTTIMER) &&
-	    ((op->j_ival1 && op->count) || op->j_ival2)) {
+	    ((op->kt_ival1.tv64 && op->count) || op->kt_ival2.tv64)) {
 
 		/* spec: send can_frame when starting timer */
 		op->flags |= TX_ANNOUNCE;
 
-		if (op->j_ival1 && (op->count > 0)) {
+		if (op->kt_ival1.tv64 && (op->count > 0)) {
 			/* op->count-- is done in bcm_tx_timeout_handler */
-			mod_timer(&op->timer, jiffies + op->j_ival1);
+			hrtimer_start(&op->timer, op->kt_ival1,
+				      HRTIMER_MODE_REL);
 		} else
-			mod_timer(&op->timer, jiffies + op->j_ival2);
+			hrtimer_start(&op->timer, op->kt_ival2,
+				      HRTIMER_MODE_REL);
 	}
 
 	if (op->flags & TX_ANNOUNCE)
@@ -1032,15 +1046,11 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 		op->ifindex = ifindex;
 
 		/* initialize uninitialized (kzalloc) structure */
-		setup_timer(&op->timer, bcm_rx_timeout_handler,
-			    (unsigned long)op);
+		hrtimer_init(&op->timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+		op->timer.function = bcm_rx_timeout_handler;
 
-		/* init throttle timer for RX_CHANGED */
-		setup_timer(&op->thrtimer, bcm_rx_thr_handler,
-			    (unsigned long)op);
-
-		/* mark disabled timer */
-		op->thrtimer.expires = 0;
+		hrtimer_init(&op->thrtimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+		op->thrtimer.function = bcm_rx_thr_handler;
 
 		/* add this bcm_op to the list of the rx_ops */
 		list_add(&op->list, &bo->rx_ops);
@@ -1056,8 +1066,8 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 	if (op->flags & RX_RTR_FRAME) {
 
 		/* no timers in RTR-mode */
-		del_timer(&op->thrtimer);
-		del_timer(&op->timer);
+		hrtimer_cancel(&op->thrtimer);
+		hrtimer_cancel(&op->timer);
 
 		/*
 		 * funny feature in RX(!)_SETUP only for RTR-mode:
@@ -1074,28 +1084,25 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
 			/* set timer value */
 			op->ival1 = msg_head->ival1;
 			op->ival2 = msg_head->ival2;
-			op->j_ival1 = rounded_tv2jif(&msg_head->ival1);
-			op->j_ival2 = rounded_tv2jif(&msg_head->ival2);
+			op->kt_ival1 = timeval_to_ktime(msg_head->ival1);
+			op->kt_ival2 = timeval_to_ktime(msg_head->ival2);
 
 			/* disable an active timer due to zero value? */
-			if (!op->j_ival1)
-				del_timer(&op->timer);
-
-			/* free currently blocked msgs ? */
-			if (op->thrtimer.expires) {
-				/* send blocked msgs hereafter */
-				mod_timer(&op->thrtimer, jiffies + 2);
-			}
+			if (!op->kt_ival1.tv64)
+				hrtimer_cancel(&op->timer);
 
 			/*
-			 * if (op->j_ival2) is zero, no (new) throttling
-			 * will happen. For details see functions
-			 * bcm_rx_update_and_send() and bcm_rx_thr_handler()
+			 * In any case cancel the throttle timer, flush
+			 * potentially blocked msgs and reset throttle handling
 			 */
+			op->kt_lastmsg = ktime_set(0, 0);
+			hrtimer_cancel(&op->thrtimer);
+			bcm_rx_thr_flush(op);
 		}
 
-		if ((op->flags & STARTTIMER) && op->j_ival1)
-			mod_timer(&op->timer, jiffies + op->j_ival1);
+		if ((op->flags & STARTTIMER) && op->kt_ival1.tv64)
+			hrtimer_start(&op->timer, op->kt_ival1,
+				      HRTIMER_MODE_REL);
 	}
 
 	/* now we can register for can_ids, if we added a new bcm_op */

--------------000105050400060509000504--
