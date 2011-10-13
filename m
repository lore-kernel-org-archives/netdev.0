From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 18:24:50 +0200
Message-ID: <1318523090.2393.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318521901.2745.18.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53477 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462Ab1JMQYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 12:24:34 -0400
Received: by wyg34 with SMTP id 34so2037969wyg.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 09:24:33 -0700 (PDT)
In-Reply-To: <1318521901.2745.18.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 octobre 2011 =C3=A0 17:05 +0100, Ben Hutchings a =C3=A9crit=
 :
> On Thu, 2011-10-13 at 17:26 +0200, Eric Dumazet wrote:
> > skb truesize currently accounts for sk_buff struct and part of skb =
head.
> >=20
> > Considering that skb_shared_info is larger than sk_buff, its time t=
o
> > take it into account for better memory accounting.
> >=20
> > This patch introduces SKB_TRUESIZE(X) macro to centralize various
> > assumptions into a single place.
> >=20
> > At skb alloc phase, we put skb_shared_info struct at the exact end =
of
> > skb head, to allow a better use of memory (lowering number of
> > reallocations), since kmalloc() gives us power-of-two memory blocks=
=2E
> [...]
> > index 5b2c5f1..be66154 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -184,11 +184,15 @@ struct sk_buff *__alloc_skb(unsigned int size=
, gfp_t gfp_mask,
> >  		goto out;
> >  	prefetchw(skb);
> > =20
> > -	size =3D SKB_DATA_ALIGN(size);
> > -	data =3D kmalloc_node_track_caller(size + sizeof(struct skb_share=
d_info),
> > -			gfp_mask, node);
> > +	size +=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> [...]
>=20
> If we want to put the data and skb_shared_info on separate cache-line=
s
> then we should use:
> 	size =3D SKB_DATA_ALIGN(size) + sizeof(struct skb_shared_info);
> (which is effectively what we're doing now).
>=20

Same behavior after my patch : skb_shared_info starts at a cache-line
boundary, like before, unless kmalloc() gives us unaligned memory (it
can in certain debugging situations)

So previous part (before skb_shared_info) will also be a multiple of
SMP_CACHE_BYTES because of kmalloc() behavior.

> If that's not important, and we just want to be sure that the allocat=
ion
> occupies at least a whole cache line, then it should be:
> 	size =3D SKB_DATA_ALIGN(size + sizeof(struct skb_shared_info));
>=20
> But I don't think it makes sense to use SKB_DATA_ALIGN(sizeof(struct
> skb_shared_info)).

If you take a closer look, you'll see that my patch addresses your
concerns, but at minimal cpu cost.

kmalloc(size + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))

will give same result than :

kmalloc(SKB_DATA_ALIGN(size) + SKB_DATA_ALIGN(sizeof(struct
skb_shared_info)))

But my version is a bit faster (a single add of a compiler known
constant)
