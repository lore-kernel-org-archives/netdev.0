From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] Unprivileged: Disable acquisition of privileges
Date: Tue, 29 Dec 2009 19:35:48 -0800
Message-ID: <m1aax1uoa3.fsf_-_@fess.ebiederm.org>
References: <20091229050114.GC14362@heat> <m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com>
	<3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<m3oclhzgm4.fsf@ursa.amorsen.dk> <m17hs5y0mg.fsf@fess.ebiederm.org>
	<20091229211139.0732a0c1@lxorguk.ukuu.org.uk>
	<m1iqbpwjtp.fsf@fess.ebiederm.org> <20091229223631.GB22578@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Bryan Donlan <bdonlan@gmail.com>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Al V
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751624AbZL3Df7@vger.kernel.org>
In-Reply-To: <20091229223631.GB22578@us.ibm.com> (Serge E. Hallyn's message of "Tue\, 29 Dec 2009 16\:36\:31 -0600")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


If we can know that a process will never raise it's priveleges we can
enable a lot of features that otherwise would be unsafe, because they
could break assumptions of existing suid executables.

To allow this to be used as a sand boxing feature also disable
ptracing other executables without this new restriction.

For the moment I have used a per thread flag because we are out of per
process flags.

To ensure all descendants get this flag I rely on the default copying
of procss structures.

The disabling of suid executables is exactly the same as MNT_NOSUID.

This should be what we have been talking about in for disabling of
suid exec.  I choose not to use securebits as that interface requires
privilege and assumes capabilities.  This implementation is more basic
than capabilities and only adds additional sanity checks when
linux capabilities are not present.

I attempt to ensure there are no mixed priveleges present, when we
perform the disable so I don't need to handle or think about
interactions with setreuid or capabilities in this code.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 arch/x86/include/asm/thread_info.h |    2 ++
 fs/exec.c                          |    3 ++-
 include/linux/prctl.h              |    2 ++
 kernel/ptrace.c                    |    4 ++++
 kernel/sys.c                       |   16 ++++++++++++++++
 security/commoncap.c               |   15 +++++++++++++++
 6 files changed, 41 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index 375c917..e716203 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -82,6 +82,7 @@ struct thread_info {
 #define TIF_SYSCALL_EMU		6	/* syscall emulation active */
 #define TIF_SYSCALL_AUDIT	7	/* syscall auditing active */
 #define TIF_SECCOMP		8	/* secure computing */
+#define TIF_NOSUID		9	/* suid exec permanently disabled */
 #define TIF_MCE_NOTIFY		10	/* notify userspace of an MCE */
 #define TIF_USER_RETURN_NOTIFY	11	/* notify kernel of userspace return */
 #define TIF_NOTSC		16	/* TSC is not accessible in userland */
@@ -107,6 +108,7 @@ struct thread_info {
 #define _TIF_SYSCALL_EMU	(1 << TIF_SYSCALL_EMU)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_SECCOMP		(1 << TIF_SECCOMP)
+#define _TIF_NOSUID		(1 << TIF_NOSUID)
 #define _TIF_MCE_NOTIFY		(1 << TIF_MCE_NOTIFY)
 #define _TIF_USER_RETURN_NOTIFY	(1 << TIF_USER_RETURN_NOTIFY)
 #define _TIF_NOTSC		(1 << TIF_NOTSC)
diff --git a/fs/exec.c b/fs/exec.c
index 632b02e..e6c9bc5 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1132,7 +1132,8 @@ int prepare_binprm(struct linux_binprm *bprm)
 	bprm->cred->euid = current_euid();
 	bprm->cred->egid = current_egid();
 
-	if (!(bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID)) {
+	if (!(bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID) &&
+	    !test_tsk_thread_flag(current, TIF_NOSUID)) {
 		/* Set-uid? */
 		if (mode & S_ISUID) {
 			bprm->per_clear |= PER_CLEAR_ON_SETID;
diff --git a/include/linux/prctl.h b/include/linux/prctl.h
index a3baeb2..acb3516 100644
--- a/include/linux/prctl.h
+++ b/include/linux/prctl.h
@@ -102,4 +102,6 @@
 
 #define PR_MCE_KILL_GET 34
 
+#define PR_SET_NOSUID	35
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 23bd09c..4b2643c 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -152,6 +152,10 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 	if (!dumpable && !capable(CAP_SYS_PTRACE))
 		return -EPERM;
 
+	if (test_tsk_thread_flag(current, TIF_NOSUID) &&
+	    !test_tsk_thread_flag(current, TIF_NOSUID))
+		return -EPERM;
+
 	return security_ptrace_access_check(task, mode);
 }
 
diff --git a/kernel/sys.c b/kernel/sys.c
index 26a6b73..1d1902a 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1578,6 +1578,22 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 			else
 				error = PR_MCE_KILL_DEFAULT;
 			break;
+		case PR_SET_NOSUID:
+		{
+			const struct cred *cred = current->cred;
+			error = -EINVAL;
+			if (	(cred->uid != cred->suid) ||
+				(cred->uid != cred->euid) ||
+				(cred->uid != cred->fsuid) ||
+				(cred->gid != cred->sgid) ||
+				(cred->gid != cred->egid) ||
+				(cred->gid != cred->fsgid) ||
+				(atomic_read(&current->signal->count) != 1))
+				break;
+			error = 0;
+			set_tsk_thread_flag(current, TIF_NOSUID);
+			break;
+		}
 		default:
 			error = -EINVAL;
 			break;
diff --git a/security/commoncap.c b/security/commoncap.c
index f800fdb..8abd3dc 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -392,6 +392,9 @@ static int get_file_caps(struct linux_binprm *bprm, bool *effective)
 	if (bprm->file->f_vfsmnt->mnt_flags & MNT_NOSUID)
 		return 0;
 
+	if (test_tsk_thread_flag(current, TIF_NOSUID))
+		return 0;
+
 	dentry = dget(bprm->file->f_dentry);
 
 	rc = get_vfs_caps_from_disk(dentry, &vcaps);
@@ -869,6 +872,18 @@ int cap_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 			new->securebits &= ~issecure_mask(SECURE_KEEP_CAPS);
 		goto changed;
 
+	case PR_SET_NOSUID:
+	{
+		const struct cred *cred = current->cred;
+		error = -EINVAL;
+		// Perform the capabilities checks
+		if (!cap_isclear(cred->cap_permitted) ||
+		    !cap_isclear(cred->cap_effective))
+			goto error;
+		// Have the default perform the rest of the work.
+		error = -ENOSYS;
+		goto error;
+	}
 	default:
 		/* No functionality available - continue with default */
 		error = -ENOSYS;
-- 
1.6.5.2.143.g8cc62
