From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 4/4] param: convert some "on"/"off" users to strtobool
Date: Thu,  4 Feb 2016 13:00:43 -0800
Message-ID: <1454619643-14444-5-git-send-email-keescook@chromium.org>
References: <1454619643-14444-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>, x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Steve French <sfrench@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454619643-14444-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This changes several users of manual "on"/"off" parsing to use strtobool.
(Which means they will now parse y/n/1/0 meaningfully too.)

Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Acked-by: Michael Ellerman <mpe@ellerman.id.au>
Cc: x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
---
 arch/powerpc/kernel/rtasd.c                  |  9 ++-------
 arch/powerpc/platforms/pseries/hotplug-cpu.c | 10 ++--------
 arch/s390/kernel/time.c                      |  8 ++------
 arch/s390/kernel/topology.c                  |  7 ++-----
 arch/x86/kernel/aperture_64.c                | 12 ++----------
 include/linux/tick.h                         |  2 +-
 kernel/time/hrtimer.c                        | 10 ++--------
 kernel/time/tick-sched.c                     | 10 ++--------
 8 files changed, 15 insertions(+), 53 deletions(-)

diff --git a/arch/powerpc/kernel/rtasd.c b/arch/powerpc/kernel/rtasd.c
index 5a2c049c1c61..567ed5a2f43a 100644
--- a/arch/powerpc/kernel/rtasd.c
+++ b/arch/powerpc/kernel/rtasd.c
@@ -49,7 +49,7 @@ static unsigned int rtas_error_log_buffer_max;
 static unsigned int event_scan;
 static unsigned int rtas_event_scan_rate;
 
-static int full_rtas_msgs = 0;
+static bool full_rtas_msgs;
 
 /* Stop logging to nvram after first fatal error */
 static int logging_enabled; /* Until we initialize everything,
@@ -592,11 +592,6 @@ __setup("surveillance=", surveillance_setup);
 
 static int __init rtasmsgs_setup(char *str)
 {
-	if (strcmp(str, "on") == 0)
-		full_rtas_msgs = 1;
-	else if (strcmp(str, "off") == 0)
-		full_rtas_msgs = 0;
-
-	return 1;
+	return kstrtobool(str, 0, &full_rtas_msgs);
 }
 __setup("rtasmsgs=", rtasmsgs_setup);
diff --git a/arch/powerpc/platforms/pseries/hotplug-cpu.c b/arch/powerpc/platforms/pseries/hotplug-cpu.c
index 32274f72fe3f..b9787cae4108 100644
--- a/arch/powerpc/platforms/pseries/hotplug-cpu.c
+++ b/arch/powerpc/platforms/pseries/hotplug-cpu.c
@@ -47,20 +47,14 @@ static DEFINE_PER_CPU(enum cpu_state_vals, current_state) = CPU_STATE_OFFLINE;
 
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
+	return kstrtobool(str, 0, &cede_offline_enabled);
 }
 
 __setup("cede_offline=", setup_cede_offline);
diff --git a/arch/s390/kernel/time.c b/arch/s390/kernel/time.c
index 99f84ac31307..dff6ce1b84b2 100644
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
+	return kstrtobool(p, 0, &stp_online);
 }
 early_param("stp", early_parse_stp);
 
diff --git a/arch/s390/kernel/topology.c b/arch/s390/kernel/topology.c
index 40b8102fdadb..5d8a80651f61 100644
--- a/arch/s390/kernel/topology.c
+++ b/arch/s390/kernel/topology.c
@@ -37,7 +37,7 @@ static void set_topology_timer(void);
 static void topology_work_fn(struct work_struct *work);
 static struct sysinfo_15_1_x *tl_info;
 
-static int topology_enabled = 1;
+static bool topology_enabled = true;
 static DECLARE_WORK(topology_work, topology_work_fn);
 
 /*
@@ -444,10 +444,7 @@ static const struct cpumask *cpu_book_mask(int cpu)
 
 static int __init early_parse_topology(char *p)
 {
-	if (strncmp(p, "off", 3))
-		return 0;
-	topology_enabled = 0;
-	return 0;
+	return kstrtobool(p, 0, &topology_enabled);
 }
 early_param("topology", early_parse_topology);
 
diff --git a/arch/x86/kernel/aperture_64.c b/arch/x86/kernel/aperture_64.c
index 6e85f713641d..6b423754083a 100644
--- a/arch/x86/kernel/aperture_64.c
+++ b/arch/x86/kernel/aperture_64.c
@@ -227,19 +227,11 @@ static u32 __init search_agp_bridge(u32 *order, int *valid_agp)
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
+	return kstrtobool(p, 0, &gart_fix_e820);
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
index 435b8850dd80..456f066148d5 100644
--- a/kernel/time/hrtimer.c
+++ b/kernel/time/hrtimer.c
@@ -515,7 +515,7 @@ static inline ktime_t hrtimer_update_base(struct hrtimer_cpu_base *base)
 /*
  * High resolution timer enabled ?
  */
-static int hrtimer_hres_enabled __read_mostly  = 1;
+static bool hrtimer_hres_enabled __read_mostly  = true;
 unsigned int hrtimer_resolution __read_mostly = LOW_RES_NSEC;
 EXPORT_SYMBOL_GPL(hrtimer_resolution);
 
@@ -524,13 +524,7 @@ EXPORT_SYMBOL_GPL(hrtimer_resolution);
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
+	return kstrtobool(str, 0, &hrtimer_hres_enabled);
 }
 
 __setup("highres=", setup_hrtimer_hres);
diff --git a/kernel/time/tick-sched.c b/kernel/time/tick-sched.c
index 9d7a053545f5..b57f822c2069 100644
--- a/kernel/time/tick-sched.c
+++ b/kernel/time/tick-sched.c
@@ -387,20 +387,14 @@ void __init tick_nohz_init(void)
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
+	return kstrtobool(str, 0, &tick_nohz_enabled);
 }
 
 __setup("nohz=", setup_tick_nohz);
-- 
2.6.3
