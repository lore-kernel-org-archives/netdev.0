From: Will Drewry <wad@chromium.org>
Subject: [PATCH v10 08/11] seccomp: Add SECCOMP_RET_TRAP
Date: Tue, 21 Feb 2012 11:30:32 -0600
Message-ID: <1329845435-2313-8-git-send-email-wad@chromium.org>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
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
	keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-879-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1329845435-2313-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

Adds a new return value to seccomp filters that triggers a SIGSYS to be
delivered with the new SYS_SECCOMP si_code.

This allows in-process system call emulation, including just specifying
an errno or cleanly dumping core, rather than just dying.

v10: - use SIGSYS, syscall_get_arch, updates arch/Kconfig
       note suggested-by (though original suggestion had other behaviors)
v9:  - changes to SIGILL
v8:  - clean up based on changes to dependent patches
v7:  - introduction

Suggested-by: Markus Gutschke <markus@chromium.org>
Suggested-by: Julien Tinnes <jln@chromium.org>
Signed-off-by: Will Drewry <wad@chromium.org>
---
 arch/Kconfig            |   14 +++++++++-----
 include/linux/seccomp.h |    1 +
 kernel/seccomp.c        |   28 ++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index aa00571..6d6d9dc 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -202,11 +202,15 @@ config HAVE_CMPXCHG_DOUBLE
 config HAVE_ARCH_SECCOMP_FILTER
 	bool
 	help
-	  This symbol should be selected by an architecure if it provides
-	  asm/syscall.h, specifically syscall_get_arguments(),
-	  syscall_get_arch(), and syscall_set_return_value().  Additionally,
-	  its system call entry path must respect a return value of -1 from
-	  __secure_computing_int() and/or secure_computing().
+	  This symbol should be selected by an architecure if it provides:
+	  asm/syscall.h:
+	  - syscall_get_arch()
+	  - syscall_get_arguments()
+	  - syscall_rollback()
+	  - syscall_set_return_value()
+	  SIGSYS siginfo_t support must be implemented.
+	  __secure_computing_int()/secure_computing()'s return value must be
+	  checked, with -1 resulting in the syscall being skipped.
 
 config SECCOMP_FILTER
 	def_bool y
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 54ecb61..d039b7b 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -19,6 +19,7 @@
  * selects the least permissive choice.
  */
 #define SECCOMP_RET_KILL	0x00000000U /* kill the task immediately */
+#define SECCOMP_RET_TRAP	0x00020000U /* disallow and send sigtrap */
 #define SECCOMP_RET_ERRNO	0x00030000U /* returns an errno */
 #define SECCOMP_RET_ALLOW	0x7fff0000U /* allow */
 
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 23f1844..fc25d3a 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -279,6 +279,26 @@ void copy_seccomp(struct seccomp *child,
 	child->mode = prev->mode;
 	child->filter = get_seccomp_filter(prev->filter);
 }
+
+/**
+ * seccomp_send_sigsys - signals the task to allow in-process syscall emulation
+ * @syscall: syscall number to send to userland
+ * @reason: filter-supplied reason code to send to userland (via si_errno)
+ *
+ * Forces a SIGSYS with a code of SYS_SECCOMP and related sigsys info.
+ */
+static void seccomp_send_sigsys(int syscall, int reason)
+{
+	struct siginfo info;
+	memset(&info, 0, sizeof(info));
+	info.si_signo = SIGSYS;
+	info.si_code = SYS_SECCOMP;
+	info.si_call_addr = (void __user *)KSTK_EIP(current);
+	info.si_errno = reason;
+	info.si_arch = syscall_get_arch(current, task_pt_regs(current));
+	info.si_syscall = syscall;
+	force_sig_info(SIGSYS, &info, current);
+}
 #endif	/* CONFIG_SECCOMP_FILTER */
 
 /*
@@ -332,6 +352,14 @@ int __secure_computing_int(int this_syscall)
 						 -(action & SECCOMP_RET_DATA),
 						 0);
 			return -1;
+		case SECCOMP_RET_TRAP: {
+			int reason_code = action & SECCOMP_RET_DATA;
+			/* Show the handler the original registers. */
+			syscall_rollback(current, task_pt_regs(current));
+			/* Let the filter pass back 16 bits of data. */
+			seccomp_send_sigsys(this_syscall, reason_code);
+			return -1;
+		}
 		case SECCOMP_RET_ALLOW:
 			return 0;
 		case SECCOMP_RET_KILL:
-- 
1.7.5.4
