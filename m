From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 13/14] ip6ip6: Support for GSO/GRO
Date: Wed, 4 May 2016 18:02:43 -0700
Message-ID: <1462410164-1953217-14-git-send-email-tom@herbertland.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55971 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755461AbcEEBDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 21:03:04 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4510tj4028826
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 18:03:04 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22qv3w80qc-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 04 May 2016 18:03:04 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1e4127d6125d11e6b1ad0002c9dfb610-b2eeac50 for <netdev@vger.kernel.org>;	Wed,
 04 May 2016 18:03:03 -0700
In-Reply-To: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdev_features.h |  5 ++++-
 include/linux/netdevice.h       |  1 +
 include/linux/skbuff.h          |  2 ++
 net/core/ethtool.c              |  1 +
 net/ipv6/ip6_offload.c          | 27 +++++++++++++++++++++++----
 net/ipv6/ip6_tunnel.c           |  3 +++
 6 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index bc87362..db52030 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -53,8 +53,9 @@ enum {
 					 *     headers in software.
 					 */
 	NETIF_F_GSO_TUNNEL_REMCSUM_BIT, /* ... TUNNEL with TSO & REMCSUM */
+	NETIF_F_GSO_IP6IP6_BIT,		/* ... IP6IP6 tunnel with TSO */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_TUNNEL_REMCSUM_BIT,
+		NETIF_F_GSO_IP6IP6_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CRC_BIT,		/* SCTP checksum offload */
@@ -122,6 +123,7 @@ enum {
 #define NETIF_F_GSO_GRE		__NETIF_F(GSO_GRE)
 #define NETIF_F_GSO_GRE_CSUM	__NETIF_F(GSO_GRE_CSUM)
 #define NETIF_F_GSO_IPIP	__NETIF_F(GSO_IPIP)
+#define NETIF_F_GSO_IP6IP6	__NETIF_F(GSO_IP6IP6)
 #define NETIF_F_GSO_SIT		__NETIF_F(GSO_SIT)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
@@ -201,6 +203,7 @@ enum {
 #define NETIF_F_GSO_ENCAP_ALL	(NETIF_F_GSO_GRE |			\
 				 NETIF_F_GSO_GRE_CSUM |			\
 				 NETIF_F_GSO_IPIP |			\
+				 NETIF_F_GSO_IP6IP6 |			\
 				 NETIF_F_GSO_SIT |			\
 				 NETIF_F_GSO_UDP_TUNNEL |		\
 				 NETIF_F_GSO_UDP_TUNNEL_CSUM)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f218259..724b9d5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4005,6 +4005,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_GRE     != (NETIF_F_GSO_GRE >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_GRE_CSUM != (NETIF_F_GSO_GRE_CSUM >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_IPIP    != (NETIF_F_GSO_IPIP >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_IP6IP6  != (NETIF_F_GSO_IP6IP6 >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_SIT     != (NETIF_F_GSO_SIT >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c413c58..928b456 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -482,6 +482,8 @@ enum {
 	SKB_GSO_PARTIAL = 1 << 13,
 
 	SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
+
+	SKB_GSO_IP6IP6 = 1 << 15,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index bdb4013..a6a6dde 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -85,6 +85,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
 	[NETIF_F_GSO_GRE_CSUM_BIT] =	 "tx-gre-csum-segmentation",
 	[NETIF_F_GSO_IPIP_BIT] =	 "tx-ipip-segmentation",
+	[NETIF_F_GSO_IP6IP6_BIT] =	 "tx-ip6ip6-segmentation",
 	[NETIF_F_GSO_SIT_BIT] =		 "tx-sit-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] = "tx-udp_tnl-csum-segmentation",
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 9ad743b..cea42ad 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -86,7 +86,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
 
 	if (skb->encapsulation &&
-	    skb_shinfo(skb)->gso_type & (SKB_GSO_SIT|SKB_GSO_IPIP))
+	    skb_shinfo(skb)->gso_type & (SKB_GSO_SIT | SKB_GSO_IPIP |
+					 SKB_GSO_IP6IP6))
 		udpfrag = proto == IPPROTO_UDP && encap;
 	else
 		udpfrag = proto == IPPROTO_UDP && !skb->encapsulation;
@@ -253,9 +254,11 @@ out:
 	return pp;
 }
 
-static struct sk_buff **sit_gro_receive(struct sk_buff **head,
-					struct sk_buff *skb)
+static struct sk_buff **sit_ip6ip6_gro_receive(struct sk_buff **head,
+					       struct sk_buff *skb)
 {
+	/* Common GRO receive for SIT and IP6IP6 */
+
 	if (NAPI_GRO_CB(skb)->encap_mark) {
 		NAPI_GRO_CB(skb)->flush = 1;
 		return NULL;
@@ -298,6 +301,13 @@ static int sit_gro_complete(struct sk_buff *skb, int nhoff)
 	return ipv6_gro_complete(skb, nhoff);
 }
 
+static int ip6ip6_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	skb->encapsulation = 1;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_IP6IP6;
+	return ipv6_gro_complete(skb, nhoff);
+}
+
 static struct packet_offload ipv6_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
 	.callbacks = {
@@ -310,11 +320,19 @@ static struct packet_offload ipv6_packet_offload __read_mostly = {
 static const struct net_offload sit_offload = {
 	.callbacks = {
 		.gso_segment	= ipv6_gso_segment,
-		.gro_receive    = sit_gro_receive,
+		.gro_receive    = sit_ip6ip6_gro_receive,
 		.gro_complete   = sit_gro_complete,
 	},
 };
 
+static const struct net_offload ip6ip6_offload = {
+	.callbacks = {
+		.gso_segment	= ipv6_gso_segment,
+		.gro_receive    = sit_ip6ip6_gro_receive,
+		.gro_complete   = ip6ip6_gro_complete,
+	},
+};
+
 static int __init ipv6_offload_init(void)
 {
 
@@ -326,6 +344,7 @@ static int __init ipv6_offload_init(void)
 	dev_add_offload(&ipv6_packet_offload);
 
 	inet_add_offload(&sit_offload, IPPROTO_IPV6);
+	inet6_add_offload(&ip6ip6_offload, IPPROTO_IPV6);
 
 	return 0;
 }
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 0e72af4..0d01cef 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1241,6 +1241,9 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
+	if (iptunnel_handle_offloads(skb, SKB_GSO_IP6IP6))
+		return -1;
+
 	err = ip6_tnl_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
 			   IPPROTO_IPV6);
 	if (err != 0) {
-- 
2.8.0.rc2
