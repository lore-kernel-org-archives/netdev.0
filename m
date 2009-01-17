From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Sun, 18 Jan 2009 00:08:27 +1100
Message-ID: <20090117130827.GA17896@gondor.apana.org.au>
References: <20090115235803.GA9000@gondor.apana.org.au> <49704015.6020503@chelsio.com> <20090116085645.GA14678@gondor.apana.org.au> <49706B87.7080806@chelsio.com> <20090117050839.GA24215@gondor.apana.org.au> <4971BCDE.50600@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58393 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754475AbZAQNIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 08:08:37 -0500
Content-Disposition: inline
In-Reply-To: <4971BCDE.50600@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 17, 2009 at 03:11:26AM -0800, Divy Le Ray wrote:
>
> Yes.

Great.  Please give this patch a whirl.

commit a9156545da4f6ed729b1871a92e3ead04f37a034
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sat Jan 17 21:49:42 2009 +1100

    gro: Do not merge paged packets into frag_list
    
    Bigger is not always better :)
    
    It was easy to continue to merged packets into frag_list after the
    page array is full.  However, this turns out to be worse than LRO
    because frag_list is a much less efficient form of storage than the
    page array.  So we're better off stopping the merge and starting
    a new entry with an empty page array.
    
    In future we can optimise this further by doing frag_list merging
    but making sure that we continue to fill in the page array.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

commit 2e54c6210c41f7fb2c503a4b51a8288e05a1c9d5
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sat Jan 17 21:45:11 2009 +1100

    gro: Avoid copying headers of unmerged packets
    
    Unfortunately simplicity isn't always the best.  The fraginfo
    interface turned out to be suboptimal.  The problem was quite
    obvious.  For every packet, we have to copy the headers from
    the frags structure into skb->head, even though for 99% of the
    packets this part is immediately thrown away after the merge.
    
    LRO didn't have this problem because it directly read the headers
    from the frags structure.
    
    This patch attempts to address this by creating an interface
    that allows GRO to access the headers in the first frag without
    having to copy it.  Because all drivers that use frags place the
    headers in the first frag this optimisation should be enough.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

commit db14bd4bff3d85d779a83fbdc554f4147ee9b841
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sun Jan 18 00:00:13 2009 +1100

    gro: Fix merging of paged packets
    
    The previous fix to paged packets broke the merging because it
    reset the skb->len before we added it to the merged packet.  This
    wasn't detected because it simply resulted in the truncation of
    the packet while the missing bit is subsequently retransmitted.
    
    The fix is to store skb->len before we clobber it.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

commit 6ba4147cb5854d334965d89acb821e6f624534eb
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sat Jan 17 21:05:58 2009 +1100

    gro: Move common completion code into helpers
    
    Currently VLAN still has a bit of common code handling the aftermath
    of GRO that's shared with the common path.  This patch moves them
    into shared helpers to reduce code duplication.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

commit 86c3c2fc1f99394990b3ef1c2881b6036e4f5141
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sat Jan 17 15:06:40 2009 +1100

    gro: Fix error handling on extremely short frags
    
    When a frag is shorter than an Ethernet header, we'd return a
    zeroed packet instead of aborting.  This patch fixes that.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

commit 099f08d2279eff7f74226bc8f691b358b1eac7b7
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Sat Jan 17 20:12:07 2009 +1100

    gro: Fix handling of complete checksums in IPv6
    
    We need to perform skb_postpull_rcsum after pulling the IPv6
    header in order to maintain the correctness of the complete
    checksum.
    
    This patch also adds a missing iph reload after pulling.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f245568..5472328 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -983,6 +983,9 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 void netif_napi_del(struct napi_struct *napi);
 
 struct napi_gro_cb {
+	/* This indicates where we are processing relative to skb->data. */
+	int data_offset;
+
 	/* This is non-zero if the packet may be of the same flow. */
 	int same_flow;
 
@@ -1084,6 +1087,29 @@ extern int		dev_restart(struct net_device *dev);
 #ifdef CONFIG_NETPOLL_TRAP
 extern int		netpoll_trap(void);
 #endif
+extern void	      *skb_gro_header(struct sk_buff *skb, unsigned int hlen);
+extern int	       skb_gro_receive(struct sk_buff **head,
+				       struct sk_buff *skb);
+
+static inline unsigned int skb_gro_offset(const struct sk_buff *skb)
+{
+	return NAPI_GRO_CB(skb)->data_offset;
+}
+
+static inline unsigned int skb_gro_len(const struct sk_buff *skb)
+{
+	return skb->len - NAPI_GRO_CB(skb)->data_offset;
+}
+
+static inline void skb_gro_pull(struct sk_buff *skb, unsigned int len)
+{
+	NAPI_GRO_CB(skb)->data_offset += len;
+}
+
+static inline void skb_gro_reset_offset(struct sk_buff *skb)
+{
+	NAPI_GRO_CB(skb)->data_offset = 0;
+}
 
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
@@ -1372,12 +1398,15 @@ extern int		netif_receive_skb(struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi);
 extern int		dev_gro_receive(struct napi_struct *napi,
 					struct sk_buff *skb);
+extern int		napi_skb_finish(int ret, struct sk_buff *skb);
 extern int		napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
 extern void		napi_reuse_skb(struct napi_struct *napi,
 				       struct sk_buff *skb);
 extern struct sk_buff *	napi_fraginfo_skb(struct napi_struct *napi,
 					  struct napi_gro_fraginfo *info);
+extern int		napi_frags_finish(struct napi_struct *napi,
+					  struct sk_buff *skb, int ret);
 extern int		napi_gro_frags(struct napi_struct *napi,
 				       struct napi_gro_fraginfo *info);
 extern void		netif_nit_deliver(struct sk_buff *skb);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cf2cb50..acf17af 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1687,8 +1687,6 @@ extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
 				 int shiftlen);
 
 extern struct sk_buff *skb_segment(struct sk_buff *skb, int features);
-extern int	       skb_gro_receive(struct sk_buff **head,
-				       struct sk_buff *skb);
 
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 6c13239..fb0d16a 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -98,22 +98,9 @@ drop:
 int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 		     unsigned int vlan_tci, struct sk_buff *skb)
 {
-	int err = NET_RX_SUCCESS;
+	skb_gro_reset_offset(skb);
 
-	switch (vlan_gro_common(napi, grp, vlan_tci, skb)) {
-	case -1:
-		return netif_receive_skb(skb);
-
-	case 2:
-		err = NET_RX_DROP;
-		/* fall through */
-
-	case 1:
-		kfree_skb(skb);
-		break;
-	}
-
-	return err;
+	return napi_skb_finish(vlan_gro_common(napi, grp, vlan_tci, skb), skb);
 }
 EXPORT_SYMBOL(vlan_gro_receive);
 
@@ -121,27 +108,11 @@ int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 		   unsigned int vlan_tci, struct napi_gro_fraginfo *info)
 {
 	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
-	int err = NET_RX_DROP;
 
 	if (!skb)
-		goto out;
-
-	err = NET_RX_SUCCESS;
-
-	switch (vlan_gro_common(napi, grp, vlan_tci, skb)) {
-	case -1:
-		return netif_receive_skb(skb);
-
-	case 2:
-		err = NET_RX_DROP;
-		/* fall through */
-
-	case 1:
-		napi_reuse_skb(napi, skb);
-		break;
-	}
+		return NET_RX_DROP;
 
-out:
-	return err;
+	return napi_frags_finish(napi, skb,
+				 vlan_gro_common(napi, grp, vlan_tci, skb));
 }
 EXPORT_SYMBOL(vlan_gro_frags);
diff --git a/net/core/dev.c b/net/core/dev.c
index 4f69a2d..3742397 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,14 @@
 /* This should be increased if a protocol with a bigger head is added. */
 #define GRO_MAX_HEAD (MAX_HEADER + 128)
 
+enum {
+	GRO_MERGED,
+	GRO_MERGED_FREE,
+	GRO_HELD,
+	GRO_NORMAL,
+	GRO_DROP,
+};
+
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
@@ -207,6 +215,13 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 	return &net->dev_index_head[ifindex & ((1 << NETDEV_HASHBITS) - 1)];
 }
 
+static inline void *skb_gro_mac_header(struct sk_buff *skb)
+{
+	return skb_headlen(skb) ? skb_mac_header(skb) :
+	       page_address(skb_shinfo(skb)->frags[0].page) +
+	       skb_shinfo(skb)->frags[0].page_offset;
+}
+
 /* Device list insertion */
 static int list_netdevice(struct net_device *dev)
 {
@@ -2350,7 +2365,6 @@ static int napi_gro_complete(struct sk_buff *skb)
 
 out:
 	skb_shinfo(skb)->gso_size = 0;
-	__skb_push(skb, -skb_network_offset(skb));
 	return netif_receive_skb(skb);
 }
 
@@ -2368,6 +2382,25 @@ void napi_gro_flush(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_gro_flush);
 
+void *skb_gro_header(struct sk_buff *skb, unsigned int hlen)
+{
+	unsigned int offset = skb_gro_offset(skb);
+
+	hlen += offset;
+	if (hlen <= skb_headlen(skb))
+		return skb->data + offset;
+
+	if (unlikely(!skb_shinfo(skb)->nr_frags ||
+		     skb_shinfo(skb)->frags[0].size <=
+		     hlen - skb_headlen(skb) ||
+		     PageHighMem(skb_shinfo(skb)->frags[0].page)))
+		return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
+
+	return page_address(skb_shinfo(skb)->frags[0].page) +
+	       skb_shinfo(skb)->frags[0].page_offset + offset;
+}
+EXPORT_SYMBOL(skb_gro_header);
+
 int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
@@ -2377,7 +2410,7 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	int count = 0;
 	int same_flow;
 	int mac_len;
-	int free;
+	int ret;
 
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
@@ -2388,11 +2421,13 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
 		struct sk_buff *p;
+		void *mac;
 
 		if (ptype->type != type || ptype->dev || !ptype->gro_receive)
 			continue;
 
-		skb_reset_network_header(skb);
+		skb_set_network_header(skb, skb_gro_offset(skb));
+		mac = skb_gro_mac_header(skb);
 		mac_len = skb->network_header - skb->mac_header;
 		skb->mac_len = mac_len;
 		NAPI_GRO_CB(skb)->same_flow = 0;
@@ -2406,8 +2441,7 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 				continue;
 
 			if (p->mac_len != mac_len ||
-			    memcmp(skb_mac_header(p), skb_mac_header(skb),
-				   mac_len))
+			    memcmp(skb_mac_header(p), mac, mac_len))
 				NAPI_GRO_CB(p)->same_flow = 0;
 		}
 
@@ -2420,7 +2454,7 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		goto normal;
 
 	same_flow = NAPI_GRO_CB(skb)->same_flow;
-	free = NAPI_GRO_CB(skb)->free;
+	ret = NAPI_GRO_CB(skb)->free ? GRO_MERGED_FREE : GRO_MERGED;
 
 	if (pp) {
 		struct sk_buff *nskb = *pp;
@@ -2434,21 +2468,20 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	if (same_flow)
 		goto ok;
 
-	if (NAPI_GRO_CB(skb)->flush || count >= MAX_GRO_SKBS) {
-		__skb_push(skb, -skb_network_offset(skb));
+	if (NAPI_GRO_CB(skb)->flush || count >= MAX_GRO_SKBS)
 		goto normal;
-	}
 
 	NAPI_GRO_CB(skb)->count = 1;
-	skb_shinfo(skb)->gso_size = skb->len;
+	skb_shinfo(skb)->gso_size = skb_gro_len(skb);
 	skb->next = napi->gro_list;
 	napi->gro_list = skb;
+	ret = GRO_HELD;
 
 ok:
-	return free;
+	return ret;
 
 normal:
-	return -1;
+	return GRO_NORMAL;
 }
 EXPORT_SYMBOL(dev_gro_receive);
 
@@ -2464,18 +2497,32 @@ static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	return dev_gro_receive(napi, skb);
 }
 
-int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+int napi_skb_finish(int ret, struct sk_buff *skb)
 {
-	switch (__napi_gro_receive(napi, skb)) {
-	case -1:
+	int err = NET_RX_SUCCESS;
+
+	switch (ret) {
+	case GRO_NORMAL:
 		return netif_receive_skb(skb);
 
-	case 1:
+	case GRO_DROP:
+		err = NET_RX_DROP;
+		/* fall through */
+
+	case GRO_MERGED_FREE:
 		kfree_skb(skb);
 		break;
 	}
 
-	return NET_RX_SUCCESS;
+	return err;
+}
+EXPORT_SYMBOL(napi_skb_finish);
+
+int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+{
+	skb_gro_reset_offset(skb);
+
+	return napi_skb_finish(__napi_gro_receive(napi, skb), skb);
 }
 EXPORT_SYMBOL(napi_gro_receive);
 
@@ -2493,6 +2540,7 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 {
 	struct net_device *dev = napi->dev;
 	struct sk_buff *skb = napi->skb;
+	struct ethhdr *eth;
 
 	napi->skb = NULL;
 
@@ -2512,12 +2560,23 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 	skb->len += info->len;
 	skb->truesize += info->len;
 
-	if (!pskb_may_pull(skb, ETH_HLEN)) {
+	skb_reset_mac_header(skb);
+	skb_gro_reset_offset(skb);
+
+	eth = skb_gro_header(skb, sizeof(*eth));
+	if (!eth) {
 		napi_reuse_skb(napi, skb);
+		skb = NULL;
 		goto out;
 	}
 
-	skb->protocol = eth_type_trans(skb, dev);
+	skb_gro_pull(skb, sizeof(*eth));
+
+	/*
+	 * This works because the only protocols we care about don't require
+	 * special handling.  We'll fix it up properly at the end.
+	 */
+	skb->protocol = eth->h_proto;
 
 	skb->ip_summed = info->ip_summed;
 	skb->csum = info->csum;
@@ -2527,29 +2586,47 @@ out:
 }
 EXPORT_SYMBOL(napi_fraginfo_skb);
 
-int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
+int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb, int ret)
 {
-	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
-	int err = NET_RX_DROP;
+	int err = NET_RX_SUCCESS;
+	int may;
 
-	if (!skb)
-		goto out;
+	switch (ret) {
+	case GRO_NORMAL:
+	case GRO_HELD:
+		may = pskb_may_pull(skb, skb_gro_offset(skb));
+		BUG_ON(!may);
 
-	err = NET_RX_SUCCESS;
+		skb->protocol = eth_type_trans(skb, napi->dev);
 
-	switch (__napi_gro_receive(napi, skb)) {
-	case -1:
-		return netif_receive_skb(skb);
+		if (ret == GRO_NORMAL)
+			return netif_receive_skb(skb);
 
-	case 0:
-		goto out;
-	}
+		skb_gro_pull(skb, -ETH_HLEN);
+		break;
 
-	napi_reuse_skb(napi, skb);
+	case GRO_DROP:
+		err = NET_RX_DROP;
+		/* fall through */
+
+	case GRO_MERGED_FREE:
+		napi_reuse_skb(napi, skb);
+		break;
+	}
 
-out:
 	return err;
 }
+EXPORT_SYMBOL(napi_frags_finish);
+
+int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
+{
+	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
+
+	if (!skb)
+		return NET_RX_DROP;
+
+	return napi_frags_finish(napi, skb, __napi_gro_receive(napi, skb));
+}
 EXPORT_SYMBOL(napi_gro_frags);
 
 static int process_backlog(struct napi_struct *napi, int quota)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 65eac77..a11d9a4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2587,16 +2587,23 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	struct sk_buff *p = *head;
 	struct sk_buff *nskb;
 	unsigned int headroom;
-	unsigned int hlen = p->data - skb_mac_header(p);
+	unsigned int len = skb_gro_len(skb);
 
-	if (hlen + p->len + skb->len >= 65536)
+	if (p->len + len >= 65536)
 		return -E2BIG;
 
 	if (skb_shinfo(p)->frag_list)
 		goto merge;
-	else if (!skb_headlen(p) && !skb_headlen(skb) &&
-		 skb_shinfo(p)->nr_frags + skb_shinfo(skb)->nr_frags <
-		 MAX_SKB_FRAGS) {
+	else if (skb_headlen(skb) <= skb_gro_offset(skb)) {
+		if (skb_shinfo(p)->nr_frags + skb_shinfo(skb)->nr_frags >
+		    MAX_SKB_FRAGS)
+			return -E2BIG;
+
+		skb_shinfo(skb)->frags[0].page_offset +=
+			skb_gro_offset(skb) - skb_headlen(skb);
+		skb_shinfo(skb)->frags[0].size -=
+			skb_gro_offset(skb) - skb_headlen(skb);
+
 		memcpy(skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags,
 		       skb_shinfo(skb)->frags,
 		       skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
@@ -2621,12 +2628,15 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	nskb->mac_len = p->mac_len;
 
 	skb_reserve(nskb, headroom);
+	__skb_put(nskb, skb_headlen(p));
 
-	skb_set_mac_header(nskb, -hlen);
+	skb_set_mac_header(nskb, skb_mac_header(p) - p->data);
 	skb_set_network_header(nskb, skb_network_offset(p));
 	skb_set_transport_header(nskb, skb_transport_offset(p));
 
-	memcpy(skb_mac_header(nskb), skb_mac_header(p), hlen);
+	__skb_pull(p, skb_gro_offset(p));
+	memcpy(skb_mac_header(nskb), skb_mac_header(p),
+	       p->data - skb_mac_header(p));
 
 	*NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
 	skb_shinfo(nskb)->frag_list = p;
@@ -2651,9 +2661,9 @@ merge:
 
 done:
 	NAPI_GRO_CB(p)->count++;
-	p->data_len += skb->len;
-	p->truesize += skb->len;
-	p->len += skb->len;
+	p->data_len += len;
+	p->truesize += len;
+	p->len += len;
 
 	NAPI_GRO_CB(skb)->same_flow = 1;
 	return 0;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 743f554..d6770f2 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1253,10 +1253,10 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	int proto;
 	int id;
 
-	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
+	iph = skb_gro_header(skb, sizeof(*iph));
+	if (unlikely(!iph))
 		goto out;
 
-	iph = ip_hdr(skb);
 	proto = iph->protocol & (MAX_INET_PROTOS - 1);
 
 	rcu_read_lock();
@@ -1270,7 +1270,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
 		goto out_unlock;
 
-	flush = ntohs(iph->tot_len) != skb->len ||
+	flush = ntohs(iph->tot_len) != skb_gro_len(skb) ||
 		iph->frag_off != htons(IP_DF);
 	id = ntohs(iph->id);
 
@@ -1298,8 +1298,8 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	}
 
 	NAPI_GRO_CB(skb)->flush |= flush;
-	__skb_pull(skb, sizeof(*iph));
-	skb_reset_transport_header(skb);
+	skb_gro_pull(skb, sizeof(*iph));
+	skb_set_transport_header(skb, skb_gro_offset(skb));
 
 	pp = ops->gro_receive(head, skb);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ce572f9..0191d39 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2473,19 +2473,19 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	unsigned int mss = 1;
 	int flush = 1;
 
-	if (!pskb_may_pull(skb, sizeof(*th)))
+	th = skb_gro_header(skb, sizeof(*th));
+	if (unlikely(!th))
 		goto out;
 
-	th = tcp_hdr(skb);
 	thlen = th->doff * 4;
 	if (thlen < sizeof(*th))
 		goto out;
 
-	if (!pskb_may_pull(skb, thlen))
+	th = skb_gro_header(skb, thlen);
+	if (unlikely(!th))
 		goto out;
 
-	th = tcp_hdr(skb);
-	__skb_pull(skb, thlen);
+	skb_gro_pull(skb, thlen);
 
 	flags = tcp_flag_word(th);
 
@@ -2513,10 +2513,10 @@ found:
 	flush |= th->ack_seq != th2->ack_seq || th->window != th2->window;
 	flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
 
-	total = p->len;
+	total = skb_gro_len(p);
 	mss = skb_shinfo(p)->gso_size;
 
-	flush |= skb->len > mss || skb->len <= 0;
+	flush |= skb_gro_len(skb) > mss || !skb_gro_len(skb);
 	flush |= ntohl(th2->seq) + total != ntohl(th->seq);
 
 	if (flush || skb_gro_receive(head, skb)) {
@@ -2529,7 +2529,7 @@ found:
 	tcp_flag_word(th2) |= flags & (TCP_FLAG_FIN | TCP_FLAG_PSH);
 
 out_check_final:
-	flush = skb->len < mss;
+	flush = skb_gro_len(skb) < mss;
 	flush |= flags & (TCP_FLAG_URG | TCP_FLAG_PSH | TCP_FLAG_RST |
 			  TCP_FLAG_SYN | TCP_FLAG_FIN);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 19d7b42..f6b962f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2355,7 +2355,7 @@ struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
-		if (!tcp_v4_check(skb->len, iph->saddr, iph->daddr,
+		if (!tcp_v4_check(skb_gro_len(skb), iph->saddr, iph->daddr,
 				  skb->csum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			break;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 94f74f5..bd91ead 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -797,24 +797,36 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	unsigned int nlen;
 	int flush = 1;
 	int proto;
+	__wsum csum;
 
-	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
+	iph = skb_gro_header(skb, sizeof(*iph));
+	if (unlikely(!iph))
 		goto out;
 
-	iph = ipv6_hdr(skb);
-	__skb_pull(skb, sizeof(*iph));
+	skb_gro_pull(skb, sizeof(*iph));
+	skb_set_transport_header(skb, skb_gro_offset(skb));
 
-	flush += ntohs(iph->payload_len) != skb->len;
+	flush += ntohs(iph->payload_len) != skb_gro_len(skb);
 
 	rcu_read_lock();
-	proto = ipv6_gso_pull_exthdrs(skb, iph->nexthdr);
-	IPV6_GRO_CB(skb)->proto = proto;
+	proto = iph->nexthdr;
 	ops = rcu_dereference(inet6_protos[proto]);
-	if (!ops || !ops->gro_receive)
-		goto out_unlock;
+	if (!ops || !ops->gro_receive) {
+		__pskb_pull(skb, skb_gro_offset(skb));
+		proto = ipv6_gso_pull_exthdrs(skb, proto);
+		skb_gro_pull(skb, -skb_transport_offset(skb));
+		skb_reset_transport_header(skb);
+		__skb_push(skb, skb_gro_offset(skb));
+
+		if (!ops || !ops->gro_receive)
+			goto out_unlock;
+
+		iph = ipv6_hdr(skb);
+	}
+
+	IPV6_GRO_CB(skb)->proto = proto;
 
 	flush--;
-	skb_reset_transport_header(skb);
 	nlen = skb_network_header_len(skb);
 
 	for (p = *head; p; p = p->next) {
@@ -839,8 +851,13 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 
 	NAPI_GRO_CB(skb)->flush |= flush;
 
+	csum = skb->csum;
+	skb_postpull_rcsum(skb, iph, skb_network_header_len(skb));
+
 	pp = ops->gro_receive(head, skb);
 
+	skb->csum = csum;
+
 out_unlock:
 	rcu_read_unlock();
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e5b85d4..00f1269 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -948,7 +948,7 @@ struct sk_buff **tcp6_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
-		if (!tcp_v6_check(skb->len, &iph->saddr, &iph->daddr,
+		if (!tcp_v6_check(skb_gro_len(skb), &iph->saddr, &iph->daddr,
 				  skb->csum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			break;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
