From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: race in receive part
Date: Thu, 18 Jun 2009 16:06:42 +0200
Message-ID: <4A3A49F2.6060705@gmail.com>
References: <20090618102727.GC3782@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59069 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758566AbZFROHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 10:07:00 -0400
In-Reply-To: <20090618102727.GC3782@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Olsa a =C3=A9crit :
> Hi,
>=20
> in RHEL4 we can see a race in the tcp layer. We were not able to repr=
oduce=20
> this on the upstream kernel, but since the issue occurs very rarelly
> (once per 8 days), we just might not be lucky.
>=20
> I'm affraid this might be a long email, I'll try to structure it nice=
ly.. :)
>=20

Thanks for your mail and detailed analysis

>=20
>=20
> RACE DESCRIPTION
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> There's a nice pdf describing the issue (and sollution using locks) o=
n
> https://bugzilla.redhat.com/attachment.cgi?id=3D345014

I could not reach this url unfortunatly=20

--> "You are not authorized to access bug #494404. "

>=20
>=20
> The race fires, when following code paths meet, and the tp->rcv_nxt a=
nd
> __add_wait_queue updates stay in CPU caches.
>=20
> CPU1                         CPU2
>=20
>=20
> sys_select                   receive packet
>   ...                        ...
>   __add_wait_queue           update tp->rcv_nxt
>   ...                        ...
>   tp->rcv_nxt check          sock_def_readable
>   ...                        {
>   schedule                      ...
>                                 if (sk->sk_sleep && waitqueue_active(=
sk->sk_sleep))
>                                         wake_up_interruptible(sk->sk_=
sleep)
>                                 ...
>                              }
>=20
> If there were no cache the code would work ok, since the wait_queue a=
nd
> rcv_nxt are opposit to each other.
>=20
> Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 either alr=
eady
> passed the tp->rcv_nxt check and sleeps, or will get the new value fo=
r
> tp->rcv_nxt and will return with new data mask. =20
> In both cases the process (CPU1) is being added to the wait queue, so=
 the
> waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
>=20
> The bad case is when the __add_wait_queue changes done by CPU1 stay i=
n its
> cache , and so does the tp->rcv_nxt update on CPU2 side.  The CPU1 wi=
ll then
> endup calling schedule and sleep forever if there are no more data on=
 the
> socket.
>=20
> Adding smp_mb() calls before sock_def_readable call and after __add_w=
ait_queue
> should prevent the above bad scenario.
>=20
> The upstream patch is attached. It seems to prevent the issue.
>=20
>=20
>=20
> CPU BUGS
> =3D=3D=3D=3D=3D=3D=3D=3D
>=20
> The customer has been able to reproduce this problem only on one CPU =
model:
> Xeon E5345*2. They didn't reproduce on XEON MV, for example.

Is there an easy way to reproduce the problem ?

>=20
> That CPU model happens to have 2 possible issues, that might cause th=
e issue:
> (see errata http://www.intel.com/Assets/PDF/specupdate/315338.pdf)
>=20
> AJ39 and AJ18. The first one can be workarounded by BIOS upgrade,
> the other one has following notes:

AJ18 only matters on unaligned accesses, tcp code doesnt do this.

>=20
>       Software should ensure at least one of the following is true wh=
en
>       modifying shared data by multiple agents:
>              =E2=80=A2 The shared data is aligned
>              =E2=80=A2 Proper semaphores or barriers are used in orde=
r to
>                 prevent concurrent data accesses.
>=20
>=20
>=20
> RFC
> =3D=3D=3D
>=20
> I'm aware that not having this issue reproduced on upstream lowers th=
e odds
> having this checked in. However AFAICS the issue is present. I'd appr=
eciate
> any comment/ideas.
>=20
>=20
> thanks,
> jirka
>=20
>=20
> Signed-off-by: Jiri Olsa <jolsa@redhat.com>
>=20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 17b89c5..f5d9dbf 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -340,6 +340,11 @@ unsigned int tcp_poll(struct file *file, struct =
socket *sock, poll_table *wait)
>  	struct tcp_sock *tp =3D tcp_sk(sk);
> =20
>  	poll_wait(file, sk->sk_sleep, wait);

poll_wait() calls add_wait_queue() which contains a=20
spin_lock_irqsave()/spin_unlock_irqrestore() pair

Documentation/memory-barriers.txt states in line 1123 :

	Memory operations issued after the LOCK will be completed after the LO=
CK
	operation has completed.

and line 1131 states :

	Memory operations issued before the UNLOCK will be completed before th=
e
	UNLOCK operation has completed.

So yes, there is no full smp_mb() in poll_wait()

> +
> +	/* Get in sync with tcp_data_queue, tcp_urg
> +	   and tcp_rcv_established function. */
> +	smp_mb();

If this barrier is really necessary, I guess it should be done in poll_=
wait() itself.

Documentation/memory-barriers.txt misses some information about poll_wa=
it()




> +
>  	if (sk->sk_state =3D=3D TCP_LISTEN)
>  		return inet_csk_listen_poll(sk);
> =20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 2bdb0da..0606e5e 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4362,8 +4362,11 @@ queue_and_out:
> =20
>  		if (eaten > 0)
>  			__kfree_skb(skb);
> -		else if (!sock_flag(sk, SOCK_DEAD))
> +		else if (!sock_flag(sk, SOCK_DEAD)) {
> +			/* Get in sync with tcp_poll function. */
> +			smp_mb();
>  			sk->sk_data_ready(sk, 0);
> +		}
>  		return;
>

Oh well... if smp_mb() is needed, I believe it should be done
right before "if (waitqueue_active(sk->sk_sleep) ... "

 	read_lock(&sk->sk_callback_lock);
+	smp_mb();
 	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 		wake_up_interruptible(sk->sk_sleep)

It would match other parts in kernel (see fs/splice.c, fs/aio.c, ...)

Strange thing is that read_lock() on x86 is a full memory barrier, as i=
t uses
"lock subl $0x1,(%eax)"

Maybe we could define a smp_mb_after_read_lock()  (a compiler barrier()=
 on x86)

