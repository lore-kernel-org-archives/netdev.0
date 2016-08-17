From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 1/2] net: bridge: consolidate bridge and port linkxstats calls
Date: Wed, 17 Aug 2016 12:53:09 +0200
Message-ID: <1471431190-27442-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1471431190-27442-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36650 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbcHQKx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 06:53:28 -0400
Received: by mail-wm0-f46.google.com with SMTP id q128so192060448wma.1
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 03:53:28 -0700 (PDT)
In-Reply-To: <1471431190-27442-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the bridge driver we usually have the same function working for both
port and bridge. In order to follow that logic and also avoid code
duplication, consolidate the bridge_ and brport_ linkxstats calls into
one since they share most of their code. As a side effect this allows us
to dump the vlan stats also via the slave call which is in preparation for
the upcoming per-port vlan stats and vlan flag dumping.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink.c | 114 +++++++++++++++++-------------------------------
 1 file changed, 39 insertions(+), 75 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index f2a29e467e78..493ab9b3d51a 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1245,14 +1245,30 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	return 0;
 }
 
-static size_t bridge_get_linkxstats_size(const struct net_device *dev)
+static size_t br_get_linkxstats_size(const struct net_device *dev, int attr)
 {
-	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *p = NULL;
 	struct net_bridge_vlan_group *vg;
 	struct net_bridge_vlan *v;
+	struct net_bridge *br;
 	int numvls = 0;
 
-	vg = br_vlan_group(br);
+	switch (attr) {
+	case IFLA_STATS_LINK_XSTATS:
+		br = netdev_priv(dev);
+		vg = br_vlan_group(br);
+		break;
+	case IFLA_STATS_LINK_XSTATS_SLAVE:
+		p = br_port_get_rtnl(dev);
+		if (!p)
+			return 0;
+		br = p->br;
+		vg = nbp_vlan_group(p);
+		break;
+	default:
+		return 0;
+	}
+
 	if (vg) {
 		/* we need to count all, even placeholder entries */
 		list_for_each_entry(v, &vg->vlan_list, vlist)
@@ -1264,44 +1280,38 @@ static size_t bridge_get_linkxstats_size(const struct net_device *dev)
 	       nla_total_size(0);
 }
 
-static size_t brport_get_linkxstats_size(const struct net_device *dev)
-{
-	return nla_total_size(sizeof(struct br_mcast_stats)) +
-	       nla_total_size(0);
-}
-
-static size_t br_get_linkxstats_size(const struct net_device *dev, int attr)
+static int br_fill_linkxstats(struct sk_buff *skb,
+			      const struct net_device *dev,
+			      int *prividx, int attr)
 {
-	size_t retsize = 0;
+	struct nlattr *nla __maybe_unused;
+	struct net_bridge_port *p = NULL;
+	struct net_bridge_vlan_group *vg;
+	struct net_bridge_vlan *v;
+	struct net_bridge *br;
+	struct nlattr *nest;
+	int vl_idx = 0;
 
 	switch (attr) {
 	case IFLA_STATS_LINK_XSTATS:
-		retsize = bridge_get_linkxstats_size(dev);
+		br = netdev_priv(dev);
+		vg = br_vlan_group(br);
 		break;
 	case IFLA_STATS_LINK_XSTATS_SLAVE:
-		retsize = brport_get_linkxstats_size(dev);
+		p = br_port_get_rtnl(dev);
+		if (!p)
+			return 0;
+		br = p->br;
+		vg = nbp_vlan_group(p);
 		break;
+	default:
+		return -EINVAL;
 	}
 
-	return retsize;
-}
-
-static int bridge_fill_linkxstats(struct sk_buff *skb,
-				  const struct net_device *dev,
-				  int *prividx)
-{
-	struct net_bridge *br = netdev_priv(dev);
-	struct nlattr *nla __maybe_unused;
-	struct net_bridge_vlan_group *vg;
-	struct net_bridge_vlan *v;
-	struct nlattr *nest;
-	int vl_idx = 0;
-
 	nest = nla_nest_start(skb, LINK_XSTATS_TYPE_BRIDGE);
 	if (!nest)
 		return -EMSGSIZE;
 
-	vg = br_vlan_group(br);
 	if (vg) {
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			struct bridge_vlan_xstats vxi;
@@ -1329,7 +1339,7 @@ static int bridge_fill_linkxstats(struct sk_buff *skb,
 					BRIDGE_XSTATS_PAD);
 		if (!nla)
 			goto nla_put_failure;
-		br_multicast_get_stats(br, NULL, nla_data(nla));
+		br_multicast_get_stats(br, p, nla_data(nla));
 	}
 #endif
 	nla_nest_end(skb, nest);
@@ -1344,52 +1354,6 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int brport_fill_linkxstats(struct sk_buff *skb,
-				  const struct net_device *dev,
-				  int *prividx)
-{
-	struct net_bridge_port *p = br_port_get_rtnl(dev);
-	struct nlattr *nla __maybe_unused;
-	struct nlattr *nest;
-
-	if (!p)
-		return 0;
-
-	nest = nla_nest_start(skb, LINK_XSTATS_TYPE_BRIDGE);
-	if (!nest)
-		return -EMSGSIZE;
-#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
-	nla = nla_reserve_64bit(skb, BRIDGE_XSTATS_MCAST,
-				sizeof(struct br_mcast_stats),
-				BRIDGE_XSTATS_PAD);
-	if (!nla) {
-		nla_nest_end(skb, nest);
-		return -EMSGSIZE;
-	}
-	br_multicast_get_stats(p->br, p, nla_data(nla));
-#endif
-	nla_nest_end(skb, nest);
-
-	return 0;
-}
-
-static int br_fill_linkxstats(struct sk_buff *skb, const struct net_device *dev,
-			      int *prividx, int attr)
-{
-	int ret = -EINVAL;
-
-	switch (attr) {
-	case IFLA_STATS_LINK_XSTATS:
-		ret = bridge_fill_linkxstats(skb, dev, prividx);
-		break;
-	case IFLA_STATS_LINK_XSTATS_SLAVE:
-		ret = brport_fill_linkxstats(skb, dev, prividx);
-		break;
-	}
-
-	return ret;
-}
-
 static struct rtnl_af_ops br_af_ops __read_mostly = {
 	.family			= AF_BRIDGE,
 	.get_link_af_size	= br_get_link_af_size_filtered,
-- 
2.1.4
