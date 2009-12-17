From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] Security: Add prctl(PR_{GET,SET}_NETWORK) interface.
Date: Thu, 17 Dec 2009 17:25:53 +0800
Message-ID: <2375c9f90912170125u6de30803sd80ecddaa332cc6a@mail.gmail.com>
References: <1260977452-2334-1-git-send-email-michael@laptop.org>
	 <1260977565-2379-1-git-send-email-michael@laptop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934830AbZLQJ0K@vger.kernel.org>
In-Reply-To: <1260977565-2379-1-git-send-email-michael@laptop.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 16, 2009 at 11:32 PM, Michael Stone <michael@laptop.org> wr=
ote:
> Daniel Bernstein has observed [1] that security-conscious userland pr=
ocesses
> may benefit from the ability to irrevocably remove their ability to c=
reate,
> bind, connect to, or send messages except in the case of previously c=
onnected
> sockets or AF_UNIX filesystem sockets. We provide this facility by im=
plementing
> support for a new prctl(PR_SET_NETWORK) flag named PR_NETWORK_OFF.
>
> This facility is particularly attractive to security platforms like O=
LPC
> Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4]=
=2E
>
> [1]: http://cr.yp.to/unix/disablenetwork.html
> [2]: http://wiki.laptop.org/go/OLPC_Bitfrost
> [3]: http://wiki.laptop.org/go/Rainbow
> [4]: http://plash.beasts.org/
>
> Signed-off-by: Michael Stone <michael@laptop.org>
> ---
> =C2=A0include/linux/prctl.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
7 +++++++
> =C2=A0include/linux/prctl_network.h | =C2=A0 =C2=A07 +++++++
> =C2=A0include/linux/sched.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
2 ++
> =C2=A0kernel/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 | =C2=A0 =C2=A02 +-
> =C2=A0kernel/prctl_network.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 37 +=
++++++++++++++++++++++++++++++++++++
> =C2=A0kernel/sys.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| =C2=A0 =C2=A07 +++++++
> =C2=A06 files changed, 61 insertions(+), 1 deletions(-)
> =C2=A0create mode 100644 include/linux/prctl_network.h
> =C2=A0create mode 100644 kernel/prctl_network.c
>
> diff --git a/include/linux/prctl.h b/include/linux/prctl.h
> index a3baeb2..4eb4110 100644
> --- a/include/linux/prctl.h
> +++ b/include/linux/prctl.h
> @@ -102,4 +102,11 @@
>
> =C2=A0#define PR_MCE_KILL_GET 34
>
> +/* Get/set process disable-network flags */
> +#define PR_SET_NETWORK 35
> +#define PR_GET_NETWORK 36
> +# define PR_NETWORK_ON =C2=A0 =C2=A0 =C2=A0 =C2=A00
> +# define PR_NETWORK_OFF =C2=A0 =C2=A0 =C2=A0 1
> +# define PR_NETWORK_ALL_FLAGS 1
> +
> =C2=A0#endif /* _LINUX_PRCTL_H */
> diff --git a/include/linux/prctl_network.h b/include/linux/prctl_netw=
ork.h
> new file mode 100644
> index 0000000..2db83eb
> --- /dev/null
> +++ b/include/linux/prctl_network.h
> @@ -0,0 +1,7 @@
> +#ifndef _LINUX_PRCTL_NETWORK_H
> +#define _LINUX_PRCTL_NETWORK_H
> +
> +extern long prctl_get_network(void);
> +extern long prctl_set_network(unsigned long);
> +
> +#endif /* _LINUX_PRCTL_NETWORK_H */
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 5c858f3..751d372 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1395,6 +1395,8 @@ struct task_struct {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int sessionid;
> =C2=A0#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0seccomp_t seccomp;
> +/* Flags for limiting networking via prctl(PR_SET_NETWORK). */
> + =C2=A0unsigned long network;
>
> =C2=A0/* Thread group tracking */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 parent_exec_id;
> diff --git a/kernel/Makefile b/kernel/Makefile
> index 864ff75..cafbff2 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -10,7 +10,7 @@ obj-y =C2=A0 =C2=A0 =3D sched.o fork.o exec_domain.=
o panic.o printk.o \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kthread.o wait.o kfifo.o sys=
_ni.o posix-cpu-timers.o mutex.o \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hrtimer.o rwsem.o nsproxy.o =
srcu.o semaphore.o \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0notifier.o ksysfs.o pm_qos_p=
arams.o sched_clock.o cred.o \
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 async.o
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 async.o prctl_network.o
> =C2=A0obj-y +=3D groups.o
>
> =C2=A0ifdef CONFIG_FUNCTION_TRACER
> diff --git a/kernel/prctl_network.c b/kernel/prctl_network.c
> new file mode 100644
> index 0000000..d173716
> --- /dev/null
> +++ b/kernel/prctl_network.c
> @@ -0,0 +1,37 @@
> +/*
> + * linux/kernel/prctl_network.c
> + *
> + * Copyright 2009 =C2=A0Michael Stone <michael@laptop.org>
> + *
> + * Turn off a process's ability to access new networks.
> + * See Documentation/prctl_network.txt for details.
> + */
> +
> +#include <linux/prctl_network.h>
> +#include <linux/sched.h>
> +#include <linux/prctl.h>
> +
> +long prctl_get_network(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return current->network;
> +}
> +
> +long prctl_set_network(unsigned long network_flags)
> +{
> + =C2=A0 =C2=A0 =C2=A0 long ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 /* only dropping access is permitted */
> + =C2=A0 =C2=A0 =C2=A0 ret =3D -EPERM;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0if (current->network & ~network_flags)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> +
> + =C2=A0 =C2=A0 =C2=A0 ret =3D -EINVAL;
> + =C2=A0 =C2=A0 =C2=A0 if (network_flags & ~PR_NETWORK_ALL_FLAGS)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> +
> + =C2=A0 =C2=A0 =C2=A0 current->network =3D network_flags;
> + =C2=A0 =C2=A0 =C2=A0 ret =3D 0;
> +
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}


Sorry that I didn't follow the original disscusion.
Any reason why you introdce a new source file?
Why not just adding them to kernel/sys.c?


> diff --git a/kernel/sys.c b/kernel/sys.c
> index 20ccfb5..4eccc66 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -35,6 +35,7 @@
> =C2=A0#include <linux/cpu.h>
> =C2=A0#include <linux/ptrace.h>
> =C2=A0#include <linux/fs_struct.h>
> +#include <linux/prctl_network.h>
>
> =C2=A0#include <linux/compat.h>
> =C2=A0#include <linux/syscalls.h>
> @@ -1576,6 +1577,12 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned l=
ong, arg2, unsigned long, arg3,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D PR_MCE_KILL_DEFAULT=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case PR_SET_NETWOR=
K:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 error =3D prctl_set_network(arg2);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case PR_GET_NETWOR=
K:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 error =3D prctl_get_network();
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0default:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0error =3D -EINVAL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
> --
> 1.5.6.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>
