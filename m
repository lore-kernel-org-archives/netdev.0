From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 1/7] udp: Generic functions to set checksum
Date: Wed, 4 Jun 2014 17:19:48 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406041705290.14529@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:34629 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756420AbaFEATu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 20:19:50 -0400
Received: by mail-ie0-f202.google.com with SMTP id rd18so65601iec.5
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 17:19:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added udp_set_csum and udp6_set_csum functions to set UDP checksums
in packets. These are for simple UDP packets such as those that might
be created in UDP tunnels.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip6_checksum.h | 12 ++++++++++++
 include/net/udp.h          |  9 +++++++++
 net/ipv4/udp.c             | 37 +++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_checksum.c    | 38 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 96 insertions(+)

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 8ac5c21..55236cb 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -82,5 +82,17 @@ static inline void tcp_v6_send_check(struct sock *sk, struct sk_buff *skb)
 }
 #endif
 
+static inline __sum16 udp_v6_check(int len,
+				   const struct in6_addr *saddr,
+				   const struct in6_addr *daddr,
+				   __wsum base)
+{
+	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP, base);
+}
+
+void udp6_set_csum(bool nocheck, struct sk_buff *skb,
+		   const struct in6_addr *saddr,
+		   const struct in6_addr *daddr, int len);
+
 int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto);
 #endif
diff --git a/include/net/udp.h b/include/net/udp.h
index 5eb8687..2ecfc6e 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -147,6 +147,15 @@ static inline __wsum udp_csum(struct sk_buff *skb)
 	return csum;
 }
 
+static inline __sum16 udp_v4_check(int len, __be32 saddr,
+				   __be32 daddr, __wsum base)
+{
+	return csum_tcpudp_magic(saddr, daddr, len, IPPROTO_UDP, base);
+}
+
+void udp_set_csum(bool nocheck, struct sk_buff *skb,
+		  __be32 saddr, __be32 daddr, int len);
+
 /* hash routines shared between UDPv4/6 and UDP-Litev4/6 */
 static inline void udp_lib_hash(struct sock *sk)
 {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e07d52b..a84f676 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -762,6 +762,43 @@ void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
 }
 EXPORT_SYMBOL_GPL(udp4_hwcsum);
 
+/* Function to set UDP checksum for an IPv4 UDP packet. This is intended
+ * for the simple case like when setting the checksum for a UDP tunnel.
+ */
+void udp_set_csum(bool nocheck, struct sk_buff *skb,
+		  __be32 saddr, __be32 daddr, int len)
+{
+	struct udphdr *uh = udp_hdr(skb);
+
+	if (nocheck)
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
+EXPORT_SYMBOL(udp_set_csum);
+
 static int udp_send_skb(struct sk_buff *skb, struct flowi4 *fl4)
 {
 	struct sock *sk = skb->sk;
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index da26224..9a4d732 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -84,3 +84,41 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
 					   ip6_compute_pseudo);
 }
 EXPORT_SYMBOL(udp6_csum_init);
+
+/* Function to set UDP checksum for an IPv6 UDP packet. This is intended
+ * for the simple case like when setting the checksum for a UDP tunnel.
+ */
+void udp6_set_csum(bool nocheck, struct sk_buff *skb,
+		   const struct in6_addr *saddr,
+		   const struct in6_addr *daddr, int len)
+{
+	struct udphdr *uh = udp_hdr(skb);
+
+	if (nocheck)
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
+EXPORT_SYMBOL(udp6_set_csum);
-- 
2.0.0.526.g5318336
