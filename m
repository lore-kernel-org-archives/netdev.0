From: akpm@osdl.org
Subject: [patch 2/2] ipvs deadlock fix
Date: Sun, 30 Jan 2005 22:33:02 -0800
Message-ID: <200501310633.j0V6X1l01385@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



update_defense_level() is calling si_meminfo() from timer context.  But
si_meminfo takes non-irq-safe locks.

Move it all to keventd context.  

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/ipv4/ipvs/ip_vs_ctl.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff -puN net/ipv4/ipvs/ip_vs_ctl.c~ipvs-deadlock-fix net/ipv4/ipvs/ip_vs_ctl.c
--- 25/net/ipv4/ipvs/ip_vs_ctl.c~ipvs-deadlock-fix	2005-01-10 21:15:28.220163464 -0800
+++ 25-akpm/net/ipv4/ipvs/ip_vs_ctl.c	2005-01-10 21:15:28.226162552 -0800
@@ -26,7 +26,7 @@
 #include <linux/fs.h>
 #include <linux/sysctl.h>
 #include <linux/proc_fs.h>
-#include <linux/timer.h>
+#include <linux/workqueue.h>
 #include <linux/swap.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -90,7 +90,7 @@ int ip_vs_get_debug_level(void)
 #endif
 
 /*
- *	update_defense_level is called from timer bh and from sysctl.
+ *	update_defense_level is called from keventd and from sysctl.
  */
 static void update_defense_level(void)
 {
@@ -212,19 +212,19 @@ static void update_defense_level(void)
 /*
  *	Timer for checking the defense
  */
-static struct timer_list defense_timer;
 #define DEFENSE_TIMER_PERIOD	1*HZ
+static void defense_work_handler(void *data);
+static DECLARE_WORK(defense_work, defense_work_handler, NULL);
 
-static void defense_timer_handler(unsigned long data)
+static void defense_work_handler(void *data)
 {
 	update_defense_level();
 	if (atomic_read(&ip_vs_dropentry))
 		ip_vs_random_dropentry();
 
-	mod_timer(&defense_timer, jiffies + DEFENSE_TIMER_PERIOD);
+	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
 }
 
-
 int
 ip_vs_use_count_inc(void)
 {
@@ -2370,10 +2370,7 @@ int ip_vs_control_init(void)
 	ip_vs_new_estimator(&ip_vs_stats);
 
 	/* Hook the defense timer */
-	init_timer(&defense_timer);
-	defense_timer.function = defense_timer_handler;
-	defense_timer.expires = jiffies + DEFENSE_TIMER_PERIOD;
-	add_timer(&defense_timer);
+	schedule_delayed_work(&defense_work, DEFENSE_TIMER_PERIOD);
 
 	LeaveFunction(2);
 	return 0;
@@ -2384,7 +2381,7 @@ void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
 	ip_vs_trash_cleanup();
-	del_timer_sync(&defense_timer);
+	cancel_rearming_delayed_work(&defense_work);
 	ip_vs_kill_estimator(&ip_vs_stats);
 	unregister_sysctl_table(sysctl_header);
 	proc_net_remove("ip_vs_stats");
_
