From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [rfc/rft][patch] should use scheduler sync hint in
 tcp_prequeue()?
Date: Tue, 02 Mar 2010 12:27:53 +0100
Message-ID: <1267529273.2964.111.camel@edumazet-laptop>
References: <1267522901.25906.101.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Mike Galbraith <efault@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267522901.25906.101.camel@marge.simson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 02 mars 2010 =C3=A0 10:41 +0100, Mike Galbraith a =C3=A9crit :
> Greetings network land.
>=20
> The reason for this query is that wake_affine() fails if there is one
> and only one task on a runqueue to encourage tasks spreading out, whi=
ch
> increases cpu utilization.  However, for tasks which are communicatin=
g
> at high frequency, the cost of the resulting cache misses, should
> partners land in non-shared caches, is horrible to behold.  My Q6600 =
has
> shared caches, which may or may not be hit IFF something perturbs the
> system, and bounces partner to the right core.  That won't happen on =
a
> box with no shared caches of course, and even with shared caches
> available, the pain is highly visible in the TCP numbers below.=20
>=20
> The sync hint tells wake_affine() that the waker is likely going to
> sleep soonish, so it subtracts the waker from the load imbalance
> calculation, allowing the partner task to be awakened affine.  In the
> shared cache available case, that is also an enabler that the task be
> placed in an idle shared cache, which can increase throughput quite a
> bit (see .31 vs .33 AF UNIX), or may cost a bit if there is little to=
 no
> execution overlap (see pipe).
>=20
> Now, I _could_ change wake_affine() to globally succeed in the one ta=
sk
> case, but am loath to do so because that very well may upset delicate
> load balancing apple cart.  I think it's much safer to target the spo=
t
> that I know hurts like hell.  Thoughts?
>=20
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 34f5cc2..ba3fc64 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -939,7 +939,7 @@ static inline int tcp_prequeue(struct sock *sk, s=
truct sk_buff *skb)
> =20
>  		tp->ucopy.memory =3D 0;
>  	} else if (skb_queue_len(&tp->ucopy.prequeue) =3D=3D 1) {
> -		wake_up_interruptible_poll(sk->sk_sleep,
> +		wake_up_interruptible_sync_poll(sk->sk_sleep,
>  					   POLLIN | POLLRDNORM | POLLRDBAND);
>  		if (!inet_csk_ack_scheduled(sk))
>  			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
>=20

I suspect this discussion is more a lkml topic but anyway...

This wake_up_interruptible_sync_poll() change might be good for loopbac=
k
communications (and pleases tbench), but is it desirable for regular
multi flows NIC traffic ?=20

Ingo probably can answer to this question, since he changed
sock_def_readable() (and others) in commit 6f3d09291b498299
I suspect he missed tcp_prequeue() case, maybe not...

sched, net: socket wakeups are sync

'sync' wakeups are a hint towards the scheduler that (certain)
networking related wakeups likely create coupling between tasks.
