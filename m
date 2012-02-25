From: Will Drewry <wad@chromium.org>
Subject: [PATCH v11 10/12] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Fri, 24 Feb 2012 21:21:49 -0600
Message-ID: <1330140111-17201-10-git-send-email-wad@chromium.org>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
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
Return-path: <kernel-hardening-return-955-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1330140111-17201-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

This change adds support for a new ptrace option, PTRACE_O_TRACESECCOMP,
and a new return value for seccomp BPF programs, SECCOMP_RET_TRACE.

When a tracer specifies PTRACE_O_TRACESECCOMP while using
PTRACE_SYSCALL, system call notification will _only_ occur when
a seccomp BPF program returns SECCOMP_RET_TRACE.  No other system
calls will notify the tracer.

If the subordinate process is not using seccomp filter, then no
system call notifications will occur.

If there is no attached tracer when SECCOMP_RET_TRACE is returned,
the system call will not be executed and an -ENOSYS errno will be
returned to userspace.

Interestingly, this change does not add a dependency on the system
call slow path.  Instead, seccomp will only interact with ptrace
if TIF_SYSCALL_TRACE is enabled which also means the task is in
the system call slow path already and the requisite registers
are populated.

I realize that there are pending patches for cleaning up ptrace events.
I can either reintegrate with those when they are available or vice
versa. That's assuming these changes make sense and are viable.  It's
also possible to use ptrace_event(PTRACE_EVENT_SECCOMP) instead, but it
seemed sane to share the syscall path.

v11: - invert the logic to just make it a PTRACE_SYSCALL accelerator
       (indan@nul.nu)
v10: - moved to PTRACE_O_SECCOMP / PT_TRACE_SECCOMP
v9:  - n/a
v8:  - guarded PTRACE_SECCOMP use with an ifdef
v7:  - introduced

Signed-off-by: Will Drewry <wad@chromium.org>
---
 arch/Kconfig              |    1 +
 include/linux/ptrace.h    |    7 +++++--
 include/linux/seccomp.h   |    4 +++-
 include/linux/tracehook.h |    6 ++++++
 kernel/ptrace.c           |    4 ++++
 kernel/seccomp.c          |   18 ++++++++++++++++++
 6 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index d92a78e..bceced5 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -203,6 +203,7 @@ config HAVE_ARCH_SECCOMP_FILTER
 	bool
 	help
 	  This symbol should be selected by an architecure if it provides:
+	  linux/tracehook.h, for TIF_SYSCALL_TRACE and ptrace_report_syscall
 	  asm/syscall.h:
 	  - syscall_get_arch()
 	  - syscall_get_arguments()
diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index c2f1f6a..2fccdbc 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -62,8 +62,9 @@
 #define PTRACE_O_TRACEEXEC	0x00000010
 #define PTRACE_O_TRACEVFORKDONE	0x00000020
 #define PTRACE_O_TRACEEXIT	0x00000040
+#define PTRACE_O_TRACESECCOMP	0x00000080
 
-#define PTRACE_O_MASK		0x0000007f
+#define PTRACE_O_MASK		0x000000ff
 
 /* Wait extended result codes for the above trace options.  */
 #define PTRACE_EVENT_FORK	1
@@ -73,6 +74,7 @@
 #define PTRACE_EVENT_VFORK_DONE	5
 #define PTRACE_EVENT_EXIT	6
 #define PTRACE_EVENT_STOP	7
+#define PTRACE_EVENT_SECCOMP	8	/* never directly delivered */
 
 #include <asm/ptrace.h>
 
@@ -101,8 +103,9 @@
 #define PT_TRACE_EXEC		PT_EVENT_FLAG(PTRACE_EVENT_EXEC)
 #define PT_TRACE_VFORK_DONE	PT_EVENT_FLAG(PTRACE_EVENT_VFORK_DONE)
 #define PT_TRACE_EXIT		PT_EVENT_FLAG(PTRACE_EVENT_EXIT)
+#define PT_TRACE_SECCOMP	PT_EVENT_FLAG(PTRACE_EVENT_SECCOMP)
 
-#define PT_TRACE_MASK	0x000003f4
+#define PT_TRACE_MASK	0x00000ff4
 
 /* single stepping state bits (used on ARM and PA-RISC) */
 #define PT_SINGLESTEP_BIT	31
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index b44d038..b53104b 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -21,6 +21,7 @@
 #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
 #define SECCOMP_RET_TRAP	0x00020000U /* disallow and force a SIGSYS */
 #define SECCOMP_RET_ERRNO	0x00030000U /* returns an errno */
+#define SECCOMP_RET_TRACE	0x7ffe0000U /* pass to a tracer or disallow */
 #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
 
 /* Masks for the return value sections. */
@@ -55,6 +56,7 @@ struct seccomp_filter;
  *
  * @mode:  indicates one of the valid values above for controlled
  *         system calls available to a process.
+ * @trace: tells tracehook to notify for the current syscall.
  * @filter: The metadata and ruleset for determining what system calls
  *          are allowed for a task.
  *
@@ -63,6 +65,7 @@ struct seccomp_filter;
  */
 struct seccomp {
 	int mode;
+	int trace;
 	struct seccomp_filter *filter;
 };
 
@@ -118,7 +121,6 @@ extern void copy_seccomp(struct seccomp *child, const struct seccomp *parent);
 #else  /* CONFIG_SECCOMP_FILTER */
 /* The macro consumes the ->filter reference. */
 #define put_seccomp_filter(_s) do { } while (0)
-
 static inline void copy_seccomp(struct seccomp *c, const struct seccomp *p)
 {
 	return;
diff --git a/include/linux/tracehook.h b/include/linux/tracehook.h
index a71a292..68e9478 100644
--- a/include/linux/tracehook.h
+++ b/include/linux/tracehook.h
@@ -48,6 +48,7 @@
 
 #include <linux/sched.h>
 #include <linux/ptrace.h>
+#include <linux/seccomp.h>
 #include <linux/security.h>
 struct linux_binprm;
 
@@ -61,6 +62,11 @@ static inline void ptrace_report_syscall(struct pt_regs *regs)
 	if (!(ptrace & PT_PTRACED))
 		return;
 
+#ifdef CONFIG_SECCOMP_FILTER
+	if ((ptrace & PT_TRACE_SECCOMP) && !current->seccomp.trace)
+		return;
+#endif
+
 	ptrace_notify(SIGTRAP | ((ptrace & PT_TRACESYSGOOD) ? 0x80 : 0));
 
 	/*
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 00ab2ca..61e5ac4 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -19,6 +19,7 @@
 #include <linux/signal.h>
 #include <linux/audit.h>
 #include <linux/pid_namespace.h>
+#include <linux/seccomp.h>
 #include <linux/syscalls.h>
 #include <linux/uaccess.h>
 #include <linux/regset.h>
@@ -551,6 +552,9 @@ static int ptrace_setoptions(struct task_struct *child, unsigned long data)
 	if (data & PTRACE_O_TRACEEXIT)
 		child->ptrace |= PT_TRACE_EXIT;
 
+	if (data & PTRACE_O_TRACESECCOMP)
+		child->ptrace |= PT_TRACE_SECCOMP;
+
 	return (data & ~PTRACE_O_MASK) ? -EINVAL : 0;
 }
 
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index d2e173e..5aabc3c 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -354,6 +354,24 @@ int __secure_computing_int(int this_syscall)
 			seccomp_send_sigsys(this_syscall, reason_code);
 			return -1;
 		}
+		case SECCOMP_RET_TRACE: {
+			int ret;
+			struct pt_regs *regs = task_pt_regs(current);
+			if (!(test_tsk_thread_flag(current, TIF_SYSCALL_TRACE)) ||
+			    !(current->ptrace & PT_TRACE_SECCOMP))
+				return -1;
+			/*
+			 * PT_TRACE_SECCOMP and seccomp.trace indicate whether
+			 * tracehook_report_syscall_entry needs to signal the
+			 * tracer.  This avoids race conditions in hand off and
+			 * the requirement for TIF_SYSCALL_TRACE ensures that
+			 * we are in the syscall slow path.
+			 */
+			current->seccomp.trace = 1;
+			ret = tracehook_report_syscall_entry(regs);
+			current->seccomp.trace = 0;
+			return ret;
+		}
 		case SECCOMP_RET_ALLOW:
 			return 0;
 		case SECCOMP_RET_KILL:
-- 
1.7.5.4
