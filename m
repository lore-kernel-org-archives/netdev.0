From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Sun, 1 Apr 2012 19:33:56 +0200
Message-ID: <CA+1xoqe+T=iUtUeFdeqmRvMZ7TMCgkLs_1QYv-4YNtn-jCoMCQ@mail.gmail.com>
References: <CA+1xoqfA9FMowOmAXYHtkXB+D6FqgjCRREKPOk_m2c9ZCyaN4A@mail.gmail.com>
 <1333227549.2325.4051.camel@edumazet-glaptop> <20120331213423.GA21219@redhat.com>
 <CA+1xoqcAXyh306=2=QKWyM3BE44=MT+nsuRQn5YLOLgbtZqicA@mail.gmail.com>
 <CA+1xoqe1Wc_uifrKsko6hu+py9Ahz3Q0p1tRxup09jmh2NZ1rw@mail.gmail.com> <201204011221.GAG51016.JQFSFFOtLOMVHO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oleg@redhat.com, eric.dumazet@gmail.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204011221.GAG51016.JQFSFFOtLOMVHO@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 1, 2012 at 5:21 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Sasha Levin wrote:
>> While it seems that 9p is the culprit, I have to point out that this
>> bug is easily reproducible, and it happens each time due to a
>> call_usermode_helper() call. Other than that 9p behaves perfectly an=
d
>> I'd assume that I'd be seeing other things break besides
>> call_usermode_helper() related ones.
>
> I think one of below two patches can catch the bug if this is a userm=
odehelper
> related bug. Please try.
>
> ----- Patch 1 -----
> diff --git a/kernel/kmod.c b/kernel/kmod.c
> index 01394b6..3e63319 100644
> --- a/kernel/kmod.c
> +++ b/kernel/kmod.c
> @@ -571,7 +571,7 @@ int call_usermodehelper_exec(struct subprocess_in=
fo *sub_info, int wait)
> =A0 =A0 =A0 =A0 * flag, for khelper thread is already waiting for the=
 thread at
> =A0 =A0 =A0 =A0 * wait_for_completion() in do_fork().
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (wait !=3D UMH_NO_WAIT && current =3D=3D kmod_thread=
_locker) {
> + =A0 =A0 =A0 if (WARN_ON(wait !=3D UMH_NO_WAIT && current =3D=3D kmo=
d_thread_locker)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D -EBUSY;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
>
>
> ----- Patch 2 -----
> diff --git a/include/linux/kmod.h b/include/linux/kmod.h
> index 9efeae6..1350670 100644
> --- a/include/linux/kmod.h
> +++ b/include/linux/kmod.h
> @@ -48,10 +48,10 @@ static inline int request_module_nowait(const cha=
r *name, ...) { return -ENOSYS;
> =A0struct cred;
> =A0struct file;
>
> -#define UMH_NO_WAIT =A0 =A00 =A0 =A0 =A0 /* don't wait at all */
> -#define UMH_WAIT_EXEC =A01 =A0 =A0 =A0 /* wait for the exec, but not=
 the process */
> -#define UMH_WAIT_PROC =A02 =A0 =A0 =A0 /* wait for the process to co=
mplete */
> -#define UMH_KILLABLE =A0 4 =A0 =A0 =A0 /* wait for EXEC/PROC killabl=
e */
> +#define UMH_NO_WAIT =A0 =A00x10 =A0 =A0/* don't wait at all */
> +#define UMH_WAIT_EXEC =A00x11 =A0 =A0/* wait for the exec, but not t=
he process */
> +#define UMH_WAIT_PROC =A00x12 =A0 =A0/* wait for the process to comp=
lete */
> +#define UMH_KILLABLE =A0 0x04 =A0 =A0/* wait for EXEC/PROC killable =
*/
>
> =A0struct subprocess_info {
> =A0 =A0 =A0 =A0struct work_struct work;
> diff --git a/kernel/kmod.c b/kernel/kmod.c
> index 957a7aa..ecfd3d5 100644
> --- a/kernel/kmod.c
> +++ b/kernel/kmod.c
> @@ -483,6 +483,18 @@ int call_usermodehelper_exec(struct subprocess_i=
nfo *sub_info, int wait)
> =A0 =A0 =A0 =A0DECLARE_COMPLETION_ONSTACK(done);
> =A0 =A0 =A0 =A0int retval =3D 0;
>
> + =A0 =A0 =A0 if (unlikely(wait =3D=3D -1 || wait =3D=3D 0 || wait =3D=
=3D 1)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN(1, "Requesting for usermode helper=
 with hardcoded wait "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"flag. Change to use UMH_* s=
ymbols and recompile, or "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"this request will fail on L=
inux 3.4.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wait =3D=3D -1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D UMH_NO_WAIT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (wait =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D UMH_WAIT_EXEC;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D UMH_WAIT_PROC;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0helper_lock();
> =A0 =A0 =A0 =A0if (sub_info->path[0] =3D=3D '\0')
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;

Neither of these patches did the trick (no warnings showing up and
still seeing the hangs). However, the following patch has fixed it:

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 1a91efa..8ecc377 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -309,7 +309,7 @@ int kobject_uevent_env(struct kobject *kobj, enum
kobject_action action,
                        goto exit;

                retval =3D call_usermodehelper(argv[0], argv,
-                                            env->envp, UMH_WAIT_EXEC);
+                                            env->envp, UMH_NO_WAIT);
        }

 exit:

Not sure if that info helps any, but just in case.
