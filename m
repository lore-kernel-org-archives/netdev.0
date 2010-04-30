From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Fri, 30 Apr 2010 07:25:04 +0200
Message-ID: <1272605104.2209.658.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>
	 <1272118252.8918.13.camel@bigi> <1272290584.19143.43.camel@edumazet-laptop>
	 <1272293707.19143.51.camel@edumazet-laptop>
	 <20100429174056.GA8044@gargoyle.fritz.box>
	 <1272563772.2222.301.camel@edumazet-laptop>
	 <20100429182347.GA8512@gargoyle.fritz.box>
	 <1272568347.2209.11.camel@edumazet-laptop>
	 <20100429214144.GA10663@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, hadi@cyberus.ca,
	Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Andi Kleen <ak@gargoyle.fritz.box>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:33469 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932685Ab0D3Syl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:54:41 -0400
Received: by bwz19 with SMTP id 19so315494bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:54:39 -0700 (PDT)
In-Reply-To: <20100429214144.GA10663@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 avril 2010 =C3=A0 23:41 +0200, Andi Kleen a =C3=A9crit :
> On Thu, Apr 29, 2010 at 09:12:27PM +0200, Eric Dumazet wrote:
> > Yes, mostly, but about 200.000 wakeups per second I would say...
> >=20
> > If a cpu in deep state receives an IPI, process a softirq, should i=
t
> > come back to deep state immediately, or should it wait for some
> > milliseconds ?
>=20
> In principle the cpuidle governour should detect this and not put the=
 target into
> the slow deep c states. One change that was done recently to fix a si=
milar=20
> problem for disk IO was to take processes that wait for IO into accou=
nt=20
> (see 69d25870). But it doesn't work for networking.
>=20
> Here's a untested patch that might help: tell the cpuidle governour=20
> networking is waiting for IO. This will tell it to not go down the de=
eply.
>=20
> I might have missed some schedule() paths, feel free to add more.
>=20
> Actually it's probably too aggressive because it will avoid C states =
even for
> a closed window on the other side which might be hours. Better would
> be some heuristic to only do this when you're really expected IO shor=
tly.
>=20
> Also does your workload even sleep at all? If not we would need to in=
crease
> the iowait counters in recvmsg() itself.
>=20

My workload yes, uses blocking recvmsg() calls, but Jamal one uses
epoll() so I guess problem is more generic than that. We should have an
estimate of the number of wakeups (IO or not...) per second (or
sub-second) so that cpuidle can avoid these deep states ?

> Anyways might be still worth a try.
>=20
> For routing we probably need some other solution though, there are no=
=20
> schedules there.
>=20
> >=20
> > > Perhaps need to feed some information to cpuidle's governour to p=
revent this problem.
> > >=20
> > > idle=3Dpoll is very drastic, better to limit to C1=20
> > >=20
> >=20
> > How can I do this ?
>=20
> processor.max_cstate=3D1 or using /dev/network_latency=20
> (see Documentation/power/pm_qos_interface.txt)
>=20
> -Andi
>=20

Thanks, I'll play with this today !

>=20
>=20
> commit 810227a7c24ecae2bb4aac320490a7115ac33be8
> Author: Andi Kleen <ak@linux.intel.com>
> Date:   Thu Apr 29 23:33:18 2010 +0200
>=20
>     Use io_schedule() in network stack to tell cpuidle governour to g=
uarantee lower latencies
>=20
>     XXX: probably too aggressive, some of these sleeps are not under =
high load.
>=20
>     Based on a bug report from Eric Dumazet.
>    =20
>     Signed-off-by: Andi Kleen <ak@linux.intel.com>
>=20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index c5812bb..c246d6c 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1402,7 +1402,7 @@ static long sock_wait_for_wmem(struct sock *sk,=
 long timeo)
>  			break;
>  		if (sk->sk_err)
>  			break;
> -		timeo =3D schedule_timeout(timeo);
> +		timeo =3D io_schedule_timeout(timeo);
>  	}
>  	finish_wait(sk->sk_sleep, &wait);
>  	return timeo;
> @@ -1512,7 +1512,7 @@ static void __lock_sock(struct sock *sk)
>  		prepare_to_wait_exclusive(&sk->sk_lock.wq, &wait,
>  					TASK_UNINTERRUPTIBLE);
>  		spin_unlock_bh(&sk->sk_lock.slock);
> -		schedule();
> +		io_schedule();
>  		spin_lock_bh(&sk->sk_lock.slock);
>  		if (!sock_owned_by_user(sk))
>  			break;
>=20
> >=20
> > Thanks !
> >=20
> >=20


