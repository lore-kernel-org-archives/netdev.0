From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Fri, 24 Jun 2011 19:56:23 +0200
Message-ID: <1308938183.2532.8.camel@edumazet-laptop>
References: <1308930202.32717.144.camel@zakaz.uk.xensource.com>
	 <4E04C961.9010302@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel <xen-devel@lists.xensource.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47070 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930Ab1FXR41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 13:56:27 -0400
Received: by wyg8 with SMTP id 8so24955wyg.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 10:56:26 -0700 (PDT)
In-Reply-To: <4E04C961.9010302@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 juin 2011 =C3=A0 10:29 -0700, Jeremy Fitzhardinge a =C3=A9=
crit :
> On 06/24/2011 08:43 AM, Ian Campbell wrote:
> > We've previously looked into solutions using the skb destructor cal=
lback
> > but that falls over if the skb is cloned since you also need to kno=
w
> > when the clone is destroyed. Jeremy Fitzhardinge and I subsequently
> > looked at the possibility of a no-clone skb flag (i.e. always forci=
ng a
> > copy instead of a clone) but IIRC honouring it universally turned i=
nto a
> > very twisty maze with a number of nasty corner cases etc. It also s=
eemed
> > that the proportion of SKBs which get cloned at least once appeared=
 as
> > if it could be quite high which would presumably make the performan=
ce
> > impact unacceptable when using the flag. Another issue with using t=
he
> > skb destructor is that functions such as __pskb_pull_tail will eat =
(and
> > free) pages from the start of the frag array such that by the time =
the
> > skb destructor is called they are no longer there.
> >
> > AIUI Rusty Russell had previously looked into a per-page destructor=
 in
> > the shinfo but found that it couldn't be made to work (I don't reme=
mber
> > why, or if I even knew at the time). Could that be an approach wort=
h
> > reinvestigating?
> >
> > I can't really think of any other solution which doesn't involve so=
me
> > sort of driver callback at the time a page is free()d.
>=20

This reminds me the packet mmap (tx path) games we play with pages.

net/packet/af_packet.c : tpacket_destruct_skb(), poking
TP_STATUS_AVAILABLE back to user to tell him he can reuse space...

> One simple approach would be to simply make sure that we retain a pag=
e
> reference on any granted pages so that the network stack's put pages
> will never result in them being released back to the kernel.  We can
> also install an skb destructor.  If it sees a page being released wit=
h a
> refcount of 1, then we know its our own reference and can free the pa=
ge
> immediately.  If the refcount is > 1 then we can add it to a queue of
> pending pages, which can be periodically polled to free pages whose
> other references have been dropped.
>=20
> However, the question is how large will this queue get?  If it remain=
s
> small then this scheme could be entirely practical.  But if almost ev=
ery
> page ends up having transient stray references, it could become very
> awkward.
>=20
> So it comes down to "how useful is an skb destructor callback as a
> heuristic for page free"?
>=20

Dangerous I would say. You could have a skb1 page transferred to anothe=
r
skb2, and call skb1 destructor way before page being released.

TCP stack could do that in tcp_collapse() [ it currently doesnt play
with pages ]



