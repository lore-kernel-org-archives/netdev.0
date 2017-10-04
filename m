From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 01/13] timer: Convert schedule_timeout() to use from_timer()
Date: Wed,  4 Oct 2017 16:26:55 -0700
Message-ID: <1507159627-127660-2-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
        Chris Metcalf <cmetcalf-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        Harish Patil <harish.patil-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Julian Wiedmann <jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Lai Jiangshan <jiangshanlai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Manish Chopra <manish.chopra-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Mark Gross <mark.gross
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new from_timer() helper and passing
the timer pointer explicitly. Since this special timer is on the stack, it
needs to have a wrapper structure to carry state once .data is eliminated.

Cc: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Cc: Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 include/linux/timer.h |  8 ++++++++
 kernel/time/timer.c   | 26 +++++++++++++++++++-------
 2 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/include/linux/timer.h b/include/linux/timer.h
index 6383c528b148..5ef5c9e41a09 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -179,6 +179,14 @@ static inline void timer_setup(struct timer_list *timer,
 		      (TIMER_DATA_TYPE)timer, flags);
 }
 
+static inline void timer_setup_on_stack(struct timer_list *timer,
+			       void (*callback)(struct timer_list *),
+			       unsigned int flags)
+{
+	__setup_timer_on_stack(timer, (TIMER_FUNC_TYPE)callback,
+			       (TIMER_DATA_TYPE)timer, flags);
+}
+
 #define from_timer(var, callback_timer, timer_fieldname) \
 	container_of(callback_timer, typeof(*var), timer_fieldname)
 
diff --git a/kernel/time/timer.c b/kernel/time/timer.c
index f2674a056c26..38613ced2324 100644
--- a/kernel/time/timer.c
+++ b/kernel/time/timer.c
@@ -1668,9 +1668,20 @@ void run_local_timers(void)
 	raise_softirq(TIMER_SOFTIRQ);
 }
 
-static void process_timeout(unsigned long __data)
+/*
+ * Since schedule_timeout()'s timer is defined on the stack, it must store
+ * the target task on the stack as well.
+ */
+struct process_timer {
+	struct timer_list timer;
+	struct task_struct *task;
+};
+
+static void process_timeout(struct timer_list *t)
 {
-	wake_up_process((struct task_struct *)__data);
+	struct process_timer *timeout = from_timer(timeout, t, timer);
+
+	wake_up_process(timeout->task);
 }
 
 /**
@@ -1704,7 +1715,7 @@ static void process_timeout(unsigned long __data)
  */
 signed long __sched schedule_timeout(signed long timeout)
 {
-	struct timer_list timer;
+	struct process_timer timer;
 	unsigned long expire;
 
 	switch (timeout)
@@ -1738,13 +1749,14 @@ signed long __sched schedule_timeout(signed long timeout)
 
 	expire = timeout + jiffies;
 
-	setup_timer_on_stack(&timer, process_timeout, (unsigned long)current);
-	__mod_timer(&timer, expire, false);
+	timer.task = current;
+	timer_setup_on_stack(&timer.timer, process_timeout, 0);
+	__mod_timer(&timer.timer, expire, false);
 	schedule();
-	del_singleshot_timer_sync(&timer);
+	del_singleshot_timer_sync(&timer.timer);
 
 	/* Remove the timer from the object tracker */
-	destroy_timer_on_stack(&timer);
+	destroy_timer_on_stack(&timer.timer);
 
 	timeout = expire - jiffies;
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
