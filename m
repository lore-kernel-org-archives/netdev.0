From: Will Drewry <wad@chromium.org>
Subject: [PATCH v12 13/13] seccomp: remove duplicated failure logging
Date: Wed, 29 Feb 2012 17:53:40 -0600
Message-ID: <1330559620-23543-13-git-send-email-wad@chromium.org>
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
	keescook@chromium.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-1017-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1330559620-23543-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>

This consolidates the seccomp filter error logging path and adds more
details to the audit log.

Acked-by: Will Drewry <wad@chromium.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/audit.h |    8 ++++----
 kernel/auditsc.c      |    9 +++++++--
 kernel/seccomp.c      |   15 +--------------
 3 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 9ff7a2c..5aac29b 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -463,7 +463,7 @@ extern void audit_putname(const char *name);
 extern void __audit_inode(const char *name, const struct dentry *dentry);
 extern void __audit_inode_child(const struct dentry *dentry,
 				const struct inode *parent);
-extern void __audit_seccomp(unsigned long syscall);
+extern void __audit_seccomp(unsigned long syscall, long signr);
 extern void __audit_ptrace(struct task_struct *t);
 
 static inline int audit_dummy_context(void)
@@ -508,10 +508,10 @@ static inline void audit_inode_child(const struct dentry *dentry,
 }
 void audit_core_dumps(long signr);
 
-static inline void audit_seccomp(unsigned long syscall)
+static inline void audit_seccomp(unsigned long syscall, long signr)
 {
 	if (unlikely(!audit_dummy_context()))
-		__audit_seccomp(syscall);
+		__audit_seccomp(syscall, signr);
 }
 
 static inline void audit_ptrace(struct task_struct *t)
@@ -634,7 +634,7 @@ extern int audit_signals;
 #define audit_inode(n,d) do { (void)(d); } while (0)
 #define audit_inode_child(i,p) do { ; } while (0)
 #define audit_core_dumps(i) do { ; } while (0)
-#define audit_seccomp(i) do { ; } while (0)
+#define audit_seccomp(i, s) do { ; } while (0)
 #define auditsc_get_stamp(c,t,s) (0)
 #define audit_get_loginuid(t) (-1)
 #define audit_get_sessionid(t) (-1)
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index af1de0f..74652fe 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -67,6 +67,7 @@
 #include <linux/syscalls.h>
 #include <linux/capability.h>
 #include <linux/fs_struct.h>
+#include <linux/compat.h>
 
 #include "audit.h"
 
@@ -2710,13 +2711,17 @@ void audit_core_dumps(long signr)
 	audit_log_end(ab);
 }
 
-void __audit_seccomp(unsigned long syscall)
+void __audit_seccomp(unsigned long syscall, long signr)
 {
 	struct audit_buffer *ab;
 
 	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
-	audit_log_abend(ab, "seccomp", SIGKILL);
+	audit_log_abend(ab, "seccomp", signr);
 	audit_log_format(ab, " syscall=%ld", syscall);
+#ifdef CONFIG_COMPAT
+	audit_log_format(ab, " compat=%d", is_compat_task());
+#endif
+	audit_log_format(ab, " ip=0x%lx", KSTK_EIP(current));
 	audit_log_end(ab);
 }
 
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 1064327..78ecd6f 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -60,18 +60,6 @@ struct seccomp_filter {
 /* Limit any path through the tree to 5 megabytes worth of instructions. */
 #define MAX_INSNS_PER_PATH ((5 << 20) / sizeof(struct sock_filter))
 
-static void seccomp_filter_log_failure(int syscall)
-{
-	int compat = 0;
-#ifdef CONFIG_COMPAT
-	compat = is_compat_task();
-#endif
-	pr_info("%s[%d]: %ssystem call %d blocked at 0x%lx\n",
-		current->comm, task_pid_nr(current),
-		(compat ? "compat " : ""),
-		syscall, KSTK_EIP(current));
-}
-
 /**
  * get_u32 - returns a u32 offset into data
  * @data: a unsigned 64 bit value
@@ -370,7 +358,6 @@ int __secure_computing_int(int this_syscall)
 		default:
 			break;
 		}
-		seccomp_filter_log_failure(this_syscall);
 		exit_code = SIGSYS;
 		break;
 	}
@@ -382,7 +369,7 @@ int __secure_computing_int(int this_syscall)
 #ifdef SECCOMP_DEBUG
 	dump_stack();
 #endif
-	audit_seccomp(this_syscall);
+	audit_seccomp(this_syscall, exit_code);
 	do_exit(exit_code);
 	return -1;	/* never reached */
 }
-- 
1.7.5.4
