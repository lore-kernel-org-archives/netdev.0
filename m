From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v2 1/3] net: implement mechanism for HW based QOS
Date: Wed, 01 Dec 2010 10:22:52 -0800
Message-ID: <20101201182252.2748.15208.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	tgraf@infradead.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17306 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753690Ab0LASZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 13:25:00 -0500
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

None of these solutions are ideal or generic so we end up
with driver specific solutions that one-off traffic types
for example FCoE traffic is steered in ixgbe with the
queue_select routine. By using select_queue for this drivers
need to be updated for each and every traffic type and we
loose the goodness of much of the upstream work.

Firmware solutions are inherently inflexible. And finally if
admins are expected to build a qdisc and filter rules to steer
traffic this requires knowledge of how the hardware is currently
configured. The number of tx queues and the queue offsets may
change depending on resources. Also this approach incurs all the
overhead of a qdisc with filters.

With this mechanism users can set skb priority using expected
methods either socket options or the stack can set this directly.
Then the skb will be steered to the correct tx queues aligned
with hardware QOS traffic classes. In the normal case with a
single traffic class and all queues in this class every thing
works as is until the LLD enables multiple tcs.

To steer the skb we mask out the lower 8 bits of the priority
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

 include/linux/netdevice.h |   64 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            |   41 ++++++++++++++++++++++++++++-
 2 files changed, 104 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4b0c7f3..3307979 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -628,6 +628,12 @@ struct xps_dev_maps {
     (nr_cpu_ids * sizeof(struct xps_map *)))
 #endif /* CONFIG_XPS */
 
+/* HW offloaded queuing disciplines txq count and offset maps */
+struct netdev_tc_txq {
+	u16 count;
+	u16 offset;
+};
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1128,6 +1134,10 @@ struct net_device {
 	/* Data Center Bridging netlink ops */
 	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
+	u8 max_tcs;
+	u8 num_tcs;
+	struct netdev_tc_txq *_tc_to_txq;
+	u8 prio_tc_map[16];
 
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	/* max exchange id for FCoE LRO by ddp */
@@ -1144,6 +1154,57 @@ struct net_device {
 #define	NETDEV_ALIGN		32
 
 static inline
+int netdev_get_prio_tc_map(const struct net_device *dev, u32 prio)
+{
+	return dev->prio_tc_map[prio & 15];
+}
+
+static inline
+int netdev_set_prio_tc_map(struct net_device *dev, u8 prio, u8 tc)
+{
+	if (tc >= dev->num_tcs)
+		return -EINVAL;
+
+	return dev->prio_tc_map[prio & 15] = tc & 15;
+}
+
+static inline
+int netdev_set_tc_queue(struct net_device *dev, u8 tc, u16 count, u16 offset)
+{
+	struct netdev_tc_txq *tcp;
+
+	if (tc >= dev->num_tcs)
+		return -EINVAL;
+
+	tcp = &dev->_tc_to_txq[tc];
+	tcp->count = count;
+	tcp->offset = offset;
+	return 0;
+}
+
+static inline
+struct netdev_tc_txq *netdev_get_tc_queue(const struct net_device *dev, u8 tc)
+{
+	return &dev->_tc_to_txq[tc];
+}
+
+static inline
+int netdev_set_num_tc(struct net_device *dev, u8 num_tc)
+{
+	if (num_tc > dev->max_tcs)
+		return -EINVAL;
+
+	dev->num_tcs = num_tc;
+	return 0;
+}
+
+static inline
+u8 netdev_get_num_tc(const struct net_device *dev)
+{
+	return dev->num_tcs;
+}
+
+static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
 {
@@ -1368,6 +1429,9 @@ static inline void unregister_netdevice(struct net_device *dev)
 	unregister_netdevice_queue(dev, NULL);
 }
 
+extern int		netdev_alloc_max_tcs(struct net_device *dev, u8 tcs);
+extern void		netdev_free_tcs(struct net_device *dev);
+
 extern int 		netdev_refcnt_read(const struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index 3259d2c..66c3af8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2118,6 +2118,8 @@ static u32 hashrnd __read_mostly;
 u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 {
 	u32 hash;
+	u16 qoffset = 0;
+	u16 qcount = dev->real_num_tx_queues;
 
 	if (skb_rx_queue_recorded(skb)) {
 		hash = skb_get_rx_queue(skb);
@@ -2126,13 +2128,20 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 		return hash;
 	}
 
+	if (dev->num_tcs) {
+		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
+		struct netdev_tc_txq *tcp = netdev_get_tc_queue(dev, tc);
+		qoffset = tcp->offset;
+		qcount = tcp->count;
+	}
+
 	if (skb->sk && skb->sk->sk_hash)
 		hash = skb->sk->sk_hash;
 	else
 		hash = (__force u16) skb->protocol ^ skb->rxhash;
 	hash = jhash_1word(hash, hashrnd);
 
-	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
+	return (u16) ((((u64) hash * qcount)) >> 32) + qoffset;
 }
 EXPORT_SYMBOL(skb_tx_hash);
 
@@ -5088,6 +5097,35 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 }
 EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 
+int netdev_alloc_max_tcs(struct net_device *dev, u8 tcs)
+{
+	struct netdev_tc_txq *tcp;
+
+	if (tcs > 15)
+		return -EINVAL;
+
+	tcp = kcalloc(tcs, sizeof(*tcp), GFP_KERNEL);
+	if (!tcp)
+		return -ENOMEM;
+
+	dev->_tc_to_txq = tcp;
+	dev->max_tcs = tcs;
+	return tcs;
+}
+EXPORT_SYMBOL(netdev_alloc_max_tcs);
+
+void netdev_free_tcs(struct net_device *dev)
+{
+	u8 *prio_map = dev->prio_tc_map;
+
+	dev->max_tcs = 0;
+	dev->num_tcs = 0;
+	memset(prio_map, 0, sizeof(*prio_map) * 16);
+	kfree(dev->_tc_to_txq);
+	dev->_tc_to_txq = NULL;
+}
+EXPORT_SYMBOL(netdev_free_tcs);
+
 #ifdef CONFIG_RPS
 static int netif_alloc_rx_queues(struct net_device *dev)
 {
@@ -5695,6 +5733,7 @@ void free_netdev(struct net_device *dev)
 #ifdef CONFIG_RPS
 	kfree(dev->_rx);
 #endif
+	netdev_free_tcs(dev);
 
 	kfree(rcu_dereference_raw(dev->ingress_queue));
 

