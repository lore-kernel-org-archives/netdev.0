From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/4] gro: Avoid copying headers of unmerged packets
Date: Fri, 30 Jan 2009 11:19:50 +1100
Message-ID: <E1LSh6s-0000OD-5G@gondolin.me.apana.org.au>
References: <20090130001849.GA1272@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37714 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755682AbZA3ATx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:19:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---

 include/linux/netdevice.h |   26 +++++++++++++++++
 include/linux/skbuff.h    |    2 -
 net/8021q/vlan_core.c     |    2 +
 net/core/dev.c            |   70 ++++++++++++++++++++++++++++++++++++++--------
 net/core/skbuff.c         |   23 +++++++++------
 net/ipv4/af_inet.c        |   10 +++---
 net/ipv4/tcp.c            |   16 +++++-----
 net/ipv4/tcp_ipv4.c       |    2 -
 net/ipv6/af_inet6.c       |   30 +++++++++++++------
 net/ipv6/tcp_ipv6.c       |    2 -
 10 files changed, 137 insertions(+), 46 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c6b7a25..5472328 100644
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
index e9339d0..fb0d16a 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -98,6 +98,8 @@ drop:
 int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 		     unsigned int vlan_tci, struct sk_buff *skb)
 {
+	skb_gro_reset_offset(skb);
+
 	return napi_skb_finish(vlan_gro_common(napi, grp, vlan_tci, skb), skb);
 }
 EXPORT_SYMBOL(vlan_gro_receive);
diff --git a/net/core/dev.c b/net/core/dev.c
index 0b44280..3742397 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -215,6 +215,13 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
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
@@ -2358,7 +2365,6 @@ static int napi_gro_complete(struct sk_buff *skb)
 
 out:
 	skb_shinfo(skb)->gso_size = 0;
-	__skb_push(skb, -skb_network_offset(skb));
 	return netif_receive_skb(skb);
 }
 
@@ -2376,6 +2382,25 @@ void napi_gro_flush(struct napi_struct *napi)
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
@@ -2396,11 +2421,13 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
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
@@ -2414,8 +2441,7 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 				continue;
 
 			if (p->mac_len != mac_len ||
-			    memcmp(skb_mac_header(p), skb_mac_header(skb),
-				   mac_len))
+			    memcmp(skb_mac_header(p), mac, mac_len))
 				NAPI_GRO_CB(p)->same_flow = 0;
 		}
 
@@ -2442,13 +2468,11 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
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
 	ret = GRO_HELD;
@@ -2496,6 +2520,8 @@ EXPORT_SYMBOL(napi_skb_finish);
 
 int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
+	skb_gro_reset_offset(skb);
+
 	return napi_skb_finish(__napi_gro_receive(napi, skb), skb);
 }
 EXPORT_SYMBOL(napi_gro_receive);
@@ -2514,6 +2540,7 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 {
 	struct net_device *dev = napi->dev;
 	struct sk_buff *skb = napi->skb;
+	struct ethhdr *eth;
 
 	napi->skb = NULL;
 
@@ -2533,13 +2560,23 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 	skb->len += info->len;
 	skb->truesize += info->len;
 
-	if (!pskb_may_pull(skb, ETH_HLEN)) {
+	skb_reset_mac_header(skb);
+	skb_gro_reset_offset(skb);
+
+	eth = skb_gro_header(skb, sizeof(*eth));
+	if (!eth) {
 		napi_reuse_skb(napi, skb);
 		skb = NULL;
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
@@ -2552,10 +2589,21 @@ EXPORT_SYMBOL(napi_fraginfo_skb);
 int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb, int ret)
 {
 	int err = NET_RX_SUCCESS;
+	int may;
 
 	switch (ret) {
 	case GRO_NORMAL:
-		return netif_receive_skb(skb);
+	case GRO_HELD:
+		may = pskb_may_pull(skb, skb_gro_offset(skb));
+		BUG_ON(!may);
+
+		skb->protocol = eth_type_trans(skb, napi->dev);
+
+		if (ret == GRO_NORMAL)
+			return netif_receive_skb(skb);
+
+		skb_gro_pull(skb, -ETH_HLEN);
+		break;
 
 	case GRO_DROP:
 		err = NET_RX_DROP;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9127c47..6ecb8d7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2587,17 +2587,21 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	struct sk_buff *p = *head;
 	struct sk_buff *nskb;
 	unsigned int headroom;
-	unsigned int hlen = p->data - skb_mac_header(p);
-	unsigned int len = skb->len;
+	unsigned int len = skb_gro_len(skb);
 
-	if (hlen + p->len + len >= 65536)
+	if (p->len + len >= 65536)
 		return -E2BIG;
 
 	if (skb_shinfo(p)->frag_list)
 		goto merge;
-	else if (!skb_headlen(p) && !skb_headlen(skb) &&
-		 skb_shinfo(p)->nr_frags + skb_shinfo(skb)->nr_frags <
+	else if (skb_headlen(skb) <= skb_gro_offset(skb) &&
+		 skb_shinfo(p)->nr_frags + skb_shinfo(skb)->nr_frags <=
 		 MAX_SKB_FRAGS) {
+		skb_shinfo(skb)->frags[0].page_offset +=
+			skb_gro_offset(skb) - skb_headlen(skb);
+		skb_shinfo(skb)->frags[0].size -=
+			skb_gro_offset(skb) - skb_headlen(skb);
+
 		memcpy(skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags,
 		       skb_shinfo(skb)->frags,
 		       skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
@@ -2614,7 +2618,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	}
 
 	headroom = skb_headroom(p);
-	nskb = netdev_alloc_skb(p->dev, headroom);
+	nskb = netdev_alloc_skb(p->dev, headroom + skb_gro_offset(p));
 	if (unlikely(!nskb))
 		return -ENOMEM;
 
@@ -2622,12 +2626,15 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	nskb->mac_len = p->mac_len;
 
 	skb_reserve(nskb, headroom);
+	__skb_put(nskb, skb_gro_offset(p));
 
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
index c802bc1..bd91ead 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -799,24 +799,34 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	int proto;
 	__wsum csum;
 
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
-	iph = ipv6_hdr(skb);
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
