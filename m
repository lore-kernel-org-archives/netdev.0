From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v2 5/5] bridge: netlink: export per-vlan stats
Date: Thu, 28 Apr 2016 17:52:51 +0200
Message-ID: <1461858771-4732-6-git-send-email-nikolay@cumulusnetworks.com>
References: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36706 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbcD1PxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 11:53:13 -0400
Received: by mail-wm0-f50.google.com with SMTP id n129so70867798wmn.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 08:53:12 -0700 (PDT)
In-Reply-To: <1461858771-4732-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new LINK_XSTATS_TYPE_BRIDGE attribute and implement the
RTM_GETSTATS callbacks for IFLA_STATS_LINK_XSTATS (fill_linkxstats and
get_linkxstats_size) in order to export the per-vlan stats.
The paddings were added because soon these fields will be needed for
per-port per-vlan stats (or something else if someone beats me to it) so
avoiding at least a few more netlink attributes.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: remove unused pvid pointer, fix the case where bridge has 0 vlans
but there're global contexts and move to rtnl link type private
attributes nested into a LINK_XSTATS_TYPE_ attribute. The paddings were
added because soon these fields will be needed for per-port per-vlan
stats (or something else if someone beats me to it) so avoiding at least
a few more netlink attributes.


 include/uapi/linux/if_bridge.h | 18 ++++++++++++
 include/uapi/linux/if_link.h   |  1 +
 net/bridge/br_netlink.c        | 65 ++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h        |  7 +++++
 net/bridge/br_vlan.c           | 27 ++++++++++++++++++
 5 files changed, 118 insertions(+)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 0536eefff9bf..397d503fdedb 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -134,6 +134,16 @@ struct bridge_vlan_info {
 	__u16 vid;
 };
 
+struct bridge_vlan_xstats {
+	__u64 rx_bytes;
+	__u64 rx_packets;
+	__u64 tx_bytes;
+	__u64 tx_packets;
+	__u16 vid;
+	__u16 pad1;
+	__u32 pad2;
+};
+
 /* Bridge multicast database attributes
  * [MDBA_MDB] = {
  *     [MDBA_MDB_ENTRY] = {
@@ -233,4 +243,12 @@ enum {
 };
 #define MDBA_SET_ENTRY_MAX (__MDBA_SET_ENTRY_MAX - 1)
 
+/* Embedded inside LINK_XSTATS_TYPE_BRIDGE */
+enum {
+	BRIDGE_XSTATS_UNSPEC,
+	BRIDGE_XSTATS_VLAN,
+	__BRIDGE_XSTATS_MAX
+};
+#define BRIDGE_XSTATS_MAX (__BRIDGE_XSTATS_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_BRIDGE_H */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8577c0e4116f..fd0621ec9222 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -817,6 +817,7 @@ enum {
  */
 enum {
 	LINK_XSTATS_TYPE_UNSPEC,
+	LINK_XSTATS_TYPE_BRIDGE,
 	__LINK_XSTATS_TYPE_MAX
 };
 #define LINK_XSTATS_TYPE_MAX (__LINK_XSTATS_TYPE_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 9c74fa438a8c..c36bafcad569 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1222,6 +1222,69 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	return 0;
 }
 
+static size_t br_get_linkxstats_size(const struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_vlan_group *vg;
+	struct net_bridge_vlan *v;
+	int numvls = 0;
+
+	vg = br_vlan_group(br);
+	if (!vg)
+		return 0;
+
+	/* we need to count all, even placeholder entries */
+	list_for_each_entry(v, &vg->vlan_list, vlist)
+		numvls++;
+
+	/* account for the vlans and the link xstats type nest attribute */
+	return numvls * nla_total_size(sizeof(struct bridge_vlan_xstats)) +
+	       nla_total_size(0);
+}
+
+static int br_fill_linkxstats(struct sk_buff *skb, const struct net_device *dev,
+			      int *prividx)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_vlan_group *vg;
+	struct net_bridge_vlan *v;
+	struct nlattr *nest;
+	int vl_idx = 0;
+
+	vg = br_vlan_group(br);
+	if (!vg)
+		goto out;
+	nest = nla_nest_start(skb, LINK_XSTATS_TYPE_BRIDGE);
+	if (!nest)
+		return -EMSGSIZE;
+	list_for_each_entry(v, &vg->vlan_list, vlist) {
+		struct bridge_vlan_xstats vxi;
+		struct br_vlan_stats stats;
+
+		if (vl_idx++ < *prividx)
+			continue;
+		memset(&vxi, 0, sizeof(vxi));
+		vxi.vid = v->vid;
+		br_vlan_get_stats(v, &stats);
+		vxi.rx_bytes = stats.rx_bytes;
+		vxi.rx_packets = stats.rx_packets;
+		vxi.tx_bytes = stats.tx_bytes;
+		vxi.tx_packets = stats.tx_packets;
+
+		if (nla_put(skb, BRIDGE_XSTATS_VLAN, sizeof(vxi), &vxi))
+			goto nla_put_failure;
+	}
+	nla_nest_end(skb, nest);
+	*prividx = 0;
+out:
+	return 0;
+
+nla_put_failure:
+	nla_nest_end(skb, nest);
+	*prividx = vl_idx;
+
+	return -EMSGSIZE;
+}
 
 static struct rtnl_af_ops br_af_ops __read_mostly = {
 	.family			= AF_BRIDGE,
@@ -1240,6 +1303,8 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
 	.dellink		= br_dev_delete,
 	.get_size		= br_get_size,
 	.fill_info		= br_fill_info,
+	.fill_linkxstats	= br_fill_linkxstats,
+	.get_linkxstats_size	= br_get_linkxstats_size,
 
 	.slave_maxtype		= IFLA_BRPORT_MAX,
 	.slave_policy		= br_port_policy,
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f6876ed718a5..a10f7ed26f3b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -709,6 +709,8 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
 int nbp_vlan_init(struct net_bridge_port *port);
 int nbp_get_num_vlan_infos(struct net_bridge_port *p, u32 filter_mask);
+void br_vlan_get_stats(const struct net_bridge_vlan *v,
+		       struct br_vlan_stats *stats);
 
 static inline struct net_bridge_vlan_group *br_vlan_group(
 					const struct net_bridge *br)
@@ -876,6 +878,11 @@ static inline struct net_bridge_vlan_group *nbp_vlan_group_rcu(
 {
 	return NULL;
 }
+
+static inline void br_vlan_get_stats(const struct net_bridge_vlan *v,
+				     struct br_vlan_stats *stats)
+{
+}
 #endif
 
 struct nf_br_ops {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index d7a70c2ea3ec..b39d9f5761d9 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -1029,3 +1029,30 @@ void nbp_vlan_flush(struct net_bridge_port *port)
 	synchronize_rcu();
 	__vlan_group_free(vg);
 }
+
+void br_vlan_get_stats(const struct net_bridge_vlan *v,
+		       struct br_vlan_stats *stats)
+{
+	int i;
+
+	memset(stats, 0, sizeof(*stats));
+	for_each_possible_cpu(i) {
+		u64 rxpackets, rxbytes, txpackets, txbytes;
+		struct br_vlan_stats *cpu_stats;
+		unsigned int start;
+
+		cpu_stats = per_cpu_ptr(v->stats, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&cpu_stats->syncp);
+			rxpackets = cpu_stats->rx_packets;
+			rxbytes = cpu_stats->rx_bytes;
+			txbytes = cpu_stats->tx_bytes;
+			txpackets = cpu_stats->tx_packets;
+		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, start));
+
+		stats->rx_packets += rxpackets;
+		stats->rx_bytes += rxbytes;
+		stats->tx_bytes += txbytes;
+		stats->tx_packets += txpackets;
+	}
+}
-- 
2.4.11
