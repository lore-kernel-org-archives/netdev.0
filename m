From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v3 3/4] ip_tunnel: implement __iptunnel_pull_header
Date: Tue,  5 Apr 2016 14:47:12 +0200
Message-ID: <bc1943cf408523cd466ebcc1e2444e0c7e2f77b7.1459860270.git.jbenc@redhat.com>
References: <cover.1459860270.git.jbenc@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48991 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758457AbcDEMrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 08:47:32 -0400
In-Reply-To: <cover.1459860270.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow calling of iptunnel_pull_header without special casing ETH_P_TEB inner
protocol.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
New in v2.
---
 include/net/ip_tunnels.h  | 11 +++++++++--
 net/ipv4/ip_tunnel_core.c |  8 ++++----
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 56050f913339..16435d8b1f93 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -295,8 +295,15 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 	return INET_ECN_encapsulate(tos, inner);
 }
 
-int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto,
-			 bool xnet);
+int __iptunnel_pull_header(struct sk_buff *skb, int hdr_len,
+			   __be16 inner_proto, bool raw_proto, bool xnet);
+
+static inline int iptunnel_pull_header(struct sk_buff *skb, int hdr_len,
+				       __be16 inner_proto, bool xnet)
+{
+	return __iptunnel_pull_header(skb, hdr_len, inner_proto, false, xnet);
+}
+
 void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, u8 proto,
 		   u8 tos, u8 ttl, __be16 df, bool xnet);
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index b3ab1205dfdf..43445df61efd 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -86,15 +86,15 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 }
 EXPORT_SYMBOL_GPL(iptunnel_xmit);
 
-int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto,
-			 bool xnet)
+int __iptunnel_pull_header(struct sk_buff *skb, int hdr_len,
+			   __be16 inner_proto, bool raw_proto, bool xnet)
 {
 	if (unlikely(!pskb_may_pull(skb, hdr_len)))
 		return -ENOMEM;
 
 	skb_pull_rcsum(skb, hdr_len);
 
-	if (inner_proto == htons(ETH_P_TEB)) {
+	if (!raw_proto && inner_proto == htons(ETH_P_TEB)) {
 		struct ethhdr *eh;
 
 		if (unlikely(!pskb_may_pull(skb, ETH_HLEN)))
@@ -117,7 +117,7 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto,
 
 	return iptunnel_pull_offloads(skb);
 }
-EXPORT_SYMBOL_GPL(iptunnel_pull_header);
+EXPORT_SYMBOL_GPL(__iptunnel_pull_header);
 
 struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
 					     gfp_t flags)
-- 
1.8.3.1
