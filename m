From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] [IPV6]: Avoid skb_copy/pskb_copy/skb_realloc_headroom on input
Date: Sun, 14 Oct 2007 22:49:04 +0800
Message-ID: <E1Ih4m8-0003rz-00@gondolin.me.apana.org.au>
References: <20071014144649.GA14792@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Tho
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1785 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754779AbXJNOtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 10:49:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Avoid skb_copy/pskb_copy/skb_realloc_headroom on input

This patch replaces unnecessary uses of skb_copy by pskb_expand_head
on the IPv6 input path.

This allows us to remove the double pointers later.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/exthdrs.c |   23 +++++------------------
 1 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index c82d4d4..0ff2bf1 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -234,22 +234,13 @@ static int ipv6_dest_hao(struct sk_buff **skbp, int optoff)
 		goto discard;
 
 	if (skb_cloned(skb)) {
-		struct sk_buff *skb2 = skb_copy(skb, GFP_ATOMIC);
-		struct inet6_skb_parm *opt2;
-
-		if (skb2 == NULL)
+		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 			goto discard;
 
-		opt2 = IP6CB(skb2);
-		memcpy(opt2, opt, sizeof(*opt2));
-
-		kfree_skb(skb);
-
 		/* update all variable using below by copied skbuff */
-		*skbp = skb = skb2;
-		hao = (struct ipv6_destopt_hao *)(skb_network_header(skb2) +
+		hao = (struct ipv6_destopt_hao *)(skb_network_header(skb) +
 						  optoff);
-		ipv6h = ipv6_hdr(skb2);
+		ipv6h = ipv6_hdr(skb);
 	}
 
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
@@ -464,18 +455,14 @@ looped_back:
 	   Do not damage packets queued somewhere.
 	 */
 	if (skb_cloned(skb)) {
-		struct sk_buff *skb2 = skb_copy(skb, GFP_ATOMIC);
 		/* the copy is a forwarded packet */
-		if (skb2 == NULL) {
+		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
 			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_OUTDISCARDS);
 			kfree_skb(skb);
 			return -1;
 		}
-		kfree_skb(skb);
-		*skbp = skb = skb2;
-		opt = IP6CB(skb2);
-		hdr = (struct ipv6_rt_hdr *)skb_transport_header(skb2);
+		hdr = (struct ipv6_rt_hdr *)skb_transport_header(skb);
 	}
 
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
