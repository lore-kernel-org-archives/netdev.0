From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6 1/5] udpv4: Handle large incoming UDP/IPv4
 packets and support software UFO.
Date: Thu, 09 Jul 2009 11:09:47 -0700
Message-ID: <1247162987.8649.90.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:42121 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753052AbZGISJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 14:09:50 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n69ID5dE002754
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:13:06 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n69I9nRs254054
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:09:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n69I9mVS032668
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 14:09:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next-2.6 1/5] udpv4: Handle large incoming UDP/IPv4 packets and support software UFO.

- validate and forward GSO UDP/IPv4 packets from untrusted sources.
- do software UFO if the outgoing device doesn't support UFO.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/udp.h  |    3 +++
 net/ipv4/af_inet.c |   12 +++++++++-
 net/ipv4/udp.c     |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 1 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h

--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -207,4 +207,7 @@ extern void udp4_proc_exit(void);
 #endif
 
 extern void udp_init(void);
+
+extern int udp4_ufo_send_check(struct sk_buff *skb);
+extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, int features);
 #endif	/* _UDP_H */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 566ea6c..197d024 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1187,6 +1187,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int features)
 	int proto;
 	int ihl;
 	int id;
+	unsigned int offset = 0;
 
 	if (!(features & NETIF_F_V4_CSUM))
 		features &= ~NETIF_F_SG;
@@ -1229,7 +1230,14 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int features)
 	skb = segs;
 	do {
 		iph = ip_hdr(skb);
-		iph->id = htons(id++);
+		if (proto == IPPROTO_UDP) {
+			iph->id = htons(id);
+			iph->frag_off = htons(offset >> 3);
+			if (skb->next != NULL)
+				iph->frag_off |= htons(IP_MF);
+			offset += (skb->len - skb->mac_len - iph->ihl * 4);
+		} else
+			iph->id = htons(id++);
 		iph->tot_len = htons(skb->len - skb->mac_len);
 		iph->check = 0;
 		iph->check = ip_fast_csum(skb_network_header(skb), iph->ihl);
@@ -1425,6 +1433,8 @@ static struct net_protocol tcp_protocol = {
 static struct net_protocol udp_protocol = {
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
+	.gso_send_check = udp4_ufo_send_check,
+	.gso_segment = udp4_ufo_fragment,
 	.no_policy =	1,
 	.netns_ok =	1,
 };
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 80e3812..7bc2d08 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1816,6 +1816,67 @@ void __init udp_init(void)
 	sysctl_udp_wmem_min = SK_MEM_QUANTUM;
 }
 
+int udp4_ufo_send_check(struct sk_buff *skb)
+{
+	const struct iphdr *iph;
+	struct udphdr *uh;
+
+	if (!pskb_may_pull(skb, sizeof(*uh)))
+		return -EINVAL;
+
+	iph = ip_hdr(skb);
+	uh = udp_hdr(skb);
+
+	uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
+				       IPPROTO_UDP, 0);
+	skb->csum_start = skb_transport_header(skb) - skb->head;
+	skb->csum_offset = offsetof(struct udphdr, check);
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	return 0;
+}
+
+struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, int features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	unsigned int mss;
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
+	/* Fragment the skb. IP headers of the fragments are updated in
+	 * inet_gso_segment()
+	 */
+	segs = skb_segment(skb, features);
+out:
+	return segs;
+}
+
 EXPORT_SYMBOL(udp_disconnect);
 EXPORT_SYMBOL(udp_ioctl);
 EXPORT_SYMBOL(udp_prot);


