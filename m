From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 1/3] net/core: Add VF link state control
Date: Wed, 12 Jun 2013 11:12:06 +0300
Message-ID: <1371024728-31790-2-git-send-email-ogerlitz@mellanox.com>
References: <1371024728-31790-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49113 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754466Ab3FLIKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 04:10:55 -0400
In-Reply-To: <1371024728-31790-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Add netlink directives and ndo entry to allow for controling
VF link, which can be in one of three states:

Auto - VF link state reflects the PF link state (default)

Up - VF link state is up, traffic from VF to VF works even if
the actual PF link is down

Down - VF link state is down, no traffic from/to this VF, can be of
use while configuring the VF

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/if_link.h      |    1 +
 include/linux/netdevice.h    |    3 +++
 include/uapi/linux/if_link.h |   13 +++++++++++++
 net/core/rtnetlink.c         |   22 ++++++++++++++++++++--
 4 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c3f817c..a86784d 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -12,5 +12,6 @@ struct ifla_vf_info {
 	__u32 qos;
 	__u32 tx_rate;
 	__u32 spoofchk;
+	__u32 linkstate;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2ecb96d..33f585e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -829,6 +829,7 @@ struct netdev_fcoe_hbainfo {
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
+ * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
  *			  struct nlattr *port[]);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
@@ -986,6 +987,8 @@ struct net_device_ops {
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
+	int			(*ndo_set_vf_link_state)(struct net_device *dev,
+						       int vf, int link_state);
 	int			(*ndo_set_vf_port)(struct net_device *dev,
 						   int vf,
 						   struct nlattr *port[]);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b05823c..a923efd 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -336,6 +336,7 @@ enum {
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
+	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
 	__IFLA_VF_MAX,
 };
 
@@ -362,6 +363,18 @@ struct ifla_vf_spoofchk {
 	__u32 setting;
 };
 
+enum {
+	IFLA_VF_LINK_STATE_AUTO,	/* link state of the uplink */
+	IFLA_VF_LINK_STATE_ENABLE,	/* link always up */
+	IFLA_VF_LINK_STATE_DISABLE,	/* link always down */
+	__IFLA_VF_LINK_STATE_MAX,
+};
+
+struct ifla_vf_link_state {
+	__u32 vf;
+	__u32 link_state;
+};
+
 /* VF ports management section
  *
  *	Nested layout of set/get msg is:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 49c1445..443a10c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -947,6 +947,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_vlan vf_vlan;
 			struct ifla_vf_tx_rate vf_tx_rate;
 			struct ifla_vf_spoofchk vf_spoofchk;
+			struct ifla_vf_link_state vf_linkstate;
 
 			/*
 			 * Not all SR-IOV capable drivers support the
@@ -956,18 +957,24 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			 */
 			ivi.spoofchk = -1;
 			memset(ivi.mac, 0, sizeof(ivi.mac));
+			/* The default value for VF link state is "auto" 
+ * 			 * IFLA_VF_LINK_STATE_AUTO which equals zero 
+ * 			 */
+			ivi.linkstate = 0; 
 			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
 				break;
 			vf_mac.vf =
 				vf_vlan.vf =
 				vf_tx_rate.vf =
-				vf_spoofchk.vf = ivi.vf;
+				vf_spoofchk.vf =
+				vf_linkstate.vf = ivi.vf;
 
 			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 			vf_vlan.vlan = ivi.vlan;
 			vf_vlan.qos = ivi.qos;
 			vf_tx_rate.rate = ivi.tx_rate;
 			vf_spoofchk.setting = ivi.spoofchk;
+			vf_linkstate.link_state = ivi.linkstate;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
 			if (!vf) {
 				nla_nest_cancel(skb, vfinfo);
@@ -978,7 +985,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    nla_put(skb, IFLA_VF_TX_RATE, sizeof(vf_tx_rate),
 				    &vf_tx_rate) ||
 			    nla_put(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
-				    &vf_spoofchk))
+				    &vf_spoofchk) ||
+			    nla_put(skb, IFLA_VF_LINK_STATE, sizeof(vf_linkstate),
+				    &vf_linkstate))
 				goto nla_put_failure;
 			nla_nest_end(skb, vf);
 		}
@@ -1238,6 +1247,15 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 							       ivs->setting);
 			break;
 		}
+		case IFLA_VF_LINK_STATE: {
+			struct ifla_vf_link_state *ivl;
+			ivl = nla_data(vf);
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_vf_link_state)
+				err = ops->ndo_set_vf_link_state(dev, ivl->vf,
+							   ivl->link_state);
+			break;
+		}
 		default:
 			err = -EINVAL;
 			break;
-- 
1.7.1
