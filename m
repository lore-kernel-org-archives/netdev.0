From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 15:25:40 +0200
Message-ID: <1319030740.8416.14.camel@edumazet-laptop>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4)  <1319029101.4424.36.camel@jlt3.sipsolutions.net>
	 <1319029794.4424.37.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45894 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467Ab1JSNZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 09:25:46 -0400
Received: by wyg36 with SMTP id 36so1714237wyg.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 06:25:45 -0700 (PDT)
In-Reply-To: <1319029794.4424.37.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 15:09 +0200, Johannes Berg a =C3=A9c=
rit :
> On Wed, 2011-10-19 at 14:58 +0200, Johannes Berg wrote:
>=20
> > Not disputing this either. But you said sk_refcnt can be 0, so why =
can't
> > the following happen:
> >=20
> > /* skb; skb->sk =3D sk; skb->destructor =3D sock_wfree; */
> >=20
> > /* skb is on qdisc, some time passes */
> >=20
> > sk_free(sk); /* user closed socket,
> >                 sk->sk_refcnt reaches 0,
> > 		sk->sk_wmem_alloc =3D=3D skb->truesize,
> > 		__sk_free not called, socket still lives,
> > 		but no more +1 in sk_wmem_alloc */
> >=20
> > /* some more time passes */
> >=20
> > /* ethernet hard_start_xmit calls skb_clone_tx_timestamp() */
> > skb2 =3D skb_clone(skb);
> > skb2->sk =3D skb->sk;
> > sock_hold(skb->sk);
> >=20
> > /* ethernet TX completion calls skb_free(skb) */
> > skb_free(skb):
> >   sock_wfree(skb); /* sk_wmem_alloc reaches 0,
> >                       __sk_free called DESPITE sk_refcnt > 0 */
> >=20
> > /* later, in skb_complete_tx_timestamp() */
> > sock_put(sk);	/* KABOOM */
>=20
>=20
> Given the complexity of all this, I'm not sure we shouldn't do someth=
ing
> like this, but I have no idea what the cost would be:
>=20
> --- wireless-testing.orig/include/net/sock.h	2011-10-18 22:28:41.0000=
00000 +0200
> +++ wireless-testing/include/net/sock.h	2011-10-19 15:08:45.000000000=
 +0200
> @@ -434,7 +434,10 @@ static __inline__ int __sk_del_node_init
> =20
>  static inline void sock_hold(struct sock *sk)
>  {
> -	atomic_inc(&sk->sk_refcnt);
> +	if (atomic_inc_return(&sk->sk_refcnt) =3D=3D 1) {
> +		/* was zero -- we must've gotten an sk_wmem_alloc reference */
> +		atomic_inc(&sk->sk_wmem_alloc);
> +	}
>  }
> =20

Hmm, it will be difficult to handle two atomics without adding races,
and add quite expensive atomic_inc_return() on some arches.

I would just change the skb tx cloning to take a normal reference on
sk_wmem_alloc

	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
instead of
	sock_hold(sk);
