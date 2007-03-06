From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [UDP]: Clean up UDP-Lite receive checksum
Date: Tue, 6 Mar 2007 12:41:00 +1100
Message-ID: <20070306014100.GA31417@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1158 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933801AbXCFBlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 20:41:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[UDP]: Clean up UDP-Lite receive checksum

This patch eliminates some duplicate code for the verification of
receive checksums between UDP-Lite and UDP.  It does this by
introducing __skb_checksum_complete_head which is identical to
__skb_checksum_complete_head apart from the fact that it takes
a length parameter rather than computing the first skb->len bytes.

As a result UDP-Lite will be able to use hardware checksum offload
for packets which do not use partial coverage checksums.  It also
means that UDP-Lite loopback no longer does unnecessary checksum
verification.

If any NICs start support UDP-Lite this would also start working
automatically.

This patch removes the assumption that msg_flags has MSG_TRUNC clear
upon entry in recvmsg.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
b830b85a68b42ce10139a7a9e405622e809b8de7
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..658dfad 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1381,6 +1381,7 @@ static inline void skb_set_timestamp(struct sk_buff *skb, const struct timeval *
 
 extern void __net_timestamp(struct sk_buff *skb);
 
+extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
 /**
diff --git a/include/net/udp.h b/include/net/udp.h
index 1b921fa..4a9699f 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -72,10 +72,7 @@ struct sk_buff;
  */
 static inline __sum16 __udp_lib_checksum_complete(struct sk_buff *skb)
 {
-	if (! UDP_SKB_CB(skb)->partial_cov)
-		return __skb_checksum_complete(skb);
-	return csum_fold(skb_checksum(skb, 0, UDP_SKB_CB(skb)->cscov,
-				      skb->csum));
+	return __skb_checksum_complete_head(skb, UDP_SKB_CB(skb)->cscov);
 }
 
 static inline int udp_lib_checksum_complete(struct sk_buff *skb)
diff --git a/include/net/udplite.h b/include/net/udplite.h
index 67ac514..89aa2bd 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -47,11 +47,10 @@ static inline int udplite_checksum_init(struct sk_buff *skb, struct udphdr *uh)
 		return 1;
 	}
 
-        UDP_SKB_CB(skb)->partial_cov = 0;
 	cscov = ntohs(uh->len);
 
 	if (cscov == 0)		 /* Indicates that full coverage is required. */
-		cscov = skb->len;
+		;
 	else if (cscov < 8  || cscov > skb->len) {
 		/*
 		 * Coverage length violates RFC 3828: log and discard silently.
@@ -60,42 +59,16 @@ static inline int udplite_checksum_init(struct sk_buff *skb, struct udphdr *uh)
 			       cscov, skb->len);
 		return 1;
 
-	} else if (cscov < skb->len)
+	} else if (cscov < skb->len) {
         	UDP_SKB_CB(skb)->partial_cov = 1;
-
-        UDP_SKB_CB(skb)->cscov = cscov;
-
-	/*
-	 * There is no known NIC manufacturer supporting UDP-Lite yet,
-	 * hence ip_summed is always (re-)set to CHECKSUM_NONE.
-	 */
-	skb->ip_summed = CHECKSUM_NONE;
+        	UDP_SKB_CB(skb)->cscov = cscov;
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_NONE;
+        }
 
 	return 0;
 }
 
-static __inline__ int udplite4_csum_init(struct sk_buff *skb, struct udphdr *uh)
-{
-	int rc = udplite_checksum_init(skb, uh);
-
-	if (!rc)
-		skb->csum = csum_tcpudp_nofold(skb->nh.iph->saddr,
-					       skb->nh.iph->daddr,
-					       skb->len, IPPROTO_UDPLITE, 0);
-	return rc;
-}
-
-static __inline__ int udplite6_csum_init(struct sk_buff *skb, struct udphdr *uh)
-{
-	int rc = udplite_checksum_init(skb, uh);
-
-	if (!rc)
-		skb->csum = ~csum_unfold(csum_ipv6_magic(&skb->nh.ipv6h->saddr,
-					     &skb->nh.ipv6h->daddr,
-					     skb->len, IPPROTO_UDPLITE, 0));
-	return rc;
-}
-
 static inline int udplite_sender_cscov(struct udp_sock *up, struct udphdr *uh)
 {
 	int cscov = up->len;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 186212b..cb056f4 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -411,11 +411,11 @@ fault:
 	return -EFAULT;
 }
 
-__sum16 __skb_checksum_complete(struct sk_buff *skb)
+__sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len)
 {
 	__sum16 sum;
 
-	sum = csum_fold(skb_checksum(skb, 0, skb->len, skb->csum));
+	sum = csum_fold(skb_checksum(skb, 0, len, skb->csum));
 	if (likely(!sum)) {
 		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 			netdev_rx_csum_fault(skb->dev);
@@ -423,6 +423,12 @@ __sum16 __skb_checksum_complete(struct sk_buff *skb)
 	}
 	return sum;
 }
+EXPORT_SYMBOL(__skb_checksum_complete_head);
+
+__sum16 __skb_checksum_complete(struct sk_buff *skb)
+{
+	return __skb_checksum_complete_head(skb, skb->len);
+}
 EXPORT_SYMBOL(__skb_checksum_complete);
 
 /**
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fc620a7..776569b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -810,7 +810,9 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
 	struct sk_buff *skb;
-	int copied, err, copy_only, is_udplite = IS_UDPLITE(sk);
+	unsigned int ulen, copied;
+	int err;
+	int is_udplite = IS_UDPLITE(sk);
 
 	/*
 	 *	Check any passed addresses
@@ -826,28 +828,25 @@ try_again:
 	if (!skb)
 		goto out;
 
-	copied = skb->len - sizeof(struct udphdr);
-	if (copied > len) {
-		copied = len;
+	ulen = skb->len - sizeof(struct udphdr);
+	copied = len;
+	if (copied > ulen)
+		copied = ulen;
+	else if (copied < ulen)
 		msg->msg_flags |= MSG_TRUNC;
-	}
 
 	/*
-	 * 	Decide whether to checksum and/or copy data.
-	 *
-	 * 	UDP:      checksum may have been computed in HW,
-	 * 	          (re-)compute it if message is truncated.
-	 * 	UDP-Lite: always needs to checksum, no HW support.
+	 * If checksum is needed at all, try to do it while copying the
+	 * data.  If the data is truncated, or if we only want a partial
+	 * coverage checksum (UDP-Lite), do it before the copy.
 	 */
-	copy_only = (skb->ip_summed==CHECKSUM_UNNECESSARY);
 
-	if (is_udplite  ||  (!copy_only  &&  msg->msg_flags&MSG_TRUNC)) {
-		if (__udp_lib_checksum_complete(skb))
+	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
+		if (udp_lib_checksum_complete(skb))
 			goto csum_copy_err;
-		copy_only = 1;
 	}
 
-	if (copy_only)
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
 					      msg->msg_iov, copied       );
 	else {
@@ -875,7 +874,7 @@ try_again:
 
 	err = copied;
 	if (flags & MSG_TRUNC)
-		err = skb->len - sizeof(struct udphdr);
+		err = ulen;
 
 out_free:
 	skb_free_datagram(sk, skb);
@@ -1095,10 +1094,9 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 		}
 	}
 
-	if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
-		if (__udp_lib_checksum_complete(skb))
+	if (sk->sk_filter) {
+		if (udp_lib_checksum_complete(skb))
 			goto drop;
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
@@ -1166,25 +1164,36 @@ static int __udp4_lib_mcast_deliver(struct sk_buff *skb,
  * Otherwise, csum completion requires chacksumming packet body,
  * including udp header and folding it to skb->csum.
  */
-static inline void udp4_csum_init(struct sk_buff *skb, struct udphdr *uh)
+static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
+				 int proto)
 {
+	int err;
+
+	UDP_SKB_CB(skb)->partial_cov = 0;
+	UDP_SKB_CB(skb)->cscov = skb->len;
+
+	if (proto == IPPROTO_UDPLITE) {
+		err = udplite_checksum_init(skb, uh);
+		if (err)
+			return err;
+	}
+
 	if (uh->check == 0) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
 	       if (!csum_tcpudp_magic(skb->nh.iph->saddr, skb->nh.iph->daddr,
-				      skb->len, IPPROTO_UDP, skb->csum       ))
+				      skb->len, proto, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
 		skb->csum = csum_tcpudp_nofold(skb->nh.iph->saddr,
 					       skb->nh.iph->daddr,
-					       skb->len, IPPROTO_UDP, 0);
+					       skb->len, proto, 0);
 	/* Probably, we should checksum udp header (it should be in cache
 	 * in any case) and data in tiny packets (< rx copybreak).
 	 */
 
-	/* UDP = UDP-Lite with a non-partial checksum coverage */
-	UDP_SKB_CB(skb)->partial_cov = 0;
+	return 0;
 }
 
 /*
@@ -1192,7 +1201,7 @@ static inline void udp4_csum_init(struct sk_buff *skb, struct udphdr *uh)
  */
 
 int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
-		   int is_udplite)
+		   int proto)
 {
 	struct sock *sk;
 	struct udphdr *uh = skb->h.uh;
@@ -1211,19 +1220,16 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	if (ulen > skb->len)
 		goto short_packet;
 
-	if(! is_udplite ) {		/* UDP validates ulen. */
-
+	if (proto == IPPROTO_UDP) {
+		/* UDP validates ulen. */
 		if (ulen < sizeof(*uh) || pskb_trim_rcsum(skb, ulen))
 			goto short_packet;
 		uh = skb->h.uh;
-
-		udp4_csum_init(skb, uh);
-
-	} else 	{			/* UDP-Lite validates cscov. */
-		if (udplite4_csum_init(skb, uh))
-			goto csum_error;
 	}
 
+	if (udp4_csum_init(skb, uh, proto))
+		goto csum_error;
+
 	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
 
@@ -1250,7 +1256,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 	if (udp_lib_checksum_complete(skb))
 		goto csum_error;
 
-	UDP_INC_STATS_BH(UDP_MIB_NOPORTS, is_udplite);
+	UDP_INC_STATS_BH(UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
 	/*
@@ -1262,7 +1268,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 
 short_packet:
 	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: short packet: From %u.%u.%u.%u:%u %d/%d to %u.%u.%u.%u:%u\n",
-		       is_udplite? "-Lite" : "",
+		       proto == IPPROTO_UDPLITE ? "-Lite" : "",
 		       NIPQUAD(saddr),
 		       ntohs(uh->source),
 		       ulen,
@@ -1284,14 +1290,14 @@ csum_error:
 		       ntohs(uh->dest),
 		       ulen);
 drop:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	UDP_INC_STATS_BH(UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
 	return(0);
 }
 
 __inline__ int udp_rcv(struct sk_buff *skb)
 {
-	return __udp4_lib_rcv(skb, udp_hash, 0);
+	return __udp4_lib_rcv(skb, udp_hash, IPPROTO_UDP);
 }
 
 int udp_destroy_sock(struct sock *sk)
@@ -1486,15 +1492,11 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 		struct sk_buff *skb;
 
 		spin_lock_bh(&rcvq->lock);
-		while ((skb = skb_peek(rcvq)) != NULL) {
-			if (udp_lib_checksum_complete(skb)) {
-				UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_lite);
-				__skb_unlink(skb, rcvq);
-				kfree_skb(skb);
-			} else {
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				break;
-			}
+		while ((skb = skb_peek(rcvq)) != NULL &&
+		       udp_lib_checksum_complete(skb)) {
+			UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_lite);
+			__skb_unlink(skb, rcvq);
+			kfree_skb(skb);
 		}
 		spin_unlock_bh(&rcvq->lock);
 
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index b28fe1e..f34fd68 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -31,7 +31,7 @@ static int udplite_v4_get_port(struct sock *sk, unsigned short snum)
 
 static int udplite_rcv(struct sk_buff *skb)
 {
-	return __udp4_lib_rcv(skb, udplite_hash, 1);
+	return __udp4_lib_rcv(skb, udplite_hash, IPPROTO_UDPLITE);
 }
 
 static void udplite_err(struct sk_buff *skb, u32 info)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4474480..216a1b8 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -120,8 +120,9 @@ int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
-	size_t copied;
-	int err, copy_only, is_udplite = IS_UDPLITE(sk);
+	unsigned int ulen, copied;
+	int err;
+	int is_udplite = IS_UDPLITE(sk);
 
 	if (addr_len)
 		*addr_len=sizeof(struct sockaddr_in6);
@@ -134,24 +135,25 @@ try_again:
 	if (!skb)
 		goto out;
 
-	copied = skb->len - sizeof(struct udphdr);
-	if (copied > len) {
-		copied = len;
+	ulen = skb->len - sizeof(struct udphdr);
+	copied = len;
+	if (copied > ulen)
+		copied = ulen;
+	else if (copied < ulen)
 		msg->msg_flags |= MSG_TRUNC;
-	}
 
 	/*
-	 * 	Decide whether to checksum and/or copy data.
+	 * If checksum is needed at all, try to do it while copying the
+	 * data.  If the data is truncated, or if we only want a partial
+	 * coverage checksum (UDP-Lite), do it before the copy.
 	 */
-	copy_only = (skb->ip_summed==CHECKSUM_UNNECESSARY);
 
-	if (is_udplite  ||  (!copy_only  &&  msg->msg_flags&MSG_TRUNC)) {
-		if (__udp_lib_checksum_complete(skb))
+	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov) {
+		if (udp_lib_checksum_complete(skb))
 			goto csum_copy_err;
-		copy_only = 1;
 	}
 
-	if (copy_only)
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
 					      msg->msg_iov, copied       );
 	else {
@@ -194,7 +196,7 @@ try_again:
 
 	err = copied;
 	if (flags & MSG_TRUNC)
-		err = skb->len - sizeof(struct udphdr);
+		err = ulen;
 
 out_free:
 	skb_free_datagram(sk, skb);
@@ -368,9 +370,20 @@ out:
 	return 0;
 }
 
-static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh)
-
+static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh,
+				 int proto)
 {
+	int err;
+
+	UDP_SKB_CB(skb)->partial_cov = 0;
+	UDP_SKB_CB(skb)->cscov = skb->len;
+
+	if (proto == IPPROTO_UDPLITE) {
+		err = udplite_checksum_init(skb, uh);
+		if (err)
+			return err;
+	}
+
 	if (uh->check == 0) {
 		/* RFC 2460 section 8.1 says that we SHOULD log
 		   this error. Well, it is reasonable.
@@ -380,20 +393,19 @@ static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh)
 	}
 	if (skb->ip_summed == CHECKSUM_COMPLETE &&
 	    !csum_ipv6_magic(&skb->nh.ipv6h->saddr, &skb->nh.ipv6h->daddr,
-			     skb->len, IPPROTO_UDP, skb->csum             ))
+			     skb->len, proto, skb->csum))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
 		skb->csum = ~csum_unfold(csum_ipv6_magic(&skb->nh.ipv6h->saddr,
 							 &skb->nh.ipv6h->daddr,
-							 skb->len, IPPROTO_UDP,
-							 0));
+							 skb->len, proto, 0));
 
-	return (UDP_SKB_CB(skb)->partial_cov = 0);
+	return 0;
 }
 
 int __udp6_lib_rcv(struct sk_buff **pskb, struct hlist_head udptable[],
-		   int is_udplite)
+		   int proto)
 {
 	struct sk_buff *skb = *pskb;
 	struct sock *sk;
@@ -413,7 +425,8 @@ int __udp6_lib_rcv(struct sk_buff **pskb, struct hlist_head udptable[],
 	if (ulen > skb->len)
 		goto short_packet;
 
-	if(! is_udplite ) {		/* UDP validates ulen. */
+	if (proto == IPPROTO_UDP) {
+		/* UDP validates ulen. */
 
 		/* Check for jumbo payload */
 		if (ulen == 0)
@@ -429,15 +442,11 @@ int __udp6_lib_rcv(struct sk_buff **pskb, struct hlist_head udptable[],
 			daddr = &skb->nh.ipv6h->daddr;
 			uh = skb->h.uh;
 		}
-
-		if (udp6_csum_init(skb, uh))
-			goto discard;
-
-	} else 	{			/* UDP-Lite validates cscov. */
-		if (udplite6_csum_init(skb, uh))
-			goto discard;
 	}
 
+	if (udp6_csum_init(skb, uh, proto))
+		goto discard;
+
 	/*
 	 *	Multicast receive code
 	 */
@@ -459,7 +468,7 @@ int __udp6_lib_rcv(struct sk_buff **pskb, struct hlist_head udptable[],
 
 		if (udp_lib_checksum_complete(skb))
 			goto discard;
-		UDP6_INC_STATS_BH(UDP_MIB_NOPORTS, is_udplite);
+		UDP6_INC_STATS_BH(UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
 
 		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, dev);
 
@@ -475,17 +484,18 @@ int __udp6_lib_rcv(struct sk_buff **pskb, struct hlist_head udptable[],
 
 short_packet:
 	LIMIT_NETDEBUG(KERN_DEBUG "UDP%sv6: short packet: %d/%u\n",
-		       is_udplite? "-Lite" : "",  ulen, skb->len);
+		       proto == IPPROTO_UDPLITE ? "-Lite" : "",
+		       ulen, skb->len);
 
 discard:
-	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
 	return(0);
 }
 
 static __inline__ int udpv6_rcv(struct sk_buff **pskb)
 {
-	return __udp6_lib_rcv(pskb, udp_hash, 0);
+	return __udp6_lib_rcv(pskb, udp_hash, IPPROTO_UDP);
 }
 
 /*
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 629f971..f54016a 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -19,7 +19,7 @@ DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6) __read_mostly;
 
 static int udplitev6_rcv(struct sk_buff **pskb)
 {
-	return __udp6_lib_rcv(pskb, udplite_hash, 1);
+	return __udp6_lib_rcv(pskb, udplite_hash, IPPROTO_UDPLITE);
 }
 
 static void udplitev6_err(struct sk_buff *skb,
