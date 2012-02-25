From: Will Drewry <wad@chromium.org>
Subject: [PATCH v11 05/12] arch/x86: add syscall_get_arch to syscall.h
Date: Fri, 24 Feb 2012 21:21:44 -0600
Message-ID: <1330140111-17201-5-git-send-email-wad@chromium.org>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
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
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60548 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932271Ab2BYDWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 22:22:48 -0500
Received: by ggnh1 with SMTP id h1so1475925ggn.19
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2012 19:22:48 -0800 (PST)
In-Reply-To: <1330140111-17201-1-git-send-email-wad@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add syscall_get_arch() to export the current AUDIT_ARCH_* based on system call
entry path.

Signed-off-by: Will Drewry <wad@chromium.org>
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
