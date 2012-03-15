From: Will Drewry <wad@chromium.org>
Subject: [PATCH v15 04/13] arch/x86: add syscall_get_arch to syscall.h
Date: Wed, 14 Mar 2012 22:11:56 -0500
Message-ID: <1331781125-15658-5-git-send-email-wad@chromium.org>
References: <1331781125-15658-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
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
Return-path: <kernel-hardening-return-1125-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1331781125-15658-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

Add syscall_get_arch() to export the current AUDIT_ARCH_* based on system call
entry path.

Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Will Drewry <wad@chromium.org>

v14: rebase/nochanges
v13: rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
---
 arch/x86/include/asm/syscall.h |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
index d962e56..1d713e4 100644
--- a/arch/x86/include/asm/syscall.h
+++ b/arch/x86/include/asm/syscall.h
@@ -13,6 +13,7 @@
 #ifndef _ASM_X86_SYSCALL_H
 #define _ASM_X86_SYSCALL_H
 
+#include <linux/audit.h>
 #include <linux/sched.h>
 #include <linux/err.h>
 #include <asm/asm-offsets.h>	/* For NR_syscalls */
@@ -87,6 +88,12 @@ static inline void syscall_set_arguments(struct task_struct *task,
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
@@ -211,6 +218,22 @@ static inline void syscall_set_arguments(struct task_struct *task,
 		}
 }
 
+static inline int syscall_get_arch(struct task_struct *task,
+				   struct pt_regs *regs)
+{
+#ifdef CONFIG_IA32_EMULATION
+	/*
+	 * TS_COMPAT is set for 32-bit syscall entries and then
+	 * remains set until we return to user mode.
+	 *
+	 * TIF_IA32 tasks should always have TS_COMPAT set at
+	 * system call time.
+	 */
+	if (task_thread_info(task)->status & TS_COMPAT)
+		return AUDIT_ARCH_I386;
+#endif
+	return AUDIT_ARCH_X86_64;
+}
 #endif	/* CONFIG_X86_32 */
 
 #endif	/* _ASM_X86_SYSCALL_H */
-- 
1.7.5.4
