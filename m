From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] virtif: initial interface extensions
Date: Sun, 9 May 2010 01:20:19 +0200
Message-ID: <201005090120.19958.arnd@arndb.de>
References: <C8083A0F.2EC10%scofeldm@cisco.com> <201005061842.51981.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:50949 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab0EHXUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 May 2010 19:20:25 -0400
In-Reply-To: <201005061842.51981.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building on the work of Scott Feldman, this extends the netlink interface
to deal with not only port profiles but also CDCP multichannel and VDP
VSI registration.

The protocols are split apart into separate netlink attributes for
a cleaner separation. A device can have multiple IFLA_VIRTIF attributes,
each pointing to one of the slaves that get registered using one of
the protocols. In case of VDP, each IFLA_VIRTIF attribute needs
both an IFLA_VIRTIF_VSI and one or more IFLA_VIRTIF_VSI_MAC_VLAN
attributes.

The VF number is split out because it only makes sense when the
implementation is in the device driver or firmware, but not for
software-only implementations like we do for the initial VDP code
using LLDPAD. If a IFLA_VIRTIF_VF attribute is given, the kernel
takes care of the association through the device driver for that
VF, otherwise we do it in user space. This should work for each
of the three protocols.

This code is a first rough prototype, completely untested and
very likely buggy. This is also the first time I'm trying
to deal with netlink in the kernel, so chances are that I've
misunderstood something in a major way.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/if_link.h   |   81 ++++++++++++++++++++++++++++------
 include/linux/netdevice.h |    8 ++--
 net/core/rtnetlink.c      |  106 ++++++++++++++++++++++++++++++++++-----------
 3 files changed, 152 insertions(+), 43 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index d763358..675d190 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -116,7 +116,7 @@ enum {
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VFINFO,
 	IFLA_STATS64,
-	IFLA_VF_PORT_PROFILE,
+	IFLA_VIRTIF,
 	__IFLA_MAX
 };
 
@@ -262,26 +262,79 @@ struct ifla_vf_info {
 };
 
 enum {
-	IFLA_VF_PORT_PROFILE_STATUS_UNKNOWN,
-	IFLA_VF_PORT_PROFILE_STATUS_SUCCESS,
-	IFLA_VF_PORT_PROFILE_STATUS_INPROGRESS,
-	IFLA_VF_PORT_PROFILE_STATUS_ERROR,
+	IFLA_VIRTIF_UNSPEC,
+	IFLA_VIRTIF_VF,
+	IFLA_VIRTIF_PORT_PROFILE, /* Cisco enic */
+	IFLA_VIRTIF_CHANNEL,	  /* 802.1Qbg CDCP */
+	IFLA_VIRTIF_VSI,	  /* 802.1Qbg VDP */
+	IFLA_VIRTIF_VSI_MAC_VLAN,
+	__IFLA_VIRTIF_MAX,
 };
 
-#define IFLA_VF_PORT_PROFILE_MAX	40
-#define IFLA_VF_UUID_MAX		40
-#define IFLA_VF_CLIENT_NAME_MAX		40
+#define IFLA_VIRTIF_MAX (__IFLA_VIRTIF_MAX - 1)
 
-struct ifla_vf_port_profile {
-	__u32 vf;
+enum {
+	VIRTIF_PORT_PROFILE_STATUS_UNKNOWN,
+	VIRTIF_PORT_PROFILE_STATUS_SUCCESS,
+	VIRTIF_PORT_PROFILE_STATUS_INPROGRESS,
+	VIRTIF_PORT_PROFILE_STATUS_ERROR,
+};
+
+#define VIRTIF_PORT_PROFILE_MAX	40
+#define VIRTIF_UUID_MAX		40
+#define VIRTIF_CLIENT_NAME_MAX	40
+
+struct ifla_virtif_port_profile {
 	__u32 flags;
 	__u32 status;
-	__u8 port_profile[IFLA_VF_PORT_PROFILE_MAX];
+	__u8 port_profile[VIRTIF_PORT_PROFILE_MAX];
 	__u8 mac[32];					/* MAX_ADDR_LEN */
 	/* UUID e.g. "CEEFD3B1-9E11-11DE-BDFD-000BAB01C0FB" */
-	__u8 host_uuid[IFLA_VF_UUID_MAX];
-	__u8 client_uuid[IFLA_VF_UUID_MAX];
-	__u8 client_name[IFLA_VF_CLIENT_NAME_MAX];	/* e.g. "vm0-eth1" */
+	__u8 host_uuid[VIRTIF_UUID_MAX];
+	__u8 client_uuid[VIRTIF_UUID_MAX];
+	__u8 client_name[VIRTIF_CLIENT_NAME_MAX];	/* e.g. "vm0-eth1" */
+};
+
+/*
+ * CDCP and VDP come from the 802.1Qbg standard, these definitions are taken
+ * from the respective TLV definitions in there. Adapters implementing CDCP
+ * or VDP can encapsulate the structures in LLDP/ECP headers and send them
+ * to the switch.
+ */
+struct ifla_virtif_channel {
+	__u16 scid;	/* S-Channel ID */
+	__u16 svid;	/* S-VLAN ID */
+};
+
+enum {
+	VIRTIF_VDP_REQUEST_PREASSOCIATE = 0,
+	VIRVIF_VDP_REQUEST_PREASSOCIATE_RR,
+	VIRVIF_VDP_REQUEST_ASSOCIATE,
+	VIRVIF_VDP_REQUEST_DISASSOCIATE,
+};
+
+enum {
+	VIRTIF_VDP_RESPONSE_SUCCESS = 0,
+	VIRTIF_VDP_RESPONSE_INVALID_FORMAT,
+	VIRTIF_VDP_RESPONSE_INSUFFICIENT_RESOURCES,
+	VIRTIF_VDP_RESPONSE_UNUSED_VTID,
+	VIRTIF_VDP_RESPONSE_VTID_VIOLATION,
+	VIRTIF_VDP_RESPONSE_VTID_VERSION_VIOLATION,
+	VIRTIF_VDP_RESPONSE_OUT_OF_SYNC,
+};
+
+struct ifla_virtif_vsi {
+	__u8 mode_request;
+	__u8 mode_response;
+	__u8 vsi_mgr_id;	/* these three define the policy */
+	__u8 vsi_type_id[3]; 	/*   for the guest */
+	__u8 vsi_type_version;
+	__u8 vsi_instance[16];	/* identifies the guest */
+};
+
+struct ifla_virtif_vsi_mac_vlan {
+	__u8 mac[6];
+	__u8 vlan_id[2];
 };
 
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f5b0be5..d549a3d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -687,9 +687,9 @@ struct netdev_rx_queue {
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
  * int (*ndo_set_vf_port_profile)(struct net_device *dev, int vf,
- *				  struct ifla_vf_port_profile *ivp);
+ *				  struct virtif_port_profile *ivp);
  * int (*ndo_get_vf_port_profile)(struct net_device *dev, int vf,
- *				  struct ifla_vf_port_profile *ivp);
+ *				  struct virtif_port_profile *ivp);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -741,10 +741,10 @@ struct net_device_ops {
 						     struct ifla_vf_info *ivf);
 	int			(*ndo_set_vf_port_profile)(
 					struct net_device *dev, int vf,
-					struct ifla_vf_port_profile *ivp);
+					struct ifla_virtif_port_profile *ivp);
 	int			(*ndo_get_vf_port_profile)(
 					struct net_device *dev, int vf,
-					struct ifla_vf_port_profile *ivp);
+					struct ifla_virtif_port_profile *ivp);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d2ef45b..cf5e328 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -653,6 +653,22 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev)
 		return 0;
 }
 
+static size_t rtnl_virtif_get_size(const struct net_device *dev)
+{
+	size_t total = 0;
+
+	if (dev->netdev_ops->ndo_get_vf_port_profile) {
+		total = dev_num_vf(dev->dev.parent) *
+			(nla_total_size(sizeof(struct ifla_virtif_port_profile))
+			 + nla_total_size(4)); /* IFLA_VIRTIF_VF */
+	}
+
+	/* fill in IFLA_VIRTIF_CHANNEL and IFLA_VIRTIF_VSI when needed */
+		
+	return total;
+}
+
+
 static inline size_t if_nlmsg_size(const struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
@@ -674,6 +690,38 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(4) /* IFLA_NUM_VF */
 	       + nla_total_size(rtnl_vfinfo_size(dev)) /* IFLA_VFINFO */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
+	       + rtnl_virtif_get_size(dev); /* IFLA_VIRTIF */
+}
+
+static int rtnl_virtif_fill_ifinfo(struct sk_buff *skb, struct net_device *dev)
+{
+	if (dev->netdev_ops->ndo_get_vf_port_profile && dev->dev.parent) {
+		struct ifla_virtif_port_profile ivp;
+
+		if (dev_num_vf(dev->dev.parent)) {
+			int i;
+
+			for (i = 0; i < dev_num_vf(dev->dev.parent); i++) {
+				if (dev->netdev_ops->ndo_get_vf_port_profile(
+					dev, i, &ivp))
+					break;
+				NLA_PUT_U32(skb, IFLA_VIRTIF_VF, i);
+				NLA_PUT(skb, IFLA_VIRTIF_PORT_PROFILE,
+					sizeof(ivp), &ivp);
+			}
+		}
+#if 0 /* Not sure how we should do this -arnd */
+		 else if (!dev->netdev_ops->ndo_get_vf_port_profile(dev,
+			0, &ivp)) {
+			NLA_PUT(skb, VIRTIF_PORT_PROFILE,
+				sizeof(ivp), &ivp);
+		}
+#endif
+	}
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
 }
 
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
@@ -761,25 +809,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	if (dev->netdev_ops->ndo_get_vf_port_profile && dev->dev.parent) {
-		struct ifla_vf_port_profile ivp;
-
-		if (dev_num_vf(dev->dev.parent)) {
-			int i;
-
-			for (i = 0; i < dev_num_vf(dev->dev.parent); i++) {
-				if (dev->netdev_ops->ndo_get_vf_port_profile(
-					dev, i, &ivp))
-					break;
-				NLA_PUT(skb, IFLA_VF_PORT_PROFILE,
-					sizeof(ivp), &ivp);
-			}
-		} else if (!dev->netdev_ops->ndo_get_vf_port_profile(dev,
-			0, &ivp)) {
-			NLA_PUT(skb, IFLA_VF_PORT_PROFILE,
-				sizeof(ivp), &ivp);
-		}
-	}
+	if (rtnl_virtif_fill_ifinfo(skb, dev))
+		goto nla_put_failure;
 
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
@@ -847,8 +878,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_vlan) },
 	[IFLA_VF_TX_RATE]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct ifla_vf_tx_rate) },
-	[IFLA_VF_PORT_PROFILE]	= { .type = NLA_BINARY,
-				    .len = sizeof(struct ifla_vf_port_profile)},
+	[IFLA_VIRTIF]		= { .type = NLA_NESTED },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -857,6 +887,18 @@ static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
 	[IFLA_INFO_DATA]	= { .type = NLA_NESTED },
 };
 
+static const struct nla_policy ifla_virtif_policy[IFLA_VIRTIF_MAX+1] = {
+	[IFLA_VIRTIF_VF]	   = { .type = NLA_U32 },
+	[IFLA_VIRTIF_PORT_PROFILE] = { .type = NLA_BINARY,
+				       .len = sizeof(struct ifla_virtif_port_profile) },
+	[IFLA_VIRTIF_CHANNEL]	   = { .type = NLA_BINARY,
+				       .len = sizeof(struct ifla_virtif_channel) },
+	[IFLA_VIRTIF_VSI]	   = { .type = NLA_BINARY,
+				       .len = sizeof(struct ifla_virtif_vsi) },
+	[IFLA_VIRTIF_VSI_MAC_VLAN] = { .type = NLA_BINARY,
+				       .len = sizeof(struct ifla_virtif_vsi_mac_vlan) },
+};
+				    
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
@@ -1053,16 +1095,30 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	}
 	err = 0;
 
-	if (tb[IFLA_VF_PORT_PROFILE]) {
-		struct ifla_vf_port_profile *ivp;
-		ivp = nla_data(tb[IFLA_VF_PORT_PROFILE]);
+	if (tb[IFLA_VIRTIF]) {
+		struct ifla_virtif_port_profile *ivp;
+		struct nlattr *virtif[IFLA_VIRTIF_MAX+1];
+		u32 vf;
+
+		err = nla_parse_nested(virtif, IFLA_VIRTIF_MAX,
+				       tb[IFLA_VIRTIF], ifla_virtif_policy);
+		if (err < 0)
+			return err;
+
+		if (!virtif[IFLA_VIRTIF_VF] || !virtif[IFLA_VIRTIF_PORT_PROFILE])
+			goto novirtif; /* IFLA_VIRTIF may be directed at user space */
+
+		vf = nla_get_u32(virtif[IFLA_VIRTIF_VF]);
+		ivp = nla_data(virtif[IFLA_VIRTIF_PORT_PROFILE]);
+
 		err = -EOPNOTSUPP;
 		if (ops->ndo_set_vf_port_profile)
-			err = ops->ndo_set_vf_port_profile(dev, ivp->vf, ivp);
+			err = ops->ndo_set_vf_port_profile(dev, vf, ivp);
 		if (err < 0)
 			goto errout;
 		modified = 1;
 	}
+novirtif:
 	err = 0;
 
 errout:
-- 
1.6.3.3

