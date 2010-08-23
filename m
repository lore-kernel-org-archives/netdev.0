From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Rename skb_has_frags to skb_has_frag_list
Date: Mon, 23 Aug 2010 00:14:38 -0700 (PDT)
Message-ID: <20100823.001438.45887108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752105Ab0HWHOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 03:14:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3734924C089
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 00:14:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


SKBs can be "fragmented" in two ways, via a page array (called
skb_shinfo(skb)->frags[]) and via a list of SKBs (called
skb_shinfo(skb)->frag_list).

Since skb_has_frags() tests the latter, it's name is confusing
since it sounds more like it's testing the former.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

I was reading over the GRO code and found this helper function's
name confusing as hell.  Committed to net-next-2.6

 include/linux/netdevice.h               |    2 +-
 include/linux/skbuff.h                  |    4 ++--
 net/core/dev.c                          |    4 ++--
 net/core/skbuff.c                       |   18 +++++++++---------
 net/ipv4/ip_fragment.c                  |    2 +-
 net/ipv4/ip_output.c                    |    2 +-
 net/ipv6/ip6_output.c                   |    2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 +-
 net/ipv6/reassembly.c                   |    2 +-
 9 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 46c36ff..ce2de8b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2191,7 +2191,7 @@ static inline int net_gso_ok(int features, int gso_type)
 static inline int skb_gso_ok(struct sk_buff *skb, int features)
 {
 	return net_gso_ok(features, skb_shinfo(skb)->gso_type) &&
-	       (!skb_has_frags(skb) || (features & NETIF_F_FRAGLIST));
+	       (!skb_has_frag_list(skb) || (features & NETIF_F_FRAGLIST));
 }
 
 static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f067c95..f900ffc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1120,7 +1120,7 @@ extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
 			    int off, int size);
 
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
-#define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_has_frags(skb))
+#define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_has_frag_list(skb))
 #define SKB_LINEAR_ASSERT(skb)  BUG_ON(skb_is_nonlinear(skb))
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
@@ -1784,7 +1784,7 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
 		     skb = skb->prev)
 
 
-static inline bool skb_has_frags(const struct sk_buff *skb)
+static inline bool skb_has_frag_list(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->frag_list != NULL;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index d569f88..859e30f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1930,7 +1930,7 @@ static inline int skb_needs_linearize(struct sk_buff *skb,
 				      struct net_device *dev)
 {
 	return skb_is_nonlinear(skb) &&
-	       ((skb_has_frags(skb) && !(dev->features & NETIF_F_FRAGLIST)) ||
+	       ((skb_has_frag_list(skb) && !(dev->features & NETIF_F_FRAGLIST)) ||
 	        (skb_shinfo(skb)->nr_frags && (!(dev->features & NETIF_F_SG) ||
 					      illegal_highdma(dev, skb))));
 }
@@ -3090,7 +3090,7 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	if (!(skb->dev->features & NETIF_F_GRO) || netpoll_rx_on(skb))
 		goto normal;
 
-	if (skb_is_gso(skb) || skb_has_frags(skb))
+	if (skb_is_gso(skb) || skb_has_frag_list(skb))
 		goto normal;
 
 	rcu_read_lock();
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 99ef721..e2535fb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -340,7 +340,7 @@ static void skb_release_data(struct sk_buff *skb)
 				put_page(skb_shinfo(skb)->frags[i].page);
 		}
 
-		if (skb_has_frags(skb))
+		if (skb_has_frag_list(skb))
 			skb_drop_fraglist(skb);
 
 		kfree(skb->head);
@@ -759,7 +759,7 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 		skb_shinfo(n)->nr_frags = i;
 	}
 
-	if (skb_has_frags(skb)) {
+	if (skb_has_frag_list(skb)) {
 		skb_shinfo(n)->frag_list = skb_shinfo(skb)->frag_list;
 		skb_clone_fraglist(n);
 	}
@@ -822,7 +822,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 		get_page(skb_shinfo(skb)->frags[i].page);
 
-	if (skb_has_frags(skb))
+	if (skb_has_frag_list(skb))
 		skb_clone_fraglist(skb);
 
 	skb_release_data(skb);
@@ -1099,7 +1099,7 @@ drop_pages:
 		for (; i < nfrags; i++)
 			put_page(skb_shinfo(skb)->frags[i].page);
 
-		if (skb_has_frags(skb))
+		if (skb_has_frag_list(skb))
 			skb_drop_fraglist(skb);
 		goto done;
 	}
@@ -1194,7 +1194,7 @@ unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
 	/* Optimization: no fragments, no reasons to preestimate
 	 * size of pulled pages. Superb.
 	 */
-	if (!skb_has_frags(skb))
+	if (!skb_has_frag_list(skb))
 		goto pull_pages;
 
 	/* Estimate size of pulled pages. */
@@ -2323,7 +2323,7 @@ next_skb:
 		st->frag_data = NULL;
 	}
 
-	if (st->root_skb == st->cur_skb && skb_has_frags(st->root_skb)) {
+	if (st->root_skb == st->cur_skb && skb_has_frag_list(st->root_skb)) {
 		st->cur_skb = skb_shinfo(st->root_skb)->frag_list;
 		st->frag_idx = 0;
 		goto next_skb;
@@ -2889,7 +2889,7 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 		return -ENOMEM;
 
 	/* Easy case. Most of packets will go this way. */
-	if (!skb_has_frags(skb)) {
+	if (!skb_has_frag_list(skb)) {
 		/* A little of trouble, not enough of space for trailer.
 		 * This should not happen, when stack is tuned to generate
 		 * good frames. OK, on miss we reallocate and reserve even more
@@ -2924,7 +2924,7 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 
 		if (skb1->next == NULL && tailbits) {
 			if (skb_shinfo(skb1)->nr_frags ||
-			    skb_has_frags(skb1) ||
+			    skb_has_frag_list(skb1) ||
 			    skb_tailroom(skb1) < tailbits)
 				ntail = tailbits + 128;
 		}
@@ -2933,7 +2933,7 @@ int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer)
 		    skb_cloned(skb1) ||
 		    ntail ||
 		    skb_shinfo(skb1)->nr_frags ||
-		    skb_has_frags(skb1)) {
+		    skb_has_frag_list(skb1)) {
 			struct sk_buff *skb2;
 
 			/* Fuck, we are miserable poor guys... */
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b7c4165..f4dc879 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -542,7 +542,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	/* If the first fragment is fragmented itself, we split
 	 * it to two chunks: the first with data and paged part
 	 * and the second, holding only fragments. */
-	if (skb_has_frags(head)) {
+	if (skb_has_frag_list(head)) {
 		struct sk_buff *clone;
 		int i, plen = 0;
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e807492..6d2753c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -487,7 +487,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	 * LATER: this step can be merged to real generation of fragments,
 	 * we can switch to copy when see the first bad fragment.
 	 */
-	if (skb_has_frags(skb)) {
+	if (skb_has_frag_list(skb)) {
 		struct sk_buff *frag;
 		int first_len = skb_pagelen(skb);
 		int truesizes = 0;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d40b330..1838927 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -637,7 +637,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	}
 	mtu -= hlen + sizeof(struct frag_hdr);
 
-	if (skb_has_frags(skb)) {
+	if (skb_has_frag_list(skb)) {
 		int first_len = skb_pagelen(skb);
 		int truesizes = 0;
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 13ef5bc..089c598 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -413,7 +413,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	/* If the first fragment is fragmented itself, we split
 	 * it to two chunks: the first with data and paged part
 	 * and the second, holding only fragments. */
-	if (skb_has_frags(head)) {
+	if (skb_has_frag_list(head)) {
 		struct sk_buff *clone;
 		int i, plen = 0;
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 545c414..8aea3f3 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -499,7 +499,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	/* If the first fragment is fragmented itself, we split
 	 * it to two chunks: the first with data and paged part
 	 * and the second, holding only fragments. */
-	if (skb_has_frags(head)) {
+	if (skb_has_frag_list(head)) {
 		struct sk_buff *clone;
 		int i, plen = 0;
 
-- 
1.7.2.2

