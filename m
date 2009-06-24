From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [RFC 2/2] udpv6: Support software UFO and handle large incoming
 UDP/IPv6 packets
Date: Wed, 24 Jun 2009 09:16:56 -0700
Message-ID: <1245860216.23459.14.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44523 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760740AbZFXQQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2009 12:16:57 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5OGCCoY021962
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 12:12:12 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5OGH0Tr227246
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 12:17:00 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5OGEbhG031432
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 12:14:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[RFC 2/2] udpv6: Support software UFO and handle large incoming UDP/IPv6 packets

- add HW checksum support for outgoing large UDP/IPv6 packets destined for a
  UFO enabled device.
- fix gso_size setting for ipv6 fragment to be a multiple of 8 bytes.
- move ipv6_select_ident() inline function to ipv6.h and remove the unused
  skb argument.
- validate and forward GSO UDP/IPv6 packets from untrusted sources(guests under KVM).
- do software UFO if the outgoing device doesn't support UFO.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -441,6 +441,18 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
+static __inline__ void ipv6_select_ident(struct frag_hdr *fhdr)
+{
+	static u32 ipv6_fragmentation_id = 1;
+	static DEFINE_SPINLOCK(ip6_id_lock);
+
+	spin_lock_bh(&ip6_id_lock);
+	fhdr->identification = htonl(ipv6_fragmentation_id);
+	if (++ipv6_fragmentation_id == 0)
+		ipv6_fragmentation_id = 1;
+	spin_unlock_bh(&ip6_id_lock);
+}
+
 /*
  *	Prototypes exported by ipv6
  */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -772,6 +772,11 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct ipv6hdr *ipv6h;
 	struct inet6_protocol *ops;
+	int proto;
+	struct frag_hdr *fptr;
+	unsigned int unfrag_ip6hlen;
+	u8 *prevhdr;
+	int offset = 0;
 
 	if (!(features & NETIF_F_V6_CSUM))
 		features &= ~NETIF_F_SG;
@@ -791,10 +796,9 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 	__skb_pull(skb, sizeof(*ipv6h));
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
+	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
 	rcu_read_lock();
-	ops = rcu_dereference(inet6_protos[
-		ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr)]);
-
+	ops = rcu_dereference(inet6_protos[proto]);
 	if (likely(ops && ops->gso_segment)) {
 		skb_reset_transport_header(skb);
 		segs = ops->gso_segment(skb, features);
@@ -808,6 +812,16 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 		ipv6h = ipv6_hdr(skb);
 		ipv6h->payload_len = htons(skb->len - skb->mac_len -
 					   sizeof(*ipv6h));
+		if (proto == IPPROTO_UDP) {
+			unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
+			fptr = (struct frag_hdr *)(skb_network_header(skb) +
+				unfrag_ip6hlen);
+			fptr->frag_off = htons(offset);
+			if (skb->next != NULL)
+				fptr->frag_off |= htons(IP6_MF);
+			offset += (ntohs(ipv6h->payload_len) -
+				   sizeof(struct frag_hdr));
+		}
 	}
 
 out:
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -57,18 +57,6 @@
 
 static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 
-static __inline__ void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *fhdr)
-{
-	static u32 ipv6_fragmentation_id = 1;
-	static DEFINE_SPINLOCK(ip6_id_lock);
-
-	spin_lock_bh(&ip6_id_lock);
-	fhdr->identification = htonl(ipv6_fragmentation_id);
-	if (++ipv6_fragmentation_id == 0)
-		ipv6_fragmentation_id = 1;
-	spin_unlock_bh(&ip6_id_lock);
-}
-
 int __ip6_local_out(struct sk_buff *skb)
 {
 	int len;
@@ -706,7 +694,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		skb_reset_network_header(skb);
 		memcpy(skb_network_header(skb), tmp_hdr, hlen);
 
-		ipv6_select_ident(skb, fh);
+		ipv6_select_ident(fh);
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
 		fh->frag_off = htons(IP6_MF);
@@ -844,7 +832,7 @@ slow_path:
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
 		if (!frag_id) {
-			ipv6_select_ident(skb, fh);
+			ipv6_select_ident(fh);
 			frag_id = fh->identification;
 		} else
 			fh->identification = frag_id;
@@ -1087,14 +1075,15 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	if (!err) {
 		struct frag_hdr fhdr;
 
-		/* specify the length of each IP datagram fragment*/
-		skb_shinfo(skb)->gso_size = mtu - fragheaderlen -
-					    sizeof(struct frag_hdr);
+		/* Specify the length of each IPv6 datagram fragment.
+ 		 * It has to be a multiple of 8.
+		 */
+		skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
+					     sizeof(struct frag_hdr)) & ~7;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-		ipv6_select_ident(skb, &fhdr);
+		ipv6_select_ident(&fhdr);
 		skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
 		__skb_queue_tail(&sk->sk_write_queue, skb);
-
 		return 0;
 	}
 	/* There is not enough support do UPD LSO,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -638,6 +638,47 @@ static void udp_v6_flush_pending_frames(struct sock *sk)
 	}
 }
 
+/**
+ * 	udp6_hwcsum_outgoing  -  handle outgoing HW checksumming
+ * 	@sk: 	socket we are sending on
+ * 	@skb: 	sk_buff containing the filled-in UDP header
+ * 	        (checksum field must be zeroed out)
+ */
+static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
+				 const struct in6_addr *saddr,
+				 const struct in6_addr *daddr, int len)
+{
+	unsigned int offset;
+	struct udphdr *uh = udp_hdr(skb);
+	__wsum csum = 0;
+
+	if (skb_queue_len(&sk->sk_write_queue) == 1) {
+		/* Only one fragment on the socket.  */
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP, 0);
+	} else {
+		/*
+		 * HW-checksum won't work as there are two or more
+		 * fragments on the socket so that all csums of sk_buffs
+		 * should be together
+		 */
+		offset = skb_transport_offset(skb);
+		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+
+		skb->ip_summed = CHECKSUM_NONE;
+
+		skb_queue_walk(&sk->sk_write_queue, skb) {
+			csum = csum_add(csum, skb->csum);
+		}
+
+		uh->check = csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP,
+					    csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	}
+}
+
 /*
  *	Sending
  */
@@ -668,7 +709,11 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 
 	if (is_udplite)
 		csum = udplite_csum_outgoing(sk, skb);
-	 else
+	else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
+		udp6_hwcsum_outgoing(sk, skb, &fl->fl6_src, &fl->fl6_dst,
+				     up->len);
+		goto send;
+	} else
 		csum = udp_csum_outgoing(sk, skb);
 
 	/* add protocol-dependent pseudo-header */
@@ -677,6 +722,7 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
+send:
 	err = ip6_push_pending_frames(sk);
 out:
 	up->len = 0;
@@ -1032,9 +1078,94 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 }
 #endif
 
+static int udp6_ufo_send_check(struct sk_buff *skb)
+{
+	struct ipv6hdr *ipv6h;
+	struct udphdr *uh;
+
+	if (!pskb_may_pull(skb, sizeof(*uh)))
+		return -EINVAL;
+
+	ipv6h = ipv6_hdr(skb);
+	uh = udp_hdr(skb);
+
+	uh->check = 0;
+	uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
+				     IPPROTO_UDP, 0);
+	skb->csum_start = skb_transport_header(skb) - skb->head;
+	skb->csum_offset = offsetof(struct udphdr, check);
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	return 0;
+}
+
+static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, int features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	unsigned int mss;
+	unsigned int unfrag_ip6hlen, unfrag_len;
+	struct frag_hdr *fptr;
+	u8 *mac_start, *prevhdr;
+	u8 nexthdr;
+	u8 frag_hdr_sz = sizeof(struct frag_hdr);
+
+	mss = skb_shinfo(skb)->gso_size;
+	if (unlikely(skb->len <= mss))
+		goto out;
+
+	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
+		/* Packet is from an untrusted source, reset gso_segs. */
+		int type = skb_shinfo(skb)->gso_type;
+
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
+			     !(type & (SKB_GSO_UDP))))
+			goto out;
+
+		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
+
+		segs = NULL;
+		goto out;
+	}
+	
+	/* Do software UFO. Check if there is enough headroom to insert 
+	 * fragment header.
+	 */
+	if ((skb_headroom(skb) < frag_hdr_sz) && 
+	    pskb_expand_head(skb, frag_hdr_sz, 0, GFP_ATOMIC))
+		goto out;
+
+	/* Find the unfragmentable header and shift it left by frag_hdr_sz
+	 * bytes to insert fragment header.
+	 */ 
+	unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
+	nexthdr = *prevhdr;
+	*prevhdr = NEXTHDR_FRAGMENT;
+	unfrag_len = skb_network_header(skb) - skb_mac_header(skb) +
+		     unfrag_ip6hlen;
+	mac_start = skb_mac_header(skb);
+	memmove(mac_start-frag_hdr_sz, mac_start, unfrag_len);
+
+	skb->mac_header -= frag_hdr_sz;
+	skb->network_header -= frag_hdr_sz;
+
+	fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
+	fptr->nexthdr = nexthdr;
+	fptr->reserved = 0;
+	ipv6_select_ident(fptr);
+
+	/* ipv6 header and the remaining fields of the fragment header are
+	 * updated in ipv6_gso_segment()
+	 */  
+	segs = skb_segment(skb, features);
+
+out:
+	return segs;
+}
+
 static struct inet6_protocol udpv6_protocol = {
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
+	.gso_send_check =	udp6_ufo_send_check,
+	.gso_segment	=	udp6_ufo_fragment,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 


