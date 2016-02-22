From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: dead loop for rtnl_trylock
Date: Mon, 22 Feb 2016 03:39:53 -0600
Message-ID: <87y4adnkwm.fsf@x220.int.ebiederm.org>
References: <CY1PR11MB0491C022AD738CCC818BE74AAAAD0@CY1PR11MB0491.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Xianpeng Zhao <xpzhao@aerohive.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CY1PR11MB0491C022AD738CCC818BE74AAAAD0@CY1PR11MB0491.namprd11.prod.outlook.com>
	(Xianpeng Zhao's message of "Tue, 16 Feb 2016 10:31:53 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Copied netdev as that is the more appropriate mailling list for
questions like this.

Xianpeng Zhao <xpzhao@aerohive.com> writes:

> Hi Group,
>
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 I have find a proble=
m in my system, I found there have a chance that cause the system enter=
 dead loop when try to get the rtnl lock in the sysctl function in net/=
ipv6/addrconf.c
>
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 The situation should=
 like this, there are 2 processes may need get the rtnl lock, we call t=
hem process A and process B, A have high priority than B.
> B need get the rtnl lock to do something, when B schedule out without=
 release the lock; At this time, the A start to run "echo 1 > /proc/sys=
/net/ipv6/conf/<ifname>/disable_ipv6", the echo process will run to thi=
s code:
>
> =C2=A0=C2=A0=C2=A0 if (!rtnl_trylock())
>
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return restart_syscall();
>
> Because the rtnl lock was hold by process B, so here the try will be =
failure, and run the restart_syscall to let the sys_write do again, eve=
n try many times, because the B have very lower priority, the lock was =
hard to be released, so the echo process created by A will enter a loop=
 of restart system call.
>
> In my case it is the wireless_nlevent_process in process kworker take=
n the rtnl lock, and another higher priority process need use echo to d=
isable IPv6 met this problem.
>
> I am not very sure, but I think it is better to let the process A sle=
ep a while instead of try it again and again without any delay.
>
> Expects, what's your opinions?

That the entire situation is a mess.  From what little I have seen it i=
s
a very rare condition.  Does this reproduce easily in your environment?

If we are going the delay route we probably want to put the delay in
restart_syscall or in a wrapper around restart_syscall that we use
for the rtnl_trylock failure case.

On first blush I would suggest the logic for sleeping should be:
	if (need_reschedule())
		schedule();

That will limit the spinning to a single time slice which is definitely
preferrable.

Ugh.  But we already cross the kernel/userspace boundary that already
does that.

If you are encountering a deadlock it is very much because you have bee=
n
playing very ugly priority games.  At which point my sympathies but thi=
s
feels like a case of "Docter it hurts when I do this.  Then don't do th=
at."

> @@ -5304,8 +5308,10 @@ static int addrconf_disable_ipv6(struct ctl_ta=
ble *table, int *p, int newf)
>
>         struct net *net;
>
>         int old;
>
> =20
>
> -       if (!rtnl_trylock())
>
> +       if (!rtnl_trylock()){
>
> +        schedule_timeout_uninterruptible(HZ/4);
>
>                 return restart_syscall();
>
> +    }
>
> =20
>
>         net =3D (struct net *)table->extra2;
>
>         old =3D *p;

Eric
