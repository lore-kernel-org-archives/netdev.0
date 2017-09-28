From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net 2/2] udp: perform source validation for mcast early demux
Date: Thu, 28 Sep 2017 15:51:37 +0200
Message-ID: <0d35fa02ae19d561a5841b5904efe28c7e4341ce.1506606381.git.pabeni@redhat.com>
References: <cover.1506606381.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58816 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753151AbdI1Nwi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 09:52:38 -0400
In-Reply-To: <cover.1506606381.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UDP early demux can leverate the rx dst cache even for
multicast unconnected sockets.

In such scenario the ipv4 source address is validated only on
the first packet in the given flow. After that, when we fetch
the dst entry  from the socket rx cache, we stop enforcing
the rp_filter and we even start accepting any kind of martian
addresses.

Disabling the dst cache for unconnected multicast socket will
cause large performace regression, nearly reducing by half the
max ingress tput.

Instead we factor out a route helper to completely validate an
skb source address for multicast packets and we call it from
the UDP early demux for mcast packets landing on unconnected
sockets, after successful fetching the related cached dst entry.

This still gives a measurable, but limited performance
regression:

		rp_filter = 0		rp_filter = 1
edmux disabled:	1182 Kpps		1127 Kpps
edmux before:	2238 Kpps		2238 Kpps
edmux after:	2037 Kpps		2019 Kpps

The above figures are on top of current net tree.
Applying the net-next commit 6e617de84e87 ("net: avoid a full
fib lookup when rp_filter is disabled.") the delta with
rp_filter == 0 will decrease even more.

Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/route.h |  4 +++-
 net/ipv4/route.c    | 46 ++++++++++++++++++++++++++--------------------
 net/ipv4/udp.c      | 13 ++++++++++++-
 3 files changed, 41 insertions(+), 22 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 57dfc6850d37..d538e6db1afe 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -175,7 +175,9 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
 	fl4->fl4_gre_key = gre_key;
 	return ip_route_output_key(net, fl4);
 }
-
+int ip_mc_validate_source(struct sk_buff *skb, __be32 daddr, __be32 saddr,
+			  u8 tos, struct net_device *dev,
+			  struct in_device *in_dev, u32 *itag);
 int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
 			 u8 tos, struct net_device *devin);
 int ip_route_input_rcu(struct sk_buff *skb, __be32 dst, __be32 src,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 94d4cd2d5ea4..ac6fde5d45f1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1520,43 +1520,56 @@ struct rtable *rt_dst_alloc(struct net_device *dev,
 EXPORT_SYMBOL(rt_dst_alloc);
 
 /* called in rcu_read_lock() section */
-static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-				u8 tos, struct net_device *dev, int our)
+int ip_mc_validate_source(struct sk_buff *skb, __be32 daddr, __be32 saddr,
+			  u8 tos, struct net_device *dev,
+			  struct in_device *in_dev, u32 *itag)
 {
-	struct rtable *rth;
-	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	unsigned int flags = RTCF_MULTICAST;
-	u32 itag = 0;
 	int err;
 
 	/* Primary sanity checks. */
-
 	if (!in_dev)
 		return -EINVAL;
 
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr) ||
 	    skb->protocol != htons(ETH_P_IP))
-		goto e_inval;
+		return -EINVAL;
 
 	if (ipv4_is_loopback(saddr) && !IN_DEV_ROUTE_LOCALNET(in_dev))
-		goto e_inval;
+		return -EINVAL;
 
 	if (ipv4_is_zeronet(saddr)) {
 		if (!ipv4_is_local_multicast(daddr))
-			goto e_inval;
+			return -EINVAL;
 	} else {
 		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
-					  in_dev, &itag);
+					  in_dev, itag);
 		if (err < 0)
-			goto e_err;
+			return err;
 	}
+	return 0;
+}
+
+/* called in rcu_read_lock() section */
+static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
+			     u8 tos, struct net_device *dev, int our)
+{
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	unsigned int flags = RTCF_MULTICAST;
+	struct rtable *rth;
+	u32 itag = 0;
+	int err;
+
+	err = ip_mc_validate_source(skb, daddr, saddr, tos, dev, in_dev, &itag);
+	if (err)
+		return err;
+
 	if (our)
 		flags |= RTCF_LOCAL;
 
 	rth = rt_dst_alloc(dev_net(dev)->loopback_dev, flags, RTN_MULTICAST,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, false);
 	if (!rth)
-		goto e_nobufs;
+		return -ENOBUFS;
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
@@ -1572,13 +1585,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	skb_dst_set(skb, &rth->dst);
 	return 0;
-
-e_nobufs:
-	return -ENOBUFS;
-e_inval:
-	return -EINVAL;
-e_err:
-	return err;
 }
 
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9b30f821fe96..5676237d2b0f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2224,6 +2224,7 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 int udp_v4_early_demux(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
+	struct in_device *in_dev = NULL;
 	const struct iphdr *iph;
 	const struct udphdr *uh;
 	struct sock *sk = NULL;
@@ -2241,7 +2242,7 @@ int udp_v4_early_demux(struct sk_buff *skb)
 
 	if (skb->pkt_type == PACKET_BROADCAST ||
 	    skb->pkt_type == PACKET_MULTICAST) {
-		struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
+		in_dev = __in_dev_get_rcu(skb->dev);
 
 		if (!in_dev)
 			return 0;
@@ -2272,11 +2273,21 @@ int udp_v4_early_demux(struct sk_buff *skb)
 	if (dst)
 		dst = dst_check(dst, 0);
 	if (dst) {
+		u32 itag = 0;
+
 		/* set noref for now.
 		 * any place which wants to hold dst has to call
 		 * dst_hold_safe()
 		 */
 		skb_dst_set_noref(skb, dst);
+
+		/* for unconnected multicast sockets we need to validate
+		 * the source on each packet
+		 */
+		if (!inet_sk(sk)->inet_daddr && in_dev)
+			return ip_mc_validate_source(skb, iph->daddr,
+						     iph->saddr, iph->tos,
+						     skb->dev, in_dev, &itag);
 	}
 	return 0;
 }
-- 
2.13.5
