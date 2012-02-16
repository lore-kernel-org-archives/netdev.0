From: Will Drewry <wad@chromium.org>
Subject: [PATCH v8 4/8] seccomp: add SECCOMP_RET_ERRNO
Date: Thu, 16 Feb 2012 14:02:25 -0600
Message-ID: <1329422549-16407-4-git-send-email-wad@chromium.org>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.org, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1329422549-16407-1-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change adds the SECCOMP_RET_ERRNO as a valid return value from a
seccomp filter.  Additionally, it makes the first use of the lower
16-bits for storing a filter-supplied errno.  16-bits is more than
enough for the errno-base.h calls.

Returning errors instead of immediately terminating processes that
violate seccomp policy allow for broader use of this functionality
for kernel attack surface reduction.  For example, a linux container
could maintain a whitelist of pre-existing system calls but drop
all new ones with errnos.  This would keep a logically static attack
surface while providing errnos that may allow for graceful failure
without the downside of do_exit() on a bad call.

v8: - update Kconfig to note new need for syscall_set_return_value.
    - reordered such that TRAP behavior follows on later.
    - made the for loop a little less indent-y
v7: - introduced

Signed-off-by: Will Drewry <wad@chromium.org>
(cherry picked from commit e90e1a5389d0ce3a667640121b0a90538014a16c)
---
 arch/Kconfig            |    5 ++++-
 include/linux/seccomp.h |   20 +++++++++++++++-----
 kernel/seccomp.c        |   42 ++++++++++++++++++++++++++++++------------
 3 files changed, 49 insertions(+), 18 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index c6ba1db..3f3052b 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -203,7 +203,10 @@ config HAVE_ARCH_SECCOMP_FILTER
 	bool
 	help
 	  This symbol should be selected by an architecure if it provides
-	  asm/syscall.h, specifically syscall_get_arguments().
+	  asm/syscall.h, specifically syscall_get_arguments() and
+	  syscall_set_return_value().  Additionally, its system call
+	  entry path must respect a return value of -1 from
+	  __secure_computing_int() and/or secure_computing().
 
 config SECCOMP_FILTER
 	def_bool y
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 2bee1f7..879ece2 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -12,16 +12,20 @@
 
 /*
  * BPF programs may return a 32-bit value.
- * The bottom 16-bits are reserved for future use.
+ * The bottom 16-bits are for optional related return data.
  * The upper 16-bits are ordered from least permissive values to most.
  *
  * The ordering ensures that a min_t() over composed return values always
  * selects the least permissive choice.
  */
-#define SECCOMP_RET_MASK	0xffff0000U
 #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
+#define SECCOMP_RET_ERRNO	0x00030000U /* returns an errno */
 #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
 
+/* Masks for accessing the above values. */
+#define SECCOMP_RET_ACTION	0xffff0000U
+#define SECCOMP_RET_DATA	0x0000ffffU
+
 /* Format of the data the BPF program executes over. */
 struct seccomp_data {
 	int nr;
@@ -57,11 +61,17 @@ struct seccomp {
 	struct seccomp_filter *filter;
 };
 
-extern void __secure_computing(int);
-static inline void secure_computing(int this_syscall)
+/*
+ * Direct callers to __secure_computing should be updated as
+ * CONFIG_HAVE_ARCH_SECCOMP_FILTER propagates.
+ */
+extern void __secure_computing(int) __deprecated;
+extern int __secure_computing_int(int);
+static inline int secure_computing(int this_syscall)
 {
 	if (unlikely(test_thread_flag(TIF_SECCOMP)))
-		__secure_computing(this_syscall);
+		return  __secure_computing_int(this_syscall);
+	return 0;
 }
 
 extern long prctl_get_seccomp(void);
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 14d1869..55d000d 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -137,25 +137,22 @@ static void *bpf_pointer(const void *nr, int off, unsigned int size, void *buf)
 static u32 seccomp_run_filters(int syscall)
 {
 	struct seccomp_filter *f;
-	const struct bpf_load_fns loaders = { bpf_pointer, bpf_length };
-	u32 ret = SECCOMP_RET_KILL;
+	const struct bpf_load_fns fns = { bpf_pointer, bpf_length };
+	u32 ret = SECCOMP_RET_ALLOW;
 	const void *sc_ptr = (const void *)(uintptr_t)syscall;
 
 	/* It's not possible for the filter to be NULL here. */
 #ifdef CONFIG_COMPAT
 	if (current->seccomp.filter->compat != !!(is_compat_task()))
-		return ret;
+		return SECCOMP_RET_KILL;
 #endif
 
 	/*
 	 * All filters are evaluated in order of youngest to oldest. The lowest
 	 * BPF return value always takes priority.
 	 */
-	for (f = current->seccomp.filter; f; f = f->prev) {
-		ret = bpf_run_filter(sc_ptr, f->insns, &loaders);
-		if (ret != SECCOMP_RET_ALLOW)
-			break;
-	}
+	for (f = current->seccomp.filter; f; f = f->prev)
+		ret = min_t(u32, ret, bpf_run_filter(sc_ptr, f->insns, &fns));
 	return ret;
 }
 
@@ -314,6 +311,13 @@ static int mode1_syscalls_32[] = {
 
 void __secure_computing(int this_syscall)
 {
+	/* Filter calls should never use this function. */
+	BUG_ON(current->seccomp.mode == SECCOMP_MODE_FILTER);
+	__secure_computing_int(this_syscall);
+}
+
+int __secure_computing_int(int this_syscall)
+{
 	int mode = current->seccomp.mode;
 	int *syscall;
 
@@ -326,15 +330,28 @@ void __secure_computing(int this_syscall)
 #endif
 		do {
 			if (*syscall == this_syscall)
-				return;
+				return 0;
 		} while (*++syscall);
 		break;
 #ifdef CONFIG_SECCOMP_FILTER
-	case SECCOMP_MODE_FILTER:
-		if (seccomp_run_filters(this_syscall) == SECCOMP_RET_ALLOW)
-			return;
+	case SECCOMP_MODE_FILTER: {
+		u32 action = seccomp_run_filters(this_syscall);
+		switch (action & SECCOMP_RET_ACTION) {
+		case SECCOMP_RET_ERRNO:
+			/* Set the low-order 16-bits as a errno. */
+			syscall_set_return_value(current, task_pt_regs(current),
+						 -(action & SECCOMP_RET_DATA),
+						 0);
+			return -1;
+		case SECCOMP_RET_ALLOW:
+			return 0;
+		case SECCOMP_RET_KILL:
+		default:
+			break;
+		}
 		seccomp_filter_log_failure(this_syscall);
 		break;
+	}
 #endif
 	default:
 		BUG();
@@ -345,6 +362,7 @@ void __secure_computing(int this_syscall)
 #endif
 	audit_seccomp(this_syscall);
 	do_exit(SIGKILL);
+	return -1;	/* never reached */
 }
 
 long prctl_get_seccomp(void)
-- 
1.7.5.4

