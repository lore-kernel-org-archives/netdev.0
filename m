From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/13]: net: Use queue aware tests throughout.
Date: Thu, 10 Jul 2008 03:56:46 -0700 (PDT)
Message-ID: <20080710.035646.232694803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60715
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753892AbYGJK4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:56:46 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 93C5DC8C17F
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:56:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This effectively "flips the switch" by making the core networking
and multiqueue-aware drivers use the new TX multiqueue structures.

Non-multiqueue drivers need no changes.  The interfaces they use such
as netif_stop_queue() degenerate into an operation on TX queue zero.
So everything "just works" for them.

Code that really wants to do "X" to all TX queues now invokes a
routine that does so, such as netif_tx_wake_all_queues(),
netif_tx_stop_all_queues(), etc.

pktgen and netpoll required a little bit more surgery than the others.

In particular the pktgen changes, whilst functional, could be largely
improved.  The initial check in pktgen_xmit() will sometimes check the
wrong queue, which is mostly harmless.  The thing to do is probably to
invoke fill_packet() earlier.

The bulk of the netpoll changes is to make the code operate solely on
the TX queue indicated by by the SKB queue mapping.

Setting of the SKB queue mapping is entirely confined inside of
net/core/dev.c:dev_pick_tx().  If we end up needing any kind of
special semantics (drops, for example) it will be implemented here.

Finally, we now have a "real_num_tx_queues" which is where the driver
indicates how many TX queues are actually active.  This value must
be stable while the device is open.  It may only be modified while
the device is down.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cpmac.c               |   20 ++++-----
 drivers/net/ixgbe/ixgbe_ethtool.c |   10 +----
 drivers/net/ixgbe/ixgbe_main.c    |   15 ++-----
 drivers/net/s2io.c                |   48 +++++++++-------------
 include/linux/netdevice.h         |   82 +++++++++++++++++++++++++++++++++----
 include/net/pkt_sched.h           |    4 +-
 net/core/dev.c                    |   28 +++++-------
 net/core/netpoll.c                |   24 ++++++-----
 net/core/pktgen.c                 |   69 ++++++++++++++++++++-----------
 net/sched/sch_generic.c           |    5 +-
 net/sched/sch_teql.c              |    6 +--
 11 files changed, 182 insertions(+), 129 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 7c7b54e..fbd4280 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -544,7 +544,7 @@ fatal_error:
 
 	spin_unlock(&priv->rx_lock);
 	netif_rx_complete(priv->dev, napi);
-	netif_stop_queue(priv->dev);
+	netif_tx_stop_all_queues(priv->dev);
 	napi_disable(&priv->napi);
 
 	atomic_inc(&priv->reset_pending);
@@ -750,9 +750,7 @@ static void cpmac_hw_error(struct work_struct *work)
 	barrier();
 	atomic_dec(&priv->reset_pending);
 
-	for (i = 0; i < CPMAC_QUEUES; i++)
-		netif_wake_subqueue(priv->dev, i);
-	netif_wake_queue(priv->dev);
+	netif_tx_wake_all_queues(priv->dev);
 	cpmac_write(priv->regs, CPMAC_MAC_INT_ENABLE, 3);
 }
 
@@ -781,7 +779,7 @@ static void cpmac_check_status(struct net_device *dev)
 				     dev->name, tx_code, tx_channel, macstatus);
 		}
 
-		netif_stop_queue(dev);
+		netif_tx_stop_all_queues(dev);
 		cpmac_hw_stop(dev);
 		if (schedule_work(&priv->reset_work))
 			atomic_inc(&priv->reset_pending);
@@ -842,9 +840,7 @@ static void cpmac_tx_timeout(struct net_device *dev)
 	barrier();
 	atomic_dec(&priv->reset_pending);
 
-	netif_wake_queue(priv->dev);
-	for (i = 0; i < CPMAC_QUEUES; i++)
-		netif_wake_subqueue(dev, i);
+	netif_tx_wake_all_queues(priv->dev);
 }
 
 static int cpmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -935,7 +931,7 @@ static void cpmac_adjust_link(struct net_device *dev)
 
 	spin_lock(&priv->lock);
 	if (priv->phy->link) {
-		netif_start_queue(dev);
+		netif_tx_start_all_queues(dev);
 		if (priv->phy->duplex != priv->oldduplex) {
 			new_state = 1;
 			priv->oldduplex = priv->phy->duplex;
@@ -949,10 +945,10 @@ static void cpmac_adjust_link(struct net_device *dev)
 		if (!priv->oldlink) {
 			new_state = 1;
 			priv->oldlink = 1;
-			netif_schedule(dev);
+			netif_tx_schedule_all(dev);
 		}
 	} else if (priv->oldlink) {
-		netif_stop_queue(dev);
+		netif_tx_stop_all_queues(dev);
 		new_state = 1;
 		priv->oldlink = 0;
 		priv->oldspeed = 0;
@@ -1072,7 +1068,7 @@ static int cpmac_stop(struct net_device *dev)
 	struct cpmac_priv *priv = netdev_priv(dev);
 	struct resource *mem;
 
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 
 	cancel_work_sync(&priv->reset_work);
 	napi_disable(&priv->napi);
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 81b7690..3efe5dd 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -252,16 +252,10 @@ static int ixgbe_set_tso(struct net_device *netdev, u32 data)
 		netdev->features |= NETIF_F_TSO;
 		netdev->features |= NETIF_F_TSO6;
 	} else {
-		struct ixgbe_adapter *adapter = netdev_priv(netdev);
-		int i;
-		netif_stop_queue(netdev);
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			netif_stop_subqueue(netdev, i);
+		netif_tx_stop_all_queues(netdev);
 		netdev->features &= ~NETIF_F_TSO;
 		netdev->features &= ~NETIF_F_TSO6;
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			netif_start_subqueue(netdev, i);
-		netif_start_queue(netdev);
+		netif_tx_start_all_queues(netdev);
 	}
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7a77b7a..cb0909c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2009,7 +2009,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	del_timer_sync(&adapter->watchdog_timer);
 
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
+	netif_tx_stop_all_queues(netdev);
 
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbe_reset(adapter);
@@ -2355,7 +2355,7 @@ try_msi:
 
 out:
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
-	adapter->netdev->egress_subqueue_count = adapter->num_tx_queues;
+	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
 
 	return err;
 }
@@ -2892,7 +2892,6 @@ static void ixgbe_watchdog(unsigned long data)
 	struct net_device *netdev = adapter->netdev;
 	bool link_up;
 	u32 link_speed = 0;
-	int i;
 
 	adapter->hw.mac.ops.check_link(&adapter->hw, &(link_speed), &link_up);
 
@@ -2913,9 +2912,7 @@ static void ixgbe_watchdog(unsigned long data)
 				 (FLOW_TX ? "TX" : "None"))));
 
 			netif_carrier_on(netdev);
-			netif_wake_queue(netdev);
-			for (i = 0; i < adapter->num_tx_queues; i++)
-				netif_wake_subqueue(netdev, i);
+			netif_tx_wake_all_queues(netdev);
 		} else {
 			/* Force detection of hung controller */
 			adapter->detect_tx_hung = true;
@@ -2924,7 +2921,7 @@ static void ixgbe_watchdog(unsigned long data)
 		if (netif_carrier_ok(netdev)) {
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
+			netif_tx_stop_all_queues(netdev);
 		}
 	}
 
@@ -3627,9 +3624,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	ixgbe_start_hw(hw);
 
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		netif_stop_subqueue(netdev, i);
+	netif_tx_stop_all_queues(netdev);
 
 	ixgbe_napi_add_all(adapter);
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6acbfbc..1d8433f 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -545,63 +545,53 @@ static struct pci_driver s2io_driver = {
 /* netqueue manipulation helper functions */
 static inline void s2io_stop_all_tx_queue(struct s2io_nic *sp)
 {
-	int i;
-	if (sp->config.multiq) {
-		for (i = 0; i < sp->config.tx_fifo_num; i++)
-			netif_stop_subqueue(sp->dev, i);
-	} else {
+	if (!sp->config.multiq) {
+		int i;
+
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_STOP;
-		netif_stop_queue(sp->dev);
 	}
+	netif_tx_stop_all_queues(sp->dev);
 }
 
 static inline void s2io_stop_tx_queue(struct s2io_nic *sp, int fifo_no)
 {
-	if (sp->config.multiq)
-		netif_stop_subqueue(sp->dev, fifo_no);
-	else {
+	if (!sp->config.multiq)
 		sp->mac_control.fifos[fifo_no].queue_state =
 			FIFO_QUEUE_STOP;
-		netif_stop_queue(sp->dev);
-	}
+
+	netif_tx_stop_all_queues(sp->dev);
 }
 
 static inline void s2io_start_all_tx_queue(struct s2io_nic *sp)
 {
-	int i;
-	if (sp->config.multiq) {
-		for (i = 0; i < sp->config.tx_fifo_num; i++)
-			netif_start_subqueue(sp->dev, i);
-	} else {
+	if (!sp->config.multiq) {
+		int i;
+
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_START;
-		netif_start_queue(sp->dev);
 	}
+	netif_tx_start_all_queues(sp->dev);
 }
 
 static inline void s2io_start_tx_queue(struct s2io_nic *sp, int fifo_no)
 {
-	if (sp->config.multiq)
-		netif_start_subqueue(sp->dev, fifo_no);
-	else {
+	if (!sp->config.multiq)
 		sp->mac_control.fifos[fifo_no].queue_state =
 			FIFO_QUEUE_START;
-		netif_start_queue(sp->dev);
-	}
+
+	netif_tx_start_all_queues(sp->dev);
 }
 
 static inline void s2io_wake_all_tx_queue(struct s2io_nic *sp)
 {
-	int i;
-	if (sp->config.multiq) {
-		for (i = 0; i < sp->config.tx_fifo_num; i++)
-			netif_wake_subqueue(sp->dev, i);
-	} else {
+	if (!sp->config.multiq) {
+		int i;
+
 		for (i = 0; i < sp->config.tx_fifo_num; i++)
 			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_START;
-		netif_wake_queue(sp->dev);
 	}
+	netif_tx_wake_all_queues(sp->dev);
 }
 
 static inline void s2io_wake_tx_queue(
@@ -8675,5 +8665,5 @@ static void s2io_io_resume(struct pci_dev *pdev)
 	}
 
 	netif_device_attach(netdev);
-	netif_wake_queue(netdev);
+	netif_tx_wake_all_queues(netdev);
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8804567..0d69931 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -641,7 +641,13 @@ struct net_device
 	struct netdev_queue	rx_queue;
 
 	struct netdev_queue	*_tx;
+
+	/* Number of TX queues allocated at alloc_netdev_mq() time  */
 	unsigned int		num_tx_queues;
+
+	/* Number of TX queues currently active in device  */
+	unsigned int		real_num_tx_queues;
+
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
 /*
@@ -986,6 +992,14 @@ static inline void netif_schedule(struct net_device *dev)
 	netif_schedule_queue(netdev_get_tx_queue(dev, 0));
 }
 
+static inline void netif_tx_schedule_all(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++)
+		netif_schedule_queue(netdev_get_tx_queue(dev, i));
+}
+
 /**
  *	netif_start_queue - allow transmit
  *	@dev: network device
@@ -1002,6 +1016,16 @@ static inline void netif_start_queue(struct net_device *dev)
 	netif_tx_start_queue(netdev_get_tx_queue(dev, 0));
 }
 
+static inline void netif_tx_start_all_queues(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		netif_tx_start_queue(txq);
+	}
+}
+
 /**
  *	netif_wake_queue - restart transmit
  *	@dev: network device
@@ -1026,6 +1050,16 @@ static inline void netif_wake_queue(struct net_device *dev)
 	netif_tx_wake_queue(netdev_get_tx_queue(dev, 0));
 }
 
+static inline void netif_tx_wake_all_queues(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		netif_tx_wake_queue(txq);
+	}
+}
+
 /**
  *	netif_stop_queue - stop transmitted packets
  *	@dev: network device
@@ -1043,6 +1077,16 @@ static inline void netif_stop_queue(struct net_device *dev)
 	netif_tx_stop_queue(netdev_get_tx_queue(dev, 0));
 }
 
+static inline void netif_tx_stop_all_queues(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		netif_tx_stop_queue(txq);
+	}
+}
+
 /**
  *	netif_queue_stopped - test if transmit queue is flowblocked
  *	@dev: network device
@@ -1086,7 +1130,8 @@ static inline int netif_running(const struct net_device *dev)
  */
 static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
 {
-	clear_bit(__QUEUE_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
+	clear_bit(__QUEUE_STATE_XOFF, &txq->state);
 }
 
 /**
@@ -1098,11 +1143,12 @@ static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
  */
 static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 {
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
 #ifdef CONFIG_NETPOLL_TRAP
 	if (netpoll_trap())
 		return;
 #endif
-	set_bit(__QUEUE_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
+	set_bit(__QUEUE_STATE_XOFF, &txq->state);
 }
 
 /**
@@ -1115,8 +1161,8 @@ static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 static inline int __netif_subqueue_stopped(const struct net_device *dev,
 					 u16 queue_index)
 {
-	return test_bit(__QUEUE_STATE_XOFF,
-			&dev->egress_subqueue[queue_index].state);
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
+	return test_bit(__QUEUE_STATE_XOFF, &txq->state);
 }
 
 static inline int netif_subqueue_stopped(const struct net_device *dev,
@@ -1134,13 +1180,13 @@ static inline int netif_subqueue_stopped(const struct net_device *dev,
  */
 static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 {
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
 #ifdef CONFIG_NETPOLL_TRAP
 	if (netpoll_trap())
 		return;
 #endif
-	if (test_and_clear_bit(__QUEUE_STATE_XOFF,
-			       &dev->egress_subqueue[queue_index].state))
-		__netif_schedule(netdev_get_tx_queue(dev, 0));
+	if (test_and_clear_bit(__QUEUE_STATE_XOFF, &txq->state))
+		__netif_schedule(txq);
 }
 
 /**
@@ -1183,7 +1229,8 @@ extern int		dev_set_mtu(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
-					    struct net_device *dev);
+					    struct net_device *dev,
+					    struct netdev_queue *txq);
 
 extern int		netdev_budget;
 
@@ -1432,6 +1479,12 @@ static inline void __netif_tx_lock(struct netdev_queue *txq, int cpu)
 	txq->xmit_lock_owner = cpu;
 }
 
+static inline void __netif_tx_lock_bh(struct netdev_queue *txq)
+{
+	spin_lock_bh(&txq->_xmit_lock);
+	txq->xmit_lock_owner = smp_processor_id();
+}
+
 static inline void netif_tx_lock(struct net_device *dev)
 {
 	int cpu = smp_processor_id();
@@ -1468,6 +1521,12 @@ static inline void __netif_tx_unlock(struct netdev_queue *txq)
 	spin_unlock(&txq->_xmit_lock);
 }
 
+static inline void __netif_tx_unlock_bh(struct netdev_queue *txq)
+{
+	txq->xmit_lock_owner = -1;
+	spin_unlock_bh(&txq->_xmit_lock);
+}
+
 static inline void netif_tx_unlock(struct net_device *dev)
 {
 	unsigned int i;
@@ -1499,8 +1558,13 @@ static inline void netif_tx_unlock_bh(struct net_device *dev)
 
 static inline void netif_tx_disable(struct net_device *dev)
 {
+	unsigned int i;
+
 	netif_tx_lock_bh(dev);
-	netif_stop_queue(dev);
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		netif_tx_stop_queue(txq);
+	}
 	netif_tx_unlock_bh(dev);
 }
 
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index d58c1a5..cb95278 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -88,9 +88,7 @@ extern void __qdisc_run(struct netdev_queue *txq);
 
 static inline void qdisc_run(struct netdev_queue *txq)
 {
-	struct net_device *dev = txq->dev;
-
-	if (!netif_queue_stopped(dev) &&
+	if (!netif_tx_queue_stopped(txq) &&
 	    !test_and_set_bit(__QUEUE_STATE_QDISC_RUNNING, &txq->state))
 		__qdisc_run(txq);
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 0fd454f..0c088b5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1598,7 +1598,8 @@ static int dev_gso_segment(struct sk_buff *skb)
 	return 0;
 }
 
-int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
+			struct netdev_queue *txq)
 {
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
@@ -1627,9 +1628,7 @@ gso:
 			skb->next = nskb;
 			return rc;
 		}
-		if (unlikely((netif_queue_stopped(dev) ||
-			     netif_subqueue_stopped(dev, skb)) &&
-			     skb->next))
+		if (unlikely(netif_tx_queue_stopped(txq) && skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
 
@@ -1669,7 +1668,10 @@ out_kfree_skb:
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
-	return netdev_get_tx_queue(dev, 0);
+	u16 queue_index = 0;
+
+	skb_set_queue_mapping(skb, queue_index);
+	return netdev_get_tx_queue(dev, queue_index);
 }
 
 int dev_queue_xmit(struct sk_buff *skb)
@@ -1737,8 +1739,6 @@ gso:
 		spin_lock(&txq->lock);
 		q = txq->qdisc;
 		if (q->enqueue) {
-			/* reset queue_mapping to zero */
-			skb_set_queue_mapping(skb, 0);
 			rc = q->enqueue(skb, q);
 			qdisc_run(txq);
 			spin_unlock(&txq->lock);
@@ -1768,10 +1768,9 @@ gso:
 
 			HARD_TX_LOCK(dev, txq, cpu);
 
-			if (!netif_queue_stopped(dev) &&
-			    !netif_subqueue_stopped(dev, skb)) {
+			if (!netif_tx_queue_stopped(txq)) {
 				rc = 0;
-				if (!dev_hard_start_xmit(skb, dev)) {
+				if (!dev_hard_start_xmit(skb, dev, txq)) {
 					HARD_TX_UNLOCK(dev, txq);
 					goto out;
 				}
@@ -4132,8 +4131,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
-	alloc_size = sizeof(struct net_device) +
-		     sizeof(struct net_device_subqueue) * (queue_count - 1);
+	alloc_size = sizeof(struct net_device);
 	if (sizeof_priv) {
 		/* ensure 32-byte alignment of private area */
 		alloc_size = (alloc_size + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
@@ -4163,16 +4161,14 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev->_tx = tx;
 	dev->num_tx_queues = queue_count;
+	dev->real_num_tx_queues = queue_count;
 
 	if (sizeof_priv) {
 		dev->priv = ((char *)dev +
-			     ((sizeof(struct net_device) +
-			       (sizeof(struct net_device_subqueue) *
-				(queue_count - 1)) + NETDEV_ALIGN_CONST)
+			     ((sizeof(struct net_device) + NETDEV_ALIGN_CONST)
 			      & ~NETDEV_ALIGN_CONST));
 	}
 
-	dev->egress_subqueue_count = queue_count;
 	dev->gso_max_size = GSO_MAX_SIZE;
 
 	netdev_init_queues(dev);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 8fb134d..c127208 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -58,25 +58,27 @@ static void queue_process(struct work_struct *work)
 
 	while ((skb = skb_dequeue(&npinfo->txq))) {
 		struct net_device *dev = skb->dev;
+		struct netdev_queue *txq;
 
 		if (!netif_device_present(dev) || !netif_running(dev)) {
 			__kfree_skb(skb);
 			continue;
 		}
 
+		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+
 		local_irq_save(flags);
-		netif_tx_lock(dev);
-		if ((netif_queue_stopped(dev) ||
-		     netif_subqueue_stopped(dev, skb)) ||
-		     dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
+		__netif_tx_lock(txq, smp_processor_id());
+		if (netif_tx_queue_stopped(txq) ||
+		    dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
-			netif_tx_unlock(dev);
+			__netif_tx_unlock(txq);
 			local_irq_restore(flags);
 
 			schedule_delayed_work(&npinfo->tx_work, HZ/10);
 			return;
 		}
-		netif_tx_unlock(dev);
+		__netif_tx_unlock(txq);
 		local_irq_restore(flags);
 	}
 }
@@ -278,17 +280,19 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 
 	/* don't get messages out of order, and no recursion */
 	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
+		struct netdev_queue *txq;
 		unsigned long flags;
 
+		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+
 		local_irq_save(flags);
 		/* try until next clock tick */
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
 		     tries > 0; --tries) {
-			if (netif_tx_trylock(dev)) {
-				if (!netif_queue_stopped(dev) &&
-				    !netif_subqueue_stopped(dev, skb))
+			if (__netif_tx_trylock(txq)) {
+				if (!netif_tx_queue_stopped(txq))
 					status = dev->hard_start_xmit(skb, dev);
-				netif_tx_unlock(dev);
+				__netif_tx_unlock(txq);
 
 				if (status == NETDEV_TX_OK)
 					break;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fdf5377..906802d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2123,6 +2123,24 @@ static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
 	}
 }
 #endif
+static void set_cur_queue_map(struct pktgen_dev *pkt_dev)
+{
+	if (pkt_dev->queue_map_min < pkt_dev->queue_map_max) {
+		__u16 t;
+		if (pkt_dev->flags & F_QUEUE_MAP_RND) {
+			t = random32() %
+				(pkt_dev->queue_map_max -
+				 pkt_dev->queue_map_min + 1)
+				+ pkt_dev->queue_map_min;
+		} else {
+			t = pkt_dev->cur_queue_map + 1;
+			if (t > pkt_dev->queue_map_max)
+				t = pkt_dev->queue_map_min;
+		}
+		pkt_dev->cur_queue_map = t;
+	}
+}
+
 /* Increment/randomize headers according to flags and current values
  * for IP src/dest, UDP src/dst port, MAC-Addr src/dst
  */
@@ -2325,19 +2343,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		pkt_dev->cur_pkt_size = t;
 	}
 
-	if (pkt_dev->queue_map_min < pkt_dev->queue_map_max) {
-		__u16 t;
-		if (pkt_dev->flags & F_QUEUE_MAP_RND) {
-			t = random32() %
-				(pkt_dev->queue_map_max - pkt_dev->queue_map_min + 1)
-				+ pkt_dev->queue_map_min;
-		} else {
-			t = pkt_dev->cur_queue_map + 1;
-			if (t > pkt_dev->queue_map_max)
-				t = pkt_dev->queue_map_min;
-		}
-		pkt_dev->cur_queue_map = t;
-	}
+	set_cur_queue_map(pkt_dev);
 
 	pkt_dev->flows[flow].count++;
 }
@@ -2458,7 +2464,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	__be16 *vlan_encapsulated_proto = NULL;  /* packet type ID field (or len) for VLAN tag */
 	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
-
+	u16 queue_map;
 
 	if (pkt_dev->nr_labels)
 		protocol = htons(ETH_P_MPLS_UC);
@@ -2469,6 +2475,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
+	queue_map = pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
 
 	datalen = (odev->hard_header_len + 16) & ~0xf;
@@ -2507,7 +2514,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	skb->network_header = skb->tail;
 	skb->transport_header = skb->network_header + sizeof(struct iphdr);
 	skb_put(skb, sizeof(struct iphdr) + sizeof(struct udphdr));
-	skb_set_queue_mapping(skb, pkt_dev->cur_queue_map);
+	skb_set_queue_mapping(skb, queue_map);
 	iph = ip_hdr(skb);
 	udph = udp_hdr(skb);
 
@@ -2797,6 +2804,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	__be16 *vlan_encapsulated_proto = NULL;  /* packet type ID field (or len) for VLAN tag */
 	__be16 *svlan_tci = NULL;                /* Encapsulates priority and SVLAN ID */
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
+	u16 queue_map;
 
 	if (pkt_dev->nr_labels)
 		protocol = htons(ETH_P_MPLS_UC);
@@ -2807,6 +2815,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
+	queue_map = pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
 
 	skb = alloc_skb(pkt_dev->cur_pkt_size + 64 + 16 +
@@ -2844,7 +2853,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	skb->network_header = skb->tail;
 	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
 	skb_put(skb, sizeof(struct ipv6hdr) + sizeof(struct udphdr));
-	skb_set_queue_mapping(skb, pkt_dev->cur_queue_map);
+	skb_set_queue_mapping(skb, queue_map);
 	iph = ipv6_hdr(skb);
 	udph = udp_hdr(skb);
 
@@ -3263,7 +3272,9 @@ static void pktgen_rem_thread(struct pktgen_thread *t)
 static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = NULL;
+	struct netdev_queue *txq;
 	__u64 idle_start = 0;
+	u16 queue_map;
 	int ret;
 
 	odev = pkt_dev->odev;
@@ -3285,9 +3296,15 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		}
 	}
 
-	if ((netif_queue_stopped(odev) ||
-	     (pkt_dev->skb &&
-	      netif_subqueue_stopped(odev, pkt_dev->skb))) ||
+	if (!pkt_dev->skb) {
+		set_cur_queue_map(pkt_dev);
+		queue_map = pkt_dev->cur_queue_map;
+	} else {
+		queue_map = skb_get_queue_mapping(pkt_dev->skb);
+	}
+
+	txq = netdev_get_tx_queue(odev, queue_map);
+	if (netif_tx_queue_stopped(txq) ||
 	    need_resched()) {
 		idle_start = getCurUs();
 
@@ -3303,8 +3320,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 		pkt_dev->idle_acc += getCurUs() - idle_start;
 
-		if (netif_queue_stopped(odev) ||
-		    netif_subqueue_stopped(odev, pkt_dev->skb)) {
+		if (netif_tx_queue_stopped(txq)) {
 			pkt_dev->next_tx_us = getCurUs();	/* TODO */
 			pkt_dev->next_tx_ns = 0;
 			goto out;	/* Try the next interface */
@@ -3331,9 +3347,12 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		}
 	}
 
-	netif_tx_lock_bh(odev);
-	if (!netif_queue_stopped(odev) &&
-	    !netif_subqueue_stopped(odev, pkt_dev->skb)) {
+	/* fill_packet() might have changed the queue */
+	queue_map = skb_get_queue_mapping(pkt_dev->skb);
+	txq = netdev_get_tx_queue(odev, queue_map);
+
+	__netif_tx_lock_bh(txq);
+	if (!netif_tx_queue_stopped(txq)) {
 
 		atomic_inc(&(pkt_dev->skb->users));
 	      retry_now:
@@ -3377,7 +3396,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->next_tx_ns = 0;
 	}
 
-	netif_tx_unlock_bh(odev);
+	__netif_tx_unlock_bh(txq);
 
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4e2b865..2f575b9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -166,7 +166,7 @@ static inline int qdisc_restart(struct netdev_queue *txq)
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_subqueue_stopped(dev, skb))
-		ret = dev_hard_start_xmit(skb, dev);
+		ret = dev_hard_start_xmit(skb, dev, txq);
 	HARD_TX_UNLOCK(dev, txq);
 
 	spin_lock(&txq->lock);
@@ -198,11 +198,10 @@ static inline int qdisc_restart(struct netdev_queue *txq)
 
 void __qdisc_run(struct netdev_queue *txq)
 {
-	struct net_device *dev = txq->dev;
 	unsigned long start_time = jiffies;
 
 	while (qdisc_restart(txq)) {
-		if (netif_queue_stopped(dev))
+		if (netif_tx_queue_stopped(txq))
 			break;
 
 		/*
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 44a2c34..ade3372 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -295,8 +295,7 @@ restart:
 		slave_txq = netdev_get_tx_queue(slave, 0);
 		if (slave_txq->qdisc_sleeping != q)
 			continue;
-		if (netif_queue_stopped(slave) ||
-		    __netif_subqueue_stopped(slave, subq) ||
+		if (__netif_subqueue_stopped(slave, subq) ||
 		    !netif_running(slave)) {
 			busy = 1;
 			continue;
@@ -305,8 +304,7 @@ restart:
 		switch (teql_resolve(skb, skb_res, slave)) {
 		case 0:
 			if (netif_tx_trylock(slave)) {
-				if (!netif_queue_stopped(slave) &&
-				    !__netif_subqueue_stopped(slave, subq) &&
+				if (!__netif_subqueue_stopped(slave, subq) &&
 				    slave->hard_start_xmit(skb, slave) == 0) {
 					netif_tx_unlock(slave);
 					master->slaves = NEXT_SLAVE(q);
-- 
1.5.6.2.255.gbed62

