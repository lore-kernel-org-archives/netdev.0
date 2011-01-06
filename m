From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Thu, 06 Jan 2011 14:28:18 +0100
Message-ID: <1294320498.3074.36.camel@edumazet-laptop>
References: <20110106093312.GA1564@verge.net.au>
	 <1294309362.3074.11.camel@edumazet-laptop>
	 <20110106124439.GA17004@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62754 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725Ab1AFN2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 08:28:24 -0500
In-Reply-To: <20110106124439.GA17004@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 janvier 2011 =C3=A0 21:44 +0900, Simon Horman a =C3=A9crit =
:

> Hi Eric !
>=20
> Thanks for the advice. I had thought about the socket buffer but at s=
ome
> point it slipped my mind.
>=20
> In any case the following patch seems to implement the change that I =
had in
> mind. However my discussions Michael Tsirkin elsewhere in this thread=
 are
> beginning to make me think that think that perhaps this change isn't =
the
> best solution.
>=20
> diff --git a/datapath/actions.c b/datapath/actions.c
> index 5e16143..505f13f 100644
> --- a/datapath/actions.c
> +++ b/datapath/actions.c
> @@ -384,7 +384,12 @@ static int do_execute_actions(struct datapath *d=
p, struct sk_buff *skb,
> =20
>  	for (a =3D actions, rem =3D actions_len; rem > 0; a =3D nla_next(a,=
 &rem)) {
>  		if (prev_port !=3D -1) {
> -			do_output(dp, skb_clone(skb, GFP_ATOMIC), prev_port);
> +			struct sk_buff *nskb =3D skb_clone(skb, GFP_ATOMIC);
> +			if (nskb) {
> +				if (skb->sk)
> +					skb_set_owner_w(nskb, skb->sk);
> +				do_output(dp, nskb, prev_port);
> +			}
>  			prev_port =3D -1;
>  		}
>=20
> I got a rather nasty panic without the if (skb->sk),
> I guess some skbs don't have a socket.

Indeed, some packets are not linked to a socket.

(ARP packets for example)

Sorry, I should have mentioned it :)


