From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 06/13] timer: Remove users of TIMER_DEFERRED_INITIALIZER
Date: Wed,  4 Oct 2017 16:27:00 -0700
Message-ID: <1507159627-127660-7-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Lai Jiangshan <jiangshanlai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
        Chris Metcalf <cmetcalf-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        Harish Patil <harish.patil-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Julian Wiedmann <jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This removes uses of TIMER_DEFERRED_INITIALIZER and chooses a location
to call timer_setup() from before add_timer() or mod_timer() is called.
Adjusts callbacks to use from_timer() as needed.

Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Lai Jiangshan <jiangshanlai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 arch/s390/kernel/lgr.c      | 6 +++---
 arch/s390/kernel/topology.c | 6 +++---
 kernel/workqueue.c          | 8 +++-----
 3 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/arch/s390/kernel/lgr.c b/arch/s390/kernel/lgr.c
index ae7dff110054..bf9622f0e6b1 100644
--- a/arch/s390/kernel/lgr.c
+++ b/arch/s390/kernel/lgr.c
@@ -153,14 +153,13 @@ static void lgr_timer_set(void);
 /*
  * LGR timer callback
  */
-static void lgr_timer_fn(unsigned long ignored)
+static void lgr_timer_fn(struct timer_list *unused)
 {
 	lgr_info_log();
 	lgr_timer_set();
 }
 
-static struct timer_list lgr_timer =
-	TIMER_DEFERRED_INITIALIZER(lgr_timer_fn, 0, 0);
+static struct timer_list lgr_timer;
 
 /*
  * Setup next LGR timer
@@ -181,6 +180,7 @@ static int __init lgr_init(void)
 	debug_register_view(lgr_dbf, &debug_hex_ascii_view);
 	lgr_info_get(&lgr_info_last);
 	debug_event(lgr_dbf, 1, &lgr_info_last, sizeof(lgr_info_last));
+	timer_setup(&lgr_timer, lgr_timer_fn, TIMER_DEFERRABLE);
 	lgr_timer_set();
 	return 0;
 }
diff --git a/arch/s390/kernel/topology.c b/arch/s390/kernel/topology.c
index ed0bdd220e1a..d7ece9888c29 100644
--- a/arch/s390/kernel/topology.c
+++ b/arch/s390/kernel/topology.c
@@ -320,15 +320,14 @@ static void topology_flush_work(void)
 	flush_work(&topology_work);
 }
 
-static void topology_timer_fn(unsigned long ignored)
+static void topology_timer_fn(struct timer_list *unused)
 {
 	if (ptf(PTF_CHECK))
 		topology_schedule_update();
 	set_topology_timer();
 }
 
-static struct timer_list topology_timer =
-	TIMER_DEFERRED_INITIALIZER(topology_timer_fn, 0, 0);
+static struct timer_list topology_timer;
 
 static atomic_t topology_poll = ATOMIC_INIT(0);
 
@@ -597,6 +596,7 @@ static struct ctl_table topology_dir_table[] = {
 
 static int __init topology_init(void)
 {
+	timer_setup(&topology_timer, topology_timer_fn, TIMER_DEFERRABLE);
 	if (MACHINE_HAS_TOPOLOGY)
 		set_topology_timer();
 	else
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 64d0edf428f8..a5361fc6215d 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -5390,11 +5390,8 @@ static void workqueue_sysfs_unregister(struct workqueue_struct *wq)	{ }
  */
 #ifdef CONFIG_WQ_WATCHDOG
 
-static void wq_watchdog_timer_fn(unsigned long data);
-
 static unsigned long wq_watchdog_thresh = 30;
-static struct timer_list wq_watchdog_timer =
-	TIMER_DEFERRED_INITIALIZER(wq_watchdog_timer_fn, 0, 0);
+static struct timer_list wq_watchdog_timer;
 
 static unsigned long wq_watchdog_touched = INITIAL_JIFFIES;
 static DEFINE_PER_CPU(unsigned long, wq_watchdog_touched_cpu) = INITIAL_JIFFIES;
@@ -5408,7 +5405,7 @@ static void wq_watchdog_reset_touched(void)
 		per_cpu(wq_watchdog_touched_cpu, cpu) = jiffies;
 }
 
-static void wq_watchdog_timer_fn(unsigned long data)
+static void wq_watchdog_timer_fn(struct timer_list *unused)
 {
 	unsigned long thresh = READ_ONCE(wq_watchdog_thresh) * HZ;
 	bool lockup_detected = false;
@@ -5510,6 +5507,7 @@ module_param_cb(watchdog_thresh, &wq_watchdog_thresh_ops, &wq_watchdog_thresh,
 
 static void wq_watchdog_init(void)
 {
+	timer_setup(&wq_watchdog_timer, wq_watchdog_timer_fn, TIMER_DEFERRABLE);
 	wq_watchdog_set_thresh(wq_watchdog_thresh);
 }
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
