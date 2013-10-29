From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Mon, 28 Oct 2013 18:15:08 -0700
Message-ID: <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131028115552.GC4408@cpaasch-mac>
	 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40504 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756674Ab3J2BPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 21:15:11 -0400
Received: by mail-pb0-f46.google.com with SMTP id un4so1566157pbc.19
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 18:15:10 -0700 (PDT)
In-Reply-To: <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-28 at 06:21 -0700, Eric Dumazet wrote:

> But we also need to fix the skb_segment() bug anyway.

Hi Christoph

I cooked a minimal patch, could you please try it ?

I'll refactor skb_segment() to be smarter for the next release
(linux-3.14).

Thanks !

 net/core/skbuff.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0ab32faa520f..771946487a8d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2761,7 +2761,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	unsigned int len;
 	__be16 proto;
 	bool csum;
-	int sg = !!(features & NETIF_F_SG);
+	bool sg = !!(features & NETIF_F_SG);
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	int err = -ENOMEM;
 	int i = 0;
@@ -2793,7 +2793,11 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			hsize = len;
 
 		if (!hsize && i >= nfrags) {
-			BUG_ON(fskb->len != len);
+			if (fskb->len != len) {
+				hsize = len;
+				sg = false;
+				goto do_linear;
+			}
 
 			pos += len;
 			nskb = skb_clone(fskb, GFP_ATOMIC);
@@ -2812,6 +2816,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			skb_release_head_state(nskb);
 			__skb_push(nskb, doffset);
 		} else {
+do_linear:
 			nskb = __alloc_skb(hsize + doffset + headroom,
 					   GFP_ATOMIC, skb_alloc_rx_flag(skb),
 					   NUMA_NO_NODE);
@@ -2838,9 +2843,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 nskb->data - tnl_hlen,
 						 doffset + tnl_hlen);
 
-		if (fskb != skb_shinfo(skb)->frag_list)
-			goto perform_csum_check;
-
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
 			nskb->csum = skb_copy_and_csum_bits(skb, offset,
@@ -2849,6 +2851,9 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			continue;
 		}
 
+		if (fskb != skb_shinfo(skb)->frag_list)
+			goto perform_csum_check;
+
 		frag = skb_shinfo(nskb)->frags;
 
 		skb_copy_from_linear_data_offset(skb, offset,
