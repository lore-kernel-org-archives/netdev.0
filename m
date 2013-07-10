From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH] net: add a rate_limit attribute to netdev_queue and a
 rtnetlink
Date: Wed, 10 Jul 2013 07:04:12 -0700
Message-ID: <20130710140409.6691.77084.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	therbert@google.com
To: stephen@networkplumber.org, ben@decadent.org.uk,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:55899 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022Ab3GJOFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 10:05:03 -0400
Received: by mail-ob0-f177.google.com with SMTP id ta17so8441491obb.8
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 07:05:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a rate_limit attribute to netdev_queue and a corresponding
ndo ops to pass the parameter to the driver. Also provide an
rtnetlink attribute to dump and set arbitrary queue attributes
the first of which is the rate_limit.

Netlink attribute layout shown here,

/* Queue Attributes management
 *      Nested layout of queue attributes is:
 *      [IFLA_QUEUE_ATTRIBS]
 *              [IFLA_QUEUE_ATTRIB]
 *                      [IFLA_QUEUE_INDEX]      <required>
 *                      [IFLA_QUEUE_RATE]       <optional>
 *              [IFLA_QUEUE_ATTRIB]
 *                      [...]
 */

Adding this as a queue attribute and _not_ a qdisc option allows
using rate limits with qdisc schemes that may not align with tx rings
and also allows using QOS schemes along with rate limits.

A sample implementation is provided for ixgbe. Any improvements or
suggestions welcome I would also be interested to know if this works
with other hardware and if Mbps is a good default unit.

The ndo op is only called when the netlink API is invoked, so drivers
may need to adjust internal registers on link events (speed changes)
as needed. More attributes can be added as needed.

A test patch for iproute2 will be provided.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   16 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   47 +++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |    2 +
 include/linux/netdevice.h                      |   14 ++++
 include/uapi/linux/if_link.h                   |   24 ++++++
 net/core/rtnetlink.c                           |   90 ++++++++++++++++++++++++
 6 files changed, 187 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 047ebaa..6a9b99c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5579,6 +5579,19 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 
 }
 
+static void ixgbe_reset_rate_limits(struct ixgbe_adapter *adapter)
+{
+	struct net_device *dev = adapter->netdev;
+	int i;
+
+	for (i = 0; i < dev->real_num_tx_queues; i++) {
+		struct netdev_queue *q = netdev_get_tx_queue(dev, i);
+		u32 rate = q->rate_limit;
+
+		ixgbe_set_rate_limit(adapter->netdev, i, &rate);
+	}
+}
+
 /**
  * ixgbe_watchdog_update_link - update the link status
  * @adapter: pointer to the device adapter structure
@@ -5620,6 +5633,8 @@ static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)
 
 	adapter->link_up = link_up;
 	adapter->link_speed = link_speed;
+
+	ixgbe_reset_rate_limits(adapter);
 }
 
 static void ixgbe_update_default_up(struct ixgbe_adapter *adapter)
@@ -7244,6 +7259,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
 	.ndo_bridge_setlink	= ixgbe_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
+	.ndo_set_ratelimit	= ixgbe_set_rate_limit,
 };
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 1e7d587..1ea78f1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1107,17 +1107,14 @@ static int ixgbe_link_mbps(struct ixgbe_adapter *adapter)
 	}
 }
 
-static void ixgbe_set_vf_rate_limit(struct ixgbe_adapter *adapter, int vf)
+static u32 ixgbe_bcnrc_from_rate(struct ixgbe_adapter *adapter,
+				 u16 tx_rate, int link_speed)
 {
-	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
-	struct ixgbe_hw *hw = &adapter->hw;
 	u32 bcnrc_val = 0;
-	u16 queue, queues_per_pool;
-	u16 tx_rate = adapter->vfinfo[vf].tx_rate;
 
 	if (tx_rate) {
 		/* start with base link speed value */
-		bcnrc_val = adapter->vf_rate_link_speed;
+		bcnrc_val = link_speed;
 
 		/* Calculate the rate factor values to set */
 		bcnrc_val <<= IXGBE_RTTBCNRC_RF_INT_SHIFT;
@@ -1131,6 +1128,11 @@ static void ixgbe_set_vf_rate_limit(struct ixgbe_adapter *adapter, int vf)
 		bcnrc_val |= IXGBE_RTTBCNRC_RS_ENA;
 	}
 
+	return bcnrc_val;
+}
+
+static void ixgbe_set_xmit_compensation(struct ixgbe_hw *hw)
+{
 	/*
 	 * Set global transmit compensation time to the MMW_SIZE in RTTBCNRM
 	 * register. Typically MMW_SIZE=0x014 if 9728-byte jumbo is supported
@@ -1146,6 +1148,39 @@ static void ixgbe_set_vf_rate_limit(struct ixgbe_adapter *adapter, int vf)
 	default:
 		break;
 	}
+}
+
+int ixgbe_set_rate_limit(struct net_device *dev, int index, u32 *tx_rate)
+{
+	struct ixgbe_adapter *a = netdev_priv(dev);
+	struct ixgbe_hw *hw = &a->hw;
+	int linkspeed = ixgbe_link_mbps(a);
+	u8 reg_idx = a->tx_ring[index]->reg_idx;
+	u32 bcnrc = ixgbe_bcnrc_from_rate(a, *tx_rate, linkspeed);
+
+	/* rate limit cannot be less than 10Mbs */
+	if (*tx_rate && (*tx_rate <= 10))
+		return -EINVAL;
+
+	ixgbe_set_xmit_compensation(hw);
+
+	IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, reg_idx);
+	IXGBE_WRITE_REG(hw, IXGBE_RTTBCNRC, bcnrc);
+
+	return 0;
+}
+
+static void ixgbe_set_vf_rate_limit(struct ixgbe_adapter *adapter, int vf)
+{
+	struct ixgbe_ring_feature *vmdq = &adapter->ring_feature[RING_F_VMDQ];
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 bcnrc_val = 0;
+	u16 queue, queues_per_pool;
+	u16 tx_rate = adapter->vfinfo[vf].tx_rate;
+
+	bcnrc_val = ixgbe_bcnrc_from_rate(adapter, tx_rate,
+					  adapter->vf_rate_link_speed);
+	ixgbe_set_xmit_compensation(hw);
 
 	/* determine how many queues per pool based on VMDq mask */
 	queues_per_pool = __ALIGN_MASK(1, ~vmdq->mask);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 4713f9f..d8b4bbe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -56,5 +56,7 @@ static inline void ixgbe_set_vmvir(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_VMVIR(vf), vmvir);
 }
 
+int ixgbe_set_rate_limit(struct net_device *dev, int index, u32 *tx_rate);
+
 #endif /* _IXGBE_SRIOV_H_ */
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 09b4188..0e67b09 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -574,6 +574,7 @@ struct netdev_queue {
 #ifdef CONFIG_BQL
 	struct dql		dql;
 #endif
+	u32			rate_limit;
 } ____cacheline_aligned_in_smp;
 
 static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
@@ -932,6 +933,16 @@ struct netdev_fcoe_hbainfo {
  *	that determine carrier state from physical hardware properties (eg
  *	network cables) or protocol-dependent mechanisms (eg
  *	USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
+ *
+ * int (*ndo_set_ratelimit)(struct net_device *dev,
+ *			    int queue_index, u32 *maxrate)
+ *	Called to set the rate limit in Mpbs of the specified queue_index
+ *	setting the limit to maxrate. It is expected that hardware may
+ *	quantize the rate limits. In these cases the driver should guarantee the
+ *	specified maxrate is not exceeded and return the set value in maxrate.
+ *	Zero should be returned on success otherwise use appropriate error code.
+ *	Drivers must handle any updates required with link speed changes within
+ *	normal driver code paths.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1060,6 +1071,9 @@ struct net_device_ops {
 						      struct nlmsghdr *nlh);
 	int			(*ndo_change_carrier)(struct net_device *dev,
 						      bool new_carrier);
+	int			(*ndo_set_ratelimit)(struct net_device *dev,
+						     int queue_index,
+						     u32 *max_rate);
 };
 
 /*
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 03f6170..67a353c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -143,6 +143,7 @@ enum {
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
+	IFLA_QUEUE_ATTRIBS,
 	__IFLA_MAX
 };
 
@@ -449,6 +450,29 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* Queue Attributes management
+ *	Nested layout of queue attributes is:
+ *	[IFLA_QUEUE_ATTRIBS]
+ *		[IFLA_QUEUE_ATTRIB]
+ *			[IFLA_QUEUE_INDEX]	<required>
+ *			[IFLA_QUEUE_RATE]	<optional>
+ *		[IFLA_QUEUE_ATTRIB]
+ *			[...]
+ */
+enum {
+	IFLA_QUEUE_ATTRIB_UNSPEC,
+	IFLA_QUEUE_ATTRIB,			/* nest */
+	__IFLA_QUEUE_ATTRIB_MAX,
+};
+#define IFLA_QUEUE_ATTRIB_MAX (__IFLA_QUEUE_ATTRIB_MAX - 1)
+
+enum {
+	IFLA_QUEUE_UNSPEC,
+	IFLA_QUEUE_INDEX,		/* __u32 */
+	IFLA_QUEUE_RATE,		/* __u32 */
+	__IFLA_QUEUE_MAX,
+};
+#define IFLA_QUEUE_MAX (__IFLA_QUEUE_MAX - 1)
 
 /* IPoIB section */
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9007533..d7ff1c2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -846,6 +846,45 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int rtnl_queue_fill(struct sk_buff *skb, struct net_device *dev)
+{
+	int i;
+	struct nlattr *attribs, *attrib = NULL;
+
+	attribs = nla_nest_start(skb, IFLA_QUEUE_ATTRIBS);
+	if (!attribs)
+		return -EMSGSIZE;
+
+	for (i = 0; i < dev->real_num_tx_queues; i++) {
+		struct netdev_queue *q = netdev_get_tx_queue(dev, i);
+
+		if (!q->rate_limit)
+			continue;
+
+		attrib = nla_nest_start(skb, IFLA_QUEUE_ATTRIB);
+		if (!attrib) {
+			nla_nest_cancel(skb, attribs);
+			return -EMSGSIZE;
+		}
+
+		if (nla_put_u32(skb, IFLA_QUEUE_INDEX, i) ||
+		    nla_put_u32(skb, IFLA_QUEUE_RATE, q->rate_limit)) {
+			nla_nest_cancel(skb, attrib);
+			nla_nest_cancel(skb, attribs);
+			return -EMSGSIZE;
+		}
+
+		nla_nest_end(skb, attrib);
+	}
+
+	if (attrib)
+		nla_nest_end(skb, attribs);
+	else
+		nla_nest_cancel(skb, attribs);
+
+	return 0;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask)
@@ -997,6 +1036,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_port_fill(skb, dev))
 		goto nla_put_failure;
 
+	if (rtnl_queue_fill(skb, dev))
+		goto nla_put_failure;
+
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
@@ -1150,6 +1192,11 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
 };
 
+static const struct nla_policy ifla_queue_policy[IFLA_QUEUE_MAX+1] = {
+	[IFLA_QUEUE_INDEX]	= { .type = NLA_U32},
+	[IFLA_QUEUE_RATE]	= { .type = NLA_U32},
+};
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
@@ -1503,6 +1550,49 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			goto errout;
 		modified = 1;
 	}
+	if (tb[IFLA_QUEUE_ATTRIBS]) {
+		struct nlattr *attr;
+		int rem;
+
+		nla_for_each_nested(attr, tb[IFLA_QUEUE_ATTRIBS], rem) {
+			struct nlattr *queue[IFLA_QUEUE_MAX+1];
+			struct netdev_queue *q = NULL;
+			unsigned int qindex, qrate;
+
+			if (nla_type(attr) != IFLA_QUEUE_ATTRIB)
+				continue;
+
+			err = nla_parse_nested(queue, IFLA_QUEUE_MAX,
+					       attr, ifla_queue_policy);
+			if  (err < 0)
+				goto errout;
+
+			err = -EINVAL;
+			if (queue[IFLA_QUEUE_INDEX]) {
+				qindex = nla_get_u32(queue[IFLA_QUEUE_INDEX]);
+				if (qindex >= dev->real_num_tx_queues)
+					goto errout;
+
+				q = netdev_get_tx_queue(dev, qindex);
+			} else {
+				goto errout;
+			}
+
+			err = -EOPNOTSUPP;
+			if (queue[IFLA_QUEUE_RATE]) {
+				if (!ops->ndo_set_ratelimit)
+					goto errout;
+
+				qrate = nla_get_u32(queue[IFLA_QUEUE_RATE]);
+				err = ops->ndo_set_ratelimit(dev,
+							     qindex, &qrate);
+				if (err < 0)
+					goto errout;
+				q->rate_limit = qrate;
+				modified = 1;
+			}
+		}
+	}
 
 	if (tb[IFLA_AF_SPEC]) {
 		struct nlattr *af;
