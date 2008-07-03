From: David Miller <davem@davemloft.net>
Subject: [PATCH 25/39]: netdev: Kill netdev->egress_subqueue{,_count}.
Date: Thu, 03 Jul 2008 00:04:41 -0700 (PDT)
Message-ID: <20080703.000441.02056414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758069AbYGCHEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:04:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace with appropriate TX queue accesses.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 include/linux/netdevice.h      |   34 +++++++++++++++-------------------
 net/core/dev.c                 |    9 +++------
 3 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 10a1c8c..db50962 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2355,7 +2355,7 @@ try_msi:
 
 out:
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
-	adapter->netdev->egress_subqueue_count = adapter->num_tx_queues;
+	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
 
 	return err;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6bb3f8c..df44e44 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -118,14 +118,6 @@ struct wireless_dev;
 
 #endif  /*  __KERNEL__  */
 
-struct net_device_subqueue
-{
-	/* Give a control state for each queue.  This struct may contain
-	 * per-queue locks in the future.
-	 */
-	unsigned long   state;
-};
-
 /*
  *	Network device statistics. Akin to the 2.0 ether stats but
  *	with byte counters.
@@ -642,7 +634,13 @@ struct net_device
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
@@ -753,10 +751,6 @@ struct net_device
 	/* for setting kernel sock attribute on TCP connection setup */
 #define GSO_MAX_SIZE		65536
 	unsigned int		gso_max_size;
-
-	/* The TX queue control structures */
-	unsigned int			egress_subqueue_count;
-	struct net_device_subqueue	egress_subqueue[1];
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -1088,7 +1082,8 @@ static inline int netif_running(const struct net_device *dev)
  */
 static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
 {
-	clear_bit(__QUEUE_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
+	clear_bit(__QUEUE_STATE_XOFF, &txq->state);
 }
 
 /**
@@ -1100,11 +1095,12 @@ static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
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
@@ -1117,8 +1113,8 @@ static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
 static inline int __netif_subqueue_stopped(const struct net_device *dev,
 					 u16 queue_index)
 {
-	return test_bit(__QUEUE_STATE_XOFF,
-			&dev->egress_subqueue[queue_index].state);
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
+	return test_bit(__QUEUE_STATE_XOFF, &txq->state);
 }
 
 static inline int netif_subqueue_stopped(const struct net_device *dev,
@@ -1136,13 +1132,13 @@ static inline int netif_subqueue_stopped(const struct net_device *dev,
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
diff --git a/net/core/dev.c b/net/core/dev.c
index 4b1d39f..6bf4930 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4132,8 +4132,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
-	alloc_size = sizeof(struct net_device) +
-		     sizeof(struct net_device_subqueue) * (queue_count - 1);
+	alloc_size = sizeof(struct net_device);
 	if (sizeof_priv) {
 		/* ensure 32-byte alignment of private area */
 		alloc_size = (alloc_size + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
@@ -4163,16 +4162,14 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
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
-- 
1.5.6

