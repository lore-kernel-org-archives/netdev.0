From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from
 softirq to workqueue
Date: Fri, 16 Nov 2007 17:40:27 +0100
Message-ID: <20071116174027.726e6eca.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:48082 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752619AbXKPQk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 11:40:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David

This patch against net-2.6.25 is another step to get a more resistant ip route cache.

Thank you

[PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from softirq to workqueue

Every 600 seconds (ip_rt_secret_interval), a softirq flush of the whole
ip route cache is triggered. On loaded machines, this can starve softirq for
many seconds and can eventually crash.

This patch moves this flush to a workqueue context, using the worker we
intoduced in commit 39c90ece7565f5c47110c2fa77409d7a9478bd5b
(IPV4: Convert rt_check_expire() from softirq processing to workqueue.)

Also, immediate flushes (echo 0 >/proc/sys/net/ipv4/route/flush) are using
rt_do_flush() helper function, wich take attention to rescheduling.

Next step will be to handle delayed flushes 
("echo -1 >/proc/sys/net/ipv4/route/flush"  or
"ip route flush cache")

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 net/ipv4/route.c |   89 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 65 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 856807c..5d74620 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -133,13 +133,14 @@ static int ip_rt_mtu_expires		= 10 * 60 * HZ;
 static int ip_rt_min_pmtu		= 512 + 20 + 20;
 static int ip_rt_min_advmss		= 256;
 static int ip_rt_secret_interval	= 10 * 60 * HZ;
+static int ip_rt_flush_expected;
 static unsigned long rt_deadline;
 
 #define RTprint(a...)	printk(KERN_DEBUG a)
 
 static struct timer_list rt_flush_timer;
-static void rt_check_expire(struct work_struct *work);
-static DECLARE_DELAYED_WORK(expires_work, rt_check_expire);
+static void rt_worker_func(struct work_struct *work);
+static DECLARE_DELAYED_WORK(expires_work, rt_worker_func);
 static struct timer_list rt_secret_timer;
 
 /*
@@ -561,7 +562,42 @@ static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 		(fl1->iif ^ fl2->iif)) == 0;
 }
 
-static void rt_check_expire(struct work_struct *work)
+/*
+ * Perform a full scan of hash table and free all entries.
+ * Can be called by a softirq or a process.
+ * In the later case, we want to be reschedule if necessary
+ */
+static void rt_do_flush(int process_context)
+{
+	unsigned int i;
+	struct rtable *rth, *next;
+	unsigned long fake = 0, *flag_ptr;
+
+	flag_ptr = process_context ? &current_thread_info()->flags : &fake;
+
+	for (i = 0; i <= rt_hash_mask; i++) {
+		rth = rt_hash_table[i].chain;
+		if (rth) {
+			spin_lock_bh(rt_hash_lock_addr(i));
+			rth = rt_hash_table[i].chain;
+			rt_hash_table[i].chain = NULL;
+			spin_unlock_bh(rt_hash_lock_addr(i));
+		}
+		/*
+		 * This is a fast version of :
+		 * if (process_context && need_resched())
+		 */
+		if (unlikely(test_bit(TIF_NEED_RESCHED, flag_ptr)))
+			cond_resched();
+
+		for (; rth; rth = next) {
+			next = rth->u.dst.rt_next;
+			rt_free(rth);
+		}
+	}
+}
+
+static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i = rover, goal;
@@ -607,33 +643,33 @@ static void rt_check_expire(struct work_struct *work)
 		spin_unlock_bh(rt_hash_lock_addr(i));
 	}
 	rover = i;
+}
+
+/*
+ * rt_worker_func() is run in process context.
+ * If a whole flush was scheduled, it is done.
+ * Else, we call rt_check_expire() to scan part of the hash table
+ */
+static void rt_worker_func(struct work_struct *work)
+{
+	if (ip_rt_flush_expected) {
+		ip_rt_flush_expected = 0;
+		rt_do_flush(1);
+	} else
+		rt_check_expire();
 	schedule_delayed_work(&expires_work, ip_rt_gc_interval);
 }
 
 /* This can run from both BH and non-BH contexts, the latter
  * in the case of a forced flush event.
  */
-static void rt_run_flush(unsigned long dummy)
+static void rt_run_flush(unsigned long process_context)
 {
-	int i;
-	struct rtable *rth, *next;
-
 	rt_deadline = 0;
 
 	get_random_bytes(&rt_hash_rnd, 4);
 
-	for (i = rt_hash_mask; i >= 0; i--) {
-		spin_lock_bh(rt_hash_lock_addr(i));
-		rth = rt_hash_table[i].chain;
-		if (rth)
-			rt_hash_table[i].chain = NULL;
-		spin_unlock_bh(rt_hash_lock_addr(i));
-
-		for (; rth; rth = next) {
-			next = rth->u.dst.rt_next;
-			rt_free(rth);
-		}
-	}
+	rt_do_flush(process_context);
 }
 
 static DEFINE_SPINLOCK(rt_flush_lock);
@@ -667,7 +703,7 @@ void rt_cache_flush(int delay)
 
 	if (delay <= 0) {
 		spin_unlock_bh(&rt_flush_lock);
-		rt_run_flush(0);
+		rt_run_flush(user_mode);
 		return;
 	}
 
@@ -678,12 +714,17 @@ void rt_cache_flush(int delay)
 	spin_unlock_bh(&rt_flush_lock);
 }
 
+/*
+ * We change rt_hash_rnd and ask next rt_worker_func() invocation
+ * to perform a flush in process context
+ */
 static void rt_secret_rebuild(unsigned long dummy)
 {
-	unsigned long now = jiffies;
-
-	rt_cache_flush(0);
-	mod_timer(&rt_secret_timer, now + ip_rt_secret_interval);
+	get_random_bytes(&rt_hash_rnd, 4);
+	ip_rt_flush_expected = 1;
+	cancel_delayed_work(&expires_work);
+	schedule_delayed_work(&expires_work, HZ/10);
+	mod_timer(&rt_secret_timer, jiffies + ip_rt_secret_interval);
 }
 
 /*
