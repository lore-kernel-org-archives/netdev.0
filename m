From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 4/4] iptunnel: scrub packet in iptunnel_pull_header
Date: Thu, 18 Feb 2016 11:22:52 +0100
Message-ID: <29bb0a248c1b4ca8f19070d41460f183a55cd2b4.1455790645.git.jbenc@redhat.com>
References: <cover.1455790645.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945962AbcBRKXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:23:50 -0500
In-Reply-To: <cover.1455790645.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Part of skb_scrub_packet was open coded in iptunnel_pull_header. Let it call
skb_scrub_packet directly instead.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/geneve.c      | 4 ++--
 drivers/net/vxlan.c       | 4 ++--
 include/net/ip_tunnels.h  | 3 ++-
 net/ipv4/ip_gre.c         | 2 +-
 net/ipv4/ip_tunnel_core.c | 8 +++-----
 net/ipv4/ipip.c           | 2 +-
 net/ipv6/sit.c            | 2 +-
 7 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 4ceccf871b3f..dfbe3ca687f7 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -237,7 +237,6 @@ static void geneve_rx(struct geneve_dev *geneve, struct geneve_sock *gs,
 	}
 
 	skb_reset_mac_header(skb);
-	skb_scrub_packet(skb, !net_eq(geneve->net, dev_net(geneve->dev)));
 	skb->protocol = eth_type_trans(skb, geneve->dev);
 	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
@@ -356,7 +355,8 @@ static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	opts_len = geneveh->opt_len * 4;
 	if (iptunnel_pull_header(skb, GENEVE_BASE_HLEN + opts_len,
-				 htons(ETH_P_TEB)))
+				 htons(ETH_P_TEB),
+				 !net_eq(geneve->net, dev_net(geneve->dev))))
 		goto drop;
 
 	geneve_rx(geneve, gs, skb);
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index b43981416fb9..56cb9d23a6f3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1198,7 +1198,6 @@ static void vxlan_rcv(struct vxlan_dev *vxlan, struct vxlan_sock *vs,
 	int err = 0;
 
 	skb_reset_mac_header(skb);
-	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
 	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
@@ -1305,7 +1304,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!vxlan)
 		goto drop;
 
-	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
+	if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB),
+				 !net_eq(vxlan->net, dev_net(vxlan->dev))))
 		goto drop;
 
 	if (vxlan_collect_metadata(vs)) {
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 87408ab80856..4dd616376fec 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -270,7 +270,8 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 	return INET_ECN_encapsulate(tos, inner);
 }
 
-int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
+int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto,
+			 bool xnet);
 void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, u8 proto,
 		   u8 tos, u8 ttl, __be16 df, bool xnet);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 917c2c1bfadd..12071e28d958 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -238,7 +238,7 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 				return -EINVAL;
 		}
 	}
-	return iptunnel_pull_header(skb, hdr_len, tpi->proto);
+	return iptunnel_pull_header(skb, hdr_len, tpi->proto, false);
 }
 
 static void ipgre_err(struct sk_buff *skb, u32 info,
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index a6e58b6141cd..eaca2449a09a 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -86,7 +86,8 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 }
 EXPORT_SYMBOL_GPL(iptunnel_xmit);
 
-int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
+int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto,
+			 bool xnet)
 {
 	if (unlikely(!pskb_may_pull(skb, hdr_len)))
 		return -ENOMEM;
@@ -109,13 +110,10 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 		skb->protocol = inner_proto;
 	}
 
-	nf_reset(skb);
-	secpath_reset(skb);
 	skb_clear_hash_if_not_l4(skb);
-	skb_dst_drop(skb);
 	skb->vlan_tci = 0;
 	skb_set_queue_mapping(skb, 0);
-	skb->pkt_type = PACKET_HOST;
+	skb_scrub_packet(skb, xnet);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(iptunnel_pull_header);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 6ec5b42fd172..ec51d02166de 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -195,7 +195,7 @@ static int ipip_rcv(struct sk_buff *skb)
 	if (tunnel) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
-		if (iptunnel_pull_header(skb, 0, tpi.proto))
+		if (iptunnel_pull_header(skb, 0, tpi.proto, false))
 			goto drop;
 		return ip_tunnel_rcv(tunnel, skb, &tpi, NULL, log_ecn_error);
 	}
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0625ac6356b5..f45b8ffc2840 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -740,7 +740,7 @@ static int ipip_rcv(struct sk_buff *skb)
 
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
-		if (iptunnel_pull_header(skb, 0, tpi.proto))
+		if (iptunnel_pull_header(skb, 0, tpi.proto, false))
 			goto drop;
 		return ip_tunnel_rcv(tunnel, skb, &tpi, NULL, log_ecn_error);
 	}
-- 
1.8.3.1
