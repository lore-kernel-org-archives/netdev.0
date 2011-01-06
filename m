From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Fri, 7 Jan 2011 07:01:12 +0900
Message-ID: <20110106220030.GA2084@verge.net.au>
References: <20110106093312.GA1564@verge.net.au>
 <1294309362.3074.11.camel@edumazet-laptop>
 <20110106124439.GA17004@verge.net.au>
 <1294320498.3074.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49033 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab1AFWuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 17:50:50 -0500
Content-Disposition: inline
In-Reply-To: <1294320498.3074.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 06, 2011 at 02:28:18PM +0100, Eric Dumazet wrote:
> Le jeudi 06 janvier 2011 =C3=A0 21:44 +0900, Simon Horman a =C3=A9cri=
t :
>=20
> > Hi Eric !
> >=20
> > Thanks for the advice. I had thought about the socket buffer but at=
 some
> > point it slipped my mind.
> >=20
> > In any case the following patch seems to implement the change that =
I had in
> > mind. However my discussions Michael Tsirkin elsewhere in this thre=
ad are
> > beginning to make me think that think that perhaps this change isn'=
t the
> > best solution.
> >=20
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 5e16143..505f13f 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > @@ -384,7 +384,12 @@ static int do_execute_actions(struct datapath =
*dp, struct sk_buff *skb,
> > =20
> >  	for (a =3D actions, rem =3D actions_len; rem > 0; a =3D nla_next(=
a, &rem)) {
> >  		if (prev_port !=3D -1) {
> > -			do_output(dp, skb_clone(skb, GFP_ATOMIC), prev_port);
> > +			struct sk_buff *nskb =3D skb_clone(skb, GFP_ATOMIC);
> > +			if (nskb) {
> > +				if (skb->sk)
> > +					skb_set_owner_w(nskb, skb->sk);
> > +				do_output(dp, nskb, prev_port);
> > +			}
> >  			prev_port =3D -1;
> >  		}
> >=20
> > I got a rather nasty panic without the if (skb->sk),
> > I guess some skbs don't have a socket.
>=20
> Indeed, some packets are not linked to a socket.
>=20
> (ARP packets for example)
>=20
> Sorry, I should have mentioned it :)

Not at all, the occasional panic during hacking is good for the soul.
