From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 14:38:01 +0200
Message-ID: <1319027881.3103.27.camel@edumazet-laptop>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57713 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925Ab1JSMiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 08:38:08 -0400
Received: by wyg36 with SMTP id 36so1664428wyg.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 05:38:06 -0700 (PDT)
In-Reply-To: <20111019115012.GA7206@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 13:50 +0200, Richard Cochran a =C3=A9=
crit :
> On Wed, Oct 19, 2011 at 07:15:36AM +0200, Johannes Berg wrote:
> > The only thing I'm not completely sure about is whether or not it i=
s
> > permissible to sock_hold() at that point. I'm probably just missing
> > something, but: if sk_free() was called before hard_start_xmit() wh=
ich
> > will call skb_clone_tx_timestamp(), can we really call sock_hold()?
> >=20

This is not possible, or something is really broken. We specifically
dont skb_orphan(skb) if we know tx timestamping is enabled for this skb=
=2E

/*
 * Try to orphan skb early, right before transmission by the device.
 * We cannot orphan skb if tx timestamp is requested or the sk-referenc=
e
 * is needed on driver level for other reasons, e.g. see net/can/raw.c
 */
static inline void skb_orphan_try(struct sk_buff *skb)
{
        struct sock *sk =3D skb->sk;

        if (sk && !skb_shinfo(skb)->tx_flags) {
                /* skb_tx_hash() wont be able to get sk.
                 * We copy sk_hash into skb->rxhash
                 */
                if (!skb->rxhash)
                        skb->rxhash =3D sk->sk_hash;
                skb_orphan(skb);
        }
}


> > The reason I ask is that sock_wfree() doesn't check sk_refcnt, so i=
f it
> > is possible for sk_free() to have been called before hard_start_xmi=
t(),
> > maybe because the packet was stuck on the qdisc for a while, the so=
cket
> > won't be released (sk_free checks sk_wmem_alloc) but the sk_wfree()=
 when
> > the original skb is freed will actually free the socket, invalidati=
ng
> > the clone's sk pointer *even though* we called sock_hold() right af=
ter
> > making the clone.
> >=20
> > So what guarantees that sk_refcnt is still non-zero when we make th=
e
> > clone?
>=20
> In the non-qdisc path, the kernel is in a send() call, so the initial
> reference taken in socket() is held.
>=20
> I really don't know the qdisc code, whether it is somehow holding the
> skb->sk indirectly or not.
>=20
> Eric? David?

I dont really understand what's the concern, since sk_free() doesnt car=
e
at all about sk_refcnt, but sk_wmem_alloc.

void sk_free(struct sock *sk)
{
        /*
         * We subtract one from sk_wmem_alloc and can know if
         * some packets are still in some tx queue.
         * If not null, sock_wfree() will call __sk_free(sk) later
         */
        if (atomic_dec_and_test(&sk->sk_wmem_alloc))
                __sk_free(sk);
}
EXPORT_SYMBOL(sk_free);


If one skb is in flight, and still linked to a socket, then this socket
cannot disappear, because this skb->truesize was accounted into
sk->sk_wmem_alloc

Of course, this point is valid as long as skb had not been orphaned.

sk_refcnt can be 0, if user closed the socket, but socket wont disappea=
r
as long as sk_wmem_alloc is not 0.
