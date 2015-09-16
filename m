From: Florian Westphal <fw@strlen.de>
Subject: Re: IPv6 routing/fragmentation panic
Date: Wed, 16 Sep 2015 15:27:33 +0200
Message-ID: <20150916132733.GQ24810@breakpoint.cc>
References: <1442332400.131189.21.camel@infradead.org>
 <20150915234848.GO24810@breakpoint.cc>
 <1442398145.131189.46.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	johannes@sipsolutions.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38785 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752555AbbIPN1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 09:27:35 -0400
Content-Disposition: inline
In-Reply-To: <1442398145.131189.46.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> wrote:
> On Wed, 2015-09-16 at 01:48 +0200, Florian Westphal wrote:
> > 
> > What I don't understand is why you see this with fragmented ipv6 
> > packets only (and not with all ipv6 forwarded skbs).
> > 
> > Something like this copy-pastry from ip_finish_output2 should fix it:
> 
> That works; thanks.
> 
> Tested-by: David Woodhouse <David.Woodhouse@intel.com>
> 
> A little extra debugging output shows that the offending fragments were
> arriving here with skb_headroom(skb)==10. Which is reasonable, being
> the Solos ADSL card's header of 8 bytes followed by 2 bytes of PPP
> frame type.
> 
> The non-fragmented packets, on the other hand, are arriving with a
> headroom of 42 bytes. Could something else already have reallocated
> them before they get that far?

Yep.  I missed

        if (skb_cow(skb, dst->dev->hard_header_len)) {

call in ip6_forward().

Problem is of course that we only expand headroom of the skb
and not of the fragment(s) stored in that skbs frag list.

So we have several options for a fix.

- expand headroom in ip6_finish_output2, like we do for ipv4
- expand headroom in ip6_fragment
- defer to slowpath if frags don't have enough headroom.

The latter is the smallest patch and would not add test for locally
generated, non-fragmented skbs.

(not even compile tested)
David, could you test this?  I'd do an official patch submission then.

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -586,6 +586,7 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 	frag_id = ipv6_select_ident(net, &ipv6_hdr(skb)->daddr,
 				    &ipv6_hdr(skb)->saddr);
 
+	hroom = LL_RESERVED_SPACE(rt->dst.dev);
 	if (skb_has_frag_list(skb)) {
 		int first_len = skb_pagelen(skb);
 		struct sk_buff *frag2;
@@ -599,7 +600,7 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 			/* Correct geometry. */
 			if (frag->len > mtu ||
 			    ((frag->len & 7) && frag->next) ||
-			    skb_headroom(frag) < hlen)
+			    skb_headroom(frag) < (hlen + hroom))
 				goto slow_path_clean;
 
 			/* Partially cloned skb? */
@@ -724,7 +725,6 @@ slow_path:
 	 */
 
 	*prevhdr = NEXTHDR_FRAGMENT;
-	hroom = LL_RESERVED_SPACE(rt->dst.dev);
 	troom = rt->dst.dev->needed_tailroom;
 
 	/*
