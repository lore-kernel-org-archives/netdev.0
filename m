From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] gso: handle new frag_list of frags GRO packets
Date: Thu, 21 Nov 2013 11:10:04 -0800
Message-ID: <1385061004.10637.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385043004.10637.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131121.131741.737292941735802990.davem@davemloft.net>
	 <1385058216.10637.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131121.133824.1318844228024646798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux@eikelenboom.it,
	edumazet@google.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:56704 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab3KUTKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 14:10:07 -0500
Received: by mail-yh0-f47.google.com with SMTP id 29so3724326yhl.34
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 11:10:07 -0800 (PST)
In-Reply-To: <20131121.133824.1318844228024646798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

Recently GRO started generating packets with frag_lists of frags.
This was not handled by GSO, thus leading to a crash.

Thankfully these packets are of a regular form and are easy to
handle.  This patch handles them in two ways.  For completely
non-linear frag_list entries, we simply continue to iterate over
the frag_list frags once we exhaust the normal frags.  For frag_list
entries with linear parts, we call pskb_trim on the first part
of the frag_list skb, and then process the rest of the frags in
the usual way.

This patch also kills a chunk of dead frag_list code that has
obviously never ever been run since it ends up generating a bogus
GSO-segmented packet with a frag_list entry.

Future work is planned to split super big packets into TSO
ones.

Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Reported-by: Jerry Chu <hkchu@google.com>
Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Sander Eikelenboom <linux@eikelenboom.it>
Tested-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   75 +++++++++++++++++++++++++++++---------------
 1 file changed, 50 insertions(+), 25 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8cec1e6b844d..2718fed53d8c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2796,6 +2796,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	struct sk_buff *segs = NULL;
 	struct sk_buff *tail = NULL;
 	struct sk_buff *fskb = skb_shinfo(skb)->frag_list;
+	skb_frag_t *skb_frag = skb_shinfo(skb)->frags;
 	unsigned int mss = skb_shinfo(skb)->gso_size;
 	unsigned int doffset = skb->data - skb_mac_header(skb);
 	unsigned int offset = doffset;
@@ -2835,16 +2836,38 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		if (hsize > len || !sg)
 			hsize = len;
 
-		if (!hsize && i >= nfrags) {
-			BUG_ON(fskb->len != len);
+		if (!hsize && i >= nfrags && skb_headlen(fskb) &&
+		    (skb_headlen(fskb) == len || sg)) {
+			BUG_ON(skb_headlen(fskb) > len);
+
+			i = 0;
+			nfrags = skb_shinfo(fskb)->nr_frags;
+			skb_frag = skb_shinfo(fskb)->frags;
+			pos += skb_headlen(fskb);
+
+			while (pos < offset + len) {
+				BUG_ON(i >= nfrags);
+
+				size = skb_frag_size(skb_frag);
+				if (pos + size > offset + len)
+					break;
+
+				i++;
+				pos += size;
+				skb_frag++;
+			}
 
-			pos += len;
 			nskb = skb_clone(fskb, GFP_ATOMIC);
 			fskb = fskb->next;
 
 			if (unlikely(!nskb))
 				goto err;
 
+			if (unlikely(pskb_trim(nskb, len))) {
+				kfree_skb(nskb);
+				goto err;
+			}
+
 			hsize = skb_end_offset(nskb);
 			if (skb_cow_head(nskb, doffset + headroom)) {
 				kfree_skb(nskb);
@@ -2881,7 +2904,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 nskb->data - tnl_hlen,
 						 doffset + tnl_hlen);
 
-		if (fskb != skb_shinfo(skb)->frag_list)
+		if (nskb->len == len + doffset)
 			goto perform_csum_check;
 
 		if (!sg) {
@@ -2899,8 +2922,28 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 		skb_shinfo(nskb)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
 
-		while (pos < offset + len && i < nfrags) {
-			*frag = skb_shinfo(skb)->frags[i];
+		while (pos < offset + len) {
+			if (i >= nfrags) {
+				BUG_ON(skb_headlen(fskb));
+
+				i = 0;
+				nfrags = skb_shinfo(fskb)->nr_frags;
+				skb_frag = skb_shinfo(fskb)->frags;
+
+				BUG_ON(!nfrags);
+
+				fskb = fskb->next;
+			}
+
+			if (unlikely(skb_shinfo(nskb)->nr_frags >=
+				     MAX_SKB_FRAGS)) {
+				net_warn_ratelimited(
+					"skb_segment: too many frags: %u %u\n",
+					pos, mss);
+				goto err;
+			}
+
+			*frag = *skb_frag;
 			__skb_frag_ref(frag);
 			size = skb_frag_size(frag);
 
@@ -2913,6 +2956,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 			if (pos + size <= offset + len) {
 				i++;
+				skb_frag++;
 				pos += size;
 			} else {
 				skb_frag_size_sub(frag, pos + size - (offset + len));
@@ -2922,25 +2966,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 			frag++;
 		}
 
-		if (pos < offset + len) {
-			struct sk_buff *fskb2 = fskb;
-
-			BUG_ON(pos + fskb->len != offset + len);
-
-			pos += fskb->len;
-			fskb = fskb->next;
-
-			if (fskb2->next) {
-				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
-				if (!fskb2)
-					goto err;
-			} else
-				skb_get(fskb2);
-
-			SKB_FRAG_ASSERT(nskb);
-			skb_shinfo(nskb)->frag_list = fskb2;
-		}
-
 skip_fraglist:
 		nskb->data_len = len - hsize;
 		nskb->len += nskb->data_len;
