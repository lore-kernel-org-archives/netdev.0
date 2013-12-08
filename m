From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH net-next] net-gro: Prepare GRO stack for the upcoming tunneling support
Date: Sun,  8 Dec 2013 08:04:42 -0800
Message-ID: <1386518682-30488-1-git-send-email-hkchu@google.com>
Cc: Jerry Chu <hkchu@google.com>
To: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:52441 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850Ab3LHQFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 11:05:07 -0500
Received: by mail-qc0-f202.google.com with SMTP id i17so298760qcy.3
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 08:05:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

This patch modifies the GRO stack to remove the assumption that
only one IP hdr is present in the encapsulation chain. It avoids
the use of ip_hdr()/ipv6_hdr() macro in IP's *_gro_receive()/
*_gro_complete() functions because there may be more than one IP
hdr present in the encapsulation chain when various flavors of IP
tunneling support are added. By doing so it also allows multiple
level, not just a single level (i.e., with only two IP hdrs like
IP-in-IP) of encapsulation to be supported in the future.

With this patch, the GRO stack traversing now is mostly based on
skb_gro_offset rather than special hdr offsets saved in skb (e.g.,
skb->network_header, skb->transport_header,...) As a consequence
all but the top layer (which is likely to be the transport layer)
must have hdrs of the same length in order for a pkt to be
considered for aggregation. Therefore when adding a new layer
(e.g., for tunneling), one must check and skip flows (e.g., setting
NAPI_GRO_CB(p)->same_flow to 0) that have a different hdr length.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
Reviewed-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |  2 +-
 include/net/tcp.h         |  1 +
 net/core/dev.c            | 76 ++++++++++++++++-------------------------------
 net/core/skbuff.c         |  1 -
 net/ipv4/af_inet.c        | 26 +++++++++++-----
 net/ipv4/tcp_offload.c    | 27 ++++++++++-------
 net/ipv6/ip6_offload.c    | 67 ++++++++++++++++++++++++++++++-----------
 net/ipv6/tcpv6_offload.c  | 10 +++----
 8 files changed, 117 insertions(+), 93 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9d55e51..ba321f1b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1673,7 +1673,7 @@ struct offload_callbacks {
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
-	int			(*gro_complete)(struct sk_buff *skb);
+	int			(*gro_complete)(struct sk_buff *skb, int nhoff);
 };
 
 struct packet_offload {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f7e1ab2..bcd73ff 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1549,6 +1549,7 @@ void tcp_v4_destroy_sock(struct sock *sk);
 struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 				netdev_features_t features);
 struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb);
+int __tcp_gro_complete(struct sk_buff *skb, struct tcphdr *th);
 int tcp_gro_complete(struct sk_buff *skb);
 
 void __tcp_v4_send_check(struct sk_buff *skb, __be32 saddr, __be32 daddr);
diff --git a/net/core/dev.c b/net/core/dev.c
index 6cc98dd..bd71bec 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3767,7 +3767,7 @@ static int napi_gro_complete(struct sk_buff *skb)
 		if (ptype->type != type || !ptype->callbacks.gro_complete)
 			continue;
 
-		err = ptype->callbacks.gro_complete(skb);
+		err = ptype->callbacks.gro_complete(skb, 0);
 		break;
 	}
 	rcu_read_unlock();
@@ -3833,6 +3833,23 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
 	}
 }
 
+static void skb_gro_reset_offset(struct sk_buff *skb)
+{
+	const struct skb_shared_info *pinfo = skb_shinfo(skb);
+	const skb_frag_t *frag0 = &pinfo->frags[0];
+
+	NAPI_GRO_CB(skb)->data_offset = 0;
+	NAPI_GRO_CB(skb)->frag0 = NULL;
+	NAPI_GRO_CB(skb)->frag0_len = 0;
+
+	if (skb_mac_header(skb) == skb_tail_pointer(skb) &&
+	    pinfo->nr_frags &&
+	    !PageHighMem(skb_frag_page(frag0))) {
+		NAPI_GRO_CB(skb)->frag0 = skb_frag_address(frag0);
+		NAPI_GRO_CB(skb)->frag0_len = skb_frag_size(frag0);
+	}
+}
+
 static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
@@ -3848,6 +3865,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	if (skb_is_gso(skb) || skb_has_frag_list(skb))
 		goto normal;
 
+	skb_gro_reset_offset(skb);
 	gro_list_prepare(napi, skb);
 
 	rcu_read_lock();
@@ -3953,27 +3971,8 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 	return ret;
 }
 
-static void skb_gro_reset_offset(struct sk_buff *skb)
-{
-	const struct skb_shared_info *pinfo = skb_shinfo(skb);
-	const skb_frag_t *frag0 = &pinfo->frags[0];
-
-	NAPI_GRO_CB(skb)->data_offset = 0;
-	NAPI_GRO_CB(skb)->frag0 = NULL;
-	NAPI_GRO_CB(skb)->frag0_len = 0;
-
-	if (skb_mac_header(skb) == skb_tail_pointer(skb) &&
-	    pinfo->nr_frags &&
-	    !PageHighMem(skb_frag_page(frag0))) {
-		NAPI_GRO_CB(skb)->frag0 = skb_frag_address(frag0);
-		NAPI_GRO_CB(skb)->frag0_len = skb_frag_size(frag0);
-	}
-}
-
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
-	skb_gro_reset_offset(skb);
-
 	return napi_skb_finish(dev_gro_receive(napi, skb), skb);
 }
 EXPORT_SYMBOL(napi_gro_receive);
@@ -4007,12 +4006,7 @@ static gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *
 {
 	switch (ret) {
 	case GRO_NORMAL:
-	case GRO_HELD:
-		skb->protocol = eth_type_trans(skb, skb->dev);
-
-		if (ret == GRO_HELD)
-			skb_gro_pull(skb, -ETH_HLEN);
-		else if (netif_receive_skb(skb))
+		if (netif_receive_skb(skb))
 			ret = GRO_DROP;
 		break;
 
@@ -4021,6 +4015,7 @@ static gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *
 		napi_reuse_skb(napi, skb);
 		break;
 
+	case GRO_HELD:
 	case GRO_MERGED:
 		break;
 	}
@@ -4031,36 +4026,15 @@ static gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *
 static struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 {
 	struct sk_buff *skb = napi->skb;
-	struct ethhdr *eth;
-	unsigned int hlen;
-	unsigned int off;
 
 	napi->skb = NULL;
 
-	skb_reset_mac_header(skb);
-	skb_gro_reset_offset(skb);
-
-	off = skb_gro_offset(skb);
-	hlen = off + sizeof(*eth);
-	eth = skb_gro_header_fast(skb, off);
-	if (skb_gro_header_hard(skb, hlen)) {
-		eth = skb_gro_header_slow(skb, hlen, off);
-		if (unlikely(!eth)) {
-			napi_reuse_skb(napi, skb);
-			skb = NULL;
-			goto out;
-		}
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct ethhdr)))) {
+		napi_reuse_skb(napi, skb);
+		return NULL;
 	}
+	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb_gro_pull(skb, sizeof(*eth));
-
-	/*
-	 * This works because the only protocols we care about don't require
-	 * special handling.  We'll fix it up properly at the end.
-	 */
-	skb->protocol = eth->h_proto;
-
-out:
 	return skb;
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2718fed..53e3e9f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3083,7 +3083,6 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	skb_set_mac_header(nskb, skb_mac_header(p) - p->data);
 	skb_set_network_header(nskb, skb_network_offset(p));
-	skb_set_transport_header(nskb, skb_transport_offset(p));
 
 	__skb_pull(p, skb_gro_offset(p));
 	memcpy(skb_mac_header(nskb), skb_mac_header(p),
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 70011e0..cb406e9 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1377,8 +1377,12 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
 
-		iph2 = ip_hdr(p);
-
+		iph2 = (struct iphdr *)(p->data + off);
+		/* The above works because, with the exception of the top
+		 * (inner most) layer, we only aggregate pkts with the same
+		 * hdr length so all the hdrs we'll need to verify will start
+		 * at the same offset.
+		 */
 		if ((iph->protocol ^ iph2->protocol) |
 		    ((__force u32)iph->saddr ^ (__force u32)iph2->saddr) |
 		    ((__force u32)iph->daddr ^ (__force u32)iph2->daddr)) {
@@ -1397,8 +1401,12 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	}
 
 	NAPI_GRO_CB(skb)->flush |= flush;
+	skb_set_network_header(skb, off);
+	/* The above will be needed by the transport layer if there is one
+	 * immediately following this IP hdr.
+	 */
+
 	skb_gro_pull(skb, sizeof(*iph));
-	skb_set_transport_header(skb, skb_gro_offset(skb));
 
 	pp = ops->callbacks.gro_receive(head, skb);
 
@@ -1411,10 +1419,10 @@ out:
 	return pp;
 }
 
-static int inet_gro_complete(struct sk_buff *skb)
+static int inet_gro_complete(struct sk_buff *skb, int nhoff)
 {
-	__be16 newlen = htons(skb->len - skb_network_offset(skb));
-	struct iphdr *iph = ip_hdr(skb);
+	__be16 newlen = htons(skb->len - nhoff);
+	struct iphdr *iph = (struct iphdr *)(skb->data + nhoff);
 	const struct net_offload *ops;
 	int proto = iph->protocol;
 	int err = -ENOSYS;
@@ -1427,7 +1435,11 @@ static int inet_gro_complete(struct sk_buff *skb)
 	if (WARN_ON(!ops || !ops->callbacks.gro_complete))
 		goto out_unlock;
 
-	err = ops->callbacks.gro_complete(skb);
+	/* Only need to add sizeof(*iph) to get to the next hdr below
+	 * because any hdr with option will have been flushed in
+	 * inet_gro_receive().
+	 */
+	err = ops->callbacks.gro_complete(skb, nhoff + sizeof(*iph));
 
 out_unlock:
 	rcu_read_unlock();
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 0560635..0ccf4d7 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -184,7 +184,7 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
 
-		th2 = tcp_hdr(p);
+		th2 = (struct tcphdr *)(p->data + off);
 
 		if (*(u32 *)&th->source ^ *(u32 *)&th2->source) {
 			NAPI_GRO_CB(p)->same_flow = 0;
@@ -217,7 +217,7 @@ found:
 	}
 
 	p = *head;
-	th2 = tcp_hdr(p);
+	th2 = (struct tcphdr *)(p->data + off);
 	tcp_flag_word(th2) |= flags & (TCP_FLAG_FIN | TCP_FLAG_PSH);
 
 out_check_final:
@@ -236,11 +236,9 @@ out:
 }
 EXPORT_SYMBOL(tcp_gro_receive);
 
-int tcp_gro_complete(struct sk_buff *skb)
+int __tcp_gro_complete(struct sk_buff *skb, struct tcphdr *th)
 {
-	struct tcphdr *th = tcp_hdr(skb);
-
-	skb->csum_start = skb_transport_header(skb) - skb->head;
+	skb->csum_start = (unsigned char *)th - skb->head;
 	skb->csum_offset = offsetof(struct tcphdr, check);
 	skb->ip_summed = CHECKSUM_PARTIAL;
 
@@ -251,6 +249,12 @@ int tcp_gro_complete(struct sk_buff *skb)
 
 	return 0;
 }
+EXPORT_SYMBOL(__tcp_gro_complete);
+
+int tcp_gro_complete(struct sk_buff *skb)
+{
+	return __tcp_gro_complete(skb,  tcp_hdr(skb));
+}
 EXPORT_SYMBOL(tcp_gro_complete);
 
 static int tcp_v4_gso_send_check(struct sk_buff *skb)
@@ -272,6 +276,7 @@ static int tcp_v4_gso_send_check(struct sk_buff *skb)
 
 static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
+	/* Use the IP hdr immediately proceeding for this transport */
 	const struct iphdr *iph = skb_gro_network_header(skb);
 	__wsum wsum;
 
@@ -303,16 +308,16 @@ skip_csum:
 	return tcp_gro_receive(head, skb);
 }
 
-static int tcp4_gro_complete(struct sk_buff *skb)
+static int tcp4_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	struct tcphdr *th = tcp_hdr(skb);
+	struct tcphdr *th = (struct tcphdr *)(skb->data + nhoff);
 
-	th->check = ~tcp_v4_check(skb->len - skb_transport_offset(skb),
-				  iph->saddr, iph->daddr, 0);
+	th->check = ~tcp_v4_check(skb->len - nhoff, iph->saddr,
+				  iph->daddr, 0);
 	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 
-	return tcp_gro_complete(skb);
+	return __tcp_gro_complete(skb, th);
 }
 
 static const struct net_offload tcpv4_offload = {
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 4b85169..e984385 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -154,6 +154,35 @@ out:
 	return segs;
 }
 
+/* Return the total length of all the extension hdrs, following the same
+ * logic in ipv6_gso_pull_exthdrs() when parsing ext-hdrs.
+ */
+static int ipv6_exthdrs_len(struct ipv6hdr *iph,
+			    const struct net_offload **opps)
+{
+	struct ipv6_opt_hdr *opth = NULL;
+	int len = 0, proto, optlen;
+
+	proto = iph->nexthdr;
+	for (;;) {
+		if (proto != NEXTHDR_HOP) {
+			*opps = rcu_dereference(inet6_offloads[proto]);
+			if (unlikely(!(*opps)))
+				break;
+			if (!((*opps)->flags & INET6_PROTO_GSO_EXTHDR))
+				break;
+		}
+		if (opth == NULL)
+			opth = (void *)(iph+1);
+		else
+			opth = (void *)opth + optlen;
+		optlen = ipv6_optlen(opth);
+		len += optlen;
+		proto = opth->nexthdr;
+	}
+	return len;
+}
+
 static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
@@ -167,6 +196,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	int flush = 1;
 	int proto;
 	__wsum csum;
+	__u16	next_header;
 
 	off = skb_gro_offset(skb);
 	hlen = off + sizeof(*iph);
@@ -176,9 +206,9 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 		if (unlikely(!iph))
 			goto out;
 	}
-
+	skb_set_network_header(skb, off);
 	skb_gro_pull(skb, sizeof(*iph));
-	skb_set_transport_header(skb, skb_gro_offset(skb));
+	next_header = skb->data - skb->head + skb_gro_offset(skb);
 
 	flush += ntohs(iph->payload_len) != skb_gro_len(skb);
 
@@ -188,8 +218,8 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	if (!ops || !ops->callbacks.gro_receive) {
 		__pskb_pull(skb, skb_gro_offset(skb));
 		proto = ipv6_gso_pull_exthdrs(skb, proto);
-		skb_gro_pull(skb, -skb_transport_offset(skb));
-		skb_reset_transport_header(skb);
+		skb_gro_pull(skb, -(int)(skb->head + next_header - skb->data));
+		next_header = skb->data - skb->head;
 		__skb_push(skb, skb_gro_offset(skb));
 
 		ops = rcu_dereference(inet6_offloads[proto]);
@@ -198,25 +228,28 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 
 		iph = ipv6_hdr(skb);
 	}
-
 	NAPI_GRO_CB(skb)->proto = proto;
 
 	flush--;
-	nlen = skb_network_header_len(skb);
+	nlen = next_header - skb->network_header;
 
 	for (p = *head; p; p = p->next) {
-		const struct ipv6hdr *iph2;
+		struct ipv6hdr *iph2;
 		__be32 first_word; /* <Version:4><Traffic_Class:8><Flow_Label:20> */
 
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
 
-		iph2 = ipv6_hdr(p);
+		iph2 = (struct ipv6hdr *)(p->data + off);
 		first_word = *(__be32 *)iph ^ *(__be32 *)iph2 ;
 
-		/* All fields must match except length and Traffic Class. */
-		if (nlen != skb_network_header_len(p) ||
-		    (first_word & htonl(0xF00FFFFF)) ||
+		/* All fields must match except length and Traffic Class.
+		 * XXX skbs on the gro_list have all been parsed and pulled
+		 * already so we don't need to compare nlen
+		 * (nlen != (sizeof(*iph2) + ipv6_exthdrs_len(iph2, &ops)))
+		 * memcmp() alone below is suffcient, right?
+		 */
+		 if ((first_word & htonl(0xF00FFFFF)) ||
 		    memcmp(&iph->nexthdr, &iph2->nexthdr,
 			   nlen - offsetof(struct ipv6hdr, nexthdr))) {
 			NAPI_GRO_CB(p)->same_flow = 0;
@@ -245,21 +278,21 @@ out:
 	return pp;
 }
 
-static int ipv6_gro_complete(struct sk_buff *skb)
+static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	const struct net_offload *ops;
-	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct ipv6hdr *iph = (struct ipv6hdr *)(skb->data + nhoff);
 	int err = -ENOSYS;
 
-	iph->payload_len = htons(skb->len - skb_network_offset(skb) -
-				 sizeof(*iph));
+	iph->payload_len = htons(skb->len - nhoff - sizeof(*iph));
 
 	rcu_read_lock();
-	ops = rcu_dereference(inet6_offloads[NAPI_GRO_CB(skb)->proto]);
+
+	nhoff += sizeof(*iph) + ipv6_exthdrs_len(iph, &ops);
 	if (WARN_ON(!ops || !ops->callbacks.gro_complete))
 		goto out_unlock;
 
-	err = ops->callbacks.gro_complete(skb);
+	err = ops->callbacks.gro_complete(skb, nhoff);
 
 out_unlock:
 	rcu_read_unlock();
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index 6d18157..a107ad6 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -66,16 +66,16 @@ skip_csum:
 	return tcp_gro_receive(head, skb);
 }
 
-static int tcp6_gro_complete(struct sk_buff *skb)
+static int tcp6_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct tcphdr *th = tcp_hdr(skb);
+	struct tcphdr *th = (struct tcphdr *)(skb->data + nhoff);
 
-	th->check = ~tcp_v6_check(skb->len - skb_transport_offset(skb),
-				  &iph->saddr, &iph->daddr, 0);
+	th->check = ~tcp_v6_check(skb->len - nhoff, &iph->saddr,
+				  &iph->daddr, 0);
 	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
 
-	return tcp_gro_complete(skb);
+	return __tcp_gro_complete(skb, th);
 }
 
 static const struct net_offload tcpv6_offload = {
-- 
1.8.5.1
