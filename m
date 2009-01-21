From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Wed, 21 Jan 2009 19:29:37 +1100
Message-ID: <20090121082937.GA1116@gondor.apana.org.au>
References: <20090120101418.13898.57172.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34142 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757576AbZAUI3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 03:29:43 -0500
Content-Disposition: inline
In-Reply-To: <20090120101418.13898.57172.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2009 at 02:14:19AM -0800, Divy Le Ray wrote:
> 
> Here is the patch:

Thanks, I'll add it to my series and push it later.

> Here is the non detailed opreport output for the CPU managing the reception
> of netperf traffic:

This is very helpful! Now some of the extra cost of GRO is due
to extra checks which are unavoidable.  However, there is a lot
of microoptimisations that we can perform to minimise the cost
and also reduce the cost of some existing checks.

Please try the following patch (compile tested only since I'm
at LCA) and let me know if it improves things.

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 1cb0f0b..a1f17ab 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -184,4 +184,25 @@ static inline unsigned compare_ether_addr_64bits(const u8 addr1[6+2],
 }
 #endif	/* __KERNEL__ */
 
+/**
+ * compare_ether_header - Compare two Ethernet headers
+ * @a: Pointer to Ethernet header
+ * @b: Pointer to Ethernet header
+ *
+ * Compare two ethernet headers, returns 0 if equal.
+ * This assumes that the network header (i.e., IP header) is 4-byte
+ * aligned OR the platform can handle unaligned access.  This is the
+ * case for all packets coming into netif_receive_skb or similar
+ * entry points.
+ */
+
+static inline int compare_ether_header(const void *a, const void *b)
+{
+	u32 *a32 = (u32 *)((u8 *)a + 2);
+	u32 *b32 = (u32 *)((u8 *)b + 2);
+
+	return (*(u16 *)a ^ *(u16 *)b) | (a32[0] ^ b32[0]) |
+	       (a32[1] ^ b32[1]) | (a32[2] ^ b32[2]);
+}
+
 #endif	/* _LINUX_ETHERDEVICE_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5472328..89e5753 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -314,6 +314,9 @@ struct napi_struct {
 	spinlock_t		poll_lock;
 	int			poll_owner;
 #endif
+
+	unsigned int		gro_count;
+
 	struct net_device	*dev;
 	struct list_head	dev_list;
 	struct sk_buff		*gro_list;
@@ -1111,6 +1114,13 @@ static inline void skb_gro_reset_offset(struct sk_buff *skb)
 	NAPI_GRO_CB(skb)->data_offset = 0;
 }
 
+static inline void *skb_gro_mac_header(struct sk_buff *skb)
+{
+	return skb_headlen(skb) ? skb_mac_header(skb) :
+	       page_address(skb_shinfo(skb)->frags[0].page) +
+	       skb_shinfo(skb)->frags[0].page_offset;
+}
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index fb0d16a..63f103b 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -85,7 +85,9 @@ static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 		goto drop;
 
 	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow = p->dev == skb->dev;
+		NAPI_GRO_CB(p)->same_flow =
+			p->dev == skb->dev && !compare_ether_header(
+				skb_mac_header(p), skb_gro_mac_header(skb));
 		NAPI_GRO_CB(p)->flush = 0;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index d55f725..fd5998a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -215,13 +215,6 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 	return &net->dev_index_head[ifindex & ((1 << NETDEV_HASHBITS) - 1)];
 }
 
-static inline void *skb_gro_mac_header(struct sk_buff *skb)
-{
-	return skb_headlen(skb) ? skb_mac_header(skb) :
-	       page_address(skb_shinfo(skb)->frags[0].page) +
-	       skb_shinfo(skb)->frags[0].page_offset;
-}
-
 /* Device list insertion */
 static int list_netdevice(struct net_device *dev)
 {
@@ -2378,6 +2371,7 @@ void napi_gro_flush(struct napi_struct *napi)
 		napi_gro_complete(skb);
 	}
 
+	napi->gro_count = 0;
 	napi->gro_list = NULL;
 }
 EXPORT_SYMBOL(napi_gro_flush);
@@ -2407,7 +2401,6 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	struct packet_type *ptype;
 	__be16 type = skb->protocol;
 	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
-	int count = 0;
 	int same_flow;
 	int mac_len;
 	int ret;
@@ -2421,30 +2414,17 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
 		struct sk_buff *p;
-		void *mac;
 
 		if (ptype->type != type || ptype->dev || !ptype->gro_receive)
 			continue;
 
 		skb_set_network_header(skb, skb_gro_offset(skb));
-		mac = skb_gro_mac_header(skb);
 		mac_len = skb->network_header - skb->mac_header;
 		skb->mac_len = mac_len;
 		NAPI_GRO_CB(skb)->same_flow = 0;
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
 
-		for (p = napi->gro_list; p; p = p->next) {
-			count++;
-
-			if (!NAPI_GRO_CB(p)->same_flow)
-				continue;
-
-			if (p->mac_len != mac_len ||
-			    memcmp(skb_mac_header(p), mac, mac_len))
-				NAPI_GRO_CB(p)->same_flow = 0;
-		}
-
 		pp = ptype->gro_receive(&napi->gro_list, skb);
 		break;
 	}
@@ -2462,15 +2442,16 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		*pp = nskb->next;
 		nskb->next = NULL;
 		napi_gro_complete(nskb);
-		count--;
+		napi->gro_count--;
 	}
 
 	if (same_flow)
 		goto ok;
 
-	if (NAPI_GRO_CB(skb)->flush || count >= MAX_GRO_SKBS)
+	if (NAPI_GRO_CB(skb)->flush || napi->gro_count >= MAX_GRO_SKBS)
 		goto normal;
 
+	napi->gro_count++;
 	NAPI_GRO_CB(skb)->count = 1;
 	skb_shinfo(skb)->gso_size = skb_gro_len(skb);
 	skb->next = napi->gro_list;
@@ -2490,7 +2471,8 @@ static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	struct sk_buff *p;
 
 	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow = 1;
+		NAPI_GRO_CB(p)->same_flow = !compare_ether_header(
+			skb_mac_header(p), skb_gro_mac_header(skb));
 		NAPI_GRO_CB(p)->flush = 0;
 	}
 
@@ -2714,6 +2696,7 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 		    int (*poll)(struct napi_struct *, int), int weight)
 {
 	INIT_LIST_HEAD(&napi->poll_list);
+	napi->gro_count = 0;
 	napi->gro_list = NULL;
 	napi->skb = NULL;
 	napi->poll = poll;
@@ -2742,6 +2725,7 @@ void netif_napi_del(struct napi_struct *napi)
 	}
 
 	napi->gro_list = NULL;
+	napi->gro_count = 0;
 }
 EXPORT_SYMBOL(netif_napi_del);
 
@@ -5208,6 +5192,7 @@ static int __init net_dev_init(void)
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
 		queue->backlog.gro_list = NULL;
+		queue->backlog.gro_count = 0;
 	}
 
 	dev_boot_phase = 0;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d6770f2..f011ce6 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1264,7 +1264,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	if (!ops || !ops->gro_receive)
 		goto out_unlock;
 
-	if (iph->version != 4 || iph->ihl != 5)
+	if (*(u8 *)iph != 0x45)
 		goto out_unlock;
 
 	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
@@ -1282,17 +1282,18 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 
 		iph2 = ip_hdr(p);
 
-		if (iph->protocol != iph2->protocol ||
-		    iph->tos != iph2->tos ||
-		    memcmp(&iph->saddr, &iph2->saddr, 8)) {
+		if ((iph->protocol ^ iph2->protocol) |
+		    (iph->tos ^ iph2->tos) |
+		    (iph->saddr ^ iph2->saddr) |
+		    (iph->daddr ^ iph2->daddr)) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
 
 		/* All fields must match except length and checksum. */
 		NAPI_GRO_CB(p)->flush |=
-			memcmp(&iph->frag_off, &iph2->frag_off, 4) ||
-			(u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) != id;
+			(iph->ttl ^ iph2->ttl) |
+			((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
 
 		NAPI_GRO_CB(p)->flush |= flush;
 	}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0191d39..a1d1f3b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2469,9 +2469,9 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	struct tcphdr *th2;
 	unsigned int thlen;
 	unsigned int flags;
-	unsigned int total;
 	unsigned int mss = 1;
 	int flush = 1;
+	int i;
 
 	th = skb_gro_header(skb, sizeof(*th));
 	if (unlikely(!th))
@@ -2495,7 +2495,7 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 		th2 = tcp_hdr(p);
 
-		if (th->source != th2->source || th->dest != th2->dest) {
+		if ((th->source ^ th2->source) | (th->dest ^ th2->dest)) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
@@ -2510,14 +2510,15 @@ found:
 	flush |= flags & TCP_FLAG_CWR;
 	flush |= (flags ^ tcp_flag_word(th2)) &
 		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
-	flush |= th->ack_seq != th2->ack_seq || th->window != th2->window;
-	flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
+	flush |= (th->ack_seq ^ th2->ack_seq) | (th->window ^ th2->window);
+	for (i = sizeof(*th); !flush && i < thlen; i += 4)
+		flush |= *(u32 *)((u8 *)th + i) ^
+			 *(u32 *)((u8 *)th2 + i);
 
-	total = skb_gro_len(p);
 	mss = skb_shinfo(p)->gso_size;
 
-	flush |= skb_gro_len(skb) > mss || !skb_gro_len(skb);
-	flush |= ntohl(th2->seq) + total != ntohl(th->seq);
+	flush |= (skb_gro_len(skb) > mss) | !skb_gro_len(skb);
+	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
 
 	if (flush || skb_gro_receive(head, skb)) {
 		mss = 1;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
