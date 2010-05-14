From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual port
	management (was iovnl)
Date: Thu, 13 May 2010 18:35:40 -0700
Message-ID: <20100514013526.1816.45104.stgit@savbu-pc100.cisco.com>
References: <20100514013144.1816.31191.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:25779 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001Ab0ENBfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 21:35:41 -0400
In-Reply-To: <20100514013144.1816.31191.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Add new netdev ops ndo_{set|get}_vf_port to allow setting of
port-profile on a netdev interface.  Extends netlink socket RTM_SETLINK/
RTM_GETLINK with new sub cmd called IFLA_VF_PORT (added to end of
IFLA_cmd list).

A port-profile is used to configure/enable the external switch virtual port
backing the netdev interface, not to configure the host-facing side of the
netdev.  A port-profile is an identifier known to the switch.  How port-
profiles are installed on the switch or how available port-profiles are
made know to the host is outside the scope of this patch.

There are two types of port-profiles specs in the netlink msg.  The first spec
is for 802.1Qbg (pre-)standard, VDP protocol.  The second spec is for devices
that run a similar protocol as VDP but in firmware, thus hiding the protocol
details.  In either case, the specs have much in common and makes sense to
define the netlink msg as the union of the two specs.  For example, both specs
have a notition of associating/deassociating a port-profile.  And both specs
require some information from the hypervisor manager, such as client port
instance ID.

The general flow is the port-profile is applied to a host netdev interface
using RTM_SETLINK, the receiver of the RTM_SETLINK msg communicates with the
switch, and the switch virtual port backing the host netdev interface is
configured/enabled based on the settings defined by the port-profile.  What
those settings comprise, and how those settings are managed is again
outside the scope of this patch, since this patch only deals with the
first step in the flow.

There is a RTM_GETLINK cmd to to return port-profile setting of an
interface and to also return the status of the last port-profile
association.

IFLA_VF_PORT is modeled after the existing IFLA_VF_* cmd where a
VF number is passed in to identify the virtual function (VF) of an SR-IOV-
capable device.  In this case, the target of IFLA_VF_PORT msg is the
netdev physical function (PF) device.  The PF will apply the port-profile
to the VF.  IFLA_VF_PORT can also be used for devices that don't
adhere to SR-IOV and can apply the port-profile directly to the netdev
target.  In this case, the VF number is ignored.

Passing in a NULL port-profile is used to delete the port-profile association.

Acked-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 include/linux/if_link.h   |   53 +++++++++++++++++++++
 include/linux/netdevice.h |   10 ++++
 net/core/rtnetlink.c      |  116 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 178 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index cfd420b..5522055 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -116,6 +116,7 @@ enum {
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VFINFO,
 	IFLA_STATS64,
+	IFLA_VF_PORT,
 	__IFLA_MAX
 };
 
@@ -259,4 +260,56 @@ struct ifla_vf_info {
 	__u32 qos;
 	__u32 tx_rate;
 };
+
+/* VF Port management section */
+
+enum {
+	IFLA_VF_PORT_UNSPEC,
+	IFLA_VF_PORT_VF,		/* __u32 */
+	IFLA_VF_PORT_PROFILE,		/* string */
+	IFLA_VF_PORT_VSI_TYPE,		/* 802.1Qbg (pre-)standard VDP */
+	IFLA_VF_PORT_INSTANCE_UUID,	/* binary UUID */
+	IFLA_VF_PORT_HOST_UUID,		/* binary UUID */
+	IFLA_VF_PORT_REQUEST,		/* __u8 */
+	IFLA_VF_PORT_RESPONSE,		/* __u16, output only */
+	__IFLA_VF_PORT_MAX,
+};
+
+#define IFLA_VF_PORT_MAX (__IFLA_VF_PORT_MAX - 1)
+
+#define VF_PORT_PROFILE_MAX	40
+#define VF_PORT_UUID_MAX	16
+#define VF_PORT_VF_NOT_USED	-1
+
+enum {
+	VF_PORT_REQUEST_PREASSOCIATE = 0,
+	VF_PORT_REQUEST_PREASSOCIATE_RR,
+	VF_PORT_REQUEST_ASSOCIATE,
+	VF_PORT_REQUEST_DISASSOCIATE,
+};
+
+enum {
+	VF_PORT_VDP_RESPONSE_SUCCESS = 0,
+	VF_PORT_VDP_RESPONSE_INVALID_FORMAT,
+	VF_PORT_VDP_RESPONSE_INSUFFICIENT_RESOURCES,
+	VF_PORT_VDP_RESPONSE_UNUSED_VTID,
+	VF_PORT_VDP_RESPONSE_VTID_VIOLATION,
+	VF_PORT_VDP_RESPONSE_VTID_VERSION_VIOALTION,
+	VF_PORT_VDP_RESPONSE_OUT_OF_SYNC,
+	/* 0x08-0xFF reserved for future VDP use */
+	VF_PORT_PROFILE_RESPONSE_SUCCESS = 0x100,
+	VF_PORT_PROFILE_RESPONSE_INPROGRESS,
+	VF_PORT_PROFILE_RESPONSE_INVALID,
+	VF_PORT_PROFILE_RESPONSE_BADSTATE,
+	VF_PORT_PROFILE_RESPONSE_INSUFFICIENT_RESOURCES,
+	VF_PORT_PROFILE_RESPONSE_ERROR,
+};
+
+struct ifla_vf_port_vsi {
+	__u8 vsi_mgr_id;
+	__u8 vsi_type_id[3];
+	__u8 vsi_type_version;
+	__u8 pad[3];
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 69022d4..c2ba8d4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -686,6 +686,10 @@ struct netdev_rx_queue {
  * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
+ * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
+ *			  struct nlattr *vf_port[]);
+ * int (*ndo_get_vf_port)(struct net_device *dev, int vf,
+ *			  struct sk_buff *skb);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -735,6 +739,12 @@ struct net_device_ops {
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
+	int			(*ndo_set_vf_port)(struct net_device *dev,
+						   int vf,
+						   struct nlattr *vf_port[]);
+	int			(*ndo_get_vf_port)(struct net_device *dev,
+						   int vf,
+						   struct sk_buff *skb);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 23a71cb..1e9a896 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -653,6 +653,26 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev)
 		return 0;
 }
 
+static size_t rtnl_vf_port_size(const struct net_device *dev)
+{
+	size_t vf_port_size = nla_total_size(sizeof(struct nlattr))
+						     /* VF_PORT_VF */
+		+ nla_total_size(VF_PORT_PROFILE_MAX)/* VF_PORT_PROFILE */
+		+ nla_total_size(sizeof(struct ifla_vf_port_vsi))
+						     /* VF_PORT_VSI_TYPE */
+		+ nla_total_size(VF_PORT_UUID_MAX)   /* VF_PORT_VSI_INSTANCE */
+		+ nla_total_size(VF_PORT_UUID_MAX)   /* VF_PORT_HOST_UUID */
+		+ nla_total_size(1)		     /* VF_PROT_VDP_REQUEST */
+		+ nla_total_size(2);		     /* VF_PORT_VDP_RESPONSE */
+
+	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent)
+		return 0;
+	if (dev_num_vf(dev->dev.parent))
+		return vf_port_size * dev_num_vf(dev->dev.parent);
+	else
+		return vf_port_size;
+}
+
 static inline size_t if_nlmsg_size(const struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
@@ -673,9 +693,61 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_NUM_VF */
 	       + nla_total_size(rtnl_vfinfo_size(dev)) /* IFLA_VFINFO */
+	       + rtnl_vf_port_size(dev) /* IFLA_VF_PORT */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
 }
 
+static int rtnl_vf_port_fill_nest(struct sk_buff *skb, struct net_device *dev,
+				  int vf)
+{
+	struct nlattr *data;
+	int err;
+
+	data = nla_nest_start(skb, IFLA_VF_PORT);
+	if (!data)
+		return -EMSGSIZE;
+
+	if (vf != VF_PORT_VF_NOT_USED)
+		nla_put_u32(skb, IFLA_VF_PORT_VF, vf);
+
+	err = dev->netdev_ops->ndo_get_vf_port(dev, vf, skb);
+	if (err) {
+		nla_nest_cancel(skb, data);
+		return err;
+	}
+
+	nla_nest_end(skb, data);
+
+	return 0;
+}
+
+static int rtnl_vf_port_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	int num_vf;
+	int err;
+
+	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent)
+		return 0;
+
+	num_vf = dev_num_vf(dev->dev.parent);
+
+	if (num_vf) {
+		int i;
+
+		for (i = 0; i < num_vf; i++) {
+			err = rtnl_vf_port_fill_nest(skb, dev, i);
+			if (err)
+				return err;
+		}
+	} else  {
+		err = rtnl_vf_port_fill_nest(skb, dev, VF_PORT_VF_NOT_USED);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags)
@@ -747,17 +819,23 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		goto nla_put_failure;
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
+	if (dev->dev.parent)
+		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
+
 	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
 		int i;
 		struct ifla_vf_info ivi;
 
-		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
 		for (i = 0; i < dev_num_vf(dev->dev.parent); i++) {
 			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
 				break;
 			NLA_PUT(skb, IFLA_VFINFO, sizeof(ivi), &ivi);
 		}
 	}
+
+	if (rtnl_vf_port_fill(skb, dev))
+		goto nla_put_failure;
+
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
@@ -824,6 +902,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_vlan) },
 	[IFLA_VF_TX_RATE]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct ifla_vf_tx_rate) },
+	[IFLA_VF_PORT]		= { .type = NLA_NESTED },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -832,6 +911,20 @@ static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
 	[IFLA_INFO_DATA]	= { .type = NLA_NESTED },
 };
 
+static const struct nla_policy ifla_vf_port_policy[IFLA_VF_PORT_MAX+1] = {
+	[IFLA_VF_PORT_VF]	    = { .type = NLA_U32 },
+	[IFLA_VF_PORT_PROFILE]	    = { .type = NLA_STRING,
+					.len = VF_PORT_PROFILE_MAX },
+	[IFLA_VF_PORT_VSI_TYPE]     = { .type = NLA_BINARY,
+					.len = sizeof(struct ifla_vf_port_vsi)},
+	[IFLA_VF_PORT_INSTANCE_UUID]= { .type = NLA_BINARY,
+					.len = VF_PORT_UUID_MAX },
+	[IFLA_VF_PORT_HOST_UUID]    = { .type = NLA_STRING,
+					.len = VF_PORT_UUID_MAX },
+	[IFLA_VF_PORT_REQUEST]	    = { .type = NLA_U8, },
+	[IFLA_VF_PORT_RESPONSE]	    = { .type = NLA_U16, },
+};
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
@@ -1028,6 +1121,27 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	}
 	err = 0;
 
+	if (tb[IFLA_VF_PORT]) {
+		struct nlattr *vf_port[IFLA_VF_PORT_MAX+1];
+		int vf = VF_PORT_VF_NOT_USED;
+
+		err = nla_parse_nested(vf_port, IFLA_VF_PORT_MAX,
+			tb[IFLA_VF_PORT], ifla_vf_port_policy);
+		if (err < 0)
+			goto errout;
+
+		if (vf_port[IFLA_VF_PORT_VF])
+			vf = nla_get_u32(vf_port[IFLA_VF_PORT_VF]);
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_port)
+			err = ops->ndo_set_vf_port(dev, vf, vf_port);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+	err = 0;
+
 errout:
 	if (err < 0 && modified && net_ratelimit())
 		printk(KERN_WARNING "A link change request failed with "

