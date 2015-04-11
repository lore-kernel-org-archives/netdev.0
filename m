From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] if_link: Add an additional parameter to ifla_vf_info for RSS querying
Date: Sat, 11 Apr 2015 12:07:50 -0700
Message-ID: <1428779276-22523-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15376 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755404AbbDKTIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 15:08:01 -0400
In-Reply-To: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Zolotarov <vladz@cloudius-systems.com>

Add configuration setting for drivers to allow/block an RSS Redirection
Table and a Hash Key querying for discrete VFs.

On some devices VF share the mentioned above information with PF and
querying it may adduce a theoretical security risk. We want to let a
system administrator to decide if he/she wants to take this risk or not.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/if_link.h      |  1 +
 include/linux/netdevice.h    |  8 ++++++++
 include/uapi/linux/if_link.h |  8 ++++++++
 net/core/rtnetlink.c         | 32 ++++++++++++++++++++++++++------
 4 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 119130e..da49299 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -14,5 +14,6 @@ struct ifla_vf_info {
 	__u32 linkstate;
 	__u32 min_tx_rate;
 	__u32 max_tx_rate;
+	__u32 rss_query_en;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bf6d9df..13acb3d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -878,6 +878,11 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
  *			  struct nlattr *port[]);
+ *
+ *      Enable or disable the VF ability to query its RSS Redirection Table and
+ *      Hash Key. This is needed since on some devices VF share this information
+ *      with PF and querying it may adduce a theoretical security risk.
+ * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
  * int (*ndo_setup_tc)(struct net_device *dev, u8 tc)
  * 	Called to setup 'tc' number of traffic classes in the net device. This
@@ -1099,6 +1104,9 @@ struct net_device_ops {
 						   struct nlattr *port[]);
 	int			(*ndo_get_vf_port)(struct net_device *dev,
 						   int vf, struct sk_buff *skb);
+	int			(*ndo_set_vf_rss_query_en)(
+						   struct net_device *dev,
+						   int vf, bool setting);
 	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc);
 #if IS_ENABLED(CONFIG_FCOE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 7ffb18d..d9cd192 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -465,6 +465,9 @@ enum {
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
 	IFLA_VF_RATE,		/* Min and Max TX Bandwidth Allocation */
+	IFLA_VF_RSS_QUERY_EN,	/* RSS Redirection Table and Hash Key query
+				 * on/off switch
+				 */
 	__IFLA_VF_MAX,
 };
 
@@ -509,6 +512,11 @@ struct ifla_vf_link_state {
 	__u32 link_state;
 };
 
+struct ifla_vf_rss_query_en {
+	__u32 vf;
+	__u32 setting;
+};
+
 /* VF ports management section
  *
  *	Nested layout of set/get msg is:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7a83615..358d52a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -818,7 +818,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 nla_total_size(sizeof(struct ifla_vf_vlan)) +
 			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
 			 nla_total_size(sizeof(struct ifla_vf_rate)) +
-			 nla_total_size(sizeof(struct ifla_vf_link_state)));
+			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
+			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)));
 		return size;
 	} else
 		return 0;
@@ -1132,14 +1133,16 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_tx_rate vf_tx_rate;
 			struct ifla_vf_spoofchk vf_spoofchk;
 			struct ifla_vf_link_state vf_linkstate;
+			struct ifla_vf_rss_query_en vf_rss_query_en;
 
 			/*
 			 * Not all SR-IOV capable drivers support the
-			 * spoofcheck query.  Preset to -1 so the user
-			 * space tool can detect that the driver didn't
-			 * report anything.
+			 * spoofcheck and "RSS query enable" query.  Preset to
+			 * -1 so the user space tool can detect that the driver
+			 * didn't report anything.
 			 */
 			ivi.spoofchk = -1;
+			ivi.rss_query_en = -1;
 			memset(ivi.mac, 0, sizeof(ivi.mac));
 			/* The default value for VF link state is "auto"
 			 * IFLA_VF_LINK_STATE_AUTO which equals zero
@@ -1152,7 +1155,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				vf_rate.vf =
 				vf_tx_rate.vf =
 				vf_spoofchk.vf =
-				vf_linkstate.vf = ivi.vf;
+				vf_linkstate.vf =
+				vf_rss_query_en.vf = ivi.vf;
 
 			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 			vf_vlan.vlan = ivi.vlan;
@@ -1162,6 +1166,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			vf_rate.max_tx_rate = ivi.max_tx_rate;
 			vf_spoofchk.setting = ivi.spoofchk;
 			vf_linkstate.link_state = ivi.linkstate;
+			vf_rss_query_en.setting = ivi.rss_query_en;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
 			if (!vf) {
 				nla_nest_cancel(skb, vfinfo);
@@ -1176,7 +1181,10 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    nla_put(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
 				    &vf_spoofchk) ||
 			    nla_put(skb, IFLA_VF_LINK_STATE, sizeof(vf_linkstate),
-				    &vf_linkstate))
+				    &vf_linkstate) ||
+			    nla_put(skb, IFLA_VF_RSS_QUERY_EN,
+				    sizeof(vf_rss_query_en),
+				    &vf_rss_query_en))
 				goto nla_put_failure;
 			nla_nest_end(skb, vf);
 		}
@@ -1290,6 +1298,7 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 	[IFLA_VF_SPOOFCHK]	= { .len = sizeof(struct ifla_vf_spoofchk) },
 	[IFLA_VF_RATE]		= { .len = sizeof(struct ifla_vf_rate) },
 	[IFLA_VF_LINK_STATE]	= { .len = sizeof(struct ifla_vf_link_state) },
+	[IFLA_VF_RSS_QUERY_EN]	= { .len = sizeof(struct ifla_vf_rss_query_en) },
 };
 
 static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
@@ -1500,6 +1509,17 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 								 ivl->link_state);
 			break;
 		}
+		case IFLA_VF_RSS_QUERY_EN: {
+			struct ifla_vf_rss_query_en *ivrssq_en;
+
+			ivrssq_en = nla_data(vf);
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_vf_rss_query_en)
+				err = ops->ndo_set_vf_rss_query_en(dev,
+							    ivrssq_en->vf,
+							    ivrssq_en->setting);
+			break;
+		}
 		default:
 			err = -EINVAL;
 			break;
-- 
1.9.3
