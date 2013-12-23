From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: allow > 0 order atomic page alloc in
 skb_page_frag_refill
Date: Mon, 23 Dec 2013 09:24:57 -0800
Message-ID: <1387819497.12212.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	 <52B7EBB9.6050405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:38732 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757799Ab3LWRY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 12:24:59 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so5333265pdi.24
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 09:24:59 -0800 (PST)
In-Reply-To: <52B7EBB9.6050405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-23 at 15:52 +0800, Jason Wang wrote:
> On 12/17/2013 08:16 AM, Michael Dalton wrote:
> > skb_page_frag_refill currently permits only order-0 page allocs
> > unless GFP_WAIT is used. Change skb_page_frag_refill to attempt
> > higher-order page allocations whether or not GFP_WAIT is used. If
> > memory cannot be allocated, the allocator will fall back to
> > successively smaller page allocs (down to order-0 page allocs).
> >
> > This change brings skb_page_frag_refill in line with the existing
> > page allocation strategy employed by netdev_alloc_frag, which attempts
> > higher-order page allocations whether or not GFP_WAIT is set, falling
> > back to successively lower-order page allocations on failure. Part
> > of migration of virtio-net to per-receive queue page frag allocators.
> >
> > Signed-off-by: Michael Dalton <mwdalton@google.com>
> > ---
> >  net/core/sock.c | 4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> >
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index ab20ed9..7383d23 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1865,9 +1865,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
> >  		put_page(pfrag->page);
> >  	}
> >  
> > -	/* We restrict high order allocations to users that can afford to wait */
> > -	order = (prio & __GFP_WAIT) ? SKB_FRAG_PAGE_ORDER : 0;
> > -
> > +	order = SKB_FRAG_PAGE_ORDER;
> >  	do {
> >  		gfp_t gfp = prio;
> >  
> 
> The original code seems try to avoid the high order allocation for
> atomic allocation. This patch changes this, and looks like it will
> introduce some extra cost when the memory is highly fragmented.

No noticeable extra cost that I could measure.

We use the same strategy in RX path nowadays.

Acked-by: Eric Dumazet <edumazet@google.com>
