From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 12/13] net/core: Add reading VF statistics through the PF netdevice
Date: Mon, 15 Jun 2015 17:59:07 +0300
Message-ID: <1434380348-19005-13-git-send-email-ogerlitz@mellanox.com>
References: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44978 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755892AbbFOO7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 10:59:46 -0400
In-Reply-To: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Add ndo_get_vf_stats where the PF retrieves and fills the VFs traffic
statistics. We encode the VF stats in a nested manner to allow for
future extensions.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/if_link.h      |    9 +++++++
 include/linux/netdevice.h    |    4 +++
 include/uapi/linux/if_link.h |   13 ++++++++++
 net/core/rtnetlink.c         |   51 ++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index da49299..ae5d0d2 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -5,6 +5,15 @@
 
 
 /* We don't want this structure exposed to user space */
+struct ifla_vf_stats {
+	__u64 rx_packets;
+	__u64 tx_packets;
+	__u64 rx_bytes;
+	__u64 tx_bytes;
+	__u64 broadcast;
+	__u64 multicast;
+};
+
 struct ifla_vf_info {
 	__u32 vf;
 	__u8 mac[32];
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6f5f71f..e20979d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1100,6 +1100,10 @@ struct net_device_ops {
 						     struct ifla_vf_info *ivf);
 	int			(*ndo_set_vf_link_state)(struct net_device *dev,
 							 int vf, int link_state);
+	int			(*ndo_get_vf_stats)(struct net_device *dev,
+						    int vf,
+						    struct ifla_vf_stats
+						    *vf_stats);
 	int			(*ndo_set_vf_port)(struct net_device *dev,
 						   int vf,
 						   struct nlattr *port[]);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 1737b7a..9db1461 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -482,6 +482,7 @@ enum {
 	IFLA_VF_RSS_QUERY_EN,	/* RSS Redirection Table and Hash Key query
 				 * on/off switch
 				 */
+	IFLA_VF_STATS,		/* network device statistics */
 	__IFLA_VF_MAX,
 };
 
@@ -531,6 +532,18 @@ struct ifla_vf_rss_query_en {
 	__u32 setting;
 };
 
+enum {
+	IFLA_VF_STATS_RX_PACKETS,
+	IFLA_VF_STATS_TX_PACKETS,
+	IFLA_VF_STATS_RX_BYTES,
+	IFLA_VF_STATS_TX_BYTES,
+	IFLA_VF_STATS_BROADCAST,
+	IFLA_VF_STATS_MULTICAST,
+	__IFLA_VF_STATS_MAX,
+};
+
+#define IFLA_VF_STATS_MAX (__IFLA_VF_STATS_MAX - 1)
+
 /* VF ports management section
  *
  *	Nested layout of set/get msg is:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 077b6d2..2d102ce 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -819,7 +819,19 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
 			 nla_total_size(sizeof(struct ifla_vf_rate)) +
 			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
-			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)));
+			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)) +
+			 /* IFLA_VF_STATS_RX_PACKETS */
+			 nla_total_size(sizeof(__u64)) +
+			 /* IFLA_VF_STATS_TX_PACKETS */
+			 nla_total_size(sizeof(__u64)) +
+			 /* IFLA_VF_STATS_RX_BYTES */
+			 nla_total_size(sizeof(__u64)) +
+			 /* IFLA_VF_STATS_TX_BYTES */
+			 nla_total_size(sizeof(__u64)) +
+			 /* IFLA_VF_STATS_BROADCAST */
+			 nla_total_size(sizeof(__u64)) +
+			 /* IFLA_VF_STATS_MULTICAST */
+			 nla_total_size(sizeof(__u64)));
 		return size;
 	} else
 		return 0;
@@ -1123,7 +1135,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    && (ext_filter_mask & RTEXT_FILTER_VF)) {
 		int i;
 
-		struct nlattr *vfinfo, *vf;
+		struct nlattr *vfinfo, *vf, *vfstats;
 		int num_vfs = dev_num_vf(dev->dev.parent);
 
 		vfinfo = nla_nest_start(skb, IFLA_VFINFO_LIST);
@@ -1138,6 +1150,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_spoofchk vf_spoofchk;
 			struct ifla_vf_link_state vf_linkstate;
 			struct ifla_vf_rss_query_en vf_rss_query_en;
+			struct ifla_vf_stats vf_stats;
 
 			/*
 			 * Not all SR-IOV capable drivers support the
@@ -1190,6 +1203,30 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				    sizeof(vf_rss_query_en),
 				    &vf_rss_query_en))
 				goto nla_put_failure;
+			memset(&vf_stats, 0, sizeof(vf_stats));
+			if (dev->netdev_ops->ndo_get_vf_stats)
+				dev->netdev_ops->ndo_get_vf_stats(dev, i,
+								  &vf_stats);
+			vfstats = nla_nest_start(skb, IFLA_VF_STATS);
+			if (!vfstats) {
+				nla_nest_cancel(skb, vf);
+				nla_nest_cancel(skb, vfinfo);
+				goto nla_put_failure;
+			}
+			if (nla_put_u64(skb, IFLA_VF_STATS_RX_PACKETS,
+					vf_stats.rx_packets) ||
+			    nla_put_u64(skb, IFLA_VF_STATS_TX_PACKETS,
+					vf_stats.tx_packets) ||
+			    nla_put_u64(skb, IFLA_VF_STATS_RX_BYTES,
+					vf_stats.rx_bytes) ||
+			    nla_put_u64(skb, IFLA_VF_STATS_TX_BYTES,
+					vf_stats.tx_bytes) ||
+			    nla_put_u64(skb, IFLA_VF_STATS_BROADCAST,
+					vf_stats.broadcast) ||
+			    nla_put_u64(skb, IFLA_VF_STATS_MULTICAST,
+					vf_stats.multicast))
+				goto nla_put_failure;
+			nla_nest_end(skb, vfstats);
 			nla_nest_end(skb, vf);
 		}
 		nla_nest_end(skb, vfinfo);
@@ -1303,6 +1340,16 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 	[IFLA_VF_RATE]		= { .len = sizeof(struct ifla_vf_rate) },
 	[IFLA_VF_LINK_STATE]	= { .len = sizeof(struct ifla_vf_link_state) },
 	[IFLA_VF_RSS_QUERY_EN]	= { .len = sizeof(struct ifla_vf_rss_query_en) },
+	[IFLA_VF_STATS]		= { .type = NLA_NESTED },
+};
+
+static const struct nla_policy ifla_vf_stats_policy[IFLA_VF_STATS_MAX + 1] = {
+	[IFLA_VF_STATS_RX_PACKETS]	= { .type = NLA_U64 },
+	[IFLA_VF_STATS_TX_PACKETS]	= { .type = NLA_U64 },
+	[IFLA_VF_STATS_RX_BYTES]	= { .type = NLA_U64 },
+	[IFLA_VF_STATS_TX_BYTES]	= { .type = NLA_U64 },
+	[IFLA_VF_STATS_BROADCAST]	= { .type = NLA_U64 },
+	[IFLA_VF_STATS_MULTICAST]	= { .type = NLA_U64 },
 };
 
 static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
-- 
1.7.1
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>
