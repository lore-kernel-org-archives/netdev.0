From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 12:54:18 +0100
Message-ID: <1293796458.2973.59.camel@edumazet-laptop>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
	 <1293789629.2973.26.camel@edumazet-laptop>
	 <1293790979.4787.10.camel@wall-e>
	 <1293792066.2973.43.camel@edumazet-laptop>
	 <1293794589.5285.16.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293794589.5285.16.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 12:23 +0100, Stefani Seibold a=
 =C3=A9crit :
> Am Freitag, den 31.12.2010, 11:41 +0100 schrieb Eric Dumazet:
> > Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 11:22 +0100, Stefani Seibo=
ld a =C3=A9crit :
> > > Am Freitag, den 31.12.2010, 11:00 +0100 schrieb Eric Dumazet:
> > > > Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 10:29 +0100, stefani@s=
eibold.net a
> > > > =C3=A9crit :
> > > > > From: Stefani Seibold <stefani@seibold.net>
> > > > >=20
> > > > > =20
> > > > >  /*
> > > > >   *	Handle MSG_ERRQUEUE
> > > > > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > > > > index 2d3ded4..f9890a2 100644
> > > > > --- a/net/ipv4/udp.c
> > > > > +++ b/net/ipv4/udp.c
> > > > > @@ -1310,7 +1310,7 @@ static int __udp_queue_rcv_skb(struct s=
ock *sk, struct sk_buff *skb)
> > > > >  	if (inet_sk(sk)->inet_daddr)
> > > > >  		sock_rps_save_rxhash(sk, skb->rxhash);
> > > > > =20
> > > > > -	rc =3D ip_queue_rcv_skb(sk, skb);
> > > > > +	rc =3D sock_queue_rcv_skb(sk, skb);
> > > >=20
> > > > Ouch... Care to explain why you changed this part ???
> > > >=20
> > > > You just destroyed commit f84af32cbca70a intent, without any wo=
rd in
> > > > your changelog. Making UDP slower, while others try to speed it=
 must be
> > > > explained and advertised.
> > > > =20
> > > > In general, we prefer a preliminary patch introducing all the c=
hanges in
> > > > current stack, then another one with the new protocol.
> > > >=20
> > >=20
> > > I reverted this for two reasons:
> > >=20
> > > First ip_queue_rcv_skb drops the dst entry, which breaks the user=
 land
> > > application which expect packet info after a
> > >=20
> > > setsockopt(handle, IPPROTO_IP, IP_PKTINFO, &const_int_1, sizeof(i=
nt));
> > >=20
> > > But for packets already in the queue this information will be los=
t. So
> > > it is a potential race condition.
> > >=20
> >=20
> > Exactly same race with packet filters.=20
> >=20
> > If your life depends on that, you must flush incoming queue _after_
> > issuing setsockopt(handle, IPPROTO_IP, IP_PKTINFO, &const_int_1,
> > sizeof(int)). So that all following packets have the information ne=
eded.
> >=20
> >=20
>=20
> I though always that the linux kernel never breaks user land. This is=
 a
> break!
>=20

Only if user land is buggy it breaks. Where is your user land code so
that I can show you the bug ?

This dst refcount avoidance is absolutely crucial and we worked hard on
it.

> >=20
> > > Second it breaks my UDPCP communication protocol stack module, wh=
ich
> > > works very well till 2.6.35. I need this information in the data_=
ready()
> > > function to generate an ACK.
> > >=20
> > >=20
> >=20
> > See now why you should not proceed like that ?
> >=20
> > You know _perfectly_ there is a problem but prefer to keep it for y=
ou,
> > and hope this bit will be unnoticed ?
> >=20
>=20
> Stop to accuse me. There was a feature that was gone. An it took me s=
ix
> hours to figure out whats going wrong. I did not saw and see a real
> problem with this patch. It looked for me like an easy and clean
> solution. It was never my intention to trick somebody, especially u.
>=20

Silently doing a revert is not an option. How must I tell this to you ?


> > This is not how things are dealed in linux, really.
> >=20
> > You'll have to find a way so that things work well for everybody, n=
ot
> > only for you.
> >=20
> > I guess you must fix UDPCP protocol stack, not 'fix linux'
> >=20
>=20
> I cannot fix it, because the information is still lost, and i need it=
=2E=20
>=20

You can fix it. Really. If not, you can pay me and I'll fix it for you.

> In my opinion it was a very bad idea to throw away important
> information. I checked it and Linux handle this since 2.6.0 in this w=
ay.
>=20
> It would be better not to accuse than to work on a solution.=20
>=20

Where do you see an "accuse" ? Because you tried to silently "fix" the
thing without telling us how the damn thing was broken ? Come on !

> Question: How much performace gain does the early drop give. Are ther=
e
> benchmark results?

Thats pretty simple. dst refcount was the only contention point in UDP
stack. Yes, its not a joke.

Re introducing an atomic_inc() at each incoming packet, and atomic_dec(=
)
each time user process dequeues the packet can have a huge impact.

One order of magnitude actually. Depending on number of cpus fighting o=
n
this cache line, this ranges from 20% to 4000% slowdown.

Some people handle thousands of UDP sockets on one machine. Your UDPCP
apparently handle very few sockets (you have one central linked list),
so your use case probably dont care of performance.
