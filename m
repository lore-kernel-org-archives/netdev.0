From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v8 08/11] vxlan: add ipv6 route short circuit support
Date: Fri, 17 May 2013 08:21:36 +0800
Message-ID: <1368750099-14086-9-git-send-email-amwang@redhat.com>
References: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222Ab3EQAXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 20:23:52 -0400
In-Reply-To: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

route short circuit only has IPv4 part, this patch adds
the IPv6 part.

Cc: David S. Miller <davem@davemloft.net>
Cc: David Stevens <dlstevens@us.ibm.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1ee79e0..04fd499 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -995,7 +995,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct neighbour *n;
-	struct iphdr *pip;
 
 	if (is_multicast_ether_addr(eth_hdr(skb)->h_dest))
 		return false;
@@ -1003,6 +1002,9 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	n = NULL;
 	switch (ntohs(eth_hdr(skb)->h_proto)) {
 	case ETH_P_IP:
+	{
+		struct iphdr *pip;
+
 		if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 			return false;
 		pip = ip_hdr(skb);
@@ -1016,6 +1018,27 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
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
+		n = neigh_lookup(&nd_tbl, &pip6->daddr, dev);
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
@@ -1394,7 +1417,8 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	did_rsc = false;
 
 	if (f && (f->flags & NTF_ROUTER) && (vxlan->flags & VXLAN_F_RSC) &&
-	    ntohs(eth->h_proto) == ETH_P_IP) {
+	    (ntohs(eth->h_proto) == ETH_P_IP ||
+	     ntohs(eth->h_proto) == ETH_P_IPV6)) {
 		did_rsc = route_shortcircuit(dev, skb);
 		if (did_rsc)
 			f = vxlan_find_mac(vxlan, eth->h_dest);
-- 
1.7.7.6
