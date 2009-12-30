From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: [RFC][PATCH v2] Unprivileged: Disable raising of privileges
Date: Wed, 30 Dec 2009 06:52:08 -0800
Message-ID: <551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
References: <20091229050114.GC14362@heat> <m17hs5y0mg.fsf@fess.ebiederm.org>
	 <20091229211139.0732a0c1@lxorguk.ukuu.org.uk>
	 <m1iqbpwjtp.fsf@fess.ebiederm.org> <20091229223631.GB22578@us.ibm.com>
	 <m1aax1uoa3.fsf_-_@fess.ebiederm.org>
	 <3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com>
	 <m1r5qdt721.fsf@fess.ebiederm.org>
	 <3e8340490912292057g3e87eaabn115f85b78af2b08c@mail.gmail.com>
	 <m1d41w62zc.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bryan Donlan <bdonlan@gmail.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
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
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.c
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m1d41w62zc.fsf_-_@fess.ebiederm.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric,

I'm not clear why capabilities need to be manipulated by this feature
(the pure capability support already has a feature for disabling
privilege and blocking unsafe, or insufficient privilege, execution).

Perhaps I'm just unclear what features can be more safely enabled with
this in effect - that is, your description suggests that this is why
you are doing this, but leaves it unclear what they are. Could you
take a few moments to enumerate some of them?

Thanks

Andrew

On Wed, Dec 30, 2009 at 4:49 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> If we can know that a process will never raise
> it's priveleges we can enable a lot of features
> that otherwise would be unsafe, because they
> could break assumptions of existing suid executables.
>
> To allow this to be used as a sand boxing feature
> also disable ptracing other executables without
> this new restriction.
>
> For the moment I have used a per thread flag because
> we are out of per process flags.
>
> To ensure all descendants get this flag I rely on
> the default copying of procss structures.
>
> Added bprm->nosuid to make remove the need to add
> duplicate error prone checks. =A0This ensures that
> the disabling of suid executables is exactly the
> same as MNT_NOSUID.
>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
> =A0arch/x86/include/asm/thread_info.h | =A0 =A02 ++
> =A0fs/exec.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A06 ++++--
> =A0include/linux/binfmts.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0include/linux/prctl.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 ++
> =A0kernel/ptrace.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 =
++++
> =A0kernel/sys.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 16 =
++++++++++++++++
> =A0security/commoncap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 14 ++++++++=
+++++-
> =A0security/selinux/hooks.c =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A08 files changed, 43 insertions(+), 4 deletions(-)
>
> diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/as=
m/thread_info.h
> index 375c917..e716203 100644
> --- a/arch/x86/include/asm/thread_info.h
> +++ b/arch/x86/include/asm/thread_info.h
> @@ -82,6 +82,7 @@ struct thread_info {
> =A0#define TIF_SYSCALL_EMU =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A06 =A0 =A0 =A0=
 /* syscall emulation active */
> =A0#define TIF_SYSCALL_AUDIT =A0 =A0 =A07 =A0 =A0 =A0 /* syscall audi=
ting active */
> =A0#define TIF_SECCOMP =A0 =A0 =A0 =A0 =A0 =A08 =A0 =A0 =A0 /* secure=
 computing */
> +#define TIF_NOSUID =A0 =A0 =A0 =A0 =A0 =A0 9 =A0 =A0 =A0 /* suid exe=
c permanently disabled */
> =A0#define TIF_MCE_NOTIFY =A0 =A0 =A0 =A0 10 =A0 =A0 =A0/* notify use=
rspace of an MCE */
> =A0#define TIF_USER_RETURN_NOTIFY 11 =A0 =A0 =A0/* notify kernel of u=
serspace return */
> =A0#define TIF_NOTSC =A0 =A0 =A0 =A0 =A0 =A0 =A016 =A0 =A0 =A0/* TSC =
is not accessible in userland */
> @@ -107,6 +108,7 @@ struct thread_info {
> =A0#define _TIF_SYSCALL_EMU =A0 =A0 =A0 (1 << TIF_SYSCALL_EMU)
> =A0#define _TIF_SYSCALL_AUDIT =A0 =A0 (1 << TIF_SYSCALL_AUDIT)
> =A0#define _TIF_SECCOMP =A0 =A0 =A0 =A0 =A0 (1 << TIF_SECCOMP)
> +#define _TIF_NOSUID =A0 =A0 =A0 =A0 =A0 =A0(1 << TIF_NOSUID)
> =A0#define _TIF_MCE_NOTIFY =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1 << TIF_M=
CE_NOTIFY)
> =A0#define _TIF_USER_RETURN_NOTIFY =A0 =A0 =A0 =A0(1 << TIF_USER_RETU=
RN_NOTIFY)
> =A0#define _TIF_NOTSC =A0 =A0 =A0 =A0 =A0 =A0 (1 << TIF_NOTSC)
> diff --git a/fs/exec.c b/fs/exec.c
> index 632b02e..5cba5ac 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -1131,8 +1131,10 @@ int prepare_binprm(struct linux_binprm *bprm)
> =A0 =A0 =A0 =A0/* clear any previous set[ug]id data from a previous b=
inary */
> =A0 =A0 =A0 =A0bprm->cred->euid =3D current_euid();
> =A0 =A0 =A0 =A0bprm->cred->egid =3D current_egid();
> -
> - =A0 =A0 =A0 if (!(bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID)) =
{
> + =A0 =A0 =A0 bprm->nosuid =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (bprm->file->f_path.mnt->mnt_flags & MN=
T_NOSUID) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 test_tsk_thread_flag(current, TIF_NOSUI=
D);
> + =A0 =A0 =A0 if (bprm->nosuid) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Set-uid? */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (mode & S_ISUID) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bprm->per_clear |=3D P=
ER_CLEAR_ON_SETID;
> diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
> index cd4349b..c3b5a30 100644
> --- a/include/linux/binfmts.h
> +++ b/include/linux/binfmts.h
> @@ -44,6 +44,7 @@ struct linux_binprm{
> =A0#ifdef __alpha__
> =A0 =A0 =A0 =A0unsigned int taso:1;
> =A0#endif
> + =A0 =A0 =A0 unsigned int nosuid:1; =A0/* True if suid bits are igno=
red */
> =A0 =A0 =A0 =A0unsigned int recursion_depth;
> =A0 =A0 =A0 =A0struct file * file;
> =A0 =A0 =A0 =A0struct cred *cred; =A0 =A0 =A0/* new credentials */
> diff --git a/include/linux/prctl.h b/include/linux/prctl.h
> index a3baeb2..acb3516 100644
> --- a/include/linux/prctl.h
> +++ b/include/linux/prctl.h
> @@ -102,4 +102,6 @@
>
> =A0#define PR_MCE_KILL_GET 34
>
> +#define PR_SET_NOSUID =A035
> +
> =A0#endif /* _LINUX_PRCTL_H */
> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 23bd09c..b91040c 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -152,6 +152,10 @@ int __ptrace_may_access(struct task_struct *task=
, unsigned int mode)
> =A0 =A0 =A0 =A0if (!dumpable && !capable(CAP_SYS_PTRACE))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
>
> + =A0 =A0 =A0 if (test_tsk_thread_flag(current, TIF_NOSUID) &&
> + =A0 =A0 =A0 =A0 =A0 !test_tsk_thread_flag(task, TIF_NOSUID))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> +
> =A0 =A0 =A0 =A0return security_ptrace_access_check(task, mode);
> =A0}
>
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 26a6b73..1d1902a 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1578,6 +1578,22 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned l=
ong, arg2, unsigned long, arg3,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0error =
=3D PR_MCE_KILL_DEFAULT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PR_SET_NOSUID:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct cred *cred=
 =3D current->cred;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ( =A0 =A0(cred->uid =
!=3D cred->suid) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (cred->=
uid !=3D cred->euid) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (cred->=
uid !=3D cred->fsuid) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (cred->=
gid !=3D cred->sgid) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (cred->=
gid !=3D cred->egid) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (cred->=
gid !=3D cred->fsgid) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (atomic=
_read(&current->signal->count) !=3D 1))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_tsk_thread_flag(cur=
rent, TIF_NOSUID);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0error =3D -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> diff --git a/security/commoncap.c b/security/commoncap.c
> index f800fdb..28ab286 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -389,7 +389,7 @@ static int get_file_caps(struct linux_binprm *bpr=
m, bool *effective)
> =A0 =A0 =A0 =A0if (!file_caps_enabled)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 if (bprm->file->f_vfsmnt->mnt_flags & MNT_NOSUID)
> + =A0 =A0 =A0 if (bprm->nosuid)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> =A0 =A0 =A0 =A0dentry =3D dget(bprm->file->f_dentry);
> @@ -869,6 +869,18 @@ int cap_task_prctl(int option, unsigned long arg=
2, unsigned long arg3,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new->securebits &=3D ~=
issecure_mask(SECURE_KEEP_CAPS);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto changed;
>
> + =A0 =A0 =A0 case PR_SET_NOSUID:
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct cred *cred =3D current->cr=
ed;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Perform the capabilities checks */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cap_isclear(cred->cap_permitted) |=
|
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !cap_isclear(cred->cap_effectiv=
e))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Have the default perform the rest of=
 the work. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D -ENOSYS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto error;
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* No functionality available - contin=
ue with default */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0error =3D -ENOSYS;
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 7a374c2..d14cd24 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2147,7 +2147,7 @@ static int selinux_bprm_set_creds(struct linux_=
binprm *bprm)
> =A0 =A0 =A0 =A0COMMON_AUDIT_DATA_INIT(&ad, FS);
> =A0 =A0 =A0 =A0ad.u.fs.path =3D bprm->file->f_path;
>
> - =A0 =A0 =A0 if (bprm->file->f_path.mnt->mnt_flags & MNT_NOSUID)
> + =A0 =A0 =A0 if (bprm->nosid)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new_tsec->sid =3D old_tsec->sid;
>
> =A0 =A0 =A0 =A0if (new_tsec->sid =3D=3D old_tsec->sid) {
> --
> 1.6.5.2.143.g8cc62
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-secur=
ity-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
