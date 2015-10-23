From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/17] if_link: Add control trust VF
Date: Fri, 23 Oct 2015 06:17:57 -0700
Message-ID: <1445606279-19345-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Sy Jong Choi <sy.jong.choi@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60580 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267AbbJWNSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:20 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Add netlink directives and ndo entry to trust VF user.

This controls the special permission of VF user.
The administrator will dedicatedly trust VF user to use some features
which impacts security and/or performance.

The administrator never turn it on unless VF user is fully trusted.

CC: Sy Jong Choi <sy.jong.choi@intel.com>
Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/if_link.h      |  1 +
 include/linux/netdevice.h    |  3 +++
 include/uapi/linux/if_link.h |  6 ++++++
 net/core/rtnetlink.c         | 24 +++++++++++++++++++++---
 4 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index ae5d0d2..f923d15 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -24,5 +24,6 @@ struct ifla_vf_info {
 	__u32 min_tx_rate;
 	__u32 max_tx_rate;
 	__u32 rss_query_en;
+	__u32 trusted;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 69fdd42..7733838 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -881,6 +881,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
  *			  int max_tx_rate);
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
+ * int (*ndo_set_vf_trust)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
  * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
@@ -1109,6 +1110,8 @@ struct net_device_ops {
 						   int max_tx_rate);
 	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
 						       int vf, bool setting);
+	int			(*ndo_set_vf_trust)(struct net_device *dev,
+						    int vf, bool setting);
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index e3b6217..a7aea84 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -550,6 +550,7 @@ enum {
 				 * on/off switch
 				 */
 	IFLA_VF_STATS,		/* network device statistics */
+	IFLA_VF_TRUST,		/* Trust VF */
 	__IFLA_VF_MAX,
 };
 
@@ -611,6 +612,11 @@ enum {
 
 #define IFLA_VF_STATS_MAX (__IFLA_VF_STATS_MAX - 1)
 
+struct ifla_vf_trust {
+	__u32 vf;
+	__u32 setting;
+};
+
 /* VF ports management section
  *
  *	Nested layout of set/get msg is:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7c78b5a..504bd17 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -838,7 +838,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 /* IFLA_VF_STATS_BROADCAST */
 			 nla_total_size(sizeof(__u64)) +
 			 /* IFLA_VF_STATS_MULTICAST */
-			 nla_total_size(sizeof(__u64)));
+			 nla_total_size(sizeof(__u64)) +
+			 nla_total_size(sizeof(struct ifla_vf_trust)));
 		return size;
 	} else
 		return 0;
@@ -1161,6 +1162,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_link_state vf_linkstate;
 			struct ifla_vf_rss_query_en vf_rss_query_en;
 			struct ifla_vf_stats vf_stats;
+			struct ifla_vf_trust vf_trust;
 
 			/*
 			 * Not all SR-IOV capable drivers support the
@@ -1170,6 +1172,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			 */
 			ivi.spoofchk = -1;
 			ivi.rss_query_en = -1;
+			ivi.trusted = -1;
 			memset(ivi.mac, 0, sizeof(ivi.mac));
 			/* The default value for VF link state is "auto"
 			 * IFLA_VF_LINK_STATE_AUTO which equals zero
@@ -1183,7 +1186,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				vf_tx_rate.vf =
 				vf_spoofchk.vf =
 				vf_linkstate.vf =
-				vf_rss_query_en.vf = ivi.vf;
+				vf_rss_query_en.vf =
+				vf_trust.vf = ivi.vf;
 
 			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 			vf_vlan.vlan = ivi.vlan;
@@ -1194,6 +1198,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			vf_spoofchk.setting = ivi.spoofchk;
 			vf_linkstate.link_state = ivi.linkstate;
 			vf_rss_query_en.setting = ivi.rss_query_en;
+			vf_trust.setting = ivi.trusted;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
 			if (!vf) {
 				nla_nest_cancel(skb, vfinfo);
@@ -1211,7 +1216,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				    &vf_linkstate) ||
 			    nla_put(skb, IFLA_VF_RSS_QUERY_EN,
 				    sizeof(vf_rss_query_en),
-				    &vf_rss_query_en))
+				    &vf_rss_query_en) ||
+			    nla_put(skb, IFLA_VF_TRUST,
+				    sizeof(vf_trust), &vf_trust))
 				goto nla_put_failure;
 			memset(&vf_stats, 0, sizeof(vf_stats));
 			if (dev->netdev_ops->ndo_get_vf_stats)
@@ -1348,6 +1355,7 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 	[IFLA_VF_LINK_STATE]	= { .len = sizeof(struct ifla_vf_link_state) },
 	[IFLA_VF_RSS_QUERY_EN]	= { .len = sizeof(struct ifla_vf_rss_query_en) },
 	[IFLA_VF_STATS]		= { .type = NLA_NESTED },
+	[IFLA_VF_TRUST]		= { .len = sizeof(struct ifla_vf_trust) },
 };
 
 static const struct nla_policy ifla_vf_stats_policy[IFLA_VF_STATS_MAX + 1] = {
@@ -1587,6 +1595,16 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
 			return err;
 	}
 
+	if (tb[IFLA_VF_TRUST]) {
+		struct ifla_vf_trust *ivt = nla_data(tb[IFLA_VF_TRUST]);
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_trust)
+			err = ops->ndo_set_vf_trust(dev, ivt->vf, ivt->setting);
+		if (err < 0)
+			return err;
+	}
+
 	return err;
 }
 
-- 
2.4.3
