From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Tue, 21 Sep 2010 11:21:00 +0200
Message-ID: <1285060860.2617.158.camel@edumazet-laptop>
References: <20100921091248.GA8424@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40673 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171Ab0IUJVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 05:21:06 -0400
In-Reply-To: <20100921091248.GA8424@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 septembre 2010 =C3=A0 09:12 +0000, Jarek Poplawski a =C3=A9=
crit :
> On 2010-09-20 23:31, Eric Dumazet wrote:
> ...
> > [PATCH] ip : fix truesize mismatch in ip fragmentation
> >=20
> > We should not set frag->destructor to sock_wkfree() until we are su=
re we
> > dont hit slow path in ip_fragment(). Or we risk uncharging
> > frag->truesize twice, and in the end, having negative socket
> > sk_wmem_alloc counter, or even freeing socket sooner than expected.
> >=20
> > Many thanks to Nick Bowler, who provided a very clean bug report an=
d
> > test programs.
> >=20
> > While Nick bisection pointed to commit 2b85a34e911bf483 (net: No mo=
re
> > expensive sock_hold()/sock_put() on each tx), underlying bug is old=
er.
> >=20
> > Reported-and-bisected-by: Nick Bowler <nbowler@elliptictech.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  net/ipv4/ip_output.c  |    8 ++++----
> >  net/ipv6/ip6_output.c |   10 +++++-----
> >  2 files changed, 9 insertions(+), 9 deletions(-)
> >=20
> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > index 04b6989..126d9b3 100644
> > --- a/net/ipv4/ip_output.c
> > +++ b/net/ipv4/ip_output.c
> > @@ -490,7 +490,6 @@ int ip_fragment(struct sk_buff *skb, int (*outp=
ut)(struct sk_buff *))
> >  	if (skb_has_frags(skb)) {
> >  		struct sk_buff *frag;
> >  		int first_len =3D skb_pagelen(skb);
> > -		int truesizes =3D 0;
> > =20
> >  		if (first_len - hlen > mtu ||
> >  		    ((first_len - hlen) & 7) ||
> > @@ -510,11 +509,13 @@ int ip_fragment(struct sk_buff *skb, int (*ou=
tput)(struct sk_buff *))
> >  				goto slow_path;
> > =20
> >  			BUG_ON(frag->sk);
> > -			if (skb->sk) {
> > +		}
> > +		if (skb->sk) {
> > +			skb_walk_frags(skb, frag) {
> >  				frag->sk =3D skb->sk;
> >  				frag->destructor =3D sock_wfree;
>=20
> Nice catch, but it seems doing it in the first loop as now, and
> reverting changes before goto slow_path might be more optimal here.
>=20

I thought of this, but found this function already very complex.

Once everything is in cpu caches, the added loop is very cheap.

I liked the :

<check everything without changing state>
if something wrong
	goto slow_path
else
	<OK, lets do destructive things>


