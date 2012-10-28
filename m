From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next] pktgen: clean up ktime_t helpers
Date: Sun, 28 Oct 2012 19:27:19 +0100
Message-ID: <20121028182718.GA8275@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, tglx@linutronix.de,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:47581 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383Ab2J1S1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 14:27:23 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so5671187iea.19
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 11:27:22 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some years ago, the ktime_t helper functions ktime_now() and ktime_lt()
have been introduced. Instead of defining them inside pktgen.c, they
should either use ktime_t library functions or, if not available, they
should be defined in ktime.h, so that also others can benefit from them.
ktime_compare() is introduced with a similar notion as in timespec_compare().

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/ktime.h |   19 +++++++++++++++++++
 net/core/pktgen.c     |   41 +++++++++++++----------------------------
 2 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index 06177ba10..e83512f 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -282,6 +282,25 @@ static inline int ktime_equal(const ktime_t cmp1, const ktime_t cmp2)
 	return cmp1.tv64 == cmp2.tv64;
 }
 
+/**
+ * ktime_compare - Compares two ktime_t variables for less, greater or equal
+ * @cmp1:	comparable1
+ * @cmp2:	comparable2
+ *
+ * Returns ...
+ *   cmp1  < cmp2: return <0
+ *   cmp1 == cmp2: return 0
+ *   cmp1  > cmp2: return >0
+ */
+static inline int ktime_compare(const ktime_t cmp1, const ktime_t cmp2)
+{
+	if (cmp1.tv64 < cmp2.tv64)
+		return -1;
+	if (cmp1.tv64 > cmp2.tv64)
+		return 1;
+	return 0;
+}
+
 static inline s64 ktime_to_us(const ktime_t kt)
 {
 	struct timeval tv = ktime_to_timeval(kt);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1d1c216..b29dacf 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -419,20 +419,6 @@ struct pktgen_thread {
 #define REMOVE 1
 #define FIND   0
 
-static inline ktime_t ktime_now(void)
-{
-	struct timespec ts;
-	ktime_get_ts(&ts);
-
-	return timespec_to_ktime(ts);
-}
-
-/* This works even if 32 bit because of careful byte order choice */
-static inline int ktime_lt(const ktime_t cmp1, const ktime_t cmp2)
-{
-	return cmp1.tv64 < cmp2.tv64;
-}
-
 static const char version[] =
 	"Packet Generator for packet performance testing. "
 	"Version: " VERSION "\n";
@@ -675,7 +661,7 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\n");
 
 	/* not really stopped, more like last-running-at */
-	stopped = pkt_dev->running ? ktime_now() : pkt_dev->stopped_at;
+	stopped = pkt_dev->running ? ktime_get() : pkt_dev->stopped_at;
 	idle = pkt_dev->idle_acc;
 	do_div(idle, NSEC_PER_USEC);
 
@@ -2141,12 +2127,12 @@ static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 		return;
 	}
 
-	start_time = ktime_now();
+	start_time = ktime_get();
 	if (remaining < 100000) {
 		/* for small delays (<100us), just loop until limit is reached */
 		do {
-			end_time = ktime_now();
-		} while (ktime_lt(end_time, spin_until));
+			end_time = ktime_get();
+		} while (ktime_compare(end_time, spin_until) < 0);
 	} else {
 		/* see do_nanosleep */
 		hrtimer_init_sleeper(&t, current);
@@ -2162,7 +2148,7 @@ static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 			hrtimer_cancel(&t.timer);
 		} while (t.task && pkt_dev->running && !signal_pending(current));
 		__set_current_state(TASK_RUNNING);
-		end_time = ktime_now();
+		end_time = ktime_get();
 	}
 
 	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(end_time, start_time));
@@ -2912,8 +2898,7 @@ static void pktgen_run(struct pktgen_thread *t)
 			pktgen_clear_counters(pkt_dev);
 			pkt_dev->running = 1;	/* Cranke yeself! */
 			pkt_dev->skb = NULL;
-			pkt_dev->started_at =
-				pkt_dev->next_tx = ktime_now();
+			pkt_dev->started_at = pkt_dev->next_tx = ktime_get();
 
 			set_pkt_overhead(pkt_dev);
 
@@ -3072,7 +3057,7 @@ static int pktgen_stop_device(struct pktgen_dev *pkt_dev)
 
 	kfree_skb(pkt_dev->skb);
 	pkt_dev->skb = NULL;
-	pkt_dev->stopped_at = ktime_now();
+	pkt_dev->stopped_at = ktime_get();
 	pkt_dev->running = 0;
 
 	show_results(pkt_dev, nr_frags);
@@ -3091,7 +3076,7 @@ static struct pktgen_dev *next_to_run(struct pktgen_thread *t)
 			continue;
 		if (best == NULL)
 			best = pkt_dev;
-		else if (ktime_lt(pkt_dev->next_tx, best->next_tx))
+		else if (ktime_compare(pkt_dev->next_tx, best->next_tx) < 0)
 			best = pkt_dev;
 	}
 	if_unlock(t);
@@ -3176,14 +3161,14 @@ static void pktgen_rem_thread(struct pktgen_thread *t)
 
 static void pktgen_resched(struct pktgen_dev *pkt_dev)
 {
-	ktime_t idle_start = ktime_now();
+	ktime_t idle_start = ktime_get();
 	schedule();
-	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(), idle_start));
+	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_get(), idle_start));
 }
 
 static void pktgen_wait_for_skb(struct pktgen_dev *pkt_dev)
 {
-	ktime_t idle_start = ktime_now();
+	ktime_t idle_start = ktime_get();
 
 	while (atomic_read(&(pkt_dev->skb->users)) != 1) {
 		if (signal_pending(current))
@@ -3194,7 +3179,7 @@ static void pktgen_wait_for_skb(struct pktgen_dev *pkt_dev)
 		else
 			cpu_relax();
 	}
-	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(), idle_start));
+	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_get(), idle_start));
 }
 
 static void pktgen_xmit(struct pktgen_dev *pkt_dev)
@@ -3216,7 +3201,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	 * "never transmit"
 	 */
 	if (unlikely(pkt_dev->delay == ULLONG_MAX)) {
-		pkt_dev->next_tx = ktime_add_ns(ktime_now(), ULONG_MAX);
+		pkt_dev->next_tx = ktime_add_ns(ktime_get(), ULONG_MAX);
 		return;
 	}
 
