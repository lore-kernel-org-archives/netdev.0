From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 3/4] ip_tunnel: implement __iptunnel_pull_header
Date: Wed, 16 Mar 2016 17:51:11 +0100
Message-ID: <49d0fd002e715ad71118e2d355ca585c0901992b.1458146189.git.jbenc@redhat.com>
References: <cover.1458146189.git.jbenc@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42448 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934178AbcCPQv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 12:51:27 -0400
In-Reply-To: <cover.1458146189.git.jbenc@redhat.com>
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
index 5dc2e454f866..e9056dab1eb0 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -288,8 +288,15 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
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
index eaca2449a09a..ccff5682cd38 100644
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
@@ -116,7 +116,7 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto,
 	skb_scrub_packet(skb, xnet);
 	return 0;
 }
-EXPORT_SYMBOL_GPL(iptunnel_pull_header);
+EXPORT_SYMBOL_GPL(__iptunnel_pull_header);
 
 struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
 					     gfp_t flags)
-- 
1.8.3.1
