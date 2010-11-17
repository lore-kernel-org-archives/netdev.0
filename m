From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1 1/2] net: implement mechanism for HW based QOS
Date: Tue, 16 Nov 2010 21:15:45 -0800
Message-ID: <20101117051544.19800.97654.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, nhorman@tuxdriver.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46831 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270Ab0KQFSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Nov 2010 00:18:30 -0500
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
loose the goodness of much of the upstream work. For example
txq caching.

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

If this approach seems reasonable I'll go ahead and finish
this up. The priority to tc mapping should probably be exposed
to userspace either through sysfs or rtnetlink. Any thoughts?

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/netdevice.h |   47 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            |   43 ++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 89 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b45c1b8..8a2adeb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1092,6 +1092,12 @@ struct net_device {
 	/* Data Center Bridging netlink ops */
 	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
+	u8 max_tcs;
+	u8 num_tcs;
+	unsigned int *_tc_txqcount;
+	unsigned int *_tc_txqoffset;
+	u64 prio_tc_map;
+
 
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	/* max exchange id for FCoE LRO by ddp */
@@ -1108,6 +1114,44 @@ struct net_device {
 #define	NETDEV_ALIGN		32
 
 static inline
+int netdev_get_prio_tc_map(const struct net_device *dev, u32 prio)
+{
+	return (dev->prio_tc_map >> (4 * (prio & 0xF))) & 0xF;
+}
+
+static inline
+void netdev_set_prio_tc_map(struct net_device *dev, u8 prio, u8 tc)
+{
+	u64 mask = ~(-1 & (0xF << (4 * prio)));
+	/* Zero the 4 bit prio map and set traffic class */
+	dev->prio_tc_map &= mask;
+	dev->prio_tc_map |= tc << (4 * prio);
+}
+
+static inline
+void netdev_set_tc_queue(struct net_device *dev, u8 tc, u16 count, u16 offset)
+{
+	dev->_tc_txqcount[tc] = count;
+	dev->_tc_txqoffset[tc] = offset;
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
+u8 netdev_get_num_tc(struct net_device *dev)
+{
+	return dev->num_tcs;
+}
+
+static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
 {
@@ -1332,6 +1376,9 @@ static inline void unregister_netdevice(struct net_device *dev)
 	unregister_netdevice_queue(dev, NULL);
 }
 
+extern int		netdev_alloc_max_tcs(struct net_device *dev, u8 tcs);
+extern void		netdev_free_tcs(struct net_device *dev);
+
 extern int 		netdev_refcnt_read(const struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index 4a587b3..4565afc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2111,6 +2111,8 @@ static u32 hashrnd __read_mostly;
 u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 {
 	u32 hash;
+	u16 qoffset = 0;
+	u16 qcount = dev->real_num_tx_queues;
 
 	if (skb_rx_queue_recorded(skb)) {
 		hash = skb_get_rx_queue(skb);
@@ -2119,13 +2121,20 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 		return hash;
 	}
 
+	if (dev->num_tcs) {
+		u8 tc;
+		tc = netdev_get_prio_tc_map(dev, skb->priority);
+		qoffset = dev->_tc_txqoffset[tc];
+		qcount = dev->_tc_txqcount[tc];
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
 
@@ -5037,6 +5046,37 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 }
 EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 
+int netdev_alloc_max_tcs(struct net_device *dev, u8 tcs)
+{
+	unsigned int *count, *offset;
+	count = kcalloc(tcs, sizeof(unsigned int), GFP_KERNEL);
+	if (!count)
+		return -ENOMEM;
+	offset = kcalloc(tcs, sizeof(unsigned int), GFP_KERNEL);
+	if (!offset) {
+		kfree(count);
+		return -ENOMEM;
+	}
+
+	dev->_tc_txqcount = count;
+	dev->_tc_txqoffset = offset;
+	dev->max_tcs = tcs;
+	return tcs;
+}
+EXPORT_SYMBOL(netdev_alloc_max_tcs);
+
+void netdev_free_tcs(struct net_device *dev)
+{
+	dev->max_tcs = 0;
+	dev->num_tcs = 0;
+	dev->prio_tc_map = 0;
+	kfree(dev->_tc_txqcount);
+	kfree(dev->_tc_txqoffset);
+	dev->_tc_txqcount = NULL;
+	dev->_tc_txqoffset = NULL;
+}
+EXPORT_SYMBOL(netdev_free_tcs);
+
 static int netif_alloc_rx_queues(struct net_device *dev)
 {
 #ifdef CONFIG_RPS
@@ -5641,6 +5681,7 @@ void free_netdev(struct net_device *dev)
 #ifdef CONFIG_RPS
 	kfree(dev->_rx);
 #endif
+	netdev_free_tcs(dev);
 
 	kfree(rcu_dereference_raw(dev->ingress_queue));
 

