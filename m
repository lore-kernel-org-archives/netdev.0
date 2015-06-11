From: Shaohua Li <shli@fb.com>
Subject: Re: [RFC v2] net: use atomic allocation for order-3 page allocation
Date: Thu, 11 Jun 2015 16:32:35 -0700
Message-ID: <20150611233235.GA667489@devbig257.prn2.facebook.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
 <1434063184.27504.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<Kernel-team@fb.com>, <clm@fb.com>, <linux-mm@kvack.org>,
	<dbavatar@gmail.com>, Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46634 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752257AbbFKXcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 19:32:47 -0400
Content-Disposition: inline
In-Reply-To: <1434063184.27504.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 03:53:04PM -0700, Eric Dumazet wrote:
> On Thu, 2015-06-11 at 15:27 -0700, Shaohua Li wrote:
> > We saw excessive direct memory compaction triggered by skb_page_frag_refill.
> > This causes performance issues and add latency. Commit 5640f7685831e0
> > introduces the order-3 allocation. According to the changelog, the order-3
> > allocation isn't a must-have but to improve performance. But direct memory
> > compaction has high overhead. The benefit of order-3 allocation can't
> > compensate the overhead of direct memory compaction.
> > 
> > This patch makes the order-3 page allocation atomic. If there is no memory
> > pressure and memory isn't fragmented, the alloction will still success, so we
> > don't sacrifice the order-3 benefit here. If the atomic allocation fails,
> > direct memory compaction will not be triggered, skb_page_frag_refill will
> > fallback to order-0 immediately, hence the direct memory compaction overhead is
> > avoided. In the allocation failure case, kswapd is waken up and doing
> > compaction, so chances are allocation could success next time.
> > 
> > The mellanox driver does similar thing, if this is accepted, we must fix
> > the driver too.
> > 
> > V2: make the changelog clearer
> > 
> > Cc: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > ---
> >  net/core/sock.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 292f422..e9855a4 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
> >  
> >  	pfrag->offset = 0;
> >  	if (SKB_FRAG_PAGE_ORDER) {
> > -		pfrag->page = alloc_pages(gfp | __GFP_COMP |
> > +		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
> >  					  __GFP_NOWARN | __GFP_NORETRY,
> >  					  SKB_FRAG_PAGE_ORDER);
> >  		if (likely(pfrag->page)) {
> 
> 
> OK, now what about alloc_skb_with_frags() ?
> 
> This should have same problem right ?

Ok, looks similar, added. Didn't trigger this one though.


>From 940dde18f7f655377a4c30d5de54c9eff15ab5a5 Mon Sep 17 00:00:00 2001
Message-Id: <940dde18f7f655377a4c30d5de54c9eff15ab5a5.1434065353.git.shli@fb.com>
From: Shaohua Li <shli@fb.com>
Date: Thu, 11 Jun 2015 16:16:21 -0700
Subject: [RFC] net: use atomic allocation for order-3 page allocation

We saw excessive direct memory compaction triggered by skb_page_frag_refill.
This causes performance issues and add latency. Commit 5640f7685831e0
introduces the order-3 allocation. According to the changelog, the order-3
allocation isn't a must-have but to improve performance. But direct memory
compaction has high overhead. The benefit of order-3 allocation can't
compensate the overhead of direct memory compaction.

This patch makes the order-3 page allocation atomic. If there is no memory
pressure and memory isn't fragmented, the alloction will still success, so we
don't sacrifice the order-3 benefit here. If the atomic allocation fails,
direct memory compaction will not be triggered, skb_page_frag_refill will
fallback to order-0 immediately, hence the direct memory compaction overhead is
avoided. In the allocation failure case, kswapd is waken up and doing
compaction, so chances are allocation could success next time.

alloc_skb_with_frags is the same.

The mellanox driver does similar thing, if this is accepted, we must fix
the driver too.

V3: fix the same issue in alloc_skb_with_frags as pointed out by Eric
V2: make the changelog clearer

Cc: Eric Dumazet <edumazet@google.com>
Cc: Chris Mason <clm@fb.com>
Cc: Debabrata Banerjee <dbavatar@gmail.com>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 net/core/skbuff.c | 4 +++-
 net/core/sock.c   | 2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3cfff2a..9856c7a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4398,7 +4398,9 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
 
 		while (order) {
 			if (npages >= 1 << order) {
-				page = alloc_pages(gfp_mask |
+				gfp_t gfp = order > 0 ?
+					gfp_mask & ~__GFP_WAIT : gfp_mask;
+				page = alloc_pages(gfp |
 						   __GFP_COMP |
 						   __GFP_NOWARN |
 						   __GFP_NORETRY,
diff --git a/net/core/sock.c b/net/core/sock.c
index 292f422..e9855a4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
 
 	pfrag->offset = 0;
 	if (SKB_FRAG_PAGE_ORDER) {
-		pfrag->page = alloc_pages(gfp | __GFP_COMP |
+		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
 					  __GFP_NOWARN | __GFP_NORETRY,
 					  SKB_FRAG_PAGE_ORDER);
 		if (likely(pfrag->page)) {
-- 
1.8.1
