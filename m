From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/6] ipip: add GSO/TSO support
Date: Sat, 19 Oct 2013 11:42:57 -0700
Message-ID: <1382208178-22347-6-git-send-email-edumazet@google.com>
References: <1382208178-22347-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:60083 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab3JSSnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 14:43:10 -0400
Received: by mail-qc0-f201.google.com with SMTP id i8so418789qcq.2
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 11:43:09 -0700 (PDT)
In-Reply-To: <1382208178-22347-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now inet_gso_segment() is stackable, its relatively easy to
implement GSO/TSO support for IPIP

Performance results, when segmentation is done after tunnel
device (as no NIC is yet enabled for TSO IPIP support) :

Before patch :

lpq83:~# ./netperf -H 7.7.9.84 -Cc
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.9.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      3357.88   5.09     3.70     2.983   2.167

After patch :

lpq83:~# ./netperf -H 7.7.9.84 -Cc
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.9.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      7710.19   4.52     6.62     1.152   1.687

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdev_features.h |  2 ++
 include/linux/skbuff.h          |  6 ++++--
 net/core/ethtool.c              |  1 +
 net/ipv4/af_inet.c              |  9 +++++++++
 net/ipv4/gre_offload.c          |  3 ++-
 net/ipv4/ipip.c                 | 11 ++++++-----
 net/ipv4/tcp_offload.c          |  1 +
 net/ipv4/udp_offload.c          |  1 +
 net/ipv6/ip6_offload.c          |  1 +
 net/ipv6/udp_offload.c          |  1 +
 net/mpls/mpls_gso.c             |  1 +
 11 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index a2a89a5..8dad68c 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -42,6 +42,7 @@ enum {
 	NETIF_F_TSO6_BIT,		/* ... TCPv6 segmentation */
 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
 	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
+	NETIF_F_GSO_IPIP_BIT,		/* ... IPIP tunnel with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
 	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
@@ -107,6 +108,7 @@ enum {
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
 #define NETIF_F_GSO_GRE		__NETIF_F(GSO_GRE)
+#define NETIF_F_GSO_IPIP	__NETIF_F(GSO_IPIP)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_MPLS	__NETIF_F(GSO_MPLS)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cad1e0c..6072913 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -318,9 +318,11 @@ enum {
 
 	SKB_GSO_GRE = 1 << 6,
 
-	SKB_GSO_UDP_TUNNEL = 1 << 7,
+	SKB_GSO_IPIP = 1 << 7,
 
-	SKB_GSO_MPLS = 1 << 8,
+	SKB_GSO_UDP_TUNNEL = 1 << 8,
+
+	SKB_GSO_MPLS = 1 << 9,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 78e9d92..8cab774 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -81,6 +81,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_TSO6_BIT] =             "tx-tcp6-segmentation",
 	[NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
 	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
+	[NETIF_F_GSO_IPIP_BIT] =	 "tx-ipip-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
 	[NETIF_F_GSO_MPLS_BIT] =	 "tx-mpls-segmentation",
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5783ab5..4049906 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1291,6 +1291,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
+		       SKB_GSO_IPIP |
 		       SKB_GSO_TCPV6 |
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_MPLS |
@@ -1656,6 +1657,13 @@ static struct packet_offload ip_packet_offload __read_mostly = {
 	},
 };
 
+static const struct net_offload ipip_offload = {
+	.callbacks = {
+		.gso_send_check = inet_gso_send_check,
+		.gso_segment	= inet_gso_segment,
+	},
+};
+
 static int __init ipv4_offload_init(void)
 {
 	/*
@@ -1667,6 +1675,7 @@ static int __init ipv4_offload_init(void)
 		pr_crit("%s: Cannot add TCP protocol offload\n", __func__);
 
 	dev_add_offload(&ip_packet_offload);
+	inet_add_offload(&ipip_offload, IPPROTO_IPIP);
 	return 0;
 }
 
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 55e6bfb..e5d4361 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -39,7 +39,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_UDP |
 				  SKB_GSO_DODGY |
 				  SKB_GSO_TCP_ECN |
-				  SKB_GSO_GRE)))
+				  SKB_GSO_GRE |
+				  SKB_GSO_IPIP)))
 		goto out;
 
 	if (unlikely(!pskb_may_pull(skb, sizeof(*greh))))
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 7f80fb4..fe3e9f7 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -220,17 +220,17 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb->protocol != htons(ETH_P_IP)))
 		goto tx_error;
 
-	if (likely(!skb->encapsulation)) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
+	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
+	if (IS_ERR(skb))
+		goto out;
 
 	ip_tunnel_xmit(skb, dev, tiph, tiph->protocol);
 	return NETDEV_TX_OK;
 
 tx_error:
-	dev->stats.tx_errors++;
 	dev_kfree_skb(skb);
+out:
+	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
 
@@ -275,6 +275,7 @@ static const struct net_device_ops ipip_netdev_ops = {
 #define IPIP_FEATURES (NETIF_F_SG |		\
 		       NETIF_F_FRAGLIST |	\
 		       NETIF_F_HIGHDMA |	\
+		       NETIF_F_GSO_SOFTWARE |	\
 		       NETIF_F_HW_CSUM)
 
 static void ipip_tunnel_setup(struct net_device *dev)
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 8e3113f..dfc96b0 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -56,6 +56,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
 			       SKB_GSO_GRE |
+			       SKB_GSO_IPIP |
 			       SKB_GSO_MPLS |
 			       SKB_GSO_UDP_TUNNEL |
 			       0) ||
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index f35ecca..83206de 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -52,6 +52,7 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 
 		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
 				      SKB_GSO_UDP_TUNNEL |
+				      SKB_GSO_IPIP |
 				      SKB_GSO_GRE | SKB_GSO_MPLS) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index d82de72..548036a 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -98,6 +98,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
+		       SKB_GSO_IPIP |
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_MPLS |
 		       SKB_GSO_TCPV6 |
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 6055951..f63780f 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -64,6 +64,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 				      SKB_GSO_DODGY |
 				      SKB_GSO_UDP_TUNNEL |
 				      SKB_GSO_GRE |
+				      SKB_GSO_IPIP |
 				      SKB_GSO_MPLS) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 1bec121..851cd88 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -33,6 +33,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_DODGY |
 				  SKB_GSO_TCP_ECN |
 				  SKB_GSO_GRE |
+				  SKB_GSO_IPIP |
 				  SKB_GSO_MPLS)))
 		goto out;
 
-- 
1.8.4
