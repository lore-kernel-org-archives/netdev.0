From: Will Drewry <wad@chromium.org>
Subject: [PATCH v9 5/8] seccomp: Add SECCOMP_RET_TRAP
Date: Thu, 16 Feb 2012 15:11:45 -0600
Message-ID: <1329426706-26562-1-git-send-email-wad@chromium.org>
References: <CABqD9hZSLqn+=jr6sWwp_eJ5WsuGpH2Khoc_7aRmYt+1ZaEGoA@mail.gmail.com>
Mime-Version: 1.0
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABqD9hZSLqn+=jr6sWwp_eJ5WsuGpH2Khoc_7aRmYt+1ZaEGoA@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds a new return value to seccomp filters that triggers a SIGILL to be
delivered with the new ILL_SECCOMP si_code.

This allows in-process system call emulation, including just specifying
an errno or cleanly dumping core, rather than just dying.  It also
avoids interfering with normal debugger operation (injecting SIGTRAPs).

v9: - changes to SIGILL (markus@chromium.org)
v8: - clean up based on changes to dependent patches
v7: - introduction

Signed-off-by: Will Drewry <wad@chromium.org>
---
 arch/Kconfig                  |    8 ++++----
 include/asm-generic/siginfo.h |    3 ++-
 include/linux/seccomp.h       |    1 +
 kernel/seccomp.c              |   20 ++++++++++++++++++++
 4 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 3f3052b..a01c151 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -203,10 +203,10 @@ config HAVE_ARCH_SECCOMP_FILTER
 	bool
 	help
 	  This symbol should be selected by an architecure if it provides
-	  asm/syscall.h, specifically syscall_get_arguments() and
-	  syscall_set_return_value().  Additionally, its system call
-	  entry path must respect a return value of -1 from
-	  __secure_computing_int() and/or secure_computing().
+	  asm/syscall.h, specifically syscall_get_arguments(),
+	  syscall_set_return_value(), and syscall_rollback().
+	  Additionally, its system call entry path must respect a return
+	  value of -1 from __secure_computing_int() and/or secure_computing().
 
 config SECCOMP_FILTER
 	def_bool y
diff --git a/include/asm-generic/siginfo.h b/include/asm-generic/siginfo.h
index 0dd4e87..e565662 100644
--- a/include/asm-generic/siginfo.h
+++ b/include/asm-generic/siginfo.h
@@ -166,7 +166,8 @@ typedef struct siginfo {
 #define ILL_PRVREG	(__SI_FAULT|6)	/* privileged register */
 #define ILL_COPROC	(__SI_FAULT|7)	/* coprocessor error */
 #define ILL_BADSTK	(__SI_FAULT|8)	/* internal stack error */
-#define NSIGILL		8
+#define ILL_SECCOMP	(__SI_FAULT|9)	/* illegal syscall via seccomp */
+#define NSIGILL		9
 
 /*
  * SIGFPE si_codes
diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index 879ece2..1be562f 100644
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
index 55d000d..a7b6510 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -290,6 +290,21 @@ void copy_seccomp(struct seccomp *child,
 	child->mode = prev->mode;
 	child->filter = get_seccomp_filter(prev->filter);
 }
+
+/**
+ * seccomp_send_sigill - signals the task to allow in-process syscall emulation
+ *
+ * Forces a SIGILL with si_code of ILL_SECCOMP.
+ */
+static void seccomp_send_sigill(void)
+{
+	struct siginfo info;
+	memset(&info, 0, sizeof(info));
+	info.si_signo = SIGILL;
+	info.si_code = ILL_SECCOMP;
+	info.si_addr = (void __user *)KSTK_EIP(current);
+	force_sig_info(SIGILL, &info, current);
+}
 #endif	/* CONFIG_SECCOMP_FILTER */
 
 /*
@@ -343,6 +358,11 @@ int __secure_computing_int(int this_syscall)
 						 -(action & SECCOMP_RET_DATA),
 						 0);
 			return -1;
+		case SECCOMP_RET_TRAP:
+			/* Show the handler the original registers. */
+			syscall_rollback(current, task_pt_regs(current));
+			seccomp_send_sigill();
+			return -1;
 		case SECCOMP_RET_ALLOW:
 			return 0;
 		case SECCOMP_RET_KILL:
-- 
1.7.5.4

