From: Will Drewry <wad@chromium.org>
Subject: [PATCH v16 11/13] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Thu, 15 Mar 2012 15:31:20 -0500
Message-ID: <1331843480-6618-1-git-send-email-wad@chromium.org>
References: <34b2e80343549454d6c026237f248c86.squirrel@webmail.greenhost.nl>
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64131 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161465Ab2COUcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 16:32:35 -0400
Received: by ghrr11 with SMTP id r11so3499708ghr.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 13:32:34 -0700 (PDT)
In-Reply-To: <34b2e80343549454d6c026237f248c86.squirrel@webmail.greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

~~
Only this file changed from v15.  However, the whole v16 series may be
pulled from
  https://github.com/redpig/linux/tree/seccomp%2Fv16%2Fposted
The seccomp/v16/posted tag is GPG-signed.
~~

This change adds support for a new ptrace option, PTRACE_O_TRACESECCOMP,
and a new return value for seccomp BPF programs, SECCOMP_RET_TRACE.

When a tracer specifies the PTRACE_O_TRACESECCOMP ptrace option, the
tracer will be notified, via PTRACE_EVENT_SECCOMP, for any syscall that
results in a BPF program returning SECCOMP_RET_TRACE.  The 16-bit
SECCOMP_RET_DATA mask of the BPF program return value will be passed as
the ptrace_message and may be retrieved using PTRACE_GETEVENTMSG.

If the subordinate process is not using seccomp filter, then no
system call notifications will occur even if the option is specified.

If there is no tracer with PTRACE_O_TRACESECCOMP when SECCOMP_RET_TRACE
is returned, the system call will not be executed and an -ENOSYS errno
will be returned to userspace.

This change adds a dependency on the system call slow path.  Any future
efforts to use the system call fast path for seccomp filter will need to
address this restriction.

v16: - update PT_TRACE_MASK to 0xbf4 so that STOP isn't clear on
       SETOPTIONS call (indan@nul.nu)
       [Note, PT_TRACE_MASK disappears in linux-next]
v15: - add audit support for non-zero return codes
     - clean up style (indan@nul.nu)
v14: - rebase/nochanges
v13: - rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
       (Brings back a change to ptrace.c and the masks.)
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
 include/linux/ptrace.h  |    7 +++++--
 include/linux/seccomp.h |    1 +
 kernel/ptrace.c         |    3 +++
 kernel/seccomp.c        |   13 +++++++++++--
 5 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index d92a78e..3f8132c 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -202,15 +202,16 @@ config HAVE_CMPXCHG_DOUBLE
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
index c2f1f6a..3bf7ee9 100644
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
+#define PTRACE_EVENT_SECCOMP	8
 
 #include <asm/ptrace.h>
 
@@ -101,8 +103,9 @@
 #define PT_TRACE_EXEC		PT_EVENT_FLAG(PTRACE_EVENT_EXEC)
 #define PT_TRACE_VFORK_DONE	PT_EVENT_FLAG(PTRACE_EVENT_VFORK_DONE)
 #define PT_TRACE_EXIT		PT_EVENT_FLAG(PTRACE_EVENT_EXIT)
+#define PT_TRACE_SECCOMP	PT_EVENT_FLAG(PTRACE_EVENT_SECCOMP)
 
-#define PT_TRACE_MASK	0x000003f4
+#define PT_TRACE_MASK	0x00000bf4
 
 /* single stepping state bits (used on ARM and PA-RISC) */
 #define PT_SINGLESTEP_BIT	31
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index a5078fb..306733e 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -21,6 +21,7 @@
 #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
 #define SECCOMP_RET_TRAP	0x00030000U /* disallow and force a SIGSYS */
 #define SECCOMP_RET_ERRNO	0x00050000U /* returns an errno */
+#define SECCOMP_RET_TRACE	0x7ff00000U /* pass to a tracer or disallow */
 #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
 
 /* Masks for the return value sections. */
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 00ab2ca..8cf6da1 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -551,6 +551,9 @@ static int ptrace_setoptions(struct task_struct *child, unsigned long data)
 	if (data & PTRACE_O_TRACEEXIT)
 		child->ptrace |= PT_TRACE_EXIT;
 
+	if (data & PTRACE_O_TRACESECCOMP)
+		child->ptrace |= PT_TRACE_SECCOMP;
+
 	return (data & ~PTRACE_O_MASK) ? -EINVAL : 0;
 }
 
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index fb3b993..725e83e 100644
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
@@ -398,7 +398,7 @@ int __secure_computing_int(int this_syscall)
 	case SECCOMP_MODE_FILTER:
 		ret = seccomp_run_filters(this_syscall);
 		data = ret & SECCOMP_RET_DATA;
-		switch (code & SECCOMP_RET_ACTION) {
+		switch (ret & SECCOMP_RET_ACTION) {
 		case SECCOMP_RET_ERRNO:
 			/* Set the low-order 16-bits as a errno. */
 			syscall_set_return_value(current, task_pt_regs(current),
@@ -410,6 +410,15 @@ int __secure_computing_int(int this_syscall)
 			/* Let the filter pass back 16 bits of data. */
 			seccomp_send_sigsys(this_syscall, data);
 			goto skip;
+		case SECCOMP_RET_TRACE:
+			/* Skip these calls if there is no tracer. */
+			if (!ptrace_event_enabled(current, PTRACE_EVENT_SECCOMP))
+				goto skip;
+			/* Allow the BPF to provide the event message */
+			ptrace_event(PTRACE_EVENT_SECCOMP, data);
+			if (fatal_signal_pending(current))
+				break;
+			return 0;
 		case SECCOMP_RET_ALLOW:
 			return 0;
 		case SECCOMP_RET_KILL:
-- 
1.7.5.4
