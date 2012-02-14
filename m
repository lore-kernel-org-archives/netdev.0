From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [RFC net-next 1/2] if_link : add support for VF privileges
Date: Tue, 14 Feb 2012 13:26:27 -0600
Message-ID: <20120214192627.GA14163@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <shemminger@linux-foundation.org>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:31047 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757134Ab2BNT1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:27:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 include/linux/if_link.h   |   21 +++++++++++++++++++++
 include/linux/netdevice.h |    3 +++
 net/core/rtnetlink.c      |   17 ++++++++++++++++-
 3 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c52d4b5..9c93a8e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -280,11 +280,26 @@ enum {
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
+	IFLA_VF_PRIVILEGE,	/* VF Privilege level setting */
 	__IFLA_VF_MAX,
 };
 
 #define IFLA_VF_MAX (__IFLA_VF_MAX - 1)
 
+enum {
+	IFLA_VF_PRIVILEGE_DEFAULT = 1,	/* Default privileges */
+	IFLA_VF_PRIVILEGE_STATS	= 2,	/* Privilege to gather statistics */
+	IFLA_VF_PRIVILEGE_LNK_MGMT = 4,	/* Privilege to manage link params */
+	IFLA_VF_PRIVILEGE_DIAG	= 8,	/* Privilege to perform diagnostics */
+	IFLA_VF_PRIVILEGE_MAC	= 16,	/* Privilege to modify MAC address */
+	IFLA_VF_PRIVILEGE_VLAN	= 32,	/* Privilege to add or remove VLANs */
+	IFLA_VF_PRIVILEGE_DEV_CFG = 64,	/* Unrestricted admin access privlege */
+	IFLA_VF_PRIVILEGE_SECURE = 128,	/* Privilege to access secure content */
+	__IFLA_VF_PRIVILEGE_MAX,
+};
+
+#define IFLA_VF_PRIVILEGE_MAX (__IFLA_VF_PRIVILEGE_MAX - 1)
+
 struct ifla_vf_mac {
 	__u32 vf;
 	__u8 mac[32]; /* MAX_ADDR_LEN */
@@ -305,6 +320,11 @@ struct ifla_vf_spoofchk {
 	__u32 vf;
 	__u32 setting;
 };
+
+struct ifla_vf_privilege {
+	__u32 vf;
+	__u32 privilege;
+};
 #ifdef __KERNEL__
 
 /* We don't want this structure exposed to user space */
@@ -315,6 +335,7 @@ struct ifla_vf_info {
 	__u32 qos;
 	__u32 tx_rate;
 	__u32 spoofchk;
+	__u32 privilege;
 };
 #endif
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0eac07c..f80cab7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -823,6 +823,7 @@ struct netdev_fcoe_hbainfo {
  * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
  * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
+ * int (*ndo_set_vf_privilege)(struct net_device *dev, int vf, u32 privilege);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
@@ -952,6 +953,8 @@ struct net_device_ops {
 						      int vf, int rate);
 	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
 						       int vf, bool setting);
+	int			(*ndo_set_vf_privilege)(struct net_device *dev,
+							int vf, u32 privilege);
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 65aebd4..061d8e3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -959,6 +959,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_vlan vf_vlan;
 			struct ifla_vf_tx_rate vf_tx_rate;
 			struct ifla_vf_spoofchk vf_spoofchk;
+			struct ifla_vf_privilege vf_privilege;
 
 			/*
 			 * Not all SR-IOV capable drivers support the
@@ -967,18 +968,21 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			 * report anything.
 			 */
 			ivi.spoofchk = -1;
+			ivi.privilege = -1;
 			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
 				break;
 			vf_mac.vf =
 				vf_vlan.vf =
 				vf_tx_rate.vf =
-				vf_spoofchk.vf = ivi.vf;
+				vf_spoofchk.vf =
+				vf_privilege.vf = ivi.vf;
 
 			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 			vf_vlan.vlan = ivi.vlan;
 			vf_vlan.qos = ivi.qos;
 			vf_tx_rate.rate = ivi.tx_rate;
 			vf_spoofchk.setting = ivi.spoofchk;
+			vf_privilege.privilege = ivi.privilege;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
 			if (!vf) {
 				nla_nest_cancel(skb, vfinfo);
@@ -990,6 +994,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				&vf_tx_rate);
 			NLA_PUT(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
 				&vf_spoofchk);
+			NLA_PUT(skb, IFLA_VF_PRIVILEGE, sizeof(vf_privilege),
+				&vf_privilege);
 			nla_nest_end(skb, vf);
 		}
 		nla_nest_end(skb, vfinfo);
@@ -1232,6 +1238,15 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 							       ivs->setting);
 			break;
 		}
+		case IFLA_VF_PRIVILEGE: {
+			struct ifla_vf_privilege *ivp;
+			ivp = nla_data(vf);
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_vf_privilege)
+				err = ops->ndo_set_vf_privilege(dev, ivp->vf,
+							       ivp->privilege);
+			break;
+		}
 		default:
 			err = -EINVAL;
 			break;
-- 
1.7.1
