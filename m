From: Will Drewry <wad@chromium.org>
Subject: [PATCH v15 12/13] x86: Enable HAVE_ARCH_SECCOMP_FILTER
Date: Wed, 14 Mar 2012 22:12:04 -0500
Message-ID: <1331781125-15658-13-git-send-email-wad@chromium.org>
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
Return-path: <kernel-hardening-return-1129-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1331781125-15658-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

Enable support for seccomp filter on x86:
- asm/tracehook.h exists
- syscall_get_arguments() works
- syscall_rollback() works
- ptrace_report_syscall() works
- secure_computing() return value is honored (see below)

This also adds support for honoring the return
value from secure_computing().

SECCOMP_RET_TRACE and SECCOMP_RET_TRAP may result in seccomp needing to
skip a system call without killing the process.  This is done by
returning a non-zero (-1) value from secure_computing.  This change
makes x86 respect that return value.

To ensure that minimal kernel code is exposed, a non-zero return value
results in an immediate return to user space (with an invalid syscall
number).

Signed-off-by: Will Drewry <wad@chromium.org>
---
 arch/x86/Kconfig         |    1 +
 arch/x86/kernel/ptrace.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 5bed94e..4c9012b 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -82,6 +82,7 @@ config X86
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_IOMAP
+	select HAVE_ARCH_SECCOMP_FILTER
 
 config INSTRUCTION_DECODER
 	def_bool (KPROBES || PERF_EVENTS)
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 5026738..90d465a 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -1380,7 +1380,11 @@ long syscall_trace_enter(struct pt_regs *regs)
 		regs->flags |= X86_EFLAGS_TF;
 
 	/* do the secure computing check first */
-	secure_computing(regs->orig_ax);
+	if (secure_computing(regs->orig_ax)) {
+		/* seccomp failures shouldn't expose any additional code. */
+		ret = -1L;
+		goto out;
+	}
 
 	if (unlikely(test_thread_flag(TIF_SYSCALL_EMU)))
 		ret = -1L;
@@ -1405,6 +1409,7 @@ long syscall_trace_enter(struct pt_regs *regs)
 				    regs->dx, regs->r10);
 #endif
 
+out:
 	return ret ?: regs->orig_ax;
 }
 
-- 
1.7.5.4
