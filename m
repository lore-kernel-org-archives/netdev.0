From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFT 2/4] Add mod_timer_noact
Date: Tue, 17 Feb 2009 21:19:08 -0800
Message-ID: <20090218052747.437271195@vyatta.com>
References: <20090218051906.174295181@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	tglx@linutronix.de, Martin Josefsson <gandalf@wlug.westbo.se>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=mod_timer_noact.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce mod_timer_noact() which for example is to replace the calls to
del_timer()/add_timer() in __nf_ct_refresh_acct(). It works like mod_timer()
but doesn't activate or modify the timeout of an inactive timer which is the
behaviour we want in order to be able to use timers as a means of
synchronization in nf_conntrack.

A later patch will modify __nf_ct_refresh_acct() to use mod_timer_noact()
which will then save one spin_lock_irqsave() / spin_lock_irqrestore() pair per
conntrack timer update. This will also get rid of the race we currently have
without adding more locking in nf_conntrack.

Signed-off-by: Martin Josefsson <gandalf@wlug.westbo.se>

---
 include/linux/timer.h |    8 ++++++--
 kernel/relay.c        |    2 +-
 kernel/timer.c        |   40 +++++++++++++++++++++++++++++++++++-----
 3 files changed, 42 insertions(+), 8 deletions(-)

--- a/include/linux/timer.h	2009-02-17 10:55:33.427785986 -0800
+++ b/include/linux/timer.h	2009-02-17 11:04:10.291844534 -0800
@@ -25,6 +25,9 @@ struct timer_list {
 
 extern struct tvec_base boot_tvec_bases;
 
+#define TIMER_ACT	1
+#define TIMER_NOACT	0
+
 #define TIMER_INITIALIZER(_function, _expires, _data) {		\
 		.entry = { .prev = TIMER_ENTRY_STATIC },	\
 		.function = (_function),			\
@@ -86,8 +89,9 @@ static inline int timer_pending(const st
 
 extern void add_timer_on(struct timer_list *timer, int cpu);
 extern int del_timer(struct timer_list * timer);
-extern int __mod_timer(struct timer_list *timer, unsigned long expires);
+extern int __mod_timer(struct timer_list *timer, unsigned long expires, int activate);
 extern int mod_timer(struct timer_list *timer, unsigned long expires);
+extern int mod_timer_noact(struct timer_list *timer, unsigned long expires);
 
 /*
  * The jiffies value which is added to now, when there is no timer
@@ -163,7 +167,7 @@ static inline void timer_stats_timer_cle
 static inline void add_timer(struct timer_list *timer)
 {
 	BUG_ON(timer_pending(timer));
-	__mod_timer(timer, timer->expires);
+	__mod_timer(timer, timer->expires, TIMER_ACT);
 }
 
 #ifdef CONFIG_SMP
--- a/kernel/timer.c	2009-02-17 10:55:33.403580297 -0800
+++ b/kernel/timer.c	2009-02-17 11:04:10.291844534 -0800
@@ -589,7 +589,7 @@ static struct tvec_base *lock_timer_base
 	}
 }
 
-int __mod_timer(struct timer_list *timer, unsigned long expires)
+int __mod_timer(struct timer_list *timer, unsigned long expires, int activate)
 {
 	struct tvec_base *base, *new_base;
 	unsigned long flags;
@@ -603,7 +603,8 @@ int __mod_timer(struct timer_list *timer
 	if (timer_pending(timer)) {
 		detach_timer(timer, 0);
 		ret = 1;
-	}
+	} else if (activate == TIMER_NOACT)
+		goto out_unlock;
 
 	debug_timer_activate(timer);
 
@@ -629,8 +630,9 @@ int __mod_timer(struct timer_list *timer
 
 	timer->expires = expires;
 	internal_add_timer(base, timer);
-	spin_unlock_irqrestore(&base->lock, flags);
 
+out_unlock:
+	spin_unlock_irqrestore(&base->lock, flags);
 	return ret;
 }
 
@@ -699,11 +701,39 @@ int mod_timer(struct timer_list *timer, 
 	if (timer->expires == expires && timer_pending(timer))
 		return 1;
 
-	return __mod_timer(timer, expires);
+	return __mod_timer(timer, expires, TIMER_ACT);
 }
 
 EXPORT_SYMBOL(mod_timer);
 
+/***
+ * mod_timer_noact - modify a timer's timeout
+ * @timer: the timer to be modified
+ *
+ * mod_timer_noact works like mod_timer except that it doesn't activate an
+ * inactive timer, instead it returns without updating timer->expires.
+ *
+ * The function returns whether it has modified a pending timer or not.
+ * (ie. mod_timer_noact() of an inactive timer returns 0, mod_timer_noact() of
+ * an active timer returns 1.)
+ */
+int mod_timer_noact(struct timer_list *timer, unsigned long expires)
+{
+	BUG_ON(!timer->function);
+
+	/*
+	 * This is a common optimization triggered by the
+	 * networking code - if the timer is re-modified
+	 * to be the same thing then just return:
+	 */
+	if (timer->expires == expires && timer_pending(timer))
+		return 1;
+
+	return __mod_timer(timer, expires, TIMER_NOACT);
+}
+
+EXPORT_SYMBOL(mod_timer_noact);
+
 /**
  * del_timer - deactive a timer.
  * @timer: the timer to be deactivated
@@ -1268,7 +1298,7 @@ signed long __sched schedule_timeout(sig
 	expire = timeout + jiffies;
 
 	setup_timer_on_stack(&timer, process_timeout, (unsigned long)current);
-	__mod_timer(&timer, expire);
+	__mod_timer(&timer, expire, TIMER_ACT);
 	schedule();
 	del_singleshot_timer_sync(&timer);
 
--- a/kernel/relay.c	2009-02-17 10:55:33.416279439 -0800
+++ b/kernel/relay.c	2009-02-17 11:04:10.291844534 -0800
@@ -750,7 +750,7 @@ size_t relay_switch_subbuf(struct rchan_
 			 * from the scheduler (trying to re-grab
 			 * rq->lock), so defer it.
 			 */
-			__mod_timer(&buf->timer, jiffies + 1);
+			__mod_timer(&buf->timer, jiffies + 1, TIMER_NOACT);
 	}
 
 	old = buf->data;

-- 

