From: Will Drewry <wad@chromium.org>
Subject: [PATCH v12 10/13] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Wed, 29 Feb 2012 17:53:37 -0600
Message-ID: <1330559620-23543-10-git-send-email-wad@chromium.org>
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
Return-path: <kernel-hardening-return-1012-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1330559620-23543-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

This change adds support for a new ptrace option, PTRACE_O_TRACESECCOMP,
and a new return value for seccomp BPF programs, SECCOMP_RET_TRACE.

When a tracer specifies the PTRACE_O_TRACESECCOMP ptrace option, the
tracer will be notified for any syscall that results in a BPF program
returning SECCOMP_RET_TRACE.  The 16-bit SECCOMP_RET_DATA mask of the
BPF program return value will be passed as the ptrace_message and may be
retrieved using PTRACE_GETEVENTMSG.

If the subordinate process is not using seccomp filter, then no
system call notifications will occur even if the option is specified.

If there is no attached tracer when SECCOMP_RET_TRACE is returned,
the system call will not be executed and an -ENOSYS errno will be
returned to userspace.

This change adds a dependency on the system call slow path.  Any future
efforts to use the system call fast path for seccomp filter will need to
address this restriction.

v12: - rebase to linux-next
     - use ptrace_event and update arch/Kconfig to mention slow-path dependency
     - drop all tracehook changes and inclusion (oleg@redhat.com)
v11: - invert the logic to just make it a PTRACE_SYSCALL accelerator
       (indan@nul.nu)
v10: - moved to PTRACE_O_SECCOMP / PT_TRACE_SECCOMP
v9:  - n/a
v8:  - guarded PTRACE_SECCOMP use with an ifdef
v7:  - introduced

Signed-off-by: Will Drewry <wad@chromium.org>
---
 arch/Kconfig            |   11 ++++++-----
 include/linux/ptrace.h  |    5 ++++-
 include/linux/seccomp.h |    1 +
 kernel/seccomp.c        |   20 +++++++++++++++-----
 4 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 6908bf6..beb1507 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -236,15 +236,16 @@ config ARCH_WANT_OLD_COMPAT_IPC
 config HAVE_ARCH_SECCOMP_FILTER
 	bool
 	help
-	  This symbol should be selected by an architecure if it provides:
-	  asm/syscall.h:
+	  An arch should select this symbol if it provides all of these things:
 	  - syscall_get_arch()
 	  - syscall_get_arguments()
 	  - syscall_rollback()
 	  - syscall_set_return_value()
-	  SIGSYS siginfo_t support must be implemented.
-	  __secure_computing_int()/secure_computing()'s return value must be
-	  checked, with -1 resulting in the syscall being skipped.
+	  - SIGSYS siginfo_t support
+	  - uses __secure_computing_int() or secure_computing()
+	  - secure_computing is called from a ptrace_event()-safe context
+	  - secure_computing return value is checked and a return value of -1
+	    results in the system call being skipped immediately.
 
 config SECCOMP_FILTER
 	def_bool y
diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index 5c71962..597e4fd 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -58,6 +58,7 @@
 #define PTRACE_EVENT_EXEC	4
 #define PTRACE_EVENT_VFORK_DONE	5
 #define PTRACE_EVENT_EXIT	6
+#define PTRACE_EVENT_SECCOMP	7
 /* Extended result codes which enabled by means other than options.  */
 #define PTRACE_EVENT_STOP	128
 
@@ -69,8 +70,9 @@
 #define PTRACE_O_TRACEEXEC	(1 << PTRACE_EVENT_EXEC)
 #define PTRACE_O_TRACEVFORKDONE	(1 << PTRACE_EVENT_VFORK_DONE)
 #define PTRACE_O_TRACEEXIT	(1 << PTRACE_EVENT_EXIT)
+#define PTRACE_O_TRACESECCOMP	(1 << PTRACE_EVENT_SECCOMP)
 
-#define PTRACE_O_MASK		0x0000007f
+#define PTRACE_O_MASK		0x000000ff
 
 #include <asm/ptrace.h>
 
@@ -98,6 +100,7 @@
 #define PT_TRACE_EXEC		PT_EVENT_FLAG(PTRACE_EVENT_EXEC)
 #define PT_TRACE_VFORK_DONE	PT_EVENT_FLAG(PTRACE_EVENT_VFORK_DONE)
 #define PT_TRACE_EXIT		PT_EVENT_FLAG(PTRACE_EVENT_EXIT)
+#define PT_TRACE_SECCOMP	PT_EVENT_FLAG(PTRACE_EVENT_SECCOMP)
 
 /* single stepping state bits (used on ARM and PA-RISC) */
 #define PT_SINGLESTEP_BIT	31
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 3fe48fd..e183598 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -21,6 +21,7 @@
 #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
 #define SECCOMP_RET_TRAP	0x00020000U /* disallow and force a SIGSYS */
 #define SECCOMP_RET_ERRNO	0x00030000U /* returns an errno */
+#define SECCOMP_RET_TRACE	0x7ffe0000U /* pass to a tracer or disallow */
 #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
 
 /* Masks for the return value sections. */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 10c6077..1064327 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -17,13 +17,13 @@
 #include <linux/audit.h>
 #include <linux/compat.h>
 #include <linux/filter.h>
+#include <linux/ptrace.h>
 #include <linux/sched.h>
 #include <linux/seccomp.h>
 #include <linux/security.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
 
-#include <linux/tracehook.h>
 #include <asm/syscall.h>
 
 /* #define SECCOMP_DEBUG 1 */
@@ -346,14 +346,24 @@ int __secure_computing_int(int this_syscall)
 						 -(action & SECCOMP_RET_DATA),
 						 0);
 			return -1;
-		case SECCOMP_RET_TRAP: {
-			int reason_code = action & SECCOMP_RET_DATA;
+		case SECCOMP_RET_TRAP:
 			/* Show the handler the original registers. */
 			syscall_rollback(current, task_pt_regs(current));
 			/* Let the filter pass back 16 bits of data. */
-			seccomp_send_sigsys(this_syscall, reason_code);
+			seccomp_send_sigsys(this_syscall,
+					    action & SECCOMP_RET_DATA);
 			return -1;
-		}
+		case SECCOMP_RET_TRACE:
+			/* Skip these calls if there is no tracer. */
+			if (!ptrace_event_enabled(current,
+						  PTRACE_EVENT_SECCOMP))
+				return -1;
+			/* Allow the BPF to provide the event message */
+			ptrace_event(PTRACE_EVENT_SECCOMP,
+				     action & SECCOMP_RET_DATA);
+			if (fatal_signal_pending(current))
+				break;
+			return 0;
 		case SECCOMP_RET_ALLOW:
 			return 0;
 		case SECCOMP_RET_KILL:
-- 
1.7.5.4
