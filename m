From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Treat CHECKSUM_PARTIAL as CHECKSUM_UNNECESSARY
Date: Wed, 4 Apr 2007 12:06:47 +1000
Message-ID: <20070404020647.GA30077@gondor.apana.org.au>
References: <20070404020530.GA30050@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2103 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S966282AbXDDCGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 22:06:49 -0400
Content-Disposition: inline
In-Reply-To: <20070404020530.GA30050@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

Here's the other patch.

[NET]: Treat CHECKSUM_PARTIAL as CHECKSUM_UNNECESSARY

When a transmitted packet is looped back directly, CHECKSUM_PARTIAL
maps to the semantics of CHECKSUM_UNNECESSARY.  Therefore we should
treat it as such in the stack.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -33,10 +33,11 @@
 #define HAVE_ALLOC_SKB		/* For the drivers to know */
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
 
+/* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
-#define CHECKSUM_PARTIAL 1
-#define CHECKSUM_UNNECESSARY 2
-#define CHECKSUM_COMPLETE 3
+#define CHECKSUM_UNNECESSARY 1
+#define CHECKSUM_COMPLETE 2
+#define CHECKSUM_PARTIAL 3
 
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
@@ -1550,6 +1551,11 @@ static inline void __net_timestamp(struc
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
+static inline int skb_csum_unnecessary(const struct sk_buff *skb)
+{
+	return skb->ip_summed & CHECKSUM_UNNECESSARY;
+}
+
 /**
  *	skb_checksum_complete - Calculate checksum of an entire packet
  *	@skb: packet to process
@@ -1568,8 +1574,8 @@ extern __sum16 __skb_checksum_complete(s
  */
 static inline unsigned int skb_checksum_complete(struct sk_buff *skb)
 {
-	return skb->ip_summed != CHECKSUM_UNNECESSARY &&
-		__skb_checksum_complete(skb);
+	return skb_csum_unnecessary(skb) ?
+	       0 : __skb_checksum_complete(skb);
 }
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -818,7 +818,7 @@ static inline __sum16 __tcp_checksum_com
 
 static inline int tcp_checksum_complete(struct sk_buff *skb)
 {
-	return skb->ip_summed != CHECKSUM_UNNECESSARY &&
+	return !skb_csum_unnecessary(skb) &&
 		__tcp_checksum_complete(skb);
 }
 
diff --git a/include/net/udp.h b/include/net/udp.h
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -77,7 +77,7 @@ static inline __sum16 __udp_lib_checksum
 
 static inline int udp_lib_checksum_complete(struct sk_buff *skb)
 {
-	return skb->ip_summed != CHECKSUM_UNNECESSARY &&
+	return !skb_csum_unnecessary(skb) &&
 		__udp_lib_checksum_complete(skb);
 }
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -86,7 +86,7 @@ static __sum16 checksum_udp(struct sk_bu
 {
 	__wsum psum;
 
-	if (uh->check == 0 || skb->ip_summed == CHECKSUM_UNNECESSARY)
+	if (uh->check == 0 || skb_csum_unnecessary(skb))
 		return 0;
 
 	psum = csum_tcpudp_nofold(saddr, daddr, ulen, IPPROTO_UDP, 0);
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -681,8 +681,7 @@ static int ip_vs_out_icmp(struct sk_buff
 	}
 
 	/* Ensure the checksum is correct */
-	if (skb->ip_summed != CHECKSUM_UNNECESSARY &&
-	    ip_vs_checksum_complete(skb, ihl)) {
+	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
 		/* Failed checksum! */
 		IP_VS_DBG(1, "Forward ICMP: failed checksum from %d.%d.%d.%d!\n",
 			  NIPQUAD(iph->saddr));
@@ -921,8 +920,7 @@ ip_vs_in_icmp(struct sk_buff **pskb, int
 	verdict = NF_DROP;
 
 	/* Ensure the checksum is correct */
-	if (skb->ip_summed != CHECKSUM_UNNECESSARY &&
-	    ip_vs_checksum_complete(skb, ihl)) {
+	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
 		/* Failed checksum! */
 		IP_VS_DBG(1, "Incoming ICMP: failed checksum from %d.%d.%d.%d!\n",
 			  NIPQUAD(iph->saddr));
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4185,7 +4185,7 @@ static int tcp_copy_to_iovec(struct sock
 	int err;
 
 	local_bh_enable();
-	if (skb->ip_summed==CHECKSUM_UNNECESSARY)
+	if (skb_csum_unnecessary(skb))
 		err = skb_copy_datagram_iovec(skb, hlen, tp->ucopy.iov, chunk);
 	else
 		err = skb_copy_and_csum_datagram_iovec(skb, hlen,
@@ -4217,7 +4217,7 @@ static __sum16 __tcp_checksum_complete_u
 
 static inline int tcp_checksum_complete_user(struct sock *sk, struct sk_buff *skb)
 {
-	return skb->ip_summed != CHECKSUM_UNNECESSARY &&
+	return !skb_csum_unnecessary(skb) &&
 		__tcp_checksum_complete_user(sk, skb);
 }
 
@@ -4235,7 +4235,7 @@ static int tcp_dma_try_early_copy(struct
 	if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
 		tp->ucopy.dma_chan = get_softnet_dma();
 
-	if (tp->ucopy.dma_chan && skb->ip_summed == CHECKSUM_UNNECESSARY) {
+	if (tp->ucopy.dma_chan && skb_csum_unnecessary(skb)) {
 
 		dma_cookie = dma_skb_copy_datagram_iovec(tp->ucopy.dma_chan,
 			skb, hlen, tp->ucopy.iov, chunk, tp->ucopy.pinned_list);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1638,8 +1638,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	 * Packet length and doff are validated by header prediction,
 	 * provided case of th->doff==0 is eliminated.
 	 * So, we defer the checks. */
-	if ((skb->ip_summed != CHECKSUM_UNNECESSARY &&
-	     tcp_v4_checksum_init(skb)))
+	if (!skb_csum_unnecessary(skb) && tcp_v4_checksum_init(skb))
 		goto bad_packet;
 
 	th = tcp_hdr(skb);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -848,7 +848,7 @@ try_again:
 			goto csum_copy_err;
 	}
 
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
+	if (skb_csum_unnecessary(skb))
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
 					      msg->msg_iov, copied       );
 	else {
@@ -1190,7 +1190,7 @@ static inline int udp4_csum_init(struct 
 				      proto, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
-	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
+	if (!skb_csum_unnecessary(skb))
 		skb->csum = csum_tcpudp_nofold(iph->saddr, iph->daddr,
 					       skb->len, proto, 0);
 	/* Probably, we should checksum udp header (it should be in cache
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -368,7 +368,7 @@ int rawv6_rcv(struct sock *sk, struct sk
 				     skb->len, inet->num, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
-	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
+	if (!skb_csum_unnecessary(skb))
 		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 							 &ipv6_hdr(skb)->daddr,
 							 skb->len,
@@ -421,7 +421,7 @@ static int rawv6_recvmsg(struct kiocb *i
 		msg->msg_flags |= MSG_TRUNC;
 	}
 
-	if (skb->ip_summed==CHECKSUM_UNNECESSARY) {
+	if (skb_csum_unnecessary(skb)) {
 		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
 	} else if (msg->msg_flags&MSG_TRUNC) {
 		if (__skb_checksum_complete(skb))
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1707,8 +1707,7 @@ static int tcp_v6_rcv(struct sk_buff **p
 	if (!pskb_may_pull(skb, th->doff*4))
 		goto discard_it;
 
-	if ((skb->ip_summed != CHECKSUM_UNNECESSARY &&
-	     tcp_v6_checksum_init(skb)))
+	if (!skb_csum_unnecessary(skb) && tcp_v6_checksum_init(skb))
 		goto bad_packet;
 
 	th = tcp_hdr(skb);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -153,7 +153,7 @@ try_again:
 			goto csum_copy_err;
 	}
 
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
+	if (skb_csum_unnecessary(skb))
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
 					      msg->msg_iov, copied       );
 	else {
@@ -397,7 +397,7 @@ static inline int udp6_csum_init(struct 
 			     skb->len, proto, skb->csum))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
+	if (!skb_csum_unnecessary(skb))
 		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 							 &ipv6_hdr(skb)->daddr,
 							 skb->len, proto, 0));
diff --git a/net/sctp/input.c b/net/sctp/input.c
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -140,8 +140,7 @@ int sctp_rcv(struct sk_buff *skb)
 	__skb_pull(skb, skb_transport_offset(skb));
 	if (skb->len < sizeof(struct sctphdr))
 		goto discard_it;
-	if ((skb->ip_summed != CHECKSUM_UNNECESSARY) &&
-	    (sctp_rcv_checksum(skb) < 0))
+	if (!skb_csum_unnecessary(skb) && sctp_rcv_checksum(skb) < 0)
 		goto discard_it;
 
 	skb_pull(skb, sizeof(struct sctphdr));
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -154,7 +154,7 @@ int csum_partial_copy_to_xdr(struct xdr_
 	desc.offset = sizeof(struct udphdr);
 	desc.count = skb->len - desc.offset;
 
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
+	if (skb_csum_unnecessary(skb))
 		goto no_checksum;
 
 	desc.csum = csum_partial(skb->data, desc.offset, skb->csum);
