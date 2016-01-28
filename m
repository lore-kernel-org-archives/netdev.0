From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 3/3] param: convert some "on"/"off" users to strtobool
Date: Thu, 28 Jan 2016 06:17:07 -0800
Message-ID: <1453990627-19164-4-git-send-email-keescook@chromium.org>
References: <1453990627-19164-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453990627-19164-1-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This changes several users of manual "on"/"off" parsing to use strtobool.

Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 arch/powerpc/kernel/rtasd.c                  | 10 +++-------
 arch/powerpc/platforms/pseries/hotplug-cpu.c | 11 +++--------
 arch/s390/kernel/time.c                      |  8 ++------
 arch/s390/kernel/topology.c                  |  8 +++-----
 arch/x86/kernel/aperture_64.c                | 13 +++----------
 include/linux/tick.h                         |  2 +-
 kernel/time/hrtimer.c                        | 11 +++--------
 kernel/time/tick-sched.c                     | 11 +++--------
 8 files changed, 21 insertions(+), 53 deletions(-)

diff --git a/arch/powerpc/kernel/rtasd.c b/arch/powerpc/kernel/rtasd.c
index 5a2c049c1c61..984e67e91ba3 100644
--- a/arch/powerpc/kernel/rtasd.c
+++ b/arch/powerpc/kernel/rtasd.c
@@ -21,6 +21,7 @@
 #include <linux/cpu.h>
 #include <linux/workqueue.h>
 #include <linux/slab.h>
+#include <linux/string.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -49,7 +50,7 @@ static unsigned int rtas_error_log_buffer_max;
 static unsigned int event_scan;
 static unsigned int rtas_event_scan_rate;
 
-static int full_rtas_msgs = 0;
+static bool full_rtas_msgs;
 
 /* Stop logging to nvram after first fatal error */
 static int logging_enabled; /* Until we initialize everything,
@@ -592,11 +593,6 @@ __setup("surveillance=", surveillance_setup);
 
 static int __init rtasmsgs_setup(char *str)
 {
-	if (strcmp(str, "on") == 0)
-		full_rtas_msgs = 1;
-	else if (strcmp(str, "off") == 0)
-		full_rtas_msgs = 0;
-
-	return 1;
+	return strtobool(str, &full_rtas_msgs);
 }
 __setup("rtasmsgs=", rtasmsgs_setup);
diff --git a/arch/powerpc/platforms/pseries/hotplug-cpu.c b/arch/powerpc/platforms/pseries/hotplug-cpu.c
index 32274f72fe3f..bb333e9fd77a 100644
--- a/arch/powerpc/platforms/pseries/hotplug-cpu.c
+++ b/arch/powerpc/platforms/pseries/hotplug-cpu.c
@@ -27,6 +27,7 @@
 #include <linux/cpu.h>
 #include <linux/of.h>
 #include <linux/slab.h>
+#include <linux/string.h>
 #include <asm/prom.h>
 #include <asm/rtas.h>
 #include <asm/firmware.h>
@@ -47,20 +48,14 @@ static DEFINE_PER_CPU(enum cpu_state_vals, current_state) = CPU_STATE_OFFLINE;
 
 static enum cpu_state_vals default_offline_state = CPU_STATE_OFFLINE;
 
-static int cede_offline_enabled __read_mostly = 1;
+static bool cede_offline_enabled __read_mostly = true;
 
 /*
  * Enable/disable cede_offline when available.
  */
 static int __init setup_cede_offline(char *str)
 {
-	if (!strcmp(str, "off"))
-		cede_offline_enabled = 0;
-	else if (!strcmp(str, "on"))
-		cede_offline_enabled = 1;
-	else
-		return 0;
-	return 1;
+	return strtobool(str, &cede_offline_enabled);
 }
 
 __setup("cede_offline=", setup_cede_offline);
diff --git a/arch/s390/kernel/time.c b/arch/s390/kernel/time.c
index 99f84ac31307..afc7fc9684ba 100644
--- a/arch/s390/kernel/time.c
+++ b/arch/s390/kernel/time.c
@@ -1433,7 +1433,7 @@ device_initcall(etr_init_sysfs);
 /*
  * Server Time Protocol (STP) code.
  */
-static int stp_online;
+static bool stp_online;
 static struct stp_sstpi stp_info;
 static void *stp_page;
 
@@ -1444,11 +1444,7 @@ static struct timer_list stp_timer;
 
 static int __init early_parse_stp(char *p)
 {
-	if (strncmp(p, "off", 3) == 0)
-		stp_online = 0;
-	else if (strncmp(p, "on", 2) == 0)
-		stp_online = 1;
-	return 0;
+	return strtobool(p, &stp_online);
 }
 early_param("stp", early_parse_stp);
 
diff --git a/arch/s390/kernel/topology.c b/arch/s390/kernel/topology.c
index 40b8102fdadb..10e388216307 100644
--- a/arch/s390/kernel/topology.c
+++ b/arch/s390/kernel/topology.c
@@ -15,6 +15,7 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/slab.h>
+#include <linux/string.h>
 #include <linux/cpu.h>
 #include <linux/smp.h>
 #include <linux/mm.h>
@@ -37,7 +38,7 @@ static void set_topology_timer(void);
 static void topology_work_fn(struct work_struct *work);
 static struct sysinfo_15_1_x *tl_info;
 
-static int topology_enabled = 1;
+static bool topology_enabled = true;
 static DECLARE_WORK(topology_work, topology_work_fn);
 
 /*
@@ -444,10 +445,7 @@ static const struct cpumask *cpu_book_mask(int cpu)
 
 static int __init early_parse_topology(char *p)
 {
-	if (strncmp(p, "off", 3))
-		return 0;
-	topology_enabled = 0;
-	return 0;
+	return strtobool(p, &topology_enabled);
 }
 early_param("topology", early_parse_topology);
 
diff --git a/arch/x86/kernel/aperture_64.c b/arch/x86/kernel/aperture_64.c
index 6e85f713641d..6608b00a516a 100644
--- a/arch/x86/kernel/aperture_64.c
+++ b/arch/x86/kernel/aperture_64.c
@@ -20,6 +20,7 @@
 #include <linux/pci_ids.h>
 #include <linux/pci.h>
 #include <linux/bitops.h>
+#include <linux/string.h>
 #include <linux/suspend.h>
 #include <asm/e820.h>
 #include <asm/io.h>
@@ -227,19 +228,11 @@ static u32 __init search_agp_bridge(u32 *order, int *valid_agp)
 	return 0;
 }
 
-static int gart_fix_e820 __initdata = 1;
+static bool gart_fix_e820 __initdata = true;
 
 static int __init parse_gart_mem(char *p)
 {
-	if (!p)
-		return -EINVAL;
-
-	if (!strncmp(p, "off", 3))
-		gart_fix_e820 = 0;
-	else if (!strncmp(p, "on", 2))
-		gart_fix_e820 = 1;
-
-	return 0;
+	return strtobool(p, &gart_fix_e820);
 }
 early_param("gart_fix_e820", parse_gart_mem);
 
diff --git a/include/linux/tick.h b/include/linux/tick.h
index 97fd4e543846..0ecdf0e248f4 100644
--- a/include/linux/tick.h
+++ b/include/linux/tick.h
@@ -98,7 +98,7 @@ static inline void tick_broadcast_exit(void)
 }
 
 #ifdef CONFIG_NO_HZ_COMMON
-extern int tick_nohz_enabled;
+extern bool tick_nohz_enabled;
 extern int tick_nohz_tick_stopped(void);
 extern void tick_nohz_idle_enter(void);
 extern void tick_nohz_idle_exit(void);
diff --git a/kernel/time/hrtimer.c b/kernel/time/hrtimer.c
index 435b8850dd80..40d82fe4d2a5 100644
--- a/kernel/time/hrtimer.c
+++ b/kernel/time/hrtimer.c
@@ -39,6 +39,7 @@
 #include <linux/syscalls.h>
 #include <linux/kallsyms.h>
 #include <linux/interrupt.h>
+#include <linux/string.h>
 #include <linux/tick.h>
 #include <linux/seq_file.h>
 #include <linux/err.h>
@@ -515,7 +516,7 @@ static inline ktime_t hrtimer_update_base(struct hrtimer_cpu_base *base)
 /*
  * High resolution timer enabled ?
  */
-static int hrtimer_hres_enabled __read_mostly  = 1;
+static bool hrtimer_hres_enabled __read_mostly  = true;
 unsigned int hrtimer_resolution __read_mostly = LOW_RES_NSEC;
 EXPORT_SYMBOL_GPL(hrtimer_resolution);
 
@@ -524,13 +525,7 @@ EXPORT_SYMBOL_GPL(hrtimer_resolution);
  */
 static int __init setup_hrtimer_hres(char *str)
 {
-	if (!strcmp(str, "off"))
-		hrtimer_hres_enabled = 0;
-	else if (!strcmp(str, "on"))
-		hrtimer_hres_enabled = 1;
-	else
-		return 0;
-	return 1;
+	return strtobool(str, &hrtimer_hres_enabled);
 }
 
 __setup("highres=", setup_hrtimer_hres);
diff --git a/kernel/time/tick-sched.c b/kernel/time/tick-sched.c
index 9d7a053545f5..bd97702a0760 100644
--- a/kernel/time/tick-sched.c
+++ b/kernel/time/tick-sched.c
@@ -19,6 +19,7 @@
 #include <linux/percpu.h>
 #include <linux/profile.h>
 #include <linux/sched.h>
+#include <linux/string.h>
 #include <linux/module.h>
 #include <linux/irq_work.h>
 #include <linux/posix-timers.h>
@@ -387,20 +388,14 @@ void __init tick_nohz_init(void)
 /*
  * NO HZ enabled ?
  */
-int tick_nohz_enabled __read_mostly = 1;
+bool tick_nohz_enabled __read_mostly  = true;
 unsigned long tick_nohz_active  __read_mostly;
 /*
  * Enable / Disable tickless mode
  */
 static int __init setup_tick_nohz(char *str)
 {
-	if (!strcmp(str, "off"))
-		tick_nohz_enabled = 0;
-	else if (!strcmp(str, "on"))
-		tick_nohz_enabled = 1;
-	else
-		return 0;
-	return 1;
+	return strtobool(str, &tick_nohz_enabled);
 }
 
 __setup("nohz=", setup_tick_nohz);
-- 
2.6.3
