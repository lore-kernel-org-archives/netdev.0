From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC PATCH v2 tip 4/7] Revert "x86/ptrace: Remove unused regs_get_argument_nth API"
Date: Wed,  5 Feb 2014 17:10:43 -0800
Message-ID: <1391649046-4383-5-git-send-email-ast@plumgrid.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:44330 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148AbaBFBLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 20:11:01 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so1054247pde.20
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 17:11:00 -0800 (PST)
In-Reply-To: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit aa5add93e92019018e905146f8c3d3f8e3c08300.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/x86/include/asm/ptrace.h |    3 +++
 arch/x86/kernel/ptrace.c      |   24 ++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/arch/x86/include/asm/ptrace.h b/arch/x86/include/asm/ptrace.h
index 14fd6fd..e026176 100644
--- a/arch/x86/include/asm/ptrace.h
+++ b/arch/x86/include/asm/ptrace.h
@@ -222,6 +222,9 @@ static inline unsigned long regs_get_kernel_stack_nth(struct pt_regs *regs,
 		return 0;
 }
 
+/* Get Nth argument at function call */
+unsigned long regs_get_argument_nth(struct pt_regs *regs, unsigned int n);
+
 #define arch_has_single_step()	(1)
 #ifdef CONFIG_X86_DEBUGCTLMSR
 #define arch_has_block_step()	(1)
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 7461f50..ac1c705 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -141,6 +141,30 @@ static const int arg_offs_table[] = {
 #endif
 };
 
+/**
+ * regs_get_argument_nth() - get Nth argument at function call
+ * @regs:	pt_regs which contains registers at function entry.
+ * @n:		argument number.
+ *
+ * regs_get_argument_nth() returns @n th argument of a function call.
+ * Since usually the kernel stack will be changed right after function entry,
+ * you must use this at function entry. If the @n th entry is NOT in the
+ * kernel stack or pt_regs, this returns 0.
+ */
+unsigned long regs_get_argument_nth(struct pt_regs *regs, unsigned int n)
+{
+	if (n < ARRAY_SIZE(arg_offs_table))
+		return *(unsigned long *)((char *)regs + arg_offs_table[n]);
+	else {
+		/*
+		 * The typical case: arg n is on the stack.
+		 * (Note: stack[0] = return address, so skip it)
+		 */
+		n -= ARRAY_SIZE(arg_offs_table);
+		return regs_get_kernel_stack_nth(regs, 1 + n);
+	}
+}
+
 /*
  * does not yet catch signals sent when the child dies.
  * in exit.c or in signal.c.
-- 
1.7.9.5
