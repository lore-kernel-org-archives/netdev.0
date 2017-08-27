From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 1/4] net: Add SRIOV VGT+ support
Date: Sun, 27 Aug 2017 14:06:15 +0300
Message-ID: <20170827110618.20599-2-saeedm@mellanox.com>
References: <20170827110618.20599-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37289 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751132AbdH0LV3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 07:21:29 -0400
In-Reply-To: <20170827110618.20599-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

VGT+ is a security feature that gives the administrator the ability of
controlling the allowed vlan-ids list that can be transmitted/received
from/to the VF.
The allowed vlan-ids list is called "trunk".
Admin can add/remove a range of allowed vlan-ids via iptool.
Example:
After this series of configuration :
1) ip link set eth3 vf 0 trunk add 10 100 (allow vlan-id 10-100, default tpid 0x8100)
2) ip link set eth3 vf 0 trunk add 105 proto 802.1q (allow vlan-id 105 tpid 0x8100)
3) ip link set eth3 vf 0 trunk add 105 proto 802.1ad (allow vlan-id 105 tpid 0x88a8)
4) ip link set eth3 vf 0 trunk rem 90 (block vlan-id 90)
5) ip link set eth3 vf 0 trunk rem 50 60 (block vlan-ids 50-60)

The VF 0 can only communicate on vlan-ids: 10-49,61-89,91-100,105 with
tpid 0x8100 and vlan-id 105 with tpid 0x88a8.

For this purpose we added the following netlink sr-iov commands:

1) IFLA_VF_VLAN_RANGE: used to add/remove allowed vlan-ids range.
We added the ifla_vf_vlan_range struct to specify the range we want to
add/remove from the userspace.
We added ndo_add_vf_vlan_trunk_range and ndo_del_vf_vlan_trunk_range
netdev ops to add/remove allowed vlan-ids range in the netdev.

2) IFLA_VF_VLAN_TRUNK: used to query the allowed vlan-ids trunk.
We added trunk bitmap to the ifla_vf_info struct to get the current
allowed vlan-ids trunk from the netdev.
We added ifla_vf_vlan_trunk struct for sending the allowed vlan-ids
trunk to the userspace.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/if_link.h      |   2 +
 include/linux/netdevice.h    |  12 +++++
 include/uapi/linux/if_link.h |  20 ++++++++
 net/core/rtnetlink.c         | 109 +++++++++++++++++++++++++++++++------------
 4 files changed, 114 insertions(+), 29 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 0b17c585b5cd..da70af27e42e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -25,6 +25,8 @@ struct ifla_vf_info {
 	__u32 max_tx_rate;
 	__u32 rss_query_en;
 	__u32 trusted;
+	__u64 trunk_8021q[VF_VLAN_BITMAP];
+	__u64 trunk_8021ad[VF_VLAN_BITMAP];
 	__be16 vlan_proto;
 };
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c5475b37a631..10633cabc58f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -959,6 +959,10 @@ struct xfrmdev_ops {
  *      Hash Key. This is needed since on some devices VF share this information
  *      with PF and querying it may introduce a theoretical security risk.
  * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting);
+ * int (*ndo_add_vf_vlan_trunk_range)(struct net_device *dev, int vf,
+ *				      u16 start_vid, u16 end_vid, __be16 proto);
+ * int (*ndo_del_vf_vlan_trunk_range)(struct net_device *dev, int vf,
+ *				      u16 start_vid, u16 end_vid, __be16 proto);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
  * int (*ndo_setup_tc)(struct net_device *dev, enum tc_setup_type type,
  *		       void *type_data);
@@ -1208,6 +1212,14 @@ struct net_device_ops {
 	int			(*ndo_set_vf_rss_query_en)(
 						   struct net_device *dev,
 						   int vf, bool setting);
+	int			(*ndo_add_vf_vlan_trunk_range)(
+						   struct net_device *dev,
+						   int vf, u16 start_vid,
+						   u16 end_vid, __be16 proto);
+	int			(*ndo_del_vf_vlan_trunk_range)(
+						   struct net_device *dev,
+						   int vf, u16 start_vid,
+						   u16 end_vid, __be16 proto);
 	int			(*ndo_setup_tc)(struct net_device *dev,
 						enum tc_setup_type type,
 						void *type_data);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8d062c58d5cb..3aa895c5fbc1 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -168,6 +168,8 @@ enum {
 #ifndef __KERNEL__
 #define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
 #define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
+#define BITS_PER_BYTE 8
+#define DIV_ROUND_UP(n, d) (((n) + (d) - 1) / (d))
 #endif
 
 enum {
@@ -645,6 +647,8 @@ enum {
 	IFLA_VF_IB_NODE_GUID,	/* VF Infiniband node GUID */
 	IFLA_VF_IB_PORT_GUID,	/* VF Infiniband port GUID */
 	IFLA_VF_VLAN_LIST,	/* nested list of vlans, option for QinQ */
+	IFLA_VF_VLAN_RANGE,	/* add/delete vlan range filtering */
+	IFLA_VF_VLAN_TRUNK,	/* vlan trunk filtering */
 	__IFLA_VF_MAX,
 };
 
@@ -669,6 +673,7 @@ enum {
 
 #define IFLA_VF_VLAN_INFO_MAX (__IFLA_VF_VLAN_INFO_MAX - 1)
 #define MAX_VLAN_LIST_LEN 1
+#define VF_VLAN_N_VID 4096
 
 struct ifla_vf_vlan_info {
 	__u32 vf;
@@ -677,6 +682,21 @@ struct ifla_vf_vlan_info {
 	__be16 vlan_proto; /* VLAN protocol either 802.1Q or 802.1ad */
 };
 
+struct ifla_vf_vlan_range {
+	__u32 vf;
+	__u32 start_vid;   /* 1 - 4095 */
+	__u32 end_vid;     /* 1 - 4095 */
+	__u32 setting;
+	__be16 vlan_proto; /* VLAN protocol either 802.1Q or 802.1ad */
+};
+
+#define VF_VLAN_BITMAP	DIV_ROUND_UP(VF_VLAN_N_VID, sizeof(__u64) * BITS_PER_BYTE)
+struct ifla_vf_vlan_trunk {
+	__u32 vf;
+	__u64 allowed_vlans_8021q_bm[VF_VLAN_BITMAP];
+	__u64 allowed_vlans_8021ad_bm[VF_VLAN_BITMAP];
+};
+
 struct ifla_vf_tx_rate {
 	__u32 vf;
 	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a78fd61da0ec..56909f11d88e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -827,6 +827,7 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 nla_total_size(MAX_VLAN_LIST_LEN *
 					sizeof(struct ifla_vf_vlan_info)) +
 			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
+			 nla_total_size(sizeof(struct ifla_vf_vlan_trunk)) +
 			 nla_total_size(sizeof(struct ifla_vf_tx_rate)) +
 			 nla_total_size(sizeof(struct ifla_vf_rate)) +
 			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
@@ -1098,31 +1099,43 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	struct ifla_vf_link_state vf_linkstate;
 	struct ifla_vf_vlan_info vf_vlan_info;
 	struct ifla_vf_spoofchk vf_spoofchk;
+	struct ifla_vf_vlan_trunk *vf_trunk;
 	struct ifla_vf_tx_rate vf_tx_rate;
 	struct ifla_vf_stats vf_stats;
 	struct ifla_vf_trust vf_trust;
 	struct ifla_vf_vlan vf_vlan;
 	struct ifla_vf_rate vf_rate;
 	struct ifla_vf_mac vf_mac;
-	struct ifla_vf_info ivi;
+	struct ifla_vf_info *ivi;
 
-	memset(&ivi, 0, sizeof(ivi));
+	ivi = kzalloc(sizeof(*ivi), GFP_KERNEL);
+	if (!ivi)
+		return -ENOMEM;
+
+	vf_trunk = kzalloc(sizeof(*vf_trunk), GFP_KERNEL);
+	if (!vf_trunk) {
+		kfree(ivi);
+		return -ENOMEM;
+	}
 
 	/* Not all SR-IOV capable drivers support the
 	 * spoofcheck and "RSS query enable" query.  Preset to
 	 * -1 so the user space tool can detect that the driver
 	 * didn't report anything.
 	 */
-	ivi.spoofchk = -1;
-	ivi.rss_query_en = -1;
-	ivi.trusted = -1;
+	ivi->spoofchk = -1;
+	ivi->rss_query_en = -1;
+	ivi->trusted = -1;
+	memset(ivi->mac, 0, sizeof(ivi->mac));
+	memset(ivi->trunk_8021q, 0, sizeof(ivi->trunk_8021q));
+	memset(ivi->trunk_8021ad, 0, sizeof(ivi->trunk_8021ad));
 	/* The default value for VF link state is "auto"
 	 * IFLA_VF_LINK_STATE_AUTO which equals zero
 	 */
-	ivi.linkstate = 0;
+	ivi->linkstate = 0;
 	/* VLAN Protocol by default is 802.1Q */
-	ivi.vlan_proto = htons(ETH_P_8021Q);
-	if (dev->netdev_ops->ndo_get_vf_config(dev, vfs_num, &ivi))
+	ivi->vlan_proto = htons(ETH_P_8021Q);
+	if (dev->netdev_ops->ndo_get_vf_config(dev, vfs_num, ivi))
 		return 0;
 
 	memset(&vf_vlan_info, 0, sizeof(vf_vlan_info));
@@ -1135,21 +1148,24 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 		vf_spoofchk.vf =
 		vf_linkstate.vf =
 		vf_rss_query_en.vf =
-		vf_trust.vf = ivi.vf;
-
-	memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
-	vf_vlan.vlan = ivi.vlan;
-	vf_vlan.qos = ivi.qos;
-	vf_vlan_info.vlan = ivi.vlan;
-	vf_vlan_info.qos = ivi.qos;
-	vf_vlan_info.vlan_proto = ivi.vlan_proto;
-	vf_tx_rate.rate = ivi.max_tx_rate;
-	vf_rate.min_tx_rate = ivi.min_tx_rate;
-	vf_rate.max_tx_rate = ivi.max_tx_rate;
-	vf_spoofchk.setting = ivi.spoofchk;
-	vf_linkstate.link_state = ivi.linkstate;
-	vf_rss_query_en.setting = ivi.rss_query_en;
-	vf_trust.setting = ivi.trusted;
+		vf_trunk->vf =
+		vf_trust.vf = ivi->vf;
+
+	memcpy(vf_mac.mac, ivi->mac, sizeof(ivi->mac));
+	memcpy(vf_trunk->allowed_vlans_8021q_bm, ivi->trunk_8021q, sizeof(ivi->trunk_8021q));
+	memcpy(vf_trunk->allowed_vlans_8021ad_bm, ivi->trunk_8021ad, sizeof(ivi->trunk_8021ad));
+	vf_vlan.vlan = ivi->vlan;
+	vf_vlan.qos = ivi->qos;
+	vf_vlan_info.vlan = ivi->vlan;
+	vf_vlan_info.qos = ivi->qos;
+	vf_vlan_info.vlan_proto = ivi->vlan_proto;
+	vf_tx_rate.rate = ivi->max_tx_rate;
+	vf_rate.min_tx_rate = ivi->min_tx_rate;
+	vf_rate.max_tx_rate = ivi->max_tx_rate;
+	vf_spoofchk.setting = ivi->spoofchk;
+	vf_linkstate.link_state = ivi->linkstate;
+	vf_rss_query_en.setting = ivi->rss_query_en;
+	vf_trust.setting = ivi->trusted;
 	vf = nla_nest_start(skb, IFLA_VF_INFO);
 	if (!vf)
 		goto nla_put_vfinfo_failure;
@@ -1167,7 +1183,9 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 		    sizeof(vf_rss_query_en),
 		    &vf_rss_query_en) ||
 	    nla_put(skb, IFLA_VF_TRUST,
-		    sizeof(vf_trust), &vf_trust))
+		    sizeof(vf_trust), &vf_trust) ||
+	    nla_put(skb, IFLA_VF_VLAN_TRUNK,
+		    sizeof(*vf_trunk), vf_trunk))
 		goto nla_put_vf_failure;
 	vfvlanlist = nla_nest_start(skb, IFLA_VF_VLAN_LIST);
 	if (!vfvlanlist)
@@ -1202,12 +1220,16 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	}
 	nla_nest_end(skb, vfstats);
 	nla_nest_end(skb, vf);
+	kfree(vf_trunk);
+	kfree(ivi);
 	return 0;
 
 nla_put_vf_failure:
 	nla_nest_cancel(skb, vf);
 nla_put_vfinfo_failure:
 	nla_nest_cancel(skb, vfinfo);
+	kfree(vf_trunk);
+	kfree(ivi);
 	return -EMSGSIZE;
 }
 
@@ -1784,6 +1806,26 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
 			return err;
 	}
 
+	if (tb[IFLA_VF_VLAN_RANGE]) {
+		struct ifla_vf_vlan_range *ivvr =
+					nla_data(tb[IFLA_VF_VLAN_RANGE]);
+		bool add = !!ivvr->setting;
+
+		err = -EOPNOTSUPP;
+		if (add && ops->ndo_add_vf_vlan_trunk_range)
+			err = ops->ndo_add_vf_vlan_trunk_range(dev, ivvr->vf,
+							       ivvr->start_vid,
+							       ivvr->end_vid,
+							       ivvr->vlan_proto);
+		else if (!add && ops->ndo_del_vf_vlan_trunk_range)
+			err = ops->ndo_del_vf_vlan_trunk_range(dev, ivvr->vf,
+							       ivvr->start_vid,
+							       ivvr->end_vid,
+							       ivvr->vlan_proto);
+		if (err < 0)
+			return err;
+	}
+
 	if (tb[IFLA_VF_VLAN_LIST]) {
 		struct ifla_vf_vlan_info *ivvl[MAX_VLAN_LIST_LEN];
 		struct nlattr *attr;
@@ -1815,21 +1857,30 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr **tb)
 
 	if (tb[IFLA_VF_TX_RATE]) {
 		struct ifla_vf_tx_rate *ivt = nla_data(tb[IFLA_VF_TX_RATE]);
-		struct ifla_vf_info ivf;
+		struct ifla_vf_info *ivf;
+
+		ivf = kzalloc(sizeof(*ivf), GFP_KERNEL);
+		if (!ivf)
+			return -ENOMEM;
 
 		err = -EOPNOTSUPP;
 		if (ops->ndo_get_vf_config)
-			err = ops->ndo_get_vf_config(dev, ivt->vf, &ivf);
-		if (err < 0)
+			err = ops->ndo_get_vf_config(dev, ivt->vf, ivf);
+		if (err < 0) {
+			kfree(ivf);
 			return err;
+		}
 
 		err = -EOPNOTSUPP;
 		if (ops->ndo_set_vf_rate)
 			err = ops->ndo_set_vf_rate(dev, ivt->vf,
-						   ivf.min_tx_rate,
+						   ivf->min_tx_rate,
 						   ivt->rate);
-		if (err < 0)
+		if (err < 0) {
+			kfree(ivf);
 			return err;
+		}
+		kfree(ivf);
 	}
 
 	if (tb[IFLA_VF_RATE]) {
-- 
2.13.0
