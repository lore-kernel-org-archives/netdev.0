From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] if_link: Add VF multicast promiscuous control
Date: Sat,  2 May 2015 03:42:34 -0700
Message-ID: <1430563358-113833-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Sy Choi Jong <sy.jong.choi@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43420 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159AbbEBKmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 06:42:49 -0400
In-Reply-To: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Add netlink directives and ndo entry to allow VF multicast promiscuous mode.

This controls the permission to enter VF multicast promiscuous mode.
The administrator will dedicatedly allow multicast promiscuous per VF.

When the VF is under multicast promiscuous mode, all multicast packets are
sent to the VF.

Don't allow VF multicast promiscuous if the VM isn't fully trusted.

CC: Sy Choi Jong <sy.jong.choi@intel.com>
Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/if_link.h      |  1 +
 include/linux/netdevice.h    |  3 +++
 include/uapi/linux/if_link.h |  6 ++++++
 net/core/rtnetlink.c         | 19 +++++++++++++++++--
 4 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index da49299..df212f4 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -15,5 +15,6 @@ struct ifla_vf_info {
 	__u32 min_tx_rate;
 	__u32 max_tx_rate;
 	__u32 rss_query_en;
+	__u32 mc_promisc;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dbad4d7..66ffe63 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -874,6 +874,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
  *			  int max_tx_rate);
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
+ * int (*ndo_set_vf_mc_promisc)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
  * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
@@ -1095,6 +1096,8 @@ struct net_device_ops {
 						   int max_tx_rate);
 	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
 						       int vf, bool setting);
+	int			(*ndo_set_vf_mc_promisc)(struct net_device *dev,
+							 int vf, bool setting);
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index d9cd192..44c3bbe 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -468,6 +468,7 @@ enum {
 	IFLA_VF_RSS_QUERY_EN,	/* RSS Redirection Table and Hash Key query
 				 * on/off switch
 				 */
+	IFLA_VF_MC_PROMISC,	/* Multicast Promiscuous allow/disallow */
 	__IFLA_VF_MAX,
 };
 
@@ -517,6 +518,11 @@ struct ifla_vf_rss_query_en {
 	__u32 setting;
 };
 
+struct ifla_vf_mc_promisc {
+	__u32 vf;
+	__u32 setting;
+};
+
 /* VF ports management section
  *
  *	Nested layout of set/get msg is:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 358d52a..e8a5801 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -819,7 +819,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
 			 nla_total_size(sizeof(struct ifla_vf_rate)) +
 			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
-			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)));
+			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)) +
+			 nla_total_size(sizeof(struct ifla_vf_mc_promisc)));
 		return size;
 	} else
 		return 0;
@@ -1134,6 +1135,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_spoofchk vf_spoofchk;
 			struct ifla_vf_link_state vf_linkstate;
 			struct ifla_vf_rss_query_en vf_rss_query_en;
+			struct ifla_vf_mc_promisc vf_mc_promisc;
 
 			/*
 			 * Not all SR-IOV capable drivers support the
@@ -1143,6 +1145,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			 */
 			ivi.spoofchk = -1;
 			ivi.rss_query_en = -1;
+			ivi.mc_promisc = -1;
 			memset(ivi.mac, 0, sizeof(ivi.mac));
 			/* The default value for VF link state is "auto"
 			 * IFLA_VF_LINK_STATE_AUTO which equals zero
@@ -1156,7 +1159,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				vf_tx_rate.vf =
 				vf_spoofchk.vf =
 				vf_linkstate.vf =
-				vf_rss_query_en.vf = ivi.vf;
+				vf_rss_query_en.vf =
+				vf_mc_promisc.vf = ivi.vf;
 
 			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 			vf_vlan.vlan = ivi.vlan;
@@ -1167,6 +1171,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			vf_spoofchk.setting = ivi.spoofchk;
 			vf_linkstate.link_state = ivi.linkstate;
 			vf_rss_query_en.setting = ivi.rss_query_en;
+			vf_mc_promisc.setting = ivi.mc_promisc;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
 			if (!vf) {
 				nla_nest_cancel(skb, vfinfo);
@@ -1520,6 +1525,16 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 							    ivrssq_en->setting);
 			break;
 		}
+		case IFLA_VF_MC_PROMISC: {
+			struct ifla_vf_mc_promisc *ivm;
+
+			ivm = nla_data(vf);
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_vf_mc_promisc)
+				err = ops->ndo_set_vf_mc_promisc(dev, ivm->vf,
+								 ivm->setting);
+			break;
+		}
 		default:
 			err = -EINVAL;
 			break;
-- 
2.1.0
