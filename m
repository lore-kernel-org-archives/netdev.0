From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Thu, 17 Nov 2011 14:45:21 +0000
Message-ID: <1321541121.3664.270.camel@zakaz.uk.xensource.com>
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
Received: from smtp.eu.citrix.com ([62.200.22.115]:62609 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757704Ab1KQOpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 09:45:23 -0500
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

Am I right that it's not so much a case of fitting into half a page but
more like not wasting nearly half a page if you end up requiring a 4096
byte allocation? (This is probably splitting hairs, I'm really just
curious)

> Even if we dont round 488 to 512, (no cache align skb_shared_info) we
> have a problem.
>=20
> NET_SKB_PAD (64) + 1500 + 14 + 488 > 2048
>=20
> Why not using a low order bit to mark 'page' being a pointer to=20

I've given this a go but it makes the patches to the user of this
facility quite nasty (or at least it does for the sunrpc/NFS case). I'm
going to plug at it a bit more and see if I can't make it look cleaner
but I was starting to wonder about alternative approaches.

One idea was split the allocation of the data and the shinfo. Since
shinfo is a fixed size it would be easy to have a specific cache for
them. Does this sound even vaguely plausible?

> struct skb_frag_page_desc {
> 	struct page *p;
> 	atomic_t ref;
> 	int (*destroy)(void *data);
> /*	void *data; */ /* no need, see container_of() */

It turns out that container_of is not so useful here as the users
typically has a list of pages not a single page and hence has a list of
destructors too. What you actually need is the container of the pointer
to that list, IYSWIM, which you can't get at given only a pointer to an
element of the list. So you end up doing

	struct subsys_page_desc {
		struct subsys_container *container;
		struct sbk_frag_page_desc;
	}

*container here is basically the same as the void * so you might as wel=
l
include it in the base datastructure.

Ian.

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
