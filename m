From: Will Drewry <wad@chromium.org>
Subject: [PATCH v8 5/8] seccomp: Add SECCOMP_RET_TRAP
Date: Thu, 16 Feb 2012 14:02:26 -0600
Message-ID: <1329422549-16407-5-git-send-email-wad@chromium.org>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.org, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329422549-16407-1-git-send-email-wad@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds a new return value to seccomp filters that triggers a SIGTRAP to be
delivered with the new TRAP_SECCOMP si_code.

This allows in-process system call emulation -- including just
specifying an errno or cleanly dumping core -- rather than just dying.

Supporting this change requires that secure_computing returns a value.
This change adds an int return value and creates a new
__secure_computing_int and deprecates the old __secure_computing call.
This allows for piecemeal arch updating using HAVE_ARCH_SECCOMP_FILTER.
(If -1 is returned, the system call must be skipped.)

Note, the addition of TRAP_SECCOMP may not be appropriate. There are
GNU specific extensions in place (e.g., TRAP_HWBKPT), but I'm not sure
how sacred the definitions are.  If it would be preferable to add
a brand new si_code independent of the TRAP_* or use the unused si_errno
(with ENOSYS), or do something totally different, please let me know!

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
index 0dd4e87..a6c51a6 100644
--- a/include/asm-generic/siginfo.h
+++ b/include/asm-generic/siginfo.h
@@ -207,7 +207,8 @@ typedef struct siginfo {
 #define TRAP_TRACE	(__SI_FAULT|2)	/* process trace trap */
 #define TRAP_BRANCH     (__SI_FAULT|3)  /* process taken branch trap */
 #define TRAP_HWBKPT     (__SI_FAULT|4)  /* hardware breakpoint/watchpoint */
-#define NSIGTRAP	4
+#define TRAP_SECCOMP    (__SI_FAULT|5)  /* secure computing trap */
+#define NSIGTRAP	5
 
 /*
  * SIGCHLD si_codes
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
index 55d000d..c75485c 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -290,6 +290,21 @@ void copy_seccomp(struct seccomp *child,
 	child->mode = prev->mode;
 	child->filter = get_seccomp_filter(prev->filter);
 }
+
+/**
+ * seccomp_send_sigtrap - signals the task to allow in-process syscall emulation
+ *
+ * Forces a SIGTRAP with si_code of TRAP_SECCOMP.
+ */
+static void seccomp_send_sigtrap(void)
+{
+	struct siginfo info;
+	memset(&info, 0, sizeof(info));
+	info.si_signo = SIGTRAP;
+	info.si_code = TRAP_SECCOMP;
+	info.si_addr = (void __user *)KSTK_EIP(current);
+	force_sig_info(SIGTRAP, &info, current);
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
+			seccomp_send_sigtrap();
+			return -1;
 		case SECCOMP_RET_ALLOW:
 			return 0;
 		case SECCOMP_RET_KILL:
-- 
1.7.5.4
