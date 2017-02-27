From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 12:18:31 -0800
Message-ID: <1488226711.9415.204.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35425 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751285AbdB0VSl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 16:18:41 -0500
Received: by mail-pg0-f67.google.com with SMTP id 1so2153663pgz.2
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 13:18:41 -0800 (PST)
In-Reply-To: <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While playing with mlx4 hardware timestamping of RX packets, I found
that some packets were received by TCP stack with a ~200 ms delay...

Since the timestamp was provided by the NIC, and my probe was added
in tcp_v4_rcv() while in BH handler, I was confident it was not
a sender issue, or a drop in the network.

This would happen with a very low probability, but hurting RPC
workloads.

A NAPI driver normally arms the IRQ after the napi_complete_done(),
after NAPI_STATE_SCHED is cleared, so that the hard irq handler can grab
it.

Problem is that if another point in the stack grabs NAPI_STATE_SCHED bit
while IRQ are not disabled, we might have later an IRQ firing and
finding this bit set, right before napi_complete_done() clears it.

This can happen with busy polling users, or if gro_flush_timeout is
used. But some other uses of napi_schedule() in drivers can cause this
as well.

thread 1                                 thread 2 (could be on same cpu)

// busy polling or napi_watchdog()
napi_schedule();
...
napi->poll()

device polling:
read 2 packets from ring buffer
                                          Additional 3rd packet is available.
                                          device hard irq

                                          // does nothing because NAPI_STATE_SCHED bit is owned by thread 1
                                          napi_schedule();
                                          
napi_complete_done(napi, 2);
rearm_irq();


Note that rearm_irq() will not force the device to send an additional
IRQ for the packet it already signaled (3rd packet in my example)



This patch adds a new NAPI_STATE_MISSED bit, that napi_schedule_prep()
can set if it could not grab NAPI_STATE_SCHED

Then napi_complete_done() properly reschedules the napi to make sure
we do not miss something.

Since we manipulate multiple bits at once, use cmpxchg() like in
sk_busy_loop() to provide proper transactions.

In v2, I changed napi_watchdog() to use a relaxed variant of
napi_schedule_prep() : No need to set NAPI_STATE_MISSED from this point.

In v3, I added more details in the changelog and clears
NAPI_STATE_MISSED in busy_poll_stop()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |   29 +++++-----------
 net/core/dev.c            |   63 +++++++++++++++++++++++++++++++++---
 2 files changed, 68 insertions(+), 24 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f40f0ab3847a8caaf46bd4d5f224c65014f501cc..97456b2539e46d6232dda804f6a434db6fd7134f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -330,6 +330,7 @@ struct napi_struct {
 
 enum {
 	NAPI_STATE_SCHED,	/* Poll is scheduled */
+	NAPI_STATE_MISSED,	/* reschedule a napi */
 	NAPI_STATE_DISABLE,	/* Disable pending */
 	NAPI_STATE_NPSVC,	/* Netpoll - don't dequeue from poll_list */
 	NAPI_STATE_HASHED,	/* In NAPI hash (busy polling possible) */
@@ -338,12 +339,13 @@ enum {
 };
 
 enum {
-	NAPIF_STATE_SCHED	 = (1UL << NAPI_STATE_SCHED),
-	NAPIF_STATE_DISABLE	 = (1UL << NAPI_STATE_DISABLE),
-	NAPIF_STATE_NPSVC	 = (1UL << NAPI_STATE_NPSVC),
-	NAPIF_STATE_HASHED	 = (1UL << NAPI_STATE_HASHED),
-	NAPIF_STATE_NO_BUSY_POLL = (1UL << NAPI_STATE_NO_BUSY_POLL),
-	NAPIF_STATE_IN_BUSY_POLL = (1UL << NAPI_STATE_IN_BUSY_POLL),
+	NAPIF_STATE_SCHED	 = BIT(NAPI_STATE_SCHED),
+	NAPIF_STATE_MISSED	 = BIT(NAPI_STATE_MISSED),
+	NAPIF_STATE_DISABLE	 = BIT(NAPI_STATE_DISABLE),
+	NAPIF_STATE_NPSVC	 = BIT(NAPI_STATE_NPSVC),
+	NAPIF_STATE_HASHED	 = BIT(NAPI_STATE_HASHED),
+	NAPIF_STATE_NO_BUSY_POLL = BIT(NAPI_STATE_NO_BUSY_POLL),
+	NAPIF_STATE_IN_BUSY_POLL = BIT(NAPI_STATE_IN_BUSY_POLL),
 };
 
 enum gro_result {
@@ -414,20 +416,7 @@ static inline bool napi_disable_pending(struct napi_struct *n)
 	return test_bit(NAPI_STATE_DISABLE, &n->state);
 }
 
-/**
- *	napi_schedule_prep - check if NAPI can be scheduled
- *	@n: NAPI context
- *
- * Test if NAPI routine is already running, and if not mark
- * it as running.  This is used as a condition variable to
- * insure only one NAPI poll instance runs.  We also make
- * sure there is no pending NAPI disable.
- */
-static inline bool napi_schedule_prep(struct napi_struct *n)
-{
-	return !napi_disable_pending(n) &&
-		!test_and_set_bit(NAPI_STATE_SCHED, &n->state);
-}
+bool napi_schedule_prep(struct napi_struct *n);
 
 /**
  *	napi_schedule - schedule NAPI poll
diff --git a/net/core/dev.c b/net/core/dev.c
index 304f2deae5f9897e60a79ed8b69d6ef208295ded..afcab3670aac18a9c193bf5a09e36e3dc9d0d63c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4884,6 +4884,32 @@ void __napi_schedule(struct napi_struct *n)
 EXPORT_SYMBOL(__napi_schedule);
 
 /**
+ *	napi_schedule_prep - check if napi can be scheduled
+ *	@n: napi context
+ *
+ * Test if NAPI routine is already running, and if not mark
+ * it as running.  This is used as a condition variable
+ * insure only one NAPI poll instance runs.  We also make
+ * sure there is no pending NAPI disable.
+ */
+bool napi_schedule_prep(struct napi_struct *n)
+{
+	unsigned long val, new;
+
+	do {
+		val = READ_ONCE(n->state);
+		if (unlikely(val & NAPIF_STATE_DISABLE))
+			return false;
+		new = val | NAPIF_STATE_SCHED;
+		if (unlikely(val & NAPIF_STATE_SCHED))
+			new |= NAPIF_STATE_MISSED;
+	} while (cmpxchg(&n->state, val, new) != val);
+
+	return !(val & NAPIF_STATE_SCHED);
+}
+EXPORT_SYMBOL(napi_schedule_prep);
+
+/**
  * __napi_schedule_irqoff - schedule for receive
  * @n: entry to schedule
  *
@@ -4897,7 +4923,7 @@ EXPORT_SYMBOL(__napi_schedule_irqoff);
 
 bool napi_complete_done(struct napi_struct *n, int work_done)
 {
-	unsigned long flags;
+	unsigned long flags, val, new;
 
 	/*
 	 * 1) Don't let napi dequeue from the cpu poll list
@@ -4927,7 +4953,21 @@ bool napi_complete_done(struct napi_struct *n, int work_done)
 		list_del_init(&n->poll_list);
 		local_irq_restore(flags);
 	}
-	WARN_ON_ONCE(!test_and_clear_bit(NAPI_STATE_SCHED, &n->state));
+
+	do {
+		val = READ_ONCE(n->state);
+
+		WARN_ON_ONCE(!(val & NAPIF_STATE_SCHED));
+
+		new = val & ~(NAPIF_STATE_MISSED | NAPIF_STATE_SCHED);
+
+		if (unlikely(val & NAPIF_STATE_MISSED))
+			new |= NAPIF_STATE_SCHED;
+	} while (cmpxchg(&n->state, val, new) != val);
+
+	if (unlikely(val & NAPIF_STATE_MISSED))
+		__napi_schedule(n);
+
 	return true;
 }
 EXPORT_SYMBOL(napi_complete_done);
@@ -4953,6 +4993,16 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
 {
 	int rc;
 
+	/* Busy polling means there is a high chance device driver hard irq
+	 * could not grab NAPI_STATE_SCHED, and that NAPI_STATE_MISSED was
+	 * set in napi_schedule_prep().
+	 * Since we are about to call napi->poll() once more, we can safely
+	 * clear NAPI_STATE_MISSED.
+	 *
+	 * Note: x86 could use a single "lock and ..." instruction
+	 * to perform these two clear_bit()
+	 */
+	clear_bit(NAPI_STATE_MISSED, &napi->state);
 	clear_bit(NAPI_STATE_IN_BUSY_POLL, &napi->state);
 
 	local_bh_disable();
@@ -5088,8 +5138,13 @@ static enum hrtimer_restart napi_watchdog(struct hrtimer *timer)
 	struct napi_struct *napi;
 
 	napi = container_of(timer, struct napi_struct, timer);
-	if (napi->gro_list)
-		napi_schedule_irqoff(napi);
+
+	/* Note : we use a relaxed variant of napi_schedule_prep() not setting
+	 * NAPI_STATE_MISSED, since we do not react to a device IRQ.
+	 */
+	if (napi->gro_list && !napi_disable_pending(napi) &&
+	    !test_and_set_bit(NAPI_STATE_SCHED, &napi->state))
+		__napi_schedule_irqoff(napi);
 
 	return HRTIMER_NORESTART;
 }
