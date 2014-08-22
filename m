From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 2/6] net: add gro_compute_pseudo functions
Date: Fri, 22 Aug 2014 13:34:04 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408221315540.1488@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:55854 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978AbaHVUeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 16:34:05 -0400
Received: by mail-pa0-f74.google.com with SMTP id lj1so3009955pab.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 13:34:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add inet_gro_compute_pseudo and ip6_gro_compute_pseudo. These are
the logical equivalents of inet_compute_pseudo and ip6_compute_pseudo
for GRO path. The IP header is taken from skb_gro_network_header.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip.h           | 8 ++++++++
 include/net/ip6_checksum.h | 8 ++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/net/ip.h b/include/net/ip.h
index db4a771..c8fd611 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -364,6 +364,14 @@ static inline void inet_set_txhash(struct sock *sk)
 	sk->sk_txhash = flow_hash_from_keys(&keys);
 }
 
+static inline __wsum inet_gro_compute_pseudo(struct sk_buff *skb, int proto)
+{
+	const struct iphdr *iph = skb_gro_network_header(skb);
+
+	return csum_tcpudp_nofold(iph->saddr, iph->daddr,
+				  skb_gro_len(skb), proto, 0);
+}
+
 /*
  *	Map a multicast IP onto multicast MAC for type ethernet.
  */
diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 55236cb..1a49b73 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -48,6 +48,14 @@ static inline __wsum ip6_compute_pseudo(struct sk_buff *skb, int proto)
 					    skb->len, proto, 0));
 }
 
+static inline __wsum ip6_gro_compute_pseudo(struct sk_buff *skb, int proto)
+{
+	const struct ipv6hdr *iph = skb_gro_network_header(skb);
+
+	return ~csum_unfold(csum_ipv6_magic(&iph->saddr, &iph->daddr,
+					    skb_gro_len(skb), proto, 0));
+}
+
 static __inline__ __sum16 tcp_v6_check(int len,
 				   const struct in6_addr *saddr,
 				   const struct in6_addr *daddr,
-- 
2.1.0.rc2.206.gedb03e5
