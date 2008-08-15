From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for	iptables nat routing
Date: Fri, 15 Aug 2008 20:53:18 +1000
Message-ID: <20080815105318.GA5590@gondor.apana.org.au>
References: <E1KTrAo-0001YG-00@gondolin.me.apana.org.au> <1218778238.23510.22.camel@2710p.home> <20080815073343.GA20644@gondor.apana.org.au> <20080815081442.GA20971@gondor.apana.org.au> <20080815103235.GA31963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50723 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751949AbYHOKxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 06:53:33 -0400
Content-Disposition: inline
In-Reply-To: <20080815103235.GA31963@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 08:32:35PM +1000, Herbert Xu wrote:
> 
> I'll work on the netfilter state preservation next.

Here it is:

net: Preserve netfilter attributes in skb_gso_segment using __copy_skb_header

skb_gso_segment didn't preserve some attributes in the original skb
such as the netfilter fields.  This was harmless until they were used
which is the case for packets going through lo.

This patch makes it call __copy_skb_header which also picks up some
other missing attributes.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8464017..ca1ccdf 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2256,14 +2256,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 			segs = nskb;
 		tail = nskb;
 
-		nskb->dev = skb->dev;
-		skb_copy_queue_mapping(nskb, skb);
-		nskb->priority = skb->priority;
-		nskb->protocol = skb->protocol;
-		nskb->vlan_tci = skb->vlan_tci;
-		nskb->dst = dst_clone(skb->dst);
-		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
-		nskb->pkt_type = skb->pkt_type;
+		__copy_skb_header(nskb, skb);
 		nskb->mac_len = skb->mac_len;
 
 		skb_reserve(nskb, headroom);
@@ -2274,6 +2267,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 		skb_copy_from_linear_data(skb, skb_put(nskb, doffset),
 					  doffset);
 		if (!sg) {
+			nskb->ip_summed = CHECKSUM_NONE;
 			nskb->csum = skb_copy_and_csum_bits(skb, offset,
 							    skb_put(nskb, len),
 							    len, 0);
@@ -2283,8 +2277,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 		frag = skb_shinfo(nskb)->frags;
 		k = 0;
 
-		nskb->ip_summed = CHECKSUM_PARTIAL;
-		nskb->csum = skb->csum;
 		skb_copy_from_linear_data_offset(skb, offset,
 						 skb_put(nskb, hsize), hsize);
 

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
