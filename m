From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH v4 1/2] net: implement mechanism for HW based QOS
Date: Mon, 03 Jan 2011 19:05:53 -0800
Message-ID: <20110104030553.13187.69135.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, hadi@cyberus.ca, shemminger@vyatta.com,
	tgraf@infradead.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: davem@davemloft.net, jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26283 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342Ab1ADDKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 22:10:14 -0500
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

 include/linux/netdevice.h |   62 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            |   10 +++++++
 2 files changed, 71 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cc916c5..073c48d 100644
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
@@ -1146,6 +1154,9 @@ struct net_device {
 	/* Data Center Bridging netlink ops */
 	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
+	u8 num_tc;
+	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
+	u8 prio_tc_map[TC_BITMASK+1];
 
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	/* max exchange id for FCoE LRO by ddp */
@@ -1162,6 +1173,57 @@ struct net_device {
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
+u8 netdev_get_num_tc(const struct net_device *dev)
+{
+	return dev->num_tc;
+}
+
+static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index a215269..38318e2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2165,6 +2165,8 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 		  unsigned int num_tx_queues)
 {
 	u32 hash;
+	u16 qoffset = 0;
+	u16 qcount = num_tx_queues;
 
 	if (skb_rx_queue_recorded(skb)) {
 		hash = skb_get_rx_queue(skb);
@@ -2173,13 +2175,19 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
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
 

