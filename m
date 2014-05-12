From: Tom Herbert <therbert@google.com>
Subject: [PATCH 6/8] udp: Generic functions to set checksum
Date: Mon, 12 May 2014 09:59:05 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405120947310.1842@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:53299 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756437AbaELQ7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 12:59:07 -0400
Received: by mail-qc0-f202.google.com with SMTP id x3so1069416qcv.3
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 09:59:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added udp_set_csum and udp6_set_csum in packets. These are
for simple UDP packets such as those that might be created
in UDP tunnels.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/udp.h | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index 5eb8687..3d66d89 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -201,6 +201,59 @@ struct sock *__udp6_lib_lookup(struct net *net,
 			       const struct in6_addr *daddr, __be16 dport,
 			       int dif, struct udp_table *tbl);
 
+static inline void udp_set_csum(struct sock *sk, struct sk_buff *skb,
+				__be32 saddr, __be32 daddr, int len)
+{
+	struct udphdr *uh = udp_hdr(skb);
+
+	uh->check = 0;
+
+	if (sk->sk_no_check_tx)
+		skb->ip_summed = CHECKSUM_NONE;
+	else if (skb_is_gso(skb) || (skb_dst(skb) && skb_dst(skb)->dev &&
+		 (skb_dst(skb)->dev->features & NETIF_F_V4_CSUM))) {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_tcpudp_magic(saddr, daddr,
+					       len, IPPROTO_UDP, 0);
+	} else {
+		__wsum csum = skb_checksum(skb, 0, len, 0);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		uh->check = csum_tcpudp_magic(saddr, daddr,
+					      len, IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	}
+}
+
+static inline void udp6_set_csum(struct sock *sk, struct sk_buff *skb,
+				 const struct in6_addr *saddr,
+				 const struct in6_addr *daddr, int len)
+{
+	struct udphdr *uh = udp_hdr(skb);
+
+	uh->check = 0;
+
+	if (udp_get_no_check6_tx(sk))
+		skb->ip_summed = CHECKSUM_NONE;
+	else if (skb_is_gso(skb) || (skb_dst(skb) && skb_dst(skb)->dev &&
+		 (skb_dst(skb)->dev->features & NETIF_F_V6_CSUM))) {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_ipv6_magic(saddr, daddr,
+					     len, IPPROTO_UDP, 0);
+	} else {
+		__wsum csum = skb_checksum(skb, 0, len, 0);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		uh->check = csum_ipv6_magic(saddr, daddr, len,
+					    IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	}
+}
+
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
-- 
1.9.1.423.g4596e3a
