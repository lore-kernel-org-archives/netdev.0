From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 15:21:43 +0200
Message-ID: <1319030503.8416.11.camel@edumazet-laptop>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4) <1319029101.4424.36.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61494 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab1JSNVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 09:21:55 -0400
Received: by wyg36 with SMTP id 36so1709558wyg.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 06:21:54 -0700 (PDT)
In-Reply-To: <1319029101.4424.36.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 14:58 +0200, Johannes Berg a =C3=A9c=
rit :
> On Wed, 2011-10-19 at 14:38 +0200, Eric Dumazet wrote:
> > Le mercredi 19 octobre 2011 =C3=A0 13:50 +0200, Richard Cochran a =C3=
=A9crit :
> > > On Wed, Oct 19, 2011 at 07:15:36AM +0200, Johannes Berg wrote:
> > > > The only thing I'm not completely sure about is whether or not =
it is
> > > > permissible to sock_hold() at that point. I'm probably just mis=
sing
> > > > something, but: if sk_free() was called before hard_start_xmit(=
) which
> > > > will call skb_clone_tx_timestamp(), can we really call sock_hol=
d()?
> > > >=20
> >=20
> > This is not possible, or something is really broken. We specificall=
y
> > dont skb_orphan(skb) if we know tx timestamping is enabled for this=
 skb.
>=20
> Why can't sk_free() have been called? I'm not thinking of sock_wfree(=
)
> which can't have been called -- so the socket surely still exists
> because skb->truesize is still accounted to it -- but what says
> sk_refcnt hasn't reached 0 yet?
>=20
> > /*
> >  * Try to orphan skb early, right before transmission by the device=
=2E
> >  * We cannot orphan skb if tx timestamp is requested or the sk-refe=
rence
> >  * is needed on driver level for other reasons, e.g. see net/can/ra=
w.c
> >  */
> > static inline void skb_orphan_try(struct sk_buff *skb)
> > {
> >         struct sock *sk =3D skb->sk;
> >=20
> >         if (sk && !skb_shinfo(skb)->tx_flags) {
> >                 /* skb_tx_hash() wont be able to get sk.
> >                  * We copy sk_hash into skb->rxhash
> >                  */
> >                 if (!skb->rxhash)
> >                         skb->rxhash =3D sk->sk_hash;
> >                 skb_orphan(skb);
> >         }
> > }
>=20
> Right.
>=20
> > I dont really understand what's the concern, since sk_free() doesnt=
 care
> > at all about sk_refcnt, but sk_wmem_alloc.
>=20
> Right.
>=20
> > void sk_free(struct sock *sk)
> [snip]
>=20
> > If one skb is in flight, and still linked to a socket, then this so=
cket
> > cannot disappear, because this skb->truesize was accounted into
> > sk->sk_wmem_alloc
>=20
> This is undoubtedly true, I'm not disputing this.
>=20
> > Of course, this point is valid as long as skb had not been orphaned=
=2E
> >=20
> > sk_refcnt can be 0, if user closed the socket, but socket wont disa=
ppear
> > as long as sk_wmem_alloc is not 0.
>=20
> Not disputing this either. But you said sk_refcnt can be 0, so why ca=
n't
> the following happen:
>=20
> /* skb; skb->sk =3D sk; skb->destructor =3D sock_wfree; */
>=20
> /* skb is on qdisc, some time passes */
>=20
> sk_free(sk); /* user closed socket,
>                 sk->sk_refcnt reaches 0,
> 		sk->sk_wmem_alloc =3D=3D skb->truesize,
> 		__sk_free not called, socket still lives,
> 		but no more +1 in sk_wmem_alloc */
>=20
> /* some more time passes */
>=20
> /* ethernet hard_start_xmit calls skb_clone_tx_timestamp() */
> skb2 =3D skb_clone(skb);
> skb2->sk =3D skb->sk;
> sock_hold(skb->sk);
>=20
> /* ethernet TX completion calls skb_free(skb) */
> skb_free(skb):
>   sock_wfree(skb); /* sk_wmem_alloc reaches 0,
>                       __sk_free called DESPITE sk_refcnt > 0 */
>=20
> /* later, in skb_complete_tx_timestamp() */
> sock_put(sk);	/* KABOOM */
>=20
>=20
> I just want to understand why this can't happen :-)

Since you answer your own question :)

Hmm, oh well, sk_refcnt is/should not be changed if a xmit packet is
duped, but sk_wmem_alloc should be, exactly paired with skb->truesize
