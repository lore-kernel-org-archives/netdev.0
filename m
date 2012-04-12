From: Will Drewry <wad@chromium.org>
Subject: [PATCH v18 07/15] arch/x86: add syscall_get_arch to syscall.h
Date: Thu, 12 Apr 2012 16:47:56 -0500
Message-ID: <1334267284-19166-7-git-send-email-wad@chromium.org>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
Cc: linux-man@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	jmorris@namei.org, Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1334267284-19166-1-git-send-email-wad@chromium.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add syscall_get_arch() to export the current AUDIT_ARCH_* based on system call
entry path.

Signed-off-by: Will Drewry <wad@chromium.org>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Reviewed-by: H. Peter Anvin <hpa@zytor.com>
Acked-by: Eric Paris <eparis@redhat.com>

v18: - update comment about x32 tasks
     - rebase to v3.4-rc2
v17: rebase and reviewed-by
v14: rebase/nochanges
v13: rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
---
 arch/x86/include/asm/syscall.h |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
index 386b786..1ace47b 100644
--- a/arch/x86/include/asm/syscall.h
+++ b/arch/x86/include/asm/syscall.h
@@ -13,9 +13,11 @@
 #ifndef _ASM_X86_SYSCALL_H
 #define _ASM_X86_SYSCALL_H
 
+#include <linux/audit.h>
 #include <linux/sched.h>
 #include <linux/err.h>
 #include <asm/asm-offsets.h>	/* For NR_syscalls */
+#include <asm/thread_info.h>	/* for TS_COMPAT */
 #include <asm/unistd.h>
 
 extern const unsigned long sys_call_table[];
@@ -88,6 +90,12 @@ static inline void syscall_set_arguments(struct task_struct *task,
 	memcpy(&regs->bx + i, args, n * sizeof(args[0]));
 }
 
+static inline int syscall_get_arch(struct task_struct *task,
+				   struct pt_regs *regs)
+{
+	return AUDIT_ARCH_I386;
+}
+
 #else	 /* CONFIG_X86_64 */
 
 static inline void syscall_get_arguments(struct task_struct *task,
@@ -212,6 +220,25 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		}
 }
 
+static inline int syscall_get_arch(struct task_struct *task,
+				   struct pt_regs *regs)
+{
+#ifdef CONFIG_IA32_EMULATION
+	/*
+	 * TS_COMPAT is set for 32-bit syscall entry and then
+	 * remains set until we return to user mode.
+	 *
+	 * TIF_IA32 tasks should always have TS_COMPAT set at
+	 * system call time.
+	 *
+	 * x32 tasks should be considered AUDIT_ARCH_X86_64.
+	 */
+	if (task_thread_info(task)->status & TS_COMPAT)
+		return AUDIT_ARCH_I386;
+#endif
+	/* Both x32 and x86_64 are considered "64-bit". */
+	return AUDIT_ARCH_X86_64;
+}
 #endif	/* CONFIG_X86_32 */
 
 #endif	/* _ASM_X86_SYSCALL_H */
-- 
1.7.5.4

