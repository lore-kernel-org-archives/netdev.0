From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH RFC 1/2] net/core: Add netlink directives to control VF link state
Date: Wed,  8 May 2013 16:45:15 +0300
Message-ID: <1368020717-22194-2-git-send-email-ogerlitz@mellanox.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
Cc: amirv@mellanox.com, ronye@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:50980 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754935Ab3EHNpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 09:45:04 -0400
In-Reply-To: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Auto -	the VF link state will reflect the PF link state

Enable - VF link stat will be always up, traffic from VF to VF can 
	 work even if PF link is down.

Disable - VF link state is down and the VF can't send/recv, e.g can be 
  	  used to suspend the link while configuring the VF.

Signed-off-by: Rony Efraim <ronye@mellanox.com>
---
 include/linux/netdevice.h    |    3 +++
 include/uapi/linux/if_link.h |   13 +++++++++++++
 net/core/rtnetlink.c         |    9 +++++++++
 3 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8898a4..e609474 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -801,6 +801,7 @@ struct netdev_fcoe_hbainfo {
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
+ * int (*ndo_set_vf_link_state)(struct net_device *dev, int vf, int link_state);
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
  *			  struct nlattr *port[]);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
@@ -955,6 +956,8 @@ struct net_device_ops {
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
index a08bd2b..bec44a3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1238,6 +1238,15 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
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
