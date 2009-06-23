From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [RFC] tcp: race in receive part
Date: Tue, 23 Jun 2009 11:12:57 +0200
Message-ID: <20090623091257.GA4850@jolsa.lab.eng.brq.redhat.com>
References: <20090618102727.GC3782@jolsa.lab.eng.brq.redhat.com> <4A3A49F2.6060705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37894 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161AbZFWJNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2009 05:13:00 -0400
Content-Disposition: inline
In-Reply-To: <4A3A49F2.6060705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

thanks for an answer, and sorry for my late reply,
we needed the cust permission to disclose the debug data.


On Thu, Jun 18, 2009 at 04:06:42PM +0200, Eric Dumazet wrote:
> Jiri Olsa a =C3=A9crit :
> > Hi,
> >=20
> > in RHEL4 we can see a race in the tcp layer. We were not able to re=
produce=20
> > this on the upstream kernel, but since the issue occurs very rarell=
y
> > (once per 8 days), we just might not be lucky.
> >=20
> > I'm affraid this might be a long email, I'll try to structure it ni=
cely.. :)
> >=20
>=20
> Thanks for your mail and detailed analysis
>=20
> >=20
> >=20
> > RACE DESCRIPTION
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >=20
> > There's a nice pdf describing the issue (and sollution using locks)=
 on
> > https://bugzilla.redhat.com/attachment.cgi?id=3D345014
>=20
> I could not reach this url unfortunatly=20
>=20
> --> "You are not authorized to access bug #494404. "

please try it now, the bug should be accessible now

>=20
> >=20
> >=20
> > The race fires, when following code paths meet, and the tp->rcv_nxt=
 and
> > __add_wait_queue updates stay in CPU caches.
> >=20
> > CPU1                         CPU2
> >=20
> >=20
> > sys_select                   receive packet
> >   ...                        ...
> >   __add_wait_queue           update tp->rcv_nxt
> >   ...                        ...
> >   tp->rcv_nxt check          sock_def_readable
> >   ...                        {
> >   schedule                      ...
> >                                 if (sk->sk_sleep && waitqueue_activ=
e(sk->sk_sleep))
> >                                         wake_up_interruptible(sk->s=
k_sleep)
> >                                 ...
> >                              }
> >=20
> > If there were no cache the code would work ok, since the wait_queue=
 and
> > rcv_nxt are opposit to each other.
> >=20
> > Meaning that once tp->rcv_nxt is updated by CPU2, the CPU1 either a=
lready
> > passed the tp->rcv_nxt check and sleeps, or will get the new value =
for
> > tp->rcv_nxt and will return with new data mask. =20
> > In both cases the process (CPU1) is being added to the wait queue, =
so the
> > waitqueue_active (CPU2) call cannot miss and will wake up CPU1.
> >=20
> > The bad case is when the __add_wait_queue changes done by CPU1 stay=
 in its
> > cache , and so does the tp->rcv_nxt update on CPU2 side.  The CPU1 =
will then
> > endup calling schedule and sleep forever if there are no more data =
on the
> > socket.
> >=20
> > Adding smp_mb() calls before sock_def_readable call and after __add=
_wait_queue
> > should prevent the above bad scenario.
> >=20
> > The upstream patch is attached. It seems to prevent the issue.
> >=20
> >=20
> >=20
> > CPU BUGS
> > =3D=3D=3D=3D=3D=3D=3D=3D
> >=20
> > The customer has been able to reproduce this problem only on one CP=
U model:
> > Xeon E5345*2. They didn't reproduce on XEON MV, for example.
>=20
> Is there an easy way to reproduce the problem ?

there's a reproducer attached to the bug

https://enterprise.redhat.com/issue-tracker/?module=3Ddownload&fid=3D20=
1560&key=3Df6f87caf6ac2dc1eb1173257c8a5ef78

it is basically the client/server program.=20
They're passing messages to each other. When a message is sent,
both of them expect message on the input before sending another message=
=2E

Very rarely the code hits the place when the process which called selec=
t
is not woken up by incomming data. Probably because of the memory cache
incoherency. See backtrace in the=20

https://bugzilla.redhat.com/show_bug.cgi?id=3D494404#c1


>=20
> >=20
> > That CPU model happens to have 2 possible issues, that might cause =
the issue:
> > (see errata http://www.intel.com/Assets/PDF/specupdate/315338.pdf)
> >=20
> > AJ39 and AJ18. The first one can be workarounded by BIOS upgrade,
> > the other one has following notes:
>=20
> AJ18 only matters on unaligned accesses, tcp code doesnt do this.
>=20
> >=20
> >       Software should ensure at least one of the following is true =
when
> >       modifying shared data by multiple agents:
> >              =E2=80=A2 The shared data is aligned
> >              =E2=80=A2 Proper semaphores or barriers are used in or=
der to
> >                 prevent concurrent data accesses.
> >=20
> >=20
> >=20
> > RFC
> > =3D=3D=3D
> >=20
> > I'm aware that not having this issue reproduced on upstream lowers =
the odds
> > having this checked in. However AFAICS the issue is present. I'd ap=
preciate
> > any comment/ideas.
> >=20
> >=20
> > thanks,
> > jirka
> >=20
> >=20
> > Signed-off-by: Jiri Olsa <jolsa@redhat.com>
> >=20
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 17b89c5..f5d9dbf 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -340,6 +340,11 @@ unsigned int tcp_poll(struct file *file, struc=
t socket *sock, poll_table *wait)
> >  	struct tcp_sock *tp =3D tcp_sk(sk);
> > =20
> >  	poll_wait(file, sk->sk_sleep, wait);
>=20
> poll_wait() calls add_wait_queue() which contains a=20
> spin_lock_irqsave()/spin_unlock_irqrestore() pair
>=20
> Documentation/memory-barriers.txt states in line 1123 :
>=20
> 	Memory operations issued after the LOCK will be completed after the =
LOCK
> 	operation has completed.
>=20
> and line 1131 states :
>=20
> 	Memory operations issued before the UNLOCK will be completed before =
the
> 	UNLOCK operation has completed.
>=20
> So yes, there is no full smp_mb() in poll_wait()
>=20
> > +
> > +	/* Get in sync with tcp_data_queue, tcp_urg
> > +	   and tcp_rcv_established function. */
> > +	smp_mb();
>=20
> If this barrier is really necessary, I guess it should be done in pol=
l_wait() itself.
>=20
> Documentation/memory-barriers.txt misses some information about poll_=
wait()
>=20
>=20
>=20
>=20
> > +
> >  	if (sk->sk_state =3D=3D TCP_LISTEN)
> >  		return inet_csk_listen_poll(sk);
> > =20
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index 2bdb0da..0606e5e 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -4362,8 +4362,11 @@ queue_and_out:
> > =20
> >  		if (eaten > 0)
> >  			__kfree_skb(skb);
> > -		else if (!sock_flag(sk, SOCK_DEAD))
> > +		else if (!sock_flag(sk, SOCK_DEAD)) {
> > +			/* Get in sync with tcp_poll function. */
> > +			smp_mb();
> >  			sk->sk_data_ready(sk, 0);
> > +		}
> >  		return;
> >
>=20
> Oh well... if smp_mb() is needed, I believe it should be done
> right before "if (waitqueue_active(sk->sk_sleep) ... "
>=20
>  	read_lock(&sk->sk_callback_lock);
> +	smp_mb();
>  	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
>  		wake_up_interruptible(sk->sk_sleep)
>=20
> It would match other parts in kernel (see fs/splice.c, fs/aio.c, ...)
>=20
> Strange thing is that read_lock() on x86 is a full memory barrier, as=
 it uses
> "lock subl $0x1,(%eax)"
>=20
> Maybe we could define a smp_mb_after_read_lock()  (a compiler barrier=
() on x86)
>=20

=46irst version of the patch was actually in this layer, see
https://bugzilla.redhat.com/attachment.cgi?id=3D345886

I was adviced this could be to invasive (it was in waitqueue_active act=
ually),=20
so I moved the change to the TCP layer itself...=20

As far as I understand the problem there's need for 2 barriers to be
sure, the memory will have correct data. One in the codepath calling th=
e
select (tcp_poll), and in the other one updating the available data sta=
tus=20
(sock_def_readable), am I missing smth?


thanks,
jirka
