From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC 10/12] inet: Stop generating UFO packets.
Date: Wed, 05 Jul 2017 16:06:18 +0100 (WEST)
Message-ID: <20170705.160618.1318882200619430939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdGEPGX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:06:23 -0400
Received: from localhost (unknown [193.136.225.129])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id DEA65126C97F5
        for <netdev@vger.kernel.org>; Wed,  5 Jul 2017 08:06:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_output.c  | 76 ---------------------------------------------------
 net/ipv6/ip6_output.c | 76 ---------------------------------------------------
 2 files changed, 152 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7eb252d..d338f86 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -853,61 +853,6 @@ csum_page(struct page *page, int offset, int copy)
 	return csum;
 }
 
-static inline int ip_ufo_append_data(struct sock *sk,
-			struct sk_buff_head *queue,
-			int getfrag(void *from, char *to, int offset, int len,
-			       int odd, struct sk_buff *skb),
-			void *from, int length, int hh_len, int fragheaderlen,
-			int transhdrlen, int maxfraglen, unsigned int flags)
-{
-	struct sk_buff *skb;
-	int err;
-
-	/* There is support for UDP fragmentation offload by network
-	 * device, so create one single skb packet containing complete
-	 * udp datagram
-	 */
-	skb = skb_peek_tail(queue);
-	if (!skb) {
-		skb = sock_alloc_send_skb(sk,
-			hh_len + fragheaderlen + transhdrlen + 20,
-			(flags & MSG_DONTWAIT), &err);
-
-		if (!skb)
-			return err;
-
-		/* reserve space for Hardware header */
-		skb_reserve(skb, hh_len);
-
-		/* create space for UDP/IP header */
-		skb_put(skb, fragheaderlen + transhdrlen);
-
-		/* initialize network header pointer */
-		skb_reset_network_header(skb);
-
-		/* initialize protocol header pointer */
-		skb->transport_header = skb->network_header + fragheaderlen;
-
-		skb->csum = 0;
-
-		if (flags & MSG_CONFIRM)
-			skb_set_dst_pending_confirm(skb, 1);
-
-		__skb_queue_tail(queue, skb);
-	} else if (skb_is_gso(skb)) {
-		goto append;
-	}
-
-	skb->ip_summed = CHECKSUM_PARTIAL;
-	/* specify the length of each IP datagram fragment */
-	skb_shinfo(skb)->gso_size = maxfraglen - fragheaderlen;
-	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-
-append:
-	return skb_append_datato_frags(sk, skb, getfrag, from,
-				       (length - transhdrlen));
-}
-
 static int __ip_append_data(struct sock *sk,
 			    struct flowi4 *fl4,
 			    struct sk_buff_head *queue,
@@ -965,18 +910,6 @@ static int __ip_append_data(struct sock *sk,
 		csummode = CHECKSUM_PARTIAL;
 
 	cork->length += length;
-	if ((((length + (skb ? skb->len : fragheaderlen)) > mtu) ||
-	     (skb && skb_is_gso(skb))) &&
-	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->dst.dev->features & NETIF_F_UFO) && !dst_xfrm(&rt->dst) &&
-	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx) {
-		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
-					 hh_len, fragheaderlen, transhdrlen,
-					 maxfraglen, flags);
-		if (err)
-			goto error;
-		return 0;
-	}
 
 	/* So, what's going on in the loop below?
 	 *
@@ -1287,15 +1220,6 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 	if (!skb)
 		return -EINVAL;
 
-	if ((size + skb->len > mtu) &&
-	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->dst.dev->features & NETIF_F_UFO)) {
-		if (skb->ip_summed != CHECKSUM_PARTIAL)
-			return -EOPNOTSUPP;
-
-		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
-		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-	}
 	cork->length += size;
 
 	while (size > 0) {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1422d6c..c6ec064 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1114,69 +1114,6 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 }
 EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup_flow);
 
-static inline int ip6_ufo_append_data(struct sock *sk,
-			struct sk_buff_head *queue,
-			int getfrag(void *from, char *to, int offset, int len,
-			int odd, struct sk_buff *skb),
-			void *from, int length, int hh_len, int fragheaderlen,
-			int exthdrlen, int transhdrlen, int mtu,
-			unsigned int flags, const struct flowi6 *fl6)
-
-{
-	struct sk_buff *skb;
-	int err;
-
-	/* There is support for UDP large send offload by network
-	 * device, so create one single skb packet containing complete
-	 * udp datagram
-	 */
-	skb = skb_peek_tail(queue);
-	if (!skb) {
-		skb = sock_alloc_send_skb(sk,
-			hh_len + fragheaderlen + transhdrlen + 20,
-			(flags & MSG_DONTWAIT), &err);
-		if (!skb)
-			return err;
-
-		/* reserve space for Hardware header */
-		skb_reserve(skb, hh_len);
-
-		/* create space for UDP/IP header */
-		skb_put(skb, fragheaderlen + transhdrlen);
-
-		/* initialize network header pointer */
-		skb_set_network_header(skb, exthdrlen);
-
-		/* initialize protocol header pointer */
-		skb->transport_header = skb->network_header + fragheaderlen;
-
-		skb->protocol = htons(ETH_P_IPV6);
-		skb->csum = 0;
-
-		if (flags & MSG_CONFIRM)
-			skb_set_dst_pending_confirm(skb, 1);
-
-		__skb_queue_tail(queue, skb);
-	} else if (skb_is_gso(skb)) {
-		goto append;
-	}
-
-	skb->ip_summed = CHECKSUM_PARTIAL;
-	/* Specify the length of each IPv6 datagram fragment.
-	 * It has to be a multiple of 8.
-	 */
-	skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
-				     sizeof(struct frag_hdr)) & ~7;
-	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-	skb_shinfo(skb)->ip6_frag_id = ipv6_select_ident(sock_net(sk),
-							 &fl6->daddr,
-							 &fl6->saddr);
-
-append:
-	return skb_append_datato_frags(sk, skb, getfrag, from,
-				       (length - transhdrlen));
-}
-
 static inline struct ipv6_opt_hdr *ip6_opt_dup(struct ipv6_opt_hdr *src,
 					       gfp_t gfp)
 {
@@ -1385,19 +1322,6 @@ static int __ip6_append_data(struct sock *sk,
 	 */
 
 	cork->length += length;
-	if ((((length + (skb ? skb->len : headersize)) > mtu) ||
-	     (skb && skb_is_gso(skb))) &&
-	    (sk->sk_protocol == IPPROTO_UDP) &&
-	    (rt->dst.dev->features & NETIF_F_UFO) && !dst_xfrm(&rt->dst) &&
-	    (sk->sk_type == SOCK_DGRAM) && !udp_get_no_check6_tx(sk)) {
-		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
-					  hh_len, fragheaderlen, exthdrlen,
-					  transhdrlen, mtu, flags, fl6);
-		if (err)
-			goto error;
-		return 0;
-	}
-
 	if (!skb)
 		goto alloc_new_skb;
 
-- 
2.9.4
