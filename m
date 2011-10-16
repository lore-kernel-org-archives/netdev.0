From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/5] if_link: Add additional parameter to IFLA_VF_INFO for spoof checking
Date: Sun, 16 Oct 2011 13:37:00 -0700
Message-ID: <1318797423-19897-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318797423-19897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38517 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751887Ab1JPUhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Oct 2011 16:37:07 -0400
In-Reply-To: <1318797423-19897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add configuration setting for drivers to turn spoof checking on or off
for discrete VFs.

v2 - Fix indentation problem, wrap the ifla_vf_info structure in
     #ifdef __KERNEL__ to prevent user space from accessing and
     change function paramater for the spoof check setting netdev
     op from u8 to bool.
v3 - Preset spoof check setting to -1 so that user space tools such
     as ip can detect that the driver didn't report a spoofcheck
     setting.  Prevents incorrect display of spoof check settings
     for drivers that don't report it.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/if_link.h   |   10 ++++++++++
 include/linux/netdevice.h |    3 +++
 net/core/rtnetlink.c      |   33 ++++++++++++++++++++++++++++++---
 3 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 0ee969a..c52d4b5 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -279,6 +279,7 @@ enum {
 	IFLA_VF_MAC,		/* Hardware queue specific attributes */
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
+	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	__IFLA_VF_MAX,
 };
 
@@ -300,13 +301,22 @@ struct ifla_vf_tx_rate {
 	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
 };
 
+struct ifla_vf_spoofchk {
+	__u32 vf;
+	__u32 setting;
+};
+#ifdef __KERNEL__
+
+/* We don't want this structure exposed to user space */
 struct ifla_vf_info {
 	__u32 vf;
 	__u8 mac[32];
 	__u32 vlan;
 	__u32 qos;
 	__u32 tx_rate;
+	__u32 spoofchk;
 };
+#endif
 
 /* VF ports management section
  *
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 43b3298..0db1f5f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -781,6 +781,7 @@ struct netdev_tc_txq {
  * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
  * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
  * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
+ * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
@@ -900,6 +901,8 @@ struct net_device_ops {
 						   int queue, u16 vlan, u8 qos);
 	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
 						      int vf, int rate);
+	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
+						       int vf, bool setting);
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 39f8dd6..9083e82 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -731,7 +731,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev)
 		size += num_vfs *
 			(nla_total_size(sizeof(struct ifla_vf_mac)) +
 			 nla_total_size(sizeof(struct ifla_vf_vlan)) +
-			 nla_total_size(sizeof(struct ifla_vf_tx_rate)));
+			 nla_total_size(sizeof(struct ifla_vf_tx_rate)) +
+			 nla_total_size(sizeof(struct ifla_vf_spoofchk)));
 		return size;
 	} else
 		return 0;
@@ -954,13 +955,27 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_mac vf_mac;
 			struct ifla_vf_vlan vf_vlan;
 			struct ifla_vf_tx_rate vf_tx_rate;
+			struct ifla_vf_spoofchk vf_spoofchk;
+
+			/*
+			 * Not all SR-IOV capable drivers support the
+			 * spoofcheck query.  Preset to -1 so the user
+			 * space tool can detect that the driver didn't
+			 * report anything.
+			 */
+			ivi.spoofchk = -1;
 			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
 				break;
-			vf_mac.vf = vf_vlan.vf = vf_tx_rate.vf = ivi.vf;
+			vf_mac.vf =
+				vf_vlan.vf =
+				vf_tx_rate.vf =
+				vf_spoofchk.vf = ivi.vf;
+
 			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
 			vf_vlan.vlan = ivi.vlan;
 			vf_vlan.qos = ivi.qos;
 			vf_tx_rate.rate = ivi.tx_rate;
+			vf_spoofchk.setting = ivi.spoofchk;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
 			if (!vf) {
 				nla_nest_cancel(skb, vfinfo);
@@ -968,7 +983,10 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			}
 			NLA_PUT(skb, IFLA_VF_MAC, sizeof(vf_mac), &vf_mac);
 			NLA_PUT(skb, IFLA_VF_VLAN, sizeof(vf_vlan), &vf_vlan);
-			NLA_PUT(skb, IFLA_VF_TX_RATE, sizeof(vf_tx_rate), &vf_tx_rate);
+			NLA_PUT(skb, IFLA_VF_TX_RATE, sizeof(vf_tx_rate),
+				&vf_tx_rate);
+			NLA_PUT(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
+				&vf_spoofchk);
 			nla_nest_end(skb, vf);
 		}
 		nla_nest_end(skb, vfinfo);
@@ -1202,6 +1220,15 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 							      ivt->rate);
 			break;
 		}
+		case IFLA_VF_SPOOFCHK: {
+			struct ifla_vf_spoofchk *ivs;
+			ivs = nla_data(vf);
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_vf_spoofchk)
+				err = ops->ndo_set_vf_spoofchk(dev, ivs->vf,
+							       ivs->setting);
+			break;
+		}
 		default:
 			err = -EINVAL;
 			break;
-- 
1.7.6.4
