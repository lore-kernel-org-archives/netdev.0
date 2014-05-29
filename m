From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/7] udp: Generic functions to set checksum
Date: Wed, 28 May 2014 21:23:27 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405282113290.6331@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:37218 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbaE2EX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 00:23:29 -0400
Received: by mail-oa0-f73.google.com with SMTP id g18so306450oah.0
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 21:23:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added udp_set_csum and udp6_set_csum functions to set UDP checksums
in packets. These are for simple UDP packets such as those that might
be created in UDP tunnels.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip6_checksum.h | 45 +++++++++++++++++++++++++++++++++++++++++++++
 include/net/udp.h          | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 87 insertions(+)

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 8ac5c21..7382a12 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -82,5 +82,50 @@ static inline void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
 }
 #endif
 
+static inline __sum16 udp_v6_check(int len,
+				       const struct in6_addr *saddr,
+				       const struct in6_addr *daddr,
+				       __wsum base)
+{
+	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP, base);
+}
+
+
+/* Function to set UDP checksum for an IPv6 UDP packet. This is intended
+ * for the simple case like when setting the checksum for a UDP tunnel.
+ */
+static inline void udp6_set_csum(struct sock *sk, struct sk_buff *skb,
+				 const struct in6_addr *saddr,
+				 const struct in6_addr *daddr, int len)
+{
+	struct udphdr *uh = udp_hdr(skb);
+
+	if (udp_get_no_check6_tx(sk))
+		uh->check = 0;
+	else if (skb_is_gso(skb))
+		uh->check = ~udp_v6_check(len, saddr, daddr, 0);
+	else if (skb_dst(skb) && skb_dst(skb)->dev &&
+		 (skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM)) {
+
+		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
+
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~udp_v6_check(len, saddr, daddr, 0);
+	} else {
+		__wsum csum;
+
+		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
+
+		uh->check = 0;
+		csum = skb_checksum(skb, 0, len, 0);
+		uh->check = udp_v6_check(len, saddr, daddr, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+}
 int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto);
 #endif
diff --git a/include/net/udp.h b/include/net/udp.h
index 5eb8687..a8a6d69 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -147,6 +147,48 @@ static inline __wsum udp_csum(struct sk_buff *skb)
 	return csum;
 }
 
+static inline __sum16 udp_v4_check(int len, __be32 saddr,
+				   __be32 daddr, __wsum base)
+{
+	return csum_tcpudp_magic(saddr, daddr, len, IPPROTO_UDP, base);
+}
+
+/* Function to set UDP checksum for an IPv4 UDP packet. This is intended
+ * for the simple case like when setting the checksum for a UDP tunnel.
+ */
+static inline void udp_set_csum(struct sock *sk, struct sk_buff *skb,
+				__be32 saddr, __be32 daddr, int len)
+{
+	struct udphdr *uh = udp_hdr(skb);
+
+	if (sk->sk_no_check_tx)
+		uh->check = 0;
+	else if (skb_is_gso(skb))
+		uh->check = ~udp_v4_check(len, saddr, daddr, 0);
+	else if (skb_dst(skb) && skb_dst(skb)->dev &&
+		 (skb_dst(skb)->dev->features & NETIF_F_V4_CSUM)) {
+
+		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
+
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~udp_v4_check(len, saddr, daddr, 0);
+	} else {
+		__wsum csum;
+
+		BUG_ON(skb->ip_summed == CHECKSUM_PARTIAL);
+
+		uh->check = 0;
+		csum = skb_checksum(skb, 0, len, 0);
+		uh->check = udp_v4_check(len, saddr, daddr, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+}
+
 /* hash routines shared between UDPv4/6 and UDP-Litev4/6 */
 static inline void udp_lib_hash(struct sock *sk)
 {
-- 
1.9.1.423.g4596e3a
