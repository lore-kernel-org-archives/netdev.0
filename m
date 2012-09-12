From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v4 5/8] cgroup: Wrap subsystem selection macro
Date: Wed, 12 Sep 2012 16:12:05 +0200
Message-ID: <1347459128-32236-6-git-send-email-wagi@monom.org>
References: <1347459128-32236-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347459128-32236-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

Before we are able to define all subsystem ids at compile time we need
a more fine grained control what gets defined when we include
cgroup_subsys.h. For example we define the enums for the subsystems or
to declare for struct cgroup_subsys (builtin subsystem) by including
cgroup_subsys.h and defining SUBSYS accordingly.

Currently, the decision if a subsys is used is defined inside the
header by testing if CONFIG_*=y is true. By moving this test outside
of cgroup_subsys.h we are able to control it on the include level.

This is done by introducing IS_SUBSYS_ENABLED which then is defined
according the task, e.g. is CONFIG_*=y or CONFIG_*=m.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/linux/cgroup.h        |  4 ++++
 include/linux/cgroup_subsys.h | 24 ++++++++++++------------
 kernel/cgroup.c               |  1 +
 3 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1916cdb..a5ab565 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -46,10 +46,12 @@ extern const struct file_operations proc_cgroup_operations;
 
 /* Define the enumeration of all builtin cgroup subsystems */
 #define SUBSYS(_x) _x ## _subsys_id,
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 enum cgroup_subsys_id {
 #include <linux/cgroup_subsys.h>
 	__CGROUP_TEMPORARY_PLACEHOLDER
 };
+#undef IS_SUBSYS_ENABLED
 #undef SUBSYS
 /*
  * This define indicates the maximum number of subsystems that can be loaded
@@ -528,7 +530,9 @@ struct cgroup_subsys {
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 #include <linux/cgroup_subsys.h>
+#undef IS_SUBSYS_ENABLED
 #undef SUBSYS
 
 static inline struct cgroup_subsys_state *cgroup_subsys_state(
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index dfae957..f204a7a 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -7,73 +7,73 @@
 
 /* */
 
-#ifdef CONFIG_CPUSETS
+#if IS_SUBSYS_ENABLED(CONFIG_CPUSETS)
 SUBSYS(cpuset)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_DEBUG
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEBUG)
 SUBSYS(debug)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_SCHED
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_SCHED)
 SUBSYS(cpu_cgroup)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_CPUACCT
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_CPUACCT)
 SUBSYS(cpuacct)
 #endif
 
 /* */
 
-#ifdef CONFIG_MEMCG
+#if IS_SUBSYS_ENABLED(CONFIG_MEMCG)
 SUBSYS(mem_cgroup)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_DEVICE
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEVICE)
 SUBSYS(devices)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_FREEZER
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_FREEZER)
 SUBSYS(freezer)
 #endif
 
 /* */
 
-#ifdef CONFIG_NET_CLS_CGROUP
+#if IS_SUBSYS_ENABLED(CONFIG_NET_CLS_CGROUP)
 SUBSYS(net_cls)
 #endif
 
 /* */
 
-#ifdef CONFIG_BLK_CGROUP
+#if IS_SUBSYS_ENABLED(CONFIG_BLK_CGROUP)
 SUBSYS(blkio)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_PERF
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_PERF)
 SUBSYS(perf)
 #endif
 
 /* */
 
-#ifdef CONFIG_NETPRIO_CGROUP
+#if IS_SUBSYS_ENABLED(CONFIG_NETPRIO_CGROUP)
 SUBSYS(net_prio)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_HUGETLB
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_HUGETLB)
 SUBSYS(hugetlb)
 #endif
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2726d82..769600c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -93,6 +93,7 @@ static DEFINE_MUTEX(cgroup_root_mutex);
  * cgroup_mutex.
  */
 #define SUBSYS(_x) &_x ## _subsys,
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 static struct cgroup_subsys *subsys[CGROUP_SUBSYS_COUNT] = {
 #include <linux/cgroup_subsys.h>
 };
-- 
1.7.12.315.g682ce8b
