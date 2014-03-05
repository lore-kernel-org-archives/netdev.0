From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [RFC 1/2] net: Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool.
Date: Wed, 5 Mar 2014 02:33:35 -0500
Message-ID: <1394004816-23436-2-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1394004816-23436-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:24442 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751441AbaCEIJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 03:09:36 -0500
In-Reply-To: <1394004816-23436-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o A new handler set_vf_rate for attr IFLA_VF_RATE has been introduced
  which takes 4 arguments:
  netdev, VF number, min_tx_rate, max_tx_rate

o min_tx_rate puts lower limit on the VF bandwidth. VF is guaranteed
  to have a bandwidth of at least this value.
  max_tx_rate puts cap on the VF bandwidth. VF can have a bandwidth
  of up to this value.

o Idea is to deprecate IFLA_VF_TX_RATE and ndo_set_vf_tx_rate in future.
  And to have consistent display of rate values to user.

o Usage example: -

  ./ip link set p4p1 vf 0 rate 900
  WARN: "rate" option will be deprecated. Use "min_tx_rate" and
  "max_tx_rate" instead.

  ./ip link show p4p1
  32: p4p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
  DEFAULT qlen 1000
    link/ether 00:0e:1e:08:b0:f0 brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 3e:a0:ca:bd:ae:5a, tx rate 900 (Mbps)
    vf 1 MAC f6:c6:7c:3f:3d:6c
    vf 2 MAC 56:32:43:98:d7:71
    vf 3 MAC d6:be:c3:b5:85:ff
    vf 4 MAC ee:a9:9a:1e:19:14
    vf 5 MAC 4a:d0:4c:07:52:18
    vf 6 MAC 3a:76:44:93:62:f9
    vf 7 MAC 82:e9:e7:e3:15:1a

  ./ip link set p4p1 vf 0 max_tx_rate 300 min_tx_rate 200

  ./ip link show p4p1
  32: p4p1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
  DEFAULT qlen 1000
    link/ether 00:0e:1e:08:b0:f0 brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 3e:a0:ca:bd:ae:5a, max tx rate 300 (Mbps), min tx rate
  200 (Mbps)
    vf 1 MAC f6:c6:7c:3f:3d:6c
    vf 2 MAC 56:32:43:98:d7:71
    vf 3 MAC d6:be:c3:b5:85:ff
    vf 4 MAC ee:a9:9a:1e:19:14
    vf 5 MAC 4a:d0:4c:07:52:18
    vf 6 MAC 3a:76:44:93:62:f9
    vf 7 MAC 82:e9:e7:e3:15:1a

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 include/linux/if_link.h      |  2 ++
 include/linux/netdevice.h    |  5 +++++
 include/uapi/linux/if_link.h |  9 ++++++++-
 net/core/rtnetlink.c         | 30 ++++++++++++++++++++++++++++++
 4 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index a86784d..3fad5db 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -13,5 +13,7 @@ struct ifla_vf_info {
 	__u32 tx_rate;
 	__u32 spoofchk;
 	__u32 linkstate;
+	__u32 min_tx_rate;
+	__u32 max_tx_rate;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1a86948..d2bbcfc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -854,6 +854,8 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
  * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
  * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
+ * int (*ndo_set_vf_rate)(struct net_device *dev, int vf, int min_tx_rate,
+ *			  int max_tx_rate);
  * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
@@ -1050,6 +1052,9 @@ struct net_device_ops {
 						   int queue, u16 vlan, u8 qos);
 	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
 						      int vf, int rate);
+	int			(*ndo_set_vf_rate)(struct net_device *dev,
+						   int vf, int min_tx_rate,
+						   int max_tx_rate);
 	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
 						       int vf, bool setting);
 	int			(*ndo_get_vf_config)(struct net_device *dev,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 16410b6..fce6437 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -398,7 +398,8 @@ enum {
 	IFLA_VF_UNSPEC,
 	IFLA_VF_MAC,		/* Hardware queue specific attributes */
 	IFLA_VF_VLAN,
-	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
+	IFLA_VF_TX_RATE,	/* Max TX Bandwidth Allocation */
+	IFLA_VF_RATE,		/* Min and Max TX Bandwidth Allocation */
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
 	__IFLA_VF_MAX,
@@ -422,6 +423,12 @@ struct ifla_vf_tx_rate {
 	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
 };
 
+struct ifla_vf_rate {
+	__u32 vf;
+	__u32 min_tx_rate; /* Min Bandwidth in Mbps */
+	__u32 max_tx_rate; /* Max Bandwidth in Mbps */
+};
+
 struct ifla_vf_spoofchk {
 	__u32 vf;
 	__u32 setting;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index fc122fd..220d9c3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1027,6 +1027,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			struct ifla_vf_info ivi;
 			struct ifla_vf_mac vf_mac;
 			struct ifla_vf_vlan vf_vlan;
+			struct ifla_vf_rate vf_rate;
 			struct ifla_vf_tx_rate vf_tx_rate;
 			struct ifla_vf_spoofchk vf_spoofchk;
 			struct ifla_vf_link_state vf_linkstate;
@@ -1047,6 +1048,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 				break;
 			vf_mac.vf =
 				vf_vlan.vf =
+				vf_rate.vf =
 				vf_tx_rate.vf =
 				vf_spoofchk.vf =
 				vf_linkstate.vf = ivi.vf;
@@ -1055,6 +1057,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			vf_vlan.vlan = ivi.vlan;
 			vf_vlan.qos = ivi.qos;
 			vf_tx_rate.rate = ivi.tx_rate;
+			vf_rate.min_tx_rate = ivi.min_tx_rate;
+			vf_rate.max_tx_rate = ivi.max_tx_rate;
 			vf_spoofchk.setting = ivi.spoofchk;
 			vf_linkstate.link_state = ivi.linkstate;
 			vf = nla_nest_start(skb, IFLA_VF_INFO);
@@ -1064,6 +1068,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			}
 			if (nla_put(skb, IFLA_VF_MAC, sizeof(vf_mac), &vf_mac) ||
 			    nla_put(skb, IFLA_VF_VLAN, sizeof(vf_vlan), &vf_vlan) ||
+			    nla_put(skb, IFLA_VF_RATE, sizeof(vf_rate),
+				    &vf_rate) ||
 			    nla_put(skb, IFLA_VF_TX_RATE, sizeof(vf_tx_rate),
 				    &vf_tx_rate) ||
 			    nla_put(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
@@ -1328,6 +1334,30 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 							      ivt->rate);
 			break;
 		}
+		case IFLA_VF_RATE: {
+			struct ifla_vf_rate *ivt;
+			struct ifla_vf_info ivf;
+			ivt = nla_data(vf);
+			err = -EOPNOTSUPP;
+			if ((!ivt->min_tx_rate || !ivt->max_tx_rate) &&
+			    ops->ndo_get_vf_config)
+				err = ops->ndo_get_vf_config(dev, ivt->vf,
+							     &ivf);
+			else
+				err = 0;
+			if (err)
+				break;
+			if (!ivt->min_tx_rate)
+				ivt->min_tx_rate = ivf.min_tx_rate;
+			if (!ivt->max_tx_rate)
+				ivt->max_tx_rate = ivf.max_tx_rate;
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_vf_rate)
+				err = ops->ndo_set_vf_rate(dev, ivt->vf,
+							   ivt->min_tx_rate,
+							   ivt->max_tx_rate);
+			break;
+		}
 		case IFLA_VF_SPOOFCHK: {
 			struct ifla_vf_spoofchk *ivs;
 			ivs = nla_data(vf);
-- 
1.8.1.4
