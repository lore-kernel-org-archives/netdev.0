From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6 5/5] udpv6: Handle large incoming UDP/IPv6
 packets and support software UFO
Date: Thu, 09 Jul 2009 11:10:04 -0700
Message-ID: <1247163004.8649.94.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:42259 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753805AbZGISKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 14:10:11 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n69IDRsJ003348
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:13:27 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69IAAdg254738
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:10:10 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n69IA9Di002590
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:10:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next-2.6 5/5] udpv6: Handle large incoming UDP/IPv6 packets and support software UFO

- validate and forward GSO UDP/IPv6 packets from untrusted sources.
- do software UFO if the outgoing device doesn't support UFO.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/ipv6/af_inet6.c |   20 +++++++++--
 net/ipv6/udp.c      |   93 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 110 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index caa0278..bf85d5f 100644
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
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f31b1b9..d79fa67 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1078,9 +1078,102 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
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
+	int offset;
+	__wsum csum;
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
+	/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
+	 * do checksum of UDP packets sent as multiple IP fragments.
+	 */
+	offset = skb->csum_start - skb_headroom(skb);
+	csum = skb_checksum(skb, offset, skb->len- offset, 0);
+	offset += skb->csum_offset;
+	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* Check if there is enough headroom to insert fragment header. */
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
+	/* Fragment the skb. ipv6 header and the remaining fields of the
+	 * fragment header are updated in ipv6_gso_segment()
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
 


