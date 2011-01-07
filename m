From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH v6 1/2] net: implement mechanism for HW based QOS
Date: Thu, 06 Jan 2011 19:12:11 -0800
Message-ID: <20110107031211.2446.35715.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, eric.dumazet@gmail.com, shemminger@vyatta.com,
	tgraf@infradead.org, bhutchings@solarflare.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: davem@davemloft.net, jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51793 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866Ab1AGDQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 22:16:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides a mechanism for lower layer devices to
steer traffic using skb->priority to tx queues. This allows
for hardware based QOS schemes to use the default qdisc without
incurring the penalties related to global state and the qdisc
lock. While reliably receiving skbs on the correct tx ring
to avoid head of line blocking resulting from shuffling in
the LLD. Finally, all the goodness from txq caching and xps/rps
can still be leveraged.

Many drivers and hardware exist with the ability to implement
QOS schemes in the hardware but currently these drivers tend
to rely on firmware to reroute specific traffic, a driver
specific select_queue or the queue_mapping action in the
qdisc.

By using select_queue for this drivers need to be updated for
each and every traffic type and we lose the goodness of much
of the upstream work. Firmware solutions are inherently
inflexible. And finally if admins are expected to build a
qdisc and filter rules to steer traffic this requires knowledge
of how the hardware is currently configured. The number of tx
queues and the queue offsets may change depending on resources.
Also this approach incurs all the overhead of a qdisc with filters.

With the mechanism in this patch users can set skb priority using
expected methods ie setsockopt() or the stack can set the priority
directly. Then the skb will be steered to the correct tx queues
aligned with hardware QOS traffic classes. In the normal case with
a single traffic class and all queues in this class everything
works as is until the LLD enables multiple tcs.

To steer the skb we mask out the lower 4 bits of the priority
and allow the hardware to configure upto 15 distinct classes
of traffic. This is expected to be sufficient for most applications
at any rate it is more then the 8021Q spec designates and is
equal to the number of prio bands currently implemented in
the default qdisc.

This in conjunction with a userspace application such as
lldpad can be used to implement 8021Q transmission selection
algorithms one of these algorithms being the extended transmission
selection algorithm currently being used for DCB.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/netdevice.h |   65 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            |   52 +++++++++++++++++++++++++++++++++++-
 2 files changed, 116 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0f6b1c9..12fff42 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -646,6 +646,14 @@ struct xps_dev_maps {
     (nr_cpu_ids * sizeof(struct xps_map *)))
 #endif /* CONFIG_XPS */
 
+#define TC_MAX_QUEUE	16
+#define TC_BITMASK	15
+/* HW offloaded queuing disciplines txq count and offset maps */
+struct netdev_tc_txq {
+	u16 count;
+	u16 offset;
+};
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -756,6 +764,7 @@ struct xps_dev_maps {
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
  *			  struct nlattr *port[]);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
+ * void (*ndo_setup_tc)(struct net_device *dev, u8 tc)
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -814,6 +823,8 @@ struct net_device_ops {
 						   struct nlattr *port[]);
 	int			(*ndo_get_vf_port)(struct net_device *dev,
 						   int vf, struct sk_buff *skb);
+	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc,
+						unsigned int txq);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
@@ -1146,6 +1157,9 @@ struct net_device {
 	/* Data Center Bridging netlink ops */
 	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
+	u8 num_tc;
+	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
+	u8 prio_tc_map[TC_BITMASK + 1];
 
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	/* max exchange id for FCoE LRO by ddp */
@@ -1162,6 +1176,57 @@ struct net_device {
 #define	NETDEV_ALIGN		32
 
 static inline
+int netdev_get_prio_tc_map(const struct net_device *dev, u32 prio)
+{
+	return dev->prio_tc_map[prio & TC_BITMASK];
+}
+
+static inline
+int netdev_set_prio_tc_map(struct net_device *dev, u8 prio, u8 tc)
+{
+	if (tc >= dev->num_tc)
+		return -EINVAL;
+
+	dev->prio_tc_map[prio & TC_BITMASK] = tc & TC_BITMASK;
+	return 0;
+}
+
+static inline
+void netdev_reset_tc(struct net_device *dev)
+{
+	dev->num_tc = 0;
+	memset(dev->tc_to_txq, 0, sizeof(dev->tc_to_txq));
+	memset(dev->prio_tc_map, 0, sizeof(dev->prio_tc_map));
+}
+
+static inline
+int netdev_set_tc_queue(struct net_device *dev, u8 tc, u16 count, u16 offset)
+{
+	if (tc >= dev->num_tc)
+		return -EINVAL;
+
+	dev->tc_to_txq[tc].count = count;
+	dev->tc_to_txq[tc].offset = offset;
+	return 0;
+}
+
+static inline
+int netdev_set_num_tc(struct net_device *dev, u8 num_tc)
+{
+	if (num_tc > TC_MAX_QUEUE)
+		return -EINVAL;
+
+	dev->num_tc = num_tc;
+	return 0;
+}
+
+static inline
+int netdev_get_num_tc(struct net_device *dev)
+{
+	return dev->num_tc;
+}
+
+static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index a215269..12a2c2a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1593,6 +1593,45 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 	rcu_read_unlock();
 }
 
+/* netif_setup_tc - Handle tc mappings on real_num_tx_queues change
+ * @dev: Network device
+ * @txq: number of queues available
+ *
+ * If real_num_tx_queues is changed the tc mappings may no longer be
+ * valid. To resolve this if the net_device supports ndo_setup_tc
+ * call the ops routine with the new queue number. If the ops is not
+ * available verify the tc mapping remains valid and if not NULL the
+ * mapping. With no priorities mapping to this offset/count pair it
+ * will no longer be used. In the worst case TC0 is invalid nothing
+ * can be done so disable priority mappings.
+ */
+void netif_setup_tc(struct net_device *dev, unsigned int txq)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (ops->ndo_setup_tc) {
+		ops->ndo_setup_tc(dev, dev->num_tc, txq);
+	} else {
+		int i;
+		struct netdev_tc_txq *tc = &dev->tc_to_txq[0];
+
+		/* If TC0 is invalidated disable TC mapping */
+		if (tc->offset + tc->count > txq) {
+			dev->num_tc = 0;
+			return;
+		}
+
+		/* Invalidated prio to tc mappings set to TC0 */
+		for (i = 1; i < TC_BITMASK + 1; i++) {
+			int q = netdev_get_prio_tc_map(dev, i);
+			tc = &dev->tc_to_txq[q];
+
+			if (tc->offset + tc->count > txq)
+				netdev_set_prio_tc_map(dev, i, 0);
+		}
+	}
+}
+
 /*
  * Routine to help set real_num_tx_queues. To avoid skbs mapped to queues
  * greater then real_num_tx_queues stale skbs on the qdisc must be flushed.
@@ -1614,6 +1653,9 @@ int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
 
 		if (txq < dev->real_num_tx_queues)
 			qdisc_reset_all_tx_gt(dev, txq);
+
+		if (dev->num_tc)
+			netif_setup_tc(dev, txq);
 	}
 
 	dev->real_num_tx_queues = txq;
@@ -2165,6 +2207,8 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 		  unsigned int num_tx_queues)
 {
 	u32 hash;
+	u16 qoffset = 0;
+	u16 qcount = num_tx_queues;
 
 	if (skb_rx_queue_recorded(skb)) {
 		hash = skb_get_rx_queue(skb);
@@ -2173,13 +2217,19 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 		return hash;
 	}
 
+	if (dev->num_tc) {
+		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
+		qoffset = dev->tc_to_txq[tc].offset;
+		qcount = dev->tc_to_txq[tc].count;
+	}
+
 	if (skb->sk && skb->sk->sk_hash)
 		hash = skb->sk->sk_hash;
 	else
 		hash = (__force u16) skb->protocol ^ skb->rxhash;
 	hash = jhash_1word(hash, hashrnd);
 
-	return (u16) (((u64) hash * num_tx_queues) >> 32);
+	return (u16) (((u64) hash * qcount) >> 32) + qoffset;
 }
 EXPORT_SYMBOL(__skb_tx_hash);
 

