From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 09 Nov 2011 18:49:44 +0100
Message-ID: <1320860984.3916.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60257 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285Ab1KIRtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 12:49:47 -0500
Received: by wyh15 with SMTP id 15so1858840wyh.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 09:49:46 -0800 (PST)
In-Reply-To: <1320850895.955.172.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 novembre 2011 =C3=A0 15:01 +0000, Ian Campbell a =C3=A9c=
rit :
> The following series makes use of the skb fragment API (which is in 3=
=2E2)
> to add a per-paged-fragment destructor callback. This can be used by
> creators of skbs who are interested in the lifecycle of the pages
> included in that skb after they have handed it off to the network sta=
ck.
> I think these have all been posted before, but have been backed up
> behind the skb fragment API.
>=20
> The mail at [0] contains some more background and rationale but
> basically the completed series will allow entities which inject pages
> into the networking stack to receive a notification when the stack ha=
s
> really finished with those pages (i.e. including retransmissions,
> clones, pull-ups etc) and not just when the original skb is finished
> with, which is beneficial to many subsystems which wish to inject pag=
es
> into the network stack without giving up full ownership of those page=
's
> lifecycle. It implements something broadly along the lines of what wa=
s
> described in [1].
>=20
> I have also included a patch to the RPC subsystem which uses this API=
 to
> fix the bug which I describe at [2].
>=20
> I presented this work at LPC in September and there was a
> question/concern raised (by Jesse Brandenburg IIRC) regarding the
> overhead of adding this extra field per fragment. If I understand
> correctly it seems that in the there have been performance regression=
s
> in the past with allocations outgrowing one allocation size bucket an=
d
> therefore using the next. The change in datastructure size resulting
> from this series is:
> 					  BEFORE	AFTER
> AMD64:	sizeof(struct skb_frag_struct)	=3D 16		24
> 	sizeof(struct skb_shared_info)	=3D 344		488

Thats a real problem, because 488 is soo big. (its even rounded to 512
bytes)

Now, on x86, a half page (2048 bytes) wont be big enough to contain a
typical frame (MTU=3D1500)

NET_SKB_PAD (64) + 1500 + 14 + 512 > 2048


Even if we dont round 488 to 512, (no cache align skb_shared_info) we
have a problem.

NET_SKB_PAD (64) + 1500 + 14 + 488 > 2048

Why not using a low order bit to mark 'page' being a pointer to=20

struct skb_frag_page_desc {
	struct page *p;
	atomic_t ref;
	int (*destroy)(void *data);
/*	void *data; */ /* no need, see container_of() */
};

struct skb_frag_struct {
        struct {
                union {
			struct page *p; /* low order bit not set */
			struct skb_frag_page_desc *skbpage; /* low order bit set */
		};
        } page;
=2E..
