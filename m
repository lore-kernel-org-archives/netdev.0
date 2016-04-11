From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 2/5] GSO: Add GSO type for fixed IPv4 ID
Date: Sun, 10 Apr 2016 21:44:51 -0400
Message-ID: <20160411014451.11189.8100.stgit@ahduyck-xeon-server>
References: <20160411013855.11189.56567.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33960 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbcDKBo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 21:44:56 -0400
Received: by mail-pa0-f50.google.com with SMTP id ot11so27824802pab.1
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 18:44:56 -0700 (PDT)
In-Reply-To: <20160411013855.11189.56567.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for TSO using IPv4 headers with a fixed IP ID
field.  This is meant to allow us to do a lossless GRO in the case of TCP
flows that use a fixed IP ID such as those that convert IPv6 header to IPv4
headers.

In addition I am adding a feature that for now I am referring to TSO with
IP ID mangling.  Basically when this flag is enabled the device has the
option to either output the flow with incrementing IP IDs or with a fixed
IP ID regardless of what the original IP ID ordering was.  This is useful
in cases where the DF bit is set and we do not care if the original IP ID
value is maintained.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/netdev_features.h |    3 +++
 include/linux/netdevice.h       |    1 +
 include/linux/skbuff.h          |   20 +++++++++++---------
 net/core/dev.c                  |   34 +++++++++++++++++++++++++++++-----
 net/core/ethtool.c              |    1 +
 net/ipv4/af_inet.c              |   19 +++++++++++--------
 net/ipv4/gre_offload.c          |    1 +
 net/ipv4/tcp_offload.c          |    4 +++-
 net/ipv6/ip6_offload.c          |    3 ++-
 net/mpls/mpls_gso.c             |    1 +
 10 files changed, 63 insertions(+), 24 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index a734bf43d190..7cf272a4b5c8 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -39,6 +39,7 @@ enum {
 	NETIF_F_UFO_BIT,		/* ... UDPv4 fragmentation */
 	NETIF_F_GSO_ROBUST_BIT,		/* ... ->SKB_GSO_DODGY */
 	NETIF_F_TSO_ECN_BIT,		/* ... TCP ECN support */
+	NETIF_F_TSO_MANGLEID_BIT,	/* ... IPV4 ID mangling allowed */
 	NETIF_F_TSO6_BIT,		/* ... TCPv6 segmentation */
 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
 	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
@@ -120,6 +121,7 @@ enum {
 #define NETIF_F_GSO_SIT		__NETIF_F(GSO_SIT)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
+#define NETIF_F_TSO_MANGLEID	__NETIF_F(TSO_MANGLEID)
 #define NETIF_F_GSO_TUNNEL_REMCSUM __NETIF_F(GSO_TUNNEL_REMCSUM)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
@@ -147,6 +149,7 @@ enum {
 
 /* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
+				 NETIF_F_TSO_MANGLEID | \
 				 NETIF_F_TSO6 | NETIF_F_UFO)
 
 /* List of IP checksum features. Note that NETIF_F_ HW_CSUM should not be
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 347ad5de0d93..eb7f037a4068 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3992,6 +3992,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_UDP     != (NETIF_F_UFO >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_DODGY   != (NETIF_F_GSO_ROBUST >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_ECN != (NETIF_F_TSO_ECN >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_TCP_FIXEDID != (NETIF_F_TSO_MANGLEID >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCPV6   != (NETIF_F_TSO6 >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_FCOE    != (NETIF_F_FSO >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_GRE     != (NETIF_F_GSO_GRE >> NETIF_F_GSO_SHIFT));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 007381270ff8..5fba16658f9d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -465,23 +465,25 @@ enum {
 	/* This indicates the tcp segment has CWR set. */
 	SKB_GSO_TCP_ECN = 1 << 3,
 
-	SKB_GSO_TCPV6 = 1 << 4,
+	SKB_GSO_TCP_FIXEDID = 1 << 4,
 
-	SKB_GSO_FCOE = 1 << 5,
+	SKB_GSO_TCPV6 = 1 << 5,
 
-	SKB_GSO_GRE = 1 << 6,
+	SKB_GSO_FCOE = 1 << 6,
 
-	SKB_GSO_GRE_CSUM = 1 << 7,
+	SKB_GSO_GRE = 1 << 7,
 
-	SKB_GSO_IPIP = 1 << 8,
+	SKB_GSO_GRE_CSUM = 1 << 8,
 
-	SKB_GSO_SIT = 1 << 9,
+	SKB_GSO_IPIP = 1 << 9,
 
-	SKB_GSO_UDP_TUNNEL = 1 << 10,
+	SKB_GSO_SIT = 1 << 10,
 
-	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 11,
+	SKB_GSO_UDP_TUNNEL = 1 << 11,
 
-	SKB_GSO_TUNNEL_REMCSUM = 1 << 12,
+	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 12,
+
+	SKB_GSO_TUNNEL_REMCSUM = 1 << 13,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/core/dev.c b/net/core/dev.c
index 09fb1ace9dc8..e896b1953ab6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2825,14 +2825,36 @@ static netdev_features_t dflt_features_check(const struct sk_buff *skb,
 	return vlan_features_check(skb, features);
 }
 
+static netdev_features_t gso_features_check(const struct sk_buff *skb,
+					    struct net_device *dev,
+					    netdev_features_t features)
+{
+	u16 gso_segs = skb_shinfo(skb)->gso_segs;
+
+	if (gso_segs > dev->gso_max_segs)
+		return features & ~NETIF_F_GSO_MASK;
+
+	/* Make sure to clear the IPv4 ID mangling feature if
+	 * the IPv4 header has the potential to be fragmented.
+	 */
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
+		struct iphdr *iph = skb->encapsulation ?
+				    inner_ip_hdr(skb) : ip_hdr(skb);
+
+		if (!(iph->frag_off & htons(IP_DF)))
+			features &= ~NETIF_F_TSO_MANGLEID;
+	}
+
+	return features;
+}
+
 netdev_features_t netif_skb_features(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	netdev_features_t features = dev->features;
-	u16 gso_segs = skb_shinfo(skb)->gso_segs;
 
-	if (gso_segs > dev->gso_max_segs)
-		features &= ~NETIF_F_GSO_MASK;
+	if (skb_is_gso(skb))
+		features = gso_features_check(skb, dev, features);
 
 	/* If encapsulation offload request, verify we are testing
 	 * hardware encapsulation features instead of standard
@@ -6976,9 +6998,11 @@ int register_netdevice(struct net_device *dev)
 	dev->features |= NETIF_F_SOFT_FEATURES;
 	dev->wanted_features = dev->features & dev->hw_features;
 
-	if (!(dev->flags & IFF_LOOPBACK)) {
+	if (!(dev->flags & IFF_LOOPBACK))
 		dev->hw_features |= NETIF_F_NOCACHE_COPY;
-	}
+
+	if (dev->hw_features & NETIF_F_TSO)
+		dev->hw_features |= NETIF_F_TSO_MANGLEID;
 
 	/* Make NETIF_F_HIGHDMA inheritable to VLAN devices.
 	 */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6a7f99661c2f..9494c41cc77c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -79,6 +79,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_UFO_BIT] =              "tx-udp-fragmentation",
 	[NETIF_F_GSO_ROBUST_BIT] =       "tx-gso-robust",
 	[NETIF_F_TSO_ECN_BIT] =          "tx-tcp-ecn-segmentation",
+	[NETIF_F_TSO_MANGLEID_BIT] =	 "tx-tcp-mangleid-segmentation",
 	[NETIF_F_TSO6_BIT] =             "tx-tcp6-segmentation",
 	[NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
 	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8217cd22f921..5bbea9a0ce96 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1195,10 +1195,10 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
 static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 					netdev_features_t features)
 {
+	bool udpfrag = false, fixedid = false, encap;
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	const struct net_offload *ops;
 	unsigned int offset = 0;
-	bool udpfrag, encap;
 	struct iphdr *iph;
 	int proto;
 	int nhoff;
@@ -1217,6 +1217,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_TCPV6 |
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_UDP_TUNNEL_CSUM |
+		       SKB_GSO_TCP_FIXEDID |
 		       SKB_GSO_TUNNEL_REMCSUM |
 		       0)))
 		goto out;
@@ -1248,11 +1249,14 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
-	if (skb->encapsulation &&
-	    skb_shinfo(skb)->gso_type & (SKB_GSO_SIT|SKB_GSO_IPIP))
-		udpfrag = proto == IPPROTO_UDP && encap;
-	else
-		udpfrag = proto == IPPROTO_UDP && !skb->encapsulation;
+	if (!skb->encapsulation || encap) {
+		udpfrag = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
+		fixedid = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TCP_FIXEDID);
+
+		/* fixed ID is invalid if DF bit is not set */
+		if (fixedid && !(iph->frag_off & htons(IP_DF)))
+			goto out;
+	}
 
 	ops = rcu_dereference(inet_offloads[proto]);
 	if (likely(ops && ops->callbacks.gso_segment))
@@ -1265,12 +1269,11 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	do {
 		iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
 		if (udpfrag) {
-			iph->id = htons(id);
 			iph->frag_off = htons(offset >> 3);
 			if (skb->next)
 				iph->frag_off |= htons(IP_MF);
 			offset += skb->len - nhoff - ihl;
-		} else {
+		} else if (!fixedid) {
 			iph->id = htons(id++);
 		}
 		iph->tot_len = htons(skb->len - nhoff);
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 6a5bd4317866..6376b0cdf693 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -32,6 +32,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_UDP |
 				  SKB_GSO_DODGY |
 				  SKB_GSO_TCP_ECN |
+				  SKB_GSO_TCP_FIXEDID |
 				  SKB_GSO_GRE |
 				  SKB_GSO_GRE_CSUM |
 				  SKB_GSO_IPIP |
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 773083b7f1e9..08dd25d835af 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -89,6 +89,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			     ~(SKB_GSO_TCPV4 |
 			       SKB_GSO_DODGY |
 			       SKB_GSO_TCP_ECN |
+			       SKB_GSO_TCP_FIXEDID |
 			       SKB_GSO_TCPV6 |
 			       SKB_GSO_GRE |
 			       SKB_GSO_GRE_CSUM |
@@ -98,7 +99,8 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			       SKB_GSO_UDP_TUNNEL_CSUM |
 			       SKB_GSO_TUNNEL_REMCSUM |
 			       0) ||
-			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
+			     !(type & (SKB_GSO_TCPV4 |
+				       SKB_GSO_TCPV6))))
 			goto out;
 
 		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 204af2219471..b3a779393d71 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -73,6 +73,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_TCP_FIXEDID |
+		       SKB_GSO_TCPV6 |
 		       SKB_GSO_GRE |
 		       SKB_GSO_GRE_CSUM |
 		       SKB_GSO_IPIP |
@@ -80,7 +82,6 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_UDP_TUNNEL_CSUM |
 		       SKB_GSO_TUNNEL_REMCSUM |
-		       SKB_GSO_TCPV6 |
 		       0)))
 		goto out;
 
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 0183b32da942..bbcf60465e5c 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -31,6 +31,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_TCPV6 |
 				  SKB_GSO_UDP |
 				  SKB_GSO_DODGY |
+				  SKB_GSO_TCP_FIXEDID |
 				  SKB_GSO_TCP_ECN)))
 		goto out;
 
