From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Thu, 10 Nov 2011 10:39:28 +0000
Message-ID: <1320921568.955.208.camel@zakaz.uk.xensource.com>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
	 <1320860984.3916.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:58035 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756562Ab1KJKj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 05:39:29 -0500
In-Reply-To: <1320860984.3916.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-09 at 17:49 +0000, Eric Dumazet wrote:
> Le mercredi 09 novembre 2011 =C3=A0 15:01 +0000, Ian Campbell a =C3=A9=
crit :
> > The following series makes use of the skb fragment API (which is in=
 3.2)
> > to add a per-paged-fragment destructor callback. This can be used b=
y
> > creators of skbs who are interested in the lifecycle of the pages
> > included in that skb after they have handed it off to the network s=
tack.
> > I think these have all been posted before, but have been backed up
> > behind the skb fragment API.
> >=20
> > The mail at [0] contains some more background and rationale but
> > basically the completed series will allow entities which inject pag=
es
> > into the networking stack to receive a notification when the stack =
has
> > really finished with those pages (i.e. including retransmissions,
> > clones, pull-ups etc) and not just when the original skb is finishe=
d
> > with, which is beneficial to many subsystems which wish to inject p=
ages
> > into the network stack without giving up full ownership of those pa=
ge's
> > lifecycle. It implements something broadly along the lines of what =
was
> > described in [1].
> >=20
> > I have also included a patch to the RPC subsystem which uses this A=
PI to
> > fix the bug which I describe at [2].
> >=20
> > I presented this work at LPC in September and there was a
> > question/concern raised (by Jesse Brandenburg IIRC) regarding the
> > overhead of adding this extra field per fragment. If I understand
> > correctly it seems that in the there have been performance regressi=
ons
> > in the past with allocations outgrowing one allocation size bucket =
and
> > therefore using the next. The change in datastructure size resultin=
g
> > from this series is:
> > 					  BEFORE	AFTER
> > AMD64:	sizeof(struct skb_frag_struct)	=3D 16		24
> > 	sizeof(struct skb_shared_info)	=3D 344		488
>=20
> Thats a real problem, because 488 is soo big. (its even rounded to 51=
2
> bytes)
>=20
> Now, on x86, a half page (2048 bytes) wont be big enough to contain a
> typical frame (MTU=3D1500)
>=20
> NET_SKB_PAD (64) + 1500 + 14 + 512 > 2048
>=20
>=20
> Even if we dont round 488 to 512, (no cache align skb_shared_info) we
> have a problem.
>=20
> NET_SKB_PAD (64) + 1500 + 14 + 488 > 2048

Thanks Eric, that makes perfect sense. I doubt we can find a way to sav=
e
the necessary 18 bytes (or more depending on how much NET_SKB_PAD adds)
to make that > into a <=3D so I'll need to find another way.

> Why not using a low order bit to mark 'page' being a pointer to=20

Yes, that was what I meant by "steal a bit a pointer" (leaving aside my
mangled English there...). I think it's probably the best of the
options, I'll code it up.

Ian.

>=20
> struct skb_frag_page_desc {
> 	struct page *p;
> 	atomic_t ref;
> 	int (*destroy)(void *data);
> /*	void *data; */ /* no need, see container_of() */
> };
>=20
> struct skb_frag_struct {
>         struct {
>                 union {
> 			struct page *p; /* low order bit not set */
> 			struct skb_frag_page_desc *skbpage; /* low order bit set */
> 		};
>         } page;
> ...
>=20
>=20
