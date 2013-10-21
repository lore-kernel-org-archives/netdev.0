From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/3] ipv6: sit: add GSO/TSO support
Date: Sun, 20 Oct 2013 20:47:30 -0700
Message-ID: <1382327251-21079-3-git-send-email-edumazet@google.com>
References: <1382327251-21079-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Erik Kline <ek@google.com>, Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:55648 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456Ab3JUDzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 23:55:35 -0400
Received: by mail-pa0-f74.google.com with SMTP id fa1so616080pad.1
        for <netdev@vger.kernel.org>; Sun, 20 Oct 2013 20:55:33 -0700 (PDT)
In-Reply-To: <1382327251-21079-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now ipv6_gso_segment() is stackable, its relatively easy to
implement GSO/TSO support for SIT tunnels

Performance results, when segmentation is done after tunnel
device (as no NIC is yet enabled for TSO SIT support) :

Before patch :

lpq84:~# ./netperf -H 2002:af6:1153:: -Cc
MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 2002:af6:1153:: () port 0 AF_INET6
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      3168.31   4.81     4.64     2.988   2.877

After patch :

lpq84:~# ./netperf -H 2002:af6:1153:: -Cc
MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 2002:af6:1153:: () port 0 AF_INET6
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      5525.00   7.76     5.17     2.763   1.840

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdev_features.h |  2 ++
 include/linux/skbuff.h          |  6 ++++--
 net/core/ethtool.c              |  1 +
 net/ipv4/af_inet.c              |  1 +
 net/ipv4/tcp_offload.c          |  1 +
 net/ipv6/ip6_offload.c          | 11 +++++++++++
 net/ipv6/sit.c                  | 28 +++++++++++++++++++---------
 net/ipv6/udp_offload.c          |  1 +
 8 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 8dad68c..b05a4b5 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -43,6 +43,7 @@ enum {
 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
 	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
 	NETIF_F_GSO_IPIP_BIT,		/* ... IPIP tunnel with TSO */
+	NETIF_F_GSO_SIT_BIT,		/* ... SIT tunnel with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
 	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
@@ -109,6 +110,7 @@ enum {
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
 #define NETIF_F_GSO_GRE		__NETIF_F(GSO_GRE)
 #define NETIF_F_GSO_IPIP	__NETIF_F(GSO_IPIP)
+#define NETIF_F_GSO_SIT		__NETIF_F(GSO_SIT)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_MPLS	__NETIF_F(GSO_MPLS)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6072913..2c15497 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -320,9 +320,11 @@ enum {
 
 	SKB_GSO_IPIP = 1 << 7,
 
-	SKB_GSO_UDP_TUNNEL = 1 << 8,
+	SKB_GSO_SIT = 1 << 8,
 
-	SKB_GSO_MPLS = 1 << 9,
+	SKB_GSO_UDP_TUNNEL = 1 << 9,
+
+	SKB_GSO_MPLS = 1 << 10,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 8cab774..8629898 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -82,6 +82,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
 	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
 	[NETIF_F_GSO_IPIP_BIT] =	 "tx-ipip-segmentation",
+	[NETIF_F_GSO_SIT_BIT] =		 "tx-sit-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
 	[NETIF_F_GSO_MPLS_BIT] =	 "tx-mpls-segmentation",
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9433a61..4028e3e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1265,6 +1265,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
 		       SKB_GSO_IPIP |
+		       SKB_GSO_SIT |
 		       SKB_GSO_TCPV6 |
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_MPLS |
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index dfc96b0..a7a5583e 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -57,6 +57,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			       SKB_GSO_TCPV6 |
 			       SKB_GSO_GRE |
 			       SKB_GSO_IPIP |
+			       SKB_GSO_SIT |
 			       SKB_GSO_MPLS |
 			       SKB_GSO_UDP_TUNNEL |
 			       0) ||
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index f9b33d8..4b85169 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -98,6 +98,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
 		       SKB_GSO_IPIP |
+		       SKB_GSO_SIT |
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_MPLS |
 		       SKB_GSO_TCPV6 |
@@ -276,6 +277,13 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
 	},
 };
 
+static const struct net_offload sit_offload = {
+	.callbacks = {
+		.gso_send_check = ipv6_gso_send_check,
+		.gso_segment	= ipv6_gso_segment,
+	},
+};
+
 static int __init ipv6_offload_init(void)
 {
 
@@ -287,6 +295,9 @@ static int __init ipv6_offload_init(void)
 		pr_crit("%s: Cannot add EXTHDRS protocol offload\n", __func__);
 
 	dev_add_offload(&ipv6_packet_offload);
+
+	inet_add_offload(&sit_offload, IPPROTO_IPV6);
+
 	return 0;
 }
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 1926945..3a9038d 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -933,10 +933,9 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		ttl = iph6->hop_limit;
 	tos = INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
 
-	if (likely(!skb->encapsulation)) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
+	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);
+	if (IS_ERR(skb))
+		goto out;
 
 	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, IPPROTO_IPV6, tos,
 			    ttl, df, !net_eq(tunnel->net, dev_net(dev)));
@@ -946,8 +945,9 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 tx_error_icmp:
 	dst_link_failure(skb);
 tx_error:
-	dev->stats.tx_errors++;
 	dev_kfree_skb(skb);
+out:
+	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
 
@@ -956,13 +956,15 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr  *tiph = &tunnel->parms.iph;
 
-	if (likely(!skb->encapsulation)) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
+	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
+	if (IS_ERR(skb))
+		goto out;
 
 	ip_tunnel_xmit(skb, dev, tiph, IPPROTO_IPIP);
 	return NETDEV_TX_OK;
+out:
+	dev->stats.tx_errors++;
+	return NETDEV_TX_OK;
 }
 
 static netdev_tx_t sit_tunnel_xmit(struct sk_buff *skb,
@@ -1292,6 +1294,12 @@ static void ipip6_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+#define SIT_FEATURES (NETIF_F_SG	   | \
+		      NETIF_F_FRAGLIST	   | \
+		      NETIF_F_HIGHDMA	   | \
+		      NETIF_F_GSO_SOFTWARE | \
+		      NETIF_F_HW_CSUM)
+
 static void ipip6_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		= &ipip6_netdev_ops;
@@ -1305,6 +1313,8 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_LLTX;
+	dev->features		|= SIT_FEATURES;
+	dev->hw_features	|= SIT_FEATURES;
 }
 
 static int ipip6_tunnel_init(struct net_device *dev)
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index f63780f..08e23b0 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -65,6 +65,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 				      SKB_GSO_UDP_TUNNEL |
 				      SKB_GSO_GRE |
 				      SKB_GSO_IPIP |
+				      SKB_GSO_SIT |
 				      SKB_GSO_MPLS) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
-- 
1.8.4
