From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] net: Add ops->ndo_xmit_flush()
Date: Sat, 23 Aug 2014 13:28:23 -0700 (PDT)
Message-ID: <20140823.132823.531609193955178433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaHWU2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 16:28:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wan/dlci.c              |  2 +-
 drivers/usb/gadget/function/f_ncm.c |  2 +-
 include/linux/netdevice.h           | 35 +++++++++++++++++++++++++++++++++++
 net/atm/mpc.c                       |  2 +-
 net/core/dev.c                      |  5 ++---
 net/core/netpoll.c                  |  3 +--
 net/core/pktgen.c                   |  4 +---
 net/packet/af_packet.c              |  3 +--
 net/sched/sch_teql.c                |  3 +--
 9 files changed, 44 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 43c9960..81b22a1 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -193,7 +193,7 @@ static netdev_tx_t dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 	struct dlci_local *dlp = netdev_priv(dev);
 
 	if (skb)
-		dlp->slave->netdev_ops->ndo_start_xmit(skb, dlp->slave);
+		netdev_start_xmit(skb, dlp->slave);
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/usb/gadget/function/f_ncm.c b/drivers/usb/gadget/function/f_ncm.c
index bcdc882..cb5d646 100644
--- a/drivers/usb/gadget/function/f_ncm.c
+++ b/drivers/usb/gadget/function/f_ncm.c
@@ -1101,7 +1101,7 @@ static void ncm_tx_tasklet(unsigned long data)
 	/* Only send if data is available. */
 	if (ncm->skb_tx_data) {
 		ncm->timer_force_tx = true;
-		ncm->netdev->netdev_ops->ndo_start_xmit(NULL, ncm->netdev);
+		netdev_start_xmit(NULL, ncm->netdev);
 		ncm->timer_force_tx = false;
 	}
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7e2b0b8..1d05932 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -782,6 +782,19 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
  *	Required can not be NULL.
  *
+ * void (*ndo_xmit_flush)(struct net_device *dev, u16 queue);
+ *	A driver implements this function when it wishes to support
+ *	deferred TX queue flushing.  The idea is that the expensive
+ *	operation to trigger TX queue processing can be done after
+ *	N calls to ndo_start_xmit rather than being done every single
+ *	time.  In this regime ndo_start_xmit will be called one or more
+ *	times, and then a final ndo_xmit_flush call will be made to
+ *	have the driver tell the device about the new pending TX queue
+ *	entries.  The kernel keeps track of which queues need flushing
+ *	by monitoring skb->queue_mapping of the packets it submits to
+ *	ndo_start_xmit.  This is the queue value that will be passed
+ *	to ndo_xmit_flush.
+ *
  * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb,
  *                         void *accel_priv, select_queue_fallback_t fallback);
  *	Called to decide which queue to when device supports multiple
@@ -1005,6 +1018,7 @@ struct net_device_ops {
 	int			(*ndo_stop)(struct net_device *dev);
 	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
 						   struct net_device *dev);
+	void			(*ndo_xmit_flush)(struct net_device *dev, u16 queue);
 	u16			(*ndo_select_queue)(struct net_device *dev,
 						    struct sk_buff *skb,
 						    void *accel_priv,
@@ -3358,6 +3372,27 @@ int __init dev_proc_init(void);
 #define dev_proc_init() 0
 #endif
 
+static inline netdev_tx_t __netdev_start_xmit(const struct net_device_ops *ops,
+					      struct sk_buff *skb, struct net_device *dev)
+{
+	netdev_tx_t ret;
+	u16 q;
+
+	q = skb->queue_mapping;
+	ret = ops->ndo_start_xmit(skb, dev);
+	if (ops->ndo_xmit_flush)
+		ops->ndo_xmit_flush(dev, q);
+
+	return ret;
+}
+
+static inline netdev_tx_t netdev_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	return __netdev_start_xmit(ops, skb, dev);
+}
+
 int netdev_class_create_file_ns(struct class_attribute *class_attr,
 				const void *ns);
 void netdev_class_remove_file_ns(struct class_attribute *class_attr,
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index e8e0e7a..d662da1 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -599,7 +599,7 @@ static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
 	}
 
 non_ip:
-	return mpc->old_ops->ndo_start_xmit(skb, dev);
+	return __netdev_start_xmit(mpc->old_ops, skb, dev);
 }
 
 static int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
diff --git a/net/core/dev.c b/net/core/dev.c
index 1421dad..6cf06a8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2602,7 +2602,6 @@ EXPORT_SYMBOL(netif_skb_features);
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
 	int rc = NETDEV_TX_OK;
 	unsigned int skb_len;
 
@@ -2667,7 +2666,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 
 		skb_len = skb->len;
 		trace_net_dev_start_xmit(skb, dev);
-		rc = ops->ndo_start_xmit(skb, dev);
+		rc = netdev_start_xmit(skb, dev);
 		trace_net_dev_xmit(skb, rc, dev, skb_len);
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
@@ -2686,7 +2685,7 @@ gso:
 
 		skb_len = nskb->len;
 		trace_net_dev_start_xmit(nskb, dev);
-		rc = ops->ndo_start_xmit(nskb, dev);
+		rc = netdev_start_xmit(nskb, dev);
 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 907fb5e..a5ad068 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -72,7 +72,6 @@ module_param(carrier_timeout, uint, 0644);
 static int netpoll_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			      struct netdev_queue *txq)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
 	int status = NETDEV_TX_OK;
 	netdev_features_t features;
 
@@ -92,7 +91,7 @@ static int netpoll_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		skb->vlan_tci = 0;
 	}
 
-	status = ops->ndo_start_xmit(skb, dev);
+	status = netdev_start_xmit(skb, dev);
 	if (status == NETDEV_TX_OK)
 		txq_trans_update(txq);
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8b849dd..83e2b4b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3285,8 +3285,6 @@ static void pktgen_wait_for_skb(struct pktgen_dev *pkt_dev)
 static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = pkt_dev->odev;
-	netdev_tx_t (*xmit)(struct sk_buff *, struct net_device *)
-		= odev->netdev_ops->ndo_start_xmit;
 	struct netdev_queue *txq;
 	u16 queue_map;
 	int ret;
@@ -3339,7 +3337,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		goto unlock;
 	}
 	atomic_inc(&(pkt_dev->skb->users));
-	ret = (*xmit)(pkt_dev->skb, odev);
+	ret = netdev_start_xmit(pkt_dev->skb, odev);
 
 	switch (ret) {
 	case NETDEV_TX_OK:
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 93896d2..0dfa990 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -240,7 +240,6 @@ static void __fanout_link(struct sock *sk, struct packet_sock *po);
 static int packet_direct_xmit(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	const struct net_device_ops *ops = dev->netdev_ops;
 	netdev_features_t features;
 	struct netdev_queue *txq;
 	int ret = NETDEV_TX_BUSY;
@@ -262,7 +261,7 @@ static int packet_direct_xmit(struct sk_buff *skb)
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_xmit_frozen_or_drv_stopped(txq)) {
-		ret = ops->ndo_start_xmit(skb, dev);
+		ret = netdev_start_xmit(skb, dev);
 		if (ret == NETDEV_TX_OK)
 			txq_trans_update(txq);
 	}
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index bd33793..64cd93c 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -301,7 +301,6 @@ restart:
 	do {
 		struct net_device *slave = qdisc_dev(q);
 		struct netdev_queue *slave_txq = netdev_get_tx_queue(slave, 0);
-		const struct net_device_ops *slave_ops = slave->netdev_ops;
 
 		if (slave_txq->qdisc_sleeping != q)
 			continue;
@@ -317,7 +316,7 @@ restart:
 				unsigned int length = qdisc_pkt_len(skb);
 
 				if (!netif_xmit_frozen_or_stopped(slave_txq) &&
-				    slave_ops->ndo_start_xmit(skb, slave) == NETDEV_TX_OK) {
+				    netdev_start_xmit(skb, slave) == NETDEV_TX_OK) {
 					txq_trans_update(slave_txq);
 					__netif_tx_unlock(slave_txq);
 					master->slaves = NEXT_SLAVE(q);
-- 
1.7.11.7
