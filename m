From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/1] posix clocks: introduce syscall for clock tuning.
Date: Mon, 23 Aug 2010 10:16:33 +0200
Message-ID: <e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran@omicron.at>
References: <cover.1282550649.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1282550649.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A new syscall is introduced that allows tuning of a POSIX clock. The
syscall is implemented for four architectures: arm, blackfin, powerpc,
and x86.

The new syscall, clock_adjtime, takes two parameters, a frequency
adjustment in parts per billion, and a pointer to a struct timespec
containing the clock offset. If the pointer is NULL, a frequency
adjustment is performed. Otherwise, the clock offset is immediately
corrected by skipping to the new time value.

In addtion, the patch provides way to unregister a posix clock. This
function is need to support posix clocks implemented as modules.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 arch/arm/include/asm/unistd.h      |    1 +
 arch/arm/kernel/calls.S            |    1 +
 arch/blackfin/include/asm/unistd.h |    3 +-
 arch/blackfin/mach-common/entry.S  |    1 +
 arch/powerpc/include/asm/systbl.h  |    1 +
 arch/powerpc/include/asm/unistd.h  |    3 +-
 arch/x86/ia32/ia32entry.S          |    1 +
 arch/x86/include/asm/unistd_32.h   |    3 +-
 arch/x86/include/asm/unistd_64.h   |    2 +
 arch/x86/kernel/syscall_table_32.S |    1 +
 include/linux/posix-timers.h       |    5 ++++
 include/linux/syscalls.h           |    3 ++
 kernel/compat.c                    |   20 ++++++++++++++++++
 kernel/posix-cpu-timers.c          |    5 ++++
 kernel/posix-timers.c              |   38 ++++++++++++++++++++++++++++++++++++
 15 files changed, 85 insertions(+), 3 deletions(-)

diff --git a/arch/arm/include/asm/unistd.h b/arch/arm/include/asm/unistd.h
index dd2bf53..6bea0b7 100644
--- a/arch/arm/include/asm/unistd.h
+++ b/arch/arm/include/asm/unistd.h
@@ -392,6 +392,7 @@
 #define __NR_rt_tgsigqueueinfo		(__NR_SYSCALL_BASE+363)
 #define __NR_perf_event_open		(__NR_SYSCALL_BASE+364)
 #define __NR_recvmmsg			(__NR_SYSCALL_BASE+365)
+#define __NR_clock_adjtime		(__NR_SYSCALL_BASE+366)
 
 /*
  * The following SWIs are ARM private.
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 37ae301..8a22fdd 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -375,6 +375,7 @@
 		CALL(sys_rt_tgsigqueueinfo)
 		CALL(sys_perf_event_open)
 /* 365 */	CALL(sys_recvmmsg)
+		CALL(sys_clock_adjtime)
 #ifndef syscalls_counted
 .equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
 #define syscalls_counted
diff --git a/arch/blackfin/include/asm/unistd.h b/arch/blackfin/include/asm/unistd.h
index 22886cb..6671913 100644
--- a/arch/blackfin/include/asm/unistd.h
+++ b/arch/blackfin/include/asm/unistd.h
@@ -389,8 +389,9 @@
 #define __NR_rt_tgsigqueueinfo	368
 #define __NR_perf_event_open	369
 #define __NR_recvmmsg		370
+#define __NR_clock_adjtime	371
 
-#define __NR_syscall		371
+#define __NR_syscall		372
 #define NR_syscalls		__NR_syscall
 
 /* Old optional stuff no one actually uses */
diff --git a/arch/blackfin/mach-common/entry.S b/arch/blackfin/mach-common/entry.S
index a5847f5..252f2fa 100644
--- a/arch/blackfin/mach-common/entry.S
+++ b/arch/blackfin/mach-common/entry.S
@@ -1628,6 +1628,7 @@ ENTRY(_sys_call_table)
 	.long _sys_rt_tgsigqueueinfo
 	.long _sys_perf_event_open
 	.long _sys_recvmmsg		/* 370 */
+	.long _sys_clock_adjtime
 
 	.rept NR_syscalls-(.-_sys_call_table)/4
 	.long _sys_ni_syscall
diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index a5ee345..e7dce86 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -326,3 +326,4 @@ SYSCALL_SPU(perf_event_open)
 COMPAT_SYS_SPU(preadv)
 COMPAT_SYS_SPU(pwritev)
 COMPAT_SYS(rt_tgsigqueueinfo)
+COMPAT_SYS_SPU(clock_adjtime)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index f0a1026..7d4d9c8 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -345,10 +345,11 @@
 #define __NR_preadv		320
 #define __NR_pwritev		321
 #define __NR_rt_tgsigqueueinfo	322
+#define __NR_clock_adjtime	323
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		323
+#define __NR_syscalls		324
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index e790bc1..8237c8d 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -842,4 +842,5 @@ ia32_sys_call_table:
 	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
 	.quad sys_perf_event_open
 	.quad compat_sys_recvmmsg
+	.quad compat_sys_clock_adjtime
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index beb9b5f..79cbef6 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -343,10 +343,11 @@
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_event_open	336
 #define __NR_recvmmsg		337
+#define __NR_clock_adjtime	338
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 338
+#define NR_syscalls 339
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index ff4307b..3ee70cd 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -663,6 +663,8 @@ __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 __SYSCALL(__NR_perf_event_open, sys_perf_event_open)
 #define __NR_recvmmsg				299
 __SYSCALL(__NR_recvmmsg, sys_recvmmsg)
+#define __NR_clock_adjtime			300
+__SYSCALL(__NR_clock_adjtime, sys_clock_adjtime)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index 8b37293..3569859 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -337,3 +337,4 @@ ENTRY(sys_call_table)
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_event_open
 	.long sys_recvmmsg
+	.long sys_clock_adjtime
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index 4f71bf4..534c12d 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -71,6 +71,8 @@ struct k_clock {
 	int (*clock_getres) (const clockid_t which_clock, struct timespec *tp);
 	int (*clock_set) (const clockid_t which_clock, struct timespec * tp);
 	int (*clock_get) (const clockid_t which_clock, struct timespec * tp);
+	int (*clock_adj) (const clockid_t which_clock, int ppb,
+			  struct timespec *tp);
 	int (*timer_create) (struct k_itimer *timer);
 	int (*nsleep) (const clockid_t which_clock, int flags,
 		       struct timespec *, struct timespec __user *);
@@ -85,6 +87,7 @@ struct k_clock {
 };
 
 void register_posix_clock(const clockid_t clock_id, struct k_clock *new_clock);
+void unregister_posix_clock(const clockid_t clock_id);
 
 /* error handlers for timer_create, nanosleep and settime */
 int do_posix_clock_nonanosleep(const clockid_t, int flags, struct timespec *,
@@ -97,6 +100,8 @@ int posix_timer_event(struct k_itimer *timr, int si_private);
 int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *ts);
 int posix_cpu_clock_get(const clockid_t which_clock, struct timespec *ts);
 int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *ts);
+int posix_cpu_clock_adj(const clockid_t which_clock, int ppb,
+			struct timespec *tp);
 int posix_cpu_timer_create(struct k_itimer *timer);
 int posix_cpu_nsleep(const clockid_t which_clock, int flags,
 		     struct timespec *rqtp, struct timespec __user *rmtp);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 13ebb54..f641cc5 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -314,6 +314,9 @@ asmlinkage long sys_clock_settime(clockid_t which_clock,
 				const struct timespec __user *tp);
 asmlinkage long sys_clock_gettime(clockid_t which_clock,
 				struct timespec __user *tp);
+asmlinkage long sys_clock_adjtime(clockid_t which_clock,
+				int ppb,
+				const struct timespec __user *tp);
 asmlinkage long sys_clock_getres(clockid_t which_clock,
 				struct timespec __user *tp);
 asmlinkage long sys_clock_nanosleep(clockid_t which_clock, int flags,
diff --git a/kernel/compat.c b/kernel/compat.c
index 5adab05..df1e469 100644
--- a/kernel/compat.c
+++ b/kernel/compat.c
@@ -628,6 +628,26 @@ long compat_sys_clock_gettime(clockid_t which_clock,
 	return err;
 }
 
+long compat_sys_clock_adjtime(clockid_t which_clock, int ppb,
+		struct compat_timespec __user *tp)
+{
+	long err;
+	mm_segment_t oldfs;
+	struct timespec ts, *ptr = NULL;
+
+	if (tp) {
+		if (get_compat_timespec(&ts, tp))
+			return -EFAULT;
+		ptr = &ts;
+	}
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+	err = sys_clock_adjtime(which_clock, ppb,
+				(struct timespec __user *) ptr);
+	set_fs(oldfs);
+	return err;
+}
+
 long compat_sys_clock_getres(clockid_t which_clock,
 		struct compat_timespec __user *tp)
 {
diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
index 9829646..5843f5a 100644
--- a/kernel/posix-cpu-timers.c
+++ b/kernel/posix-cpu-timers.c
@@ -207,6 +207,11 @@ int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *tp)
 	return error;
 }
 
+int posix_cpu_clock_adj(const clockid_t which_clock, int ppb,
+			struct timespec *tp)
+{
+	return -EOPNOTSUPP;
+}
 
 /*
  * Sample a per-thread clock for the given task.
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index ad72342..089b0d1 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -197,6 +197,12 @@ static int common_timer_create(struct k_itimer *new_timer)
 	return 0;
 }
 
+static inline int common_clock_adj(const clockid_t which_clock, int ppb,
+				   struct timespec *tp)
+{
+	return -EOPNOTSUPP;
+}
+
 static int no_timer_create(struct k_itimer *new_timer)
 {
 	return -EOPNOTSUPP;
@@ -488,6 +494,21 @@ void register_posix_clock(const clockid_t clock_id, struct k_clock *new_clock)
 }
 EXPORT_SYMBOL_GPL(register_posix_clock);
 
+void unregister_posix_clock(const clockid_t clock_id)
+{
+	struct k_clock *clock;
+
+	if ((unsigned) clock_id >= MAX_CLOCKS) {
+		pr_err("POSIX clock unregister failed for clock_id %d\n",
+		       clock_id);
+		return;
+	}
+
+	clock = &posix_clocks[clock_id];
+	memset(clock, 0, sizeof(*clock));
+}
+EXPORT_SYMBOL_GPL(unregister_posix_clock);
+
 static struct k_itimer * alloc_posix_timer(void)
 {
 	struct k_itimer *tmr;
@@ -968,6 +989,23 @@ SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
 
 }
 
+SYSCALL_DEFINE3(clock_adjtime, const clockid_t, which_clock,
+		int, ppb, const struct timespec __user *, tp)
+{
+	struct timespec new_tp, *ts = NULL;
+
+	if (invalid_clockid(which_clock))
+		return -EINVAL;
+
+	if (tp) {
+		if (copy_from_user(&new_tp, tp, sizeof(*tp)))
+			return -EFAULT;
+		ts = &new_tp;
+	}
+
+	return CLOCK_DISPATCH(which_clock, clock_adj, (which_clock, ppb, ts));
+}
+
 SYSCALL_DEFINE2(clock_getres, const clockid_t, which_clock,
 		struct timespec __user *, tp)
 {
-- 
1.7.0.4
