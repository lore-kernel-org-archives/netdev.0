From: Will Drewry <wad@chromium.org>
Subject: [PATCH v17 01/15] Add PR_{GET,SET}_NO_NEW_PRIVS to prevent execve from granting privs
Date: Thu, 29 Mar 2012 15:01:46 -0500
Message-ID: <1333051320-30872-2-git-send-email-wad@chromium.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Cc: linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org,
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
	jmorris@namei.org,
	Andy Lutomirski <luto@amacapital.net>
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-1175-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1333051320-30872-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@amacapital.net>

With this set, a lot of dangerous operations (chroot, unshare, etc)
become a lot less dangerous because there is no possibility of
subverting privileged binaries.

This patch completely breaks apparmor.  Someone who understands (and
uses) apparmor should fix it or at least give me a hint.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>

(rebased onto -linus, bumping prctl # -wad@chromium.org)
---
 fs/exec.c                  |   10 +++++++++-
 include/linux/prctl.h      |   15 +++++++++++++++
 include/linux/sched.h      |    2 ++
 include/linux/security.h   |    1 +
 kernel/sys.c               |   10 ++++++++++
 security/apparmor/domain.c |    4 ++++
 security/commoncap.c       |    7 +++++--
 security/selinux/hooks.c   |   10 +++++++++-
 8 files changed, 55 insertions(+), 4 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index c8b63d1..a8451ec 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1245,6 +1245,13 @@ static int check_unsafe_exec(struct linux_binprm *bprm)
 			bprm->unsafe |= LSM_UNSAFE_PTRACE;
 	}
 
+	/*
+	 * This isn't strictly necessary, but it makes it harder for LSMs to
+	 * mess up.
+	 */
+	if (current->no_new_privs)
+		bprm->unsafe |= LSM_UNSAFE_NO_NEW_PRIVS;
+
 	n_fs = 1;
 	spin_lock(&p->fs->lock);
 	rcu_read_lock();
@@ -1288,7 +1295,8 @@ int prepare_binprm(struct linux_binprm *bprm)
 	bprm->cred->euid = current_euid();
 	bprm->cred->egid = current_egid();
 
-	if (!(bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID)) {
+	if (!(bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID) &&
+	    !current->no_new_privs) {
 		/* Set-uid? */
 		if (mode & S_ISUID) {
 			bprm->per_clear |= PER_CLEAR_ON_SETID;
diff --git a/include/linux/prctl.h b/include/linux/prctl.h
index e0cfec2..78b76e2 100644
--- a/include/linux/prctl.h
+++ b/include/linux/prctl.h
@@ -124,4 +124,19 @@
 #define PR_SET_CHILD_SUBREAPER 36
 #define PR_GET_CHILD_SUBREAPER 37
 
+/*
+ * If no_new_privs is set, then operations that grant new privileges (i.e.
+ * execve) will either fail or not grant them.  This affects suid/sgid,
+ * file capabilities, and LSMs.
+ *
+ * Operations that merely manipulate or drop existing privileges (setresuid,
+ * capset, etc.) will still work.  Drop those privileges if you want them gone.
+ *
+ * Changing LSM security domain is considered a new privilege.  So, for example,
+ * asking selinux for a specific new context (e.g. with runcon) will result
+ * in execve returning -EPERM.
+ */
+#define PR_SET_NO_NEW_PRIVS 38
+#define PR_GET_NO_NEW_PRIVS 39
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 81a173c..ba60897 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1341,6 +1341,8 @@ struct task_struct {
 				 * execve */
 	unsigned in_iowait:1;
 
+	/* task may not gain privileges */
+	unsigned no_new_privs:1;
 
 	/* Revert to default priority/policy when forking */
 	unsigned sched_reset_on_fork:1;
diff --git a/include/linux/security.h b/include/linux/security.h
index 673afbb..6e1dea9 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -144,6 +144,7 @@ struct request_sock;
 #define LSM_UNSAFE_SHARE	1
 #define LSM_UNSAFE_PTRACE	2
 #define LSM_UNSAFE_PTRACE_CAP	4
+#define LSM_UNSAFE_NO_NEW_PRIVS	8
 
 #ifdef CONFIG_MMU
 extern int mmap_min_addr_handler(struct ctl_table *table, int write,
diff --git a/kernel/sys.c b/kernel/sys.c
index e7006eb..b82568b 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1979,6 +1979,16 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 			error = put_user(me->signal->is_child_subreaper,
 					 (int __user *) arg2);
 			break;
+		case PR_SET_NO_NEW_PRIVS:
+			if (arg2 != 1 || arg3 || arg4 || arg5)
+				return -EINVAL;
+
+			current->no_new_privs = 1;
+			break;
+		case PR_GET_NO_NEW_PRIVS:
+			if (arg2 || arg3 || arg4 || arg5)
+				return -EINVAL;
+			return current->no_new_privs ? 1 : 0;
 		default:
 			error = -EINVAL;
 			break;
diff --git a/security/apparmor/domain.c b/security/apparmor/domain.c
index 6327685..18c88d0 100644
--- a/security/apparmor/domain.c
+++ b/security/apparmor/domain.c
@@ -360,6 +360,10 @@ int apparmor_bprm_set_creds(struct linux_binprm *bprm)
 	if (bprm->cred_prepared)
 		return 0;
 
+	/* XXX: no_new_privs is not usable with AppArmor yet */
+	if (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS)
+		return -EPERM;
+
 	cxt = bprm->cred->security;
 	BUG_ON(!cxt);
 
diff --git a/security/commoncap.c b/security/commoncap.c
index 0cf4b53..edd3918 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -506,14 +506,17 @@ int cap_bprm_set_creds(struct linux_binprm *bprm)
 skip:
 
 	/* Don't let someone trace a set[ug]id/setpcap binary with the revised
-	 * credentials unless they have the appropriate permit
+	 * credentials unless they have the appropriate permit.
+	 *
+	 * In addition, if NO_NEW_PRIVS, then ensure we get no new privs.
 	 */
 	if ((new->euid != old->uid ||
 	     new->egid != old->gid ||
 	     !cap_issubset(new->cap_permitted, old->cap_permitted)) &&
 	    bprm->unsafe & ~LSM_UNSAFE_PTRACE_CAP) {
 		/* downgrade; they get no more than they had, and maybe less */
-		if (!capable(CAP_SETUID)) {
+		if (!capable(CAP_SETUID) ||
+		    (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS)) {
 			new->euid = new->uid;
 			new->egid = new->gid;
 		}
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 3049299..be99c84 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2000,6 +2000,13 @@ static int selinux_bprm_set_creds(struct linux_binprm *bprm)
 		new_tsec->sid = old_tsec->exec_sid;
 		/* Reset exec SID on execve. */
 		new_tsec->exec_sid = 0;
+
+		/*
+		 * Minimize confusion: if no_new_privs and a transition is
+		 * explicitly requested, then fail the exec.
+		 */
+		if (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS)
+			return -EPERM;
 	} else {
 		/* Check for a default transition on this program. */
 		rc = security_transition_sid(old_tsec->sid, isec->sid,
@@ -2012,7 +2019,8 @@ static int selinux_bprm_set_creds(struct linux_binprm *bprm)
 	COMMON_AUDIT_DATA_INIT(&ad, PATH);
 	ad.u.path = bprm->file->f_path;
 
-	if (bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID)
+	if ((bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID) ||
+	    (bprm->unsafe & LSM_UNSAFE_NO_NEW_PRIVS))
 		new_tsec->sid = old_tsec->sid;
 
 	if (new_tsec->sid == old_tsec->sid) {
-- 
1.7.5.4
