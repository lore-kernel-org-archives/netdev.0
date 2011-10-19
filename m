From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 14:33:42 +0200
Message-ID: <1319027622.3103.23.camel@edumazet-laptop>
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
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36288 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944Ab1JSMdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 08:33:49 -0400
Received: by eye27 with SMTP id 27so1560345eye.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 05:33:47 -0700 (PDT)
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

This is not possible, or something is really broken.


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

I dont really understand what's the problem, since sk_free() doesnt car=
e
at all about sk_refcnt, but sk_wmem_alloc.

If one skb is in flight, and still linked to a socket, then this socket
cannot disappear, because this skb->truesize was accounted into
sk->sk_wmem_alloc

Of course, this point is valid as long as skb had not been orphaned.

And this is true=20
