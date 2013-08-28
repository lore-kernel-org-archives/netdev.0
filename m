From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v10 07/11] vxlan: add ipv6 route short circuit support
Date: Wed, 28 Aug 2013 13:22:55 +0800
Message-ID: <1377667379-2315-8-git-send-email-amwang@redhat.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39960 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669Ab3H1FZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 01:25:00 -0400
In-Reply-To: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

route short circuit only has IPv4 part, this patch adds
the IPv6 part. nd_tbl will be needed.

Cc: David S. Miller <davem@davemloft.net>
Cc: David Stevens <dlstevens@us.ibm.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c    |   28 ++++++++++++++++++++++++++--
 include/net/addrconf.h |    1 +
 net/ipv6/af_inet6.c    |    1 +
 3 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 717c6e3..79eb09c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1198,7 +1198,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct neighbour *n;
-	struct iphdr *pip;
 
 	if (is_multicast_ether_addr(eth_hdr(skb)->h_dest))
 		return false;
@@ -1206,6 +1205,9 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	n = NULL;
 	switch (ntohs(eth_hdr(skb)->h_proto)) {
 	case ETH_P_IP:
+	{
+		struct iphdr *pip;
+
 		if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 			return false;
 		pip = ip_hdr(skb);
@@ -1219,6 +1221,27 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 		}
 
 		break;
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	case ETH_P_IPV6:
+	{
+		struct ipv6hdr *pip6;
+
+		if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+			return false;
+		pip6 = ipv6_hdr(skb);
+		n = neigh_lookup(ipv6_stub->nd_tbl, &pip6->daddr, dev);
+		if (!n && vxlan->flags & VXLAN_F_L3MISS) {
+			union vxlan_addr ipa;
+			ipa.sin6.sin6_addr = pip6->daddr;
+			ipa.sa.sa_family = AF_INET6;
+			vxlan_ip_miss(dev, &ipa);
+			return false;
+		}
+
+		break;
+	}
+#endif
 	default:
 		return false;
 	}
@@ -1655,7 +1678,8 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	did_rsc = false;
 
 	if (f && (f->flags & NTF_ROUTER) && (vxlan->flags & VXLAN_F_RSC) &&
-	    ntohs(eth->h_proto) == ETH_P_IP) {
+	    (ntohs(eth->h_proto) == ETH_P_IP ||
+	     ntohs(eth->h_proto) == ETH_P_IPV6)) {
 		did_rsc = route_shortcircuit(dev, skb);
 		if (did_rsc)
 			f = vxlan_find_mac(vxlan, eth->h_dest);
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 5339cab..bcf9573 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -153,6 +153,7 @@ struct ipv6_stub {
 	int (*ipv6_dst_lookup)(struct sock *sk, struct dst_entry **dst,
 				struct flowi6 *fl6);
 	void (*udpv6_encap_enable)(void);
+	struct neigh_table *nd_tbl;
 };
 extern const struct ipv6_stub *ipv6_stub __read_mostly;
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 0c9c22f..1996a7c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -815,6 +815,7 @@ static const struct ipv6_stub ipv6_stub_impl = {
 	.ipv6_sock_mc_drop = ipv6_sock_mc_drop,
 	.ipv6_dst_lookup = ip6_dst_lookup,
 	.udpv6_encap_enable = udpv6_encap_enable,
+	.nd_tbl	= &nd_tbl,
 };
 
 static int __init inet6_init(void)
-- 
1.7.7.6
