From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 14:58:21 +0200
Message-ID: <1319029101.4424.36.camel@jlt3.sipsolutions.net>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:38151 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916Ab1JSM61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 08:58:27 -0400
In-Reply-To: <1319027881.3103.27.camel@edumazet-laptop> (sfid-20111019_143837_360206_014A6AA4)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-19 at 14:38 +0200, Eric Dumazet wrote:
> Le mercredi 19 octobre 2011 =C3=A0 13:50 +0200, Richard Cochran a =C3=
=A9crit :
> > On Wed, Oct 19, 2011 at 07:15:36AM +0200, Johannes Berg wrote:
> > > The only thing I'm not completely sure about is whether or not it=
 is
> > > permissible to sock_hold() at that point. I'm probably just missi=
ng
> > > something, but: if sk_free() was called before hard_start_xmit() =
which
> > > will call skb_clone_tx_timestamp(), can we really call sock_hold(=
)?
> > >=20
>=20
> This is not possible, or something is really broken. We specifically
> dont skb_orphan(skb) if we know tx timestamping is enabled for this s=
kb.

Why can't sk_free() have been called? I'm not thinking of sock_wfree()
which can't have been called -- so the socket surely still exists
because skb->truesize is still accounted to it -- but what says
sk_refcnt hasn't reached 0 yet?

> /*
>  * Try to orphan skb early, right before transmission by the device.
>  * We cannot orphan skb if tx timestamp is requested or the sk-refere=
nce
>  * is needed on driver level for other reasons, e.g. see net/can/raw.=
c
>  */
> static inline void skb_orphan_try(struct sk_buff *skb)
> {
>         struct sock *sk =3D skb->sk;
>=20
>         if (sk && !skb_shinfo(skb)->tx_flags) {
>                 /* skb_tx_hash() wont be able to get sk.
>                  * We copy sk_hash into skb->rxhash
>                  */
>                 if (!skb->rxhash)
>                         skb->rxhash =3D sk->sk_hash;
>                 skb_orphan(skb);
>         }
> }

Right.

> I dont really understand what's the concern, since sk_free() doesnt c=
are
> at all about sk_refcnt, but sk_wmem_alloc.

Right.

> void sk_free(struct sock *sk)
[snip]

> If one skb is in flight, and still linked to a socket, then this sock=
et
> cannot disappear, because this skb->truesize was accounted into
> sk->sk_wmem_alloc

This is undoubtedly true, I'm not disputing this.

> Of course, this point is valid as long as skb had not been orphaned.
>=20
> sk_refcnt can be 0, if user closed the socket, but socket wont disapp=
ear
> as long as sk_wmem_alloc is not 0.

Not disputing this either. But you said sk_refcnt can be 0, so why can'=
t
the following happen:

/* skb; skb->sk =3D sk; skb->destructor =3D sock_wfree; */

/* skb is on qdisc, some time passes */

sk_free(sk); /* user closed socket,
                sk->sk_refcnt reaches 0,
		sk->sk_wmem_alloc =3D=3D skb->truesize,
		__sk_free not called, socket still lives,
		but no more +1 in sk_wmem_alloc */

/* some more time passes */

/* ethernet hard_start_xmit calls skb_clone_tx_timestamp() */
skb2 =3D skb_clone(skb);
skb2->sk =3D skb->sk;
sock_hold(skb->sk);

/* ethernet TX completion calls skb_free(skb) */
skb_free(skb):
  sock_wfree(skb); /* sk_wmem_alloc reaches 0,
                      __sk_free called DESPITE sk_refcnt > 0 */

/* later, in skb_complete_tx_timestamp() */
sock_put(sk);	/* KABOOM */


I just want to understand why this can't happen :-)

johannes
