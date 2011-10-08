From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Sat, 08 Oct 2011 12:32:15 +0200
Message-ID: <1318069935.3991.25.camel@jlt3.sipsolutions.net>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <20111007.133356.489094996618032061.davem@davemloft.net>
	 <20111008075719.GA2284@netboy.at.omicron.at>
	 (sfid-20111008_095753_882744_64F82E9F)  <1318061808.3991.12.camel@jlt3.sipsolutions.net>
	 <1318064238.5276.2.camel@edumazet-laptop>
	 (sfid-20111008_105753_719848_528419C0)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:49660 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879Ab1JHKcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 06:32:22 -0400
In-Reply-To: <1318064238.5276.2.camel@edumazet-laptop> (sfid-20111008_105753_719848_528419C0)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-10-08 at 10:57 +0200, Eric Dumazet wrote:
> Le samedi 08 octobre 2011 =C3=A0 10:16 +0200, Johannes Berg a =C3=A9c=
rit :
>=20
> > I'm not terribly familiar with struct sock. Looking at it, I'm a bi=
t
> > confused by skb_orphan() -- it doesn't put the sock reference. So a=
re
> > sockets not refcounted for skbs in this way? They seem to use
> > sock_wfree() which does a bit more than this it seems, and I don't =
see
> > it using sk_refcnt anywhere so I'm a bit confused now.
>=20
> Check following commit changelog to get some information on this.
>=20
> commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Thu Jun 11 02:55:43 2009 -0700
>=20
>     net: No more expensive sock_hold()/sock_put() on each tx

Aha, thanks for the pointer!

>     As we also update sk_wmem_alloc, we could offset sk_wmem_alloc
>     by one unit at init time, until sk_free() is called.

This is the trick! Neat. I see it now, now sk_free() makes sense to
me :-)

There's one thing I still miss though: It seems to me that if you have =
a
reference to a socket that has been sk_free()'ed (which is possible
since it might still have sk_wmem_alloc > 0) you can't sock_hold() that
socket. That feels a bit unexpected -- and might happen in the code
Richard just suggested.

Basically, while you can bump a reference you own via sock_hold() by
sk_wmem_alloc, as soon as sk_refcnt reaches 0 it must never go > 0 agai=
n
because that will have released the sk_wmem_alloc offset.

That can be fixed, but I'm not exactly sure what would be an efficient
way of doing it. Maybe by adding some flag that says whether or not the
sk_wmem_alloc offset is present, but that flag would have to be atomic
since I guess even this could race.

>     Drawback is that a skb->truesize error could lead to unfreeable s=
ockets, or
>     even worse, prematurely calling __sk_free() on a live socket.

I was thinking about this yesterday as well. What we could do is wrap
all the skb truesize operations in inlines -- the regular ones like
skb_truesize_set()/add()/sub() would (depending on a debug Kconfig)
check that the skb isn't charged to a socket, and common sequences like
changing truesize and updating the sock could be wrapped into another
set of inlines that do both. Or something like that.

I was actually thinking about this for other reasons but then realised
that with the truesize bug check gone (which was really checking
something else) I didn't really need to worry any more.

johannes
