From: Will Drewry <wad@chromium.org>
Subject: [PATCH v12 07/13] seccomp: add SECCOMP_RET_ERRNO
Date: Wed, 29 Feb 2012 17:53:34 -0600
Message-ID: <1330559620-23543-7-git-send-email-wad@chromium.org>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Cc: linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org,
	x86@kernel.org,
	arnd@arndb.de,
	davem@davemloft.net,
	hpa@zytor.com,
	mingo@redhat.com,
	oleg@redhat.com,
	peterz@infradead.org,
	rdunlap@xenotime.net,
	mcgrathr@chromium.org,
	tglx@linutronix.de,
	luto@mit.edu,
	eparis@redhat.com,
	serge.hallyn@canonical.com,
	djm@mindrot.org,
	scarybeasts@gmail.com,
	indan@nul.nu,
	pmoore@redhat.com,
	akpm@linux-foundation.org,
	corbet@lwn.net,
	eric.dumazet@gmail.com,
	markus@chromium.org,
	coreyb@linux.vnet.ibm.com,
	keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-1008-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1330559620-23543-1-git-send-email-wad@chromium.org>
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

v12: - move to WARN_ON if filter is NULL
       (oleg@redhat.com, luto@mit.edu, keescook@chromium.org)
     - return immediately for filter==NULL (keescook@chromium.org)
     - change evaluation to only compare the ACTION so that layered
       errnos don't result in the lowest one being returned.
       (keeschook@chromium.org)
v11: - check for NULL filter (keescook@chromium.org)
v10: - change loaders to fn
 v9: - n/a
 v8: - update Kconfig to note new need for syscall_set_return_value.
     - reordered such that TRAP behavior follows on later.
     - made the for loop a little less indent-y
 v7: - introduced

Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Will Drewry <wad@chromium.org>
---
 arch/Kconfig            |    6 ++++--
 include/linux/seccomp.h |   15 +++++++++++----
 kernel/seccomp.c        |   43 ++++++++++++++++++++++++++++++++++---------
 3 files changed, 49 insertions(+), 15 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 7a696a9..1350d07 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -237,8 +237,10 @@ config HAVE_ARCH_SECCOMP_FILTER
 	bool
 	help
 	  This symbol should be selected by an architecure if it provides
-	  asm/syscall.h, specifically syscall_get_arguments() and
-	  syscall_get_arch().
+	  asm/syscall.h, specifically syscall_get_arguments(),
+	  syscall_get_arch(), and syscall_set_return_value().  Additionally,
+	  its system call entry path must respect a return value of -1 from
+	  __secure_computing_int() and/or secure_computing().
 
 config SECCOMP_FILTER
 	def_bool y
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 6ef133c..a81fccd 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -12,13 +12,14 @@
 
 /*
  * All BPF programs must return a 32-bit value.
- * The bottom 16-bits are reserved for future use.
+ * The bottom 16-bits are for optional return data.
  * The upper 16-bits are ordered from least permissive values to most.
  *
  * The ordering ensures that a min_t() over composed return values always
  * selects the least permissive choice.
  */
 #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
+#define SECCOMP_RET_ERRNO	0x00030000U /* returns an errno */
 #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
 
 /* Masks for the return value sections. */
@@ -64,11 +65,17 @@ struct seccomp {
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
index 71df324..88dd568 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -137,21 +137,25 @@ static void *bpf_load(const void *nr, int off, unsigned int size, void *buf)
 static u32 seccomp_run_filters(int syscall)
 {
 	struct seccomp_filter *f;
-	u32 ret = SECCOMP_RET_KILL;
 	static const struct bpf_load_fn fns = {
 		bpf_load,
 		sizeof(struct seccomp_data),
 	};
+	u32 ret = SECCOMP_RET_ALLOW;
 	const void *sc_ptr = (const void *)(uintptr_t)syscall;
 
+	/* Ensure unexpected behavior doesn't result in failing open. */
+	if (WARN_ON(current->seccomp.filter == NULL))
+		return SECCOMP_RET_KILL;
+
 	/*
 	 * All filters are evaluated in order of youngest to oldest. The lowest
-	 * BPF return value always takes priority.
+	 * BPF return value (ignoring the DATA) always takes priority.
 	 */
 	for (f = current->seccomp.filter; f; f = f->prev) {
-		ret = bpf_run_filter(sc_ptr, f->insns, &fns);
-		if (ret != SECCOMP_RET_ALLOW)
-			break;
+		u32 cur_ret = bpf_run_filter(sc_ptr, f->insns, &fns);
+		if ((cur_ret & SECCOMP_RET_ACTION) < (ret & SECCOMP_RET_ACTION))
+			ret = cur_ret;
 	}
 	return ret;
 }
@@ -289,6 +293,13 @@ static int mode1_syscalls_32[] = {
 
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
 	int exit_code = SIGKILL;
 	int *syscall;
@@ -302,16 +313,29 @@ void __secure_computing(int this_syscall)
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
 		exit_code = SIGSYS;
 		break;
+	}
 #endif
 	default:
 		BUG();
@@ -322,6 +346,7 @@ void __secure_computing(int this_syscall)
 #endif
 	audit_seccomp(this_syscall);
 	do_exit(exit_code);
+	return -1;	/* never reached */
 }
 
 long prctl_get_seccomp(void)
-- 
1.7.5.4
