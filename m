From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 V9 PATCH 1/2] Add netlink support for virtual port
	management (was iovnl)
Date: Mon, 17 May 2010 22:48:35 -0700
Message-ID: <20100518054833.21787.45456.stgit@savbu-pc100.cisco.com>
References: <20100518054330.21787.29398.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:17902 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127Ab0ERFsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:48:36 -0400
In-Reply-To: <20100518054330.21787.29398.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Add new netdev ops ndo_{set|get}_vf_port to allow setting of
port-profile on a netdev interface.  Extends netlink socket RTM_SETLINK/
RTM_GETLINK with two new sub msgs called IFLA_VF_PORTS and IFLA_PORT_SELF
(added to end of IFLA_cmd list).  These are both nested atrtibutes
using this layout:

              [IFLA_NUM_VF]
              [IFLA_VF_PORTS]
                      [IFLA_VF_PORT]
                              [IFLA_PORT_*], ...
                      [IFLA_VF_PORT]
                              [IFLA_PORT_*], ...
                      ...
              [IFLA_PORT_SELF]
                      [IFLA_PORT_*], ...

These attributes are design to be set and get symmetrically.  VF_PORTS
is a list of VF_PORTs, one for each VF, when dealing with an SR-IOV
device.  PORT_SELF is for the PF of the SR-IOV device, in case it wants
to also have a port-profile, or for the case where the VF==PF, like in
enic patch 2/2 of this patch set.

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

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
---
 include/linux/if_link.h   |   75 ++++++++++++++++++++
 include/linux/netdevice.h |    8 ++
 net/core/rtnetlink.c      |  169 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 251 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c3af67f..85c812d 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -113,6 +113,8 @@ enum {
 	IFLA_NUM_VF,		/* Number of VFs if device is SR-IOV PF */
 	IFLA_VFINFO_LIST,
 	IFLA_STATS64,
+	IFLA_VF_PORTS,
+	IFLA_PORT_SELF,
 	__IFLA_MAX
 };
 
@@ -274,4 +276,77 @@ struct ifla_vf_info {
 	__u32 qos;
 	__u32 tx_rate;
 };
+
+/* VF ports management section
+ *
+ *	Nested layout of set/get msg is:
+ *
+ *		[IFLA_NUM_VF]
+ *		[IFLA_VF_PORTS]
+ *			[IFLA_VF_PORT]
+ *				[IFLA_PORT_*], ...
+ *			[IFLA_VF_PORT]
+ *				[IFLA_PORT_*], ...
+ *			...
+ *		[IFLA_PORT_SELF]
+ *			[IFLA_PORT_*], ...
+ */
+
+enum {
+	IFLA_VF_PORT_UNSPEC,
+	IFLA_VF_PORT,			/* nest */
+	__IFLA_VF_PORT_MAX,
+};
+
+#define IFLA_VF_PORT_MAX (__IFLA_VF_PORT_MAX - 1)
+
+enum {
+	IFLA_PORT_UNSPEC,
+	IFLA_PORT_VF,			/* __u32 */
+	IFLA_PORT_PROFILE,		/* string */
+	IFLA_PORT_VSI_TYPE,		/* 802.1Qbg (pre-)standard VDP */
+	IFLA_PORT_INSTANCE_UUID,	/* binary UUID */
+	IFLA_PORT_HOST_UUID,		/* binary UUID */
+	IFLA_PORT_REQUEST,		/* __u8 */
+	IFLA_PORT_RESPONSE,		/* __u16, output only */
+	__IFLA_PORT_MAX,
+};
+
+#define IFLA_PORT_MAX (__IFLA_PORT_MAX - 1)
+
+#define PORT_PROFILE_MAX	40
+#define PORT_UUID_MAX		16
+#define PORT_SELF_VF		-1
+
+enum {
+	PORT_REQUEST_PREASSOCIATE = 0,
+	PORT_REQUEST_PREASSOCIATE_RR,
+	PORT_REQUEST_ASSOCIATE,
+	PORT_REQUEST_DISASSOCIATE,
+};
+
+enum {
+	PORT_VDP_RESPONSE_SUCCESS = 0,
+	PORT_VDP_RESPONSE_INVALID_FORMAT,
+	PORT_VDP_RESPONSE_INSUFFICIENT_RESOURCES,
+	PORT_VDP_RESPONSE_UNUSED_VTID,
+	PORT_VDP_RESPONSE_VTID_VIOLATION,
+	PORT_VDP_RESPONSE_VTID_VERSION_VIOALTION,
+	PORT_VDP_RESPONSE_OUT_OF_SYNC,
+	/* 0x08-0xFF reserved for future VDP use */
+	PORT_PROFILE_RESPONSE_SUCCESS = 0x100,
+	PORT_PROFILE_RESPONSE_INPROGRESS,
+	PORT_PROFILE_RESPONSE_INVALID,
+	PORT_PROFILE_RESPONSE_BADSTATE,
+	PORT_PROFILE_RESPONSE_INSUFFICIENT_RESOURCES,
+	PORT_PROFILE_RESPONSE_ERROR,
+};
+
+struct ifla_port_vsi {
+	__u8 vsi_mgr_id;
+	__u8 vsi_type_id[3];
+	__u8 vsi_type_version;
+	__u8 pad[3];
+};
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c1b2341..c3487a6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -686,6 +686,9 @@ struct netdev_rx_queue {
  * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
  * int (*ndo_get_vf_config)(struct net_device *dev,
  *			    int vf, struct ifla_vf_info *ivf);
+ * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
+ *			  struct nlattr *port[]);
+ * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -735,6 +738,11 @@ struct net_device_ops {
 	int			(*ndo_get_vf_config)(struct net_device *dev,
 						     int vf,
 						     struct ifla_vf_info *ivf);
+	int			(*ndo_set_vf_port)(struct net_device *dev,
+						   int vf,
+						   struct nlattr *port[]);
+	int			(*ndo_get_vf_port)(struct net_device *dev,
+						   int vf, struct sk_buff *skb);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 66db120..e4b9870 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -660,6 +660,31 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev)
 		return 0;
 }
 
+static size_t rtnl_port_size(const struct net_device *dev)
+{
+	size_t port_size = nla_total_size(4)		/* PORT_VF */
+		+ nla_total_size(PORT_PROFILE_MAX)	/* PORT_PROFILE */
+		+ nla_total_size(sizeof(struct ifla_port_vsi))
+							/* PORT_VSI_TYPE */
+		+ nla_total_size(PORT_UUID_MAX)		/* PORT_INSTANCE_UUID */
+		+ nla_total_size(PORT_UUID_MAX)		/* PORT_HOST_UUID */
+		+ nla_total_size(1)			/* PROT_VDP_REQUEST */
+		+ nla_total_size(2);			/* PORT_VDP_RESPONSE */
+	size_t vf_ports_size = nla_total_size(sizeof(struct nlattr));
+	size_t vf_port_size = nla_total_size(sizeof(struct nlattr))
+		+ port_size;
+	size_t port_self_size = nla_total_size(sizeof(struct nlattr))
+		+ port_size;
+
+	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent)
+		return 0;
+	if (dev_num_vf(dev->dev.parent))
+		return port_self_size + vf_ports_size +
+			vf_port_size * dev_num_vf(dev->dev.parent);
+	else
+		return port_self_size;
+}
+
 static inline size_t if_nlmsg_size(const struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
@@ -680,9 +705,82 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
+	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
 }
 
+static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	struct nlattr *vf_ports;
+	struct nlattr *vf_port;
+	int vf;
+	int err;
+
+	vf_ports = nla_nest_start(skb, IFLA_VF_PORTS);
+	if (!vf_ports)
+		return -EMSGSIZE;
+
+	for (vf = 0; vf < dev_num_vf(dev->dev.parent); vf++) {
+		vf_port = nla_nest_start(skb, IFLA_VF_PORT);
+		if (!vf_port) {
+			nla_nest_cancel(skb, vf_ports);
+			return -EMSGSIZE;
+		}
+		NLA_PUT_U32(skb, IFLA_PORT_VF, vf);
+		err = dev->netdev_ops->ndo_get_vf_port(dev, vf, skb);
+		if (err) {
+nla_put_failure:
+			nla_nest_cancel(skb, vf_port);
+			continue;
+		}
+		nla_nest_end(skb, vf_port);
+	}
+
+	nla_nest_end(skb, vf_ports);
+
+	return 0;
+}
+
+static int rtnl_port_self_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	struct nlattr *port_self;
+	int err;
+
+	port_self = nla_nest_start(skb, IFLA_PORT_SELF);
+	if (!port_self)
+		return -EMSGSIZE;
+
+	err = dev->netdev_ops->ndo_get_vf_port(dev, PORT_SELF_VF, skb);
+	if (err) {
+		nla_nest_cancel(skb, port_self);
+		return err;
+	}
+
+	nla_nest_end(skb, port_self);
+
+	return 0;
+}
+
+static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	int err;
+
+	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent)
+		return 0;
+
+	err = rtnl_port_self_fill(skb, dev);
+	if (err)
+		return err;
+
+	if (dev_num_vf(dev->dev.parent)) {
+		err = rtnl_vf_ports_fill(skb, dev);
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
@@ -754,13 +852,15 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		goto nla_put_failure;
 	copy_rtnl_link_stats64(nla_data(attr), stats);
 
+	if (dev->dev.parent)
+		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
+
 	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
 		int i;
 
 		struct nlattr *vfinfo, *vf;
 		int num_vfs = dev_num_vf(dev->dev.parent);
 
-		NLA_PUT_U32(skb, IFLA_NUM_VF, num_vfs);
 		vfinfo = nla_nest_start(skb, IFLA_VFINFO_LIST);
 		if (!vfinfo)
 			goto nla_put_failure;
@@ -788,6 +888,10 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		}
 		nla_nest_end(skb, vfinfo);
 	}
+
+	if (rtnl_port_fill(skb, dev))
+		goto nla_put_failure;
+
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
@@ -849,6 +953,8 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
 	[IFLA_VFINFO_LIST]	= {. type = NLA_NESTED },
+	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
+	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -870,6 +976,20 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 				    .len = sizeof(struct ifla_vf_tx_rate) },
 };
 
+static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
+	[IFLA_PORT_VF]		= { .type = NLA_U32 },
+	[IFLA_PORT_PROFILE]	= { .type = NLA_STRING,
+				    .len = PORT_PROFILE_MAX },
+	[IFLA_PORT_VSI_TYPE]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_port_vsi)},
+	[IFLA_PORT_INSTANCE_UUID] = { .type = NLA_BINARY,
+				      .len = PORT_UUID_MAX },
+	[IFLA_PORT_HOST_UUID]	= { .type = NLA_STRING,
+				    .len = PORT_UUID_MAX },
+	[IFLA_PORT_REQUEST]	= { .type = NLA_U8, },
+	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
+};
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
@@ -1089,6 +1209,53 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	}
 	err = 0;
 
+	if (tb[IFLA_VF_PORTS]) {
+		struct nlattr *port[IFLA_PORT_MAX+1];
+		struct nlattr *attr;
+		int vf;
+		int rem;
+
+		err = -EOPNOTSUPP;
+		if (!ops->ndo_set_vf_port)
+			goto errout;
+
+		nla_for_each_nested(attr, tb[IFLA_VF_PORTS], rem) {
+			if (nla_type(attr) != IFLA_VF_PORT)
+				continue;
+			err = nla_parse_nested(port, IFLA_PORT_MAX,
+				attr, ifla_port_policy);
+			if (err < 0)
+				goto errout;
+			if (!port[IFLA_PORT_VF]) {
+				err = -EOPNOTSUPP;
+				goto errout;
+			}
+			vf = nla_get_u32(port[IFLA_PORT_VF]);
+			err = ops->ndo_set_vf_port(dev, vf, port);
+			if (err < 0)
+				goto errout;
+			modified = 1;
+		}
+	}
+	err = 0;
+
+	if (tb[IFLA_PORT_SELF]) {
+		struct nlattr *port[IFLA_PORT_MAX+1];
+
+		err = nla_parse_nested(port, IFLA_PORT_MAX,
+			tb[IFLA_PORT_SELF], ifla_port_policy);
+		if (err < 0)
+			goto errout;
+
+		err = -EOPNOTSUPP;
+		if (ops->ndo_set_vf_port)
+			err = ops->ndo_set_vf_port(dev, PORT_SELF_VF, port);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+	err = 0;
+
 errout:
 	if (err < 0 && modified && net_ratelimit())
 		printk(KERN_WARNING "A link change request failed with "

