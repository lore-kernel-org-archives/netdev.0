From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 12/13] net/core: Add reading VF statistics through the PF netdevice
Date: Wed, 10 Jun 2015 17:59:37 +0300
Message-ID: <1433948378-17570-13-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38128 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933636AbbFJPCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:02:10 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Add ndo_get_vf_stats where the PF retrieves and fills the VFs traffic
statistics. Add rtnl_link_vf_stats64 for passing the VF statistics from
the PF to user-space.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/netdevice.h    |    4 ++++
 include/uapi/linux/if_link.h |   11 +++++++++++
 net/core/rtnetlink.c         |   12 ++++++++++--
 3 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6f5f71f..b1d3b88 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1100,6 +1100,10 @@ struct net_device_ops {
 						     struct ifla_vf_info *ivf);
 	int			(*ndo_set_vf_link_state)(struct net_device *dev,
 							 int vf, int link_state);
+	int			(*ndo_get_vf_stats)(struct net_device *dev,
+						    int vf,
+						    struct rtnl_link_vf_stats64
+						    *vf_stats);
 	int			(*ndo_set_vf_port)(struct net_device *dev,
 						   int vf,
 						   struct nlattr *port[]);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 1737b7a..9c25aeb 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -70,6 +70,16 @@ struct rtnl_link_stats64 {
 	__u64	tx_compressed;
 };
 
+/* VF statistics structure */
+struct rtnl_link_vf_stats64 {
+	__u64	rx_packets;		/* total packets received	*/
+	__u64	tx_packets;		/* total packets transmitted	*/
+	__u64	rx_bytes;		/* total bytes received		*/
+	__u64	tx_bytes;		/* total bytes transmitted	*/
+	__u64	broadcast;		/* broadcast packets received	*/
+	__u64	multicast;		/* multicast packets received	*/
+};
+
 /* The struct should be in sync with struct ifmap */
 struct rtnl_link_ifmap {
 	__u64	mem_start;
@@ -482,6 +492,7 @@ enum {
 	IFLA_VF_RSS_QUERY_EN,	/* RSS Redirection Table and Hash Key query
 				 * on/off switch
 				 */
+	IFLA_VF_STATS,		/* network device statistics */
 	__IFLA_VF_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 077b6d2..6d7c939 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -819,7 +819,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
 			 nla_total_size(sizeof(struct ifla_vf_rate)) +
 			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
-			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)));
+			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)) +
+			 nla_total_size(sizeof(struct rtnl_link_vf_stats64)));
 		return size;
 	} else
 		return 0;
@@ -1138,6 +1139,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_spoofchk vf_spoofchk;
 			struct ifla_vf_link_state vf_linkstate;
 			struct ifla_vf_rss_query_en vf_rss_query_en;
+			struct rtnl_link_vf_stats64 vf_stats;
 
 			/*
 			 * Not all SR-IOV capable drivers support the
@@ -1176,6 +1178,10 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				nla_nest_cancel(skb, vfinfo);
 				goto nla_put_failure;
 			}
+			memset(&vf_stats, 0, sizeof(vf_stats));
+			if (dev->netdev_ops->ndo_get_vf_stats)
+				dev->netdev_ops->ndo_get_vf_stats(dev, i,
+								  &vf_stats);
 			if (nla_put(skb, IFLA_VF_MAC, sizeof(vf_mac), &vf_mac) ||
 			    nla_put(skb, IFLA_VF_VLAN, sizeof(vf_vlan), &vf_vlan) ||
 			    nla_put(skb, IFLA_VF_RATE, sizeof(vf_rate),
@@ -1188,7 +1194,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				    &vf_linkstate) ||
 			    nla_put(skb, IFLA_VF_RSS_QUERY_EN,
 				    sizeof(vf_rss_query_en),
-				    &vf_rss_query_en))
+				    &vf_rss_query_en) ||
+			    nla_put(skb, IFLA_VF_STATS, sizeof(vf_stats),
+				    &vf_stats))
 				goto nla_put_failure;
 			nla_nest_end(skb, vf);
 		}
-- 
1.7.1

Cc: Greg Rose <gregory.v.rose@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>
