From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH] net: add a tx_queue attribute rate_queue_limits in Mbps
Date: Sun, 23 Jun 2013 20:24:11 -0700
Message-ID: <20130624032407.7546.96685.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f180.google.com ([209.85.160.180]:41114 "EHLO
	mail-gh0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab3FXDYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 23:24:42 -0400
Received: by mail-gh0-f180.google.com with SMTP id f18so3199515ghb.25
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 20:24:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a rate_queue_limit attribute to the tx_queue sysfs entry
to allow rate limiting in units of Mpbs. Along with mqprio and BQL
this provides another knob to tune queue performance. By default it
is disabled with a setting of '0'.

By adding this as a queue attribute and _not_ a qdisc option allows
using rate limits with qdisc schemes that may not align with tx rings
and also allows using QOS schemes along with rate limits.

A sample implementation is provided for ixgbe. Any improvements or
suggestions welcome I would also be interested to know if this works
with other hardware and if Mbps is a good default unit.

I tested this briefly with iperf/netperf,

# echo 4000 > /sys/class/net/p3p2/queues/tx-0/tx_rate_limit
# cat /sys/class/net/p3p2/queues/tx-0/tx_rate_limit
4000

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    1 
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   47 ++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |    2 +
 include/linux/netdevice.h                      |   12 ++++
 net/core/net-sysfs.c                           |   69 +++++++++++++++++++-----
 5 files changed, 110 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 047ebaa..8d168a0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7244,6 +7244,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
 	.ndo_bridge_setlink	= ixgbe_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
+	.ndo_set_ratelimit	= ixgbe_set_rate_limit,
 };
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 1e7d587..22f3df2 100644
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
+	/* rate limit cannot be less than 10Mbs or greater than link speed */
+	if (*tx_rate && ((*tx_rate <= 10) || (*tx_rate > linkspeed)))
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
index 09b4188..d84d69a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -574,6 +574,7 @@ struct netdev_queue {
 #ifdef CONFIG_BQL
 	struct dql		dql;
 #endif
+	unsigned long		rate_limit;
 } ____cacheline_aligned_in_smp;
 
 static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
@@ -932,6 +933,14 @@ struct netdev_fcoe_hbainfo {
  *	that determine carrier state from physical hardware properties (eg
  *	network cables) or protocol-dependent mechanisms (eg
  *	USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
+ *
+ * int (*ndo_set_ratelimit)(struct net_device *dev,
+ *			    int queue_index, u32 *maxrate)
+ *	Called to set the rate limit in Mpbs specified by maxrate of the
+ *	specified queue_index. It is expected that hardware way may quantize
+ *	the rate limits. In these cases the driver should guarentee the
+ *	specfied maxrate is not exceeded and return the set value in maxrate.
+ *	Zero should be returned on sucess otherwise use appropriate error code.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1060,6 +1069,9 @@ struct net_device_ops {
 						      struct nlmsghdr *nlh);
 	int			(*ndo_change_carrier)(struct net_device *dev,
 						      bool new_carrier);
+	int			(*ndo_set_ratelimit)(struct net_device *dev,
+						     int queue_index,
+						     u32 *max_rate);
 };
 
 /*
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 981fed3..ff61852 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -819,6 +819,59 @@ static ssize_t show_trans_timeout(struct netdev_queue *queue,
 	return sprintf(buf, "%lu", trans_timeout);
 }
 
+static ssize_t show_rate_limit(struct netdev_queue *queue,
+				  struct netdev_queue_attribute *attribute,
+				  char *buf)
+{
+	return sprintf(buf, "%lu", queue->rate_limit);
+}
+
+static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
+{
+	struct net_device *dev = queue->dev;
+	int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++)
+		if (queue == &dev->_tx[i])
+			break;
+
+	BUG_ON(i >= dev->num_tx_queues);
+
+	return i;
+}
+
+static ssize_t set_tx_rate_limit(struct netdev_queue *queue,
+				 struct netdev_queue_attribute *attribute,
+				 const char *buf, size_t len)
+{
+	struct net_device *dev = queue->dev;
+	int err, index = get_netdev_queue_index(queue);
+	u32 rate = 0;
+
+	err = kstrtou32(buf, 10, &rate);
+	if (err < 0)
+		return err;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (dev->netdev_ops->ndo_set_ratelimit)
+		err = dev->netdev_ops->ndo_set_ratelimit(dev, index, &rate);
+	else
+		err = -EOPNOTSUPP;
+	rtnl_unlock();
+
+	if (err < 0)
+		return err;
+
+	queue->rate_limit = rate;
+	return len;
+}
+
+static struct netdev_queue_attribute queue_rate_limit =
+	__ATTR(tx_rate_limit, S_IRUGO | S_IWUSR,
+	       show_rate_limit, set_tx_rate_limit);
+
 static struct netdev_queue_attribute queue_trans_timeout =
 	__ATTR(tx_timeout, S_IRUGO, show_trans_timeout, NULL);
 
@@ -933,21 +986,6 @@ static struct attribute_group dql_group = {
 #endif /* CONFIG_BQL */
 
 #ifdef CONFIG_XPS
-static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
-{
-	struct net_device *dev = queue->dev;
-	int i;
-
-	for (i = 0; i < dev->num_tx_queues; i++)
-		if (queue == &dev->_tx[i])
-			break;
-
-	BUG_ON(i >= dev->num_tx_queues);
-
-	return i;
-}
-
-
 static ssize_t show_xps_map(struct netdev_queue *queue,
 			    struct netdev_queue_attribute *attribute, char *buf)
 {
@@ -1032,6 +1070,7 @@ static struct attribute *netdev_queue_default_attrs[] = {
 #ifdef CONFIG_XPS
 	&xps_cpus_attribute.attr,
 #endif
+	&queue_rate_limit.attr,
 	NULL
 };
 
