From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 14/14] ip4ip6: Support for GSO/GRO
Date: Wed, 4 May 2016 18:02:44 -0700
Message-ID: <1462410164-1953217-15-git-send-email-tom@herbertland.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55411 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755493AbcEEBDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 21:03:05 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4511dS4007162
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 18:03:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22qtqergn9-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 04 May 2016 18:03:04 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1eb90404125d11e6b1ad0002c9dfb610-b2eeac50 for <netdev@vger.kernel.org>;	Wed,
 04 May 2016 18:03:03 -0700
In-Reply-To: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdev_features.h |  5 ++++-
 include/linux/netdevice.h       |  1 +
 include/linux/skbuff.h          |  2 ++
 include/net/inet_common.h       |  5 +++++
 net/ipv4/af_inet.c              | 12 +++++++-----
 net/ipv6/ip6_offload.c          | 33 ++++++++++++++++++++++++++++++++-
 net/ipv6/ip6_tunnel.c           |  5 ++++-
 7 files changed, 55 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index db52030..d30ea91 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -54,8 +54,9 @@ enum {
 					 */
 	NETIF_F_GSO_TUNNEL_REMCSUM_BIT, /* ... TUNNEL with TSO & REMCSUM */
 	NETIF_F_GSO_IP6IP6_BIT,		/* ... IP6IP6 tunnel with TSO */
+	NETIF_F_GSO_IP4IP6_BIT,		/* ... IP4IP6 tunnel with TSO */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_IP6IP6_BIT,
+		NETIF_F_GSO_IP4IP6_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CRC_BIT,		/* SCTP checksum offload */
@@ -125,6 +126,7 @@ enum {
 #define NETIF_F_GSO_IPIP	__NETIF_F(GSO_IPIP)
 #define NETIF_F_GSO_IP6IP6	__NETIF_F(GSO_IP6IP6)
 #define NETIF_F_GSO_SIT		__NETIF_F(GSO_SIT)
+#define NETIF_F_GSO_IP4IP6	__NETIF_F(GSO_IP4IP6)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
 #define NETIF_F_TSO_MANGLEID	__NETIF_F(TSO_MANGLEID)
@@ -204,6 +206,7 @@ enum {
 				 NETIF_F_GSO_GRE_CSUM |			\
 				 NETIF_F_GSO_IPIP |			\
 				 NETIF_F_GSO_IP6IP6 |			\
+				 NETIF_F_GSO_IP4IP6 |			\
 				 NETIF_F_GSO_SIT |			\
 				 NETIF_F_GSO_UDP_TUNNEL |		\
 				 NETIF_F_GSO_UDP_TUNNEL_CSUM)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 724b9d5..4fa678a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4006,6 +4006,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_GRE_CSUM != (NETIF_F_GSO_GRE_CSUM >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_IPIP    != (NETIF_F_GSO_IPIP >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_IP6IP6  != (NETIF_F_GSO_IP6IP6 >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_IP4IP6  != (NETIF_F_GSO_IP4IP6 >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_SIT     != (NETIF_F_GSO_SIT >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 928b456..6a811fa 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -484,6 +484,8 @@ enum {
 	SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
 
 	SKB_GSO_IP6IP6 = 1 << 15,
+
+	SKB_GSO_IP4IP6 = 1 << 16,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 109e3ee..5d68342 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -39,6 +39,11 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 int inet_recv_error(struct sock *sk, struct msghdr *msg, int len,
 		    int *addr_len);
 
+struct sk_buff **inet_gro_receive(struct sk_buff **head, struct sk_buff *skb);
+int inet_gro_complete(struct sk_buff *skb, int nhoff);
+struct sk_buff *inet_gso_segment(struct sk_buff *skb,
+				 netdev_features_t features);
+
 static inline void inet_ctl_sock_destroy(struct sock *sk)
 {
 	if (sk)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7f08d45..9d2bf87 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1192,8 +1192,8 @@ int inet_sk_rebuild_header(struct sock *sk)
 }
 EXPORT_SYMBOL(inet_sk_rebuild_header);
 
-static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
-					netdev_features_t features)
+struct sk_buff *inet_gso_segment(struct sk_buff *skb,
+				 netdev_features_t features)
 {
 	bool udpfrag = false, fixedid = false, encap;
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
@@ -1280,9 +1280,9 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 out:
 	return segs;
 }
+EXPORT_SYMBOL(inet_gso_segment);
 
-static struct sk_buff **inet_gro_receive(struct sk_buff **head,
-					 struct sk_buff *skb)
+struct sk_buff **inet_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
 	const struct net_offload *ops;
 	struct sk_buff **pp = NULL;
@@ -1398,6 +1398,7 @@ out:
 
 	return pp;
 }
+EXPORT_SYMBOL(inet_gro_receive);
 
 static struct sk_buff **ipip_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
@@ -1449,7 +1450,7 @@ int inet_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	return -EINVAL;
 }
 
-static int inet_gro_complete(struct sk_buff *skb, int nhoff)
+int inet_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	__be16 newlen = htons(skb->len - nhoff);
 	struct iphdr *iph = (struct iphdr *)(skb->data + nhoff);
@@ -1479,6 +1480,7 @@ out_unlock:
 
 	return err;
 }
+EXPORT_SYMBOL(inet_gro_complete);
 
 static int ipip_gro_complete(struct sk_buff *skb, int nhoff)
 {
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index cea42ad..507f701 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -16,6 +16,7 @@
 
 #include <net/protocol.h>
 #include <net/ipv6.h>
+#include <net/inet_common.h>
 
 #include "ip6_offload.h"
 
@@ -269,6 +270,21 @@ static struct sk_buff **sit_ip6ip6_gro_receive(struct sk_buff **head,
 	return ipv6_gro_receive(head, skb);
 }
 
+static struct sk_buff **ip4ip6_gro_receive(struct sk_buff **head,
+					   struct sk_buff *skb)
+{
+	/* Common GRO receive for SIT and IP6IP6 */
+
+	if (NAPI_GRO_CB(skb)->encap_mark) {
+		NAPI_GRO_CB(skb)->flush = 1;
+		return NULL;
+	}
+
+	NAPI_GRO_CB(skb)->encap_mark = 1;
+
+	return inet_gro_receive(head, skb);
+}
+
 static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	const struct net_offload *ops;
@@ -308,6 +324,13 @@ static int ip6ip6_gro_complete(struct sk_buff *skb, int nhoff)
 	return ipv6_gro_complete(skb, nhoff);
 }
 
+static int ip4ip6_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	skb->encapsulation = 1;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_IP4IP6;
+	return inet_gro_complete(skb, nhoff);
+}
+
 static struct packet_offload ipv6_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
 	.callbacks = {
@@ -325,6 +348,14 @@ static const struct net_offload sit_offload = {
 	},
 };
 
+static const struct net_offload ip4ip6_offload = {
+	.callbacks = {
+		.gso_segment	= inet_gso_segment,
+		.gro_receive    = ip4ip6_gro_receive,
+		.gro_complete   = ip4ip6_gro_complete,
+	},
+};
+
 static const struct net_offload ip6ip6_offload = {
 	.callbacks = {
 		.gso_segment	= ipv6_gso_segment,
@@ -332,7 +363,6 @@ static const struct net_offload ip6ip6_offload = {
 		.gro_complete   = ip6ip6_gro_complete,
 	},
 };
-
 static int __init ipv6_offload_init(void)
 {
 
@@ -345,6 +375,7 @@ static int __init ipv6_offload_init(void)
 
 	inet_add_offload(&sit_offload, IPPROTO_IPV6);
 	inet6_add_offload(&ip6ip6_offload, IPPROTO_IPV6);
+	inet6_add_offload(&ip4ip6_offload, IPPROTO_IPIP);
 
 	return 0;
 }
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 0d01cef..7ad31b6 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -897,7 +897,7 @@ drop:
 
 static int ip4ip6_rcv(struct sk_buff *skb)
 {
-	return ipxip6_rcv(skb, IPPROTO_IP, &tpi_v4,
+	return ipxip6_rcv(skb, IPPROTO_IPIP, &tpi_v4,
 			  ip4ip6_dscp_ecn_decapsulate);
 }
 
@@ -1187,6 +1187,9 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fl6.flowi6_mark = skb->mark;
 
+	if (iptunnel_handle_offloads(skb, SKB_GSO_IP4IP6))
+		return -1;
+
 	err = ip6_tnl_xmit(skb, dev, dsfield, &fl6, encap_limit, &mtu,
 			   IPPROTO_IPIP);
 	if (err != 0) {
-- 
2.8.0.rc2
