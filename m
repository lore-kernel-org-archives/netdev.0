From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 2/2] net: core: explicitly select a txq
	before doing l2 forwarding
Date: Mon,  6 Jan 2014 11:21:07 +0800
Message-ID: <1388978467-2075-2-git-send-email-jasowang@redhat.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net, Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, mst@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1388978467-2075-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Currently, the tx queue were selected implicitly in ndo_dfwd_start_xmit(). The
will cause several issues:

- NETIF_F_LLTX was forced for macvlan device in this case which lead extra lock
  contention.
- dev_hard_start_xmit() was called with NULL txq which bypasses the net device
  watchdog
- dev_hard_start_xmit() does not check txq everywhere which will lead a crash
  when tso is disabled for lower device.

Fix this by explicitly introducing a select queue method just for l2 forwarding
offload (ndo_dfwd_select_queue), and introducing dfwd_direct_xmit() to do the
queue selecting and transmitting for l2 forwarding.

With this fixes, NETIF_F_LLTX could be preserved for macvlan and there's no need
to check txq against NULL in dev_hard_start_xmit().

In the future, it was also required for macvtap l2 forwarding support since it
provides a necessary synchronization method.

Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: e1000-devel@lists.sourceforge.net
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   15 +++++++++----
 drivers/net/macvlan.c                         |    3 +-
 include/linux/netdevice.h                     |   11 +++++++++
 net/core/dev.c                                |   28 ++++++++++++++++++++++++-
 4 files changed, 49 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cc06854..ee71cf7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7629,16 +7629,20 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	kfree(fwd_adapter);
 }
 
+static u16 ixgbe_fwd_select_queue(struct net_device *dev, struct sk_buff *skb,
+				  void *priv)
+{
+	struct ixgbe_fwd_adapter *fwd_adapter = priv;
+	return skb->queue_mapping + fwd_adapter->tx_base_queue;
+}
+
 static netdev_tx_t ixgbe_fwd_xmit(struct sk_buff *skb,
 				  struct net_device *dev,
 				  void *priv)
 {
 	struct ixgbe_fwd_adapter *fwd_adapter = priv;
-	unsigned int queue;
-	struct ixgbe_ring *tx_ring;
-
-	queue = skb->queue_mapping + fwd_adapter->tx_base_queue;
-	tx_ring = fwd_adapter->real_adapter->tx_ring[queue];
+	struct ixgbe_ring *tx_ring =
+		fwd_adapter->real_adapter->tx_ring[skb->queue_mapping];
 
 	return __ixgbe_xmit_frame(skb, dev, tx_ring);
 }
@@ -7689,6 +7693,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 	.ndo_dfwd_add_station	= ixgbe_fwd_add,
 	.ndo_dfwd_del_station	= ixgbe_fwd_del,
+	.ndo_dfwd_select_queue	= ixgbe_fwd_select_queue,
 	.ndo_dfwd_start_xmit	= ixgbe_fwd_xmit,
 };
 
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 5360f73..2cbbce3 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -299,7 +299,7 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 
 	if (vlan->fwd_priv) {
 		skb->dev = vlan->lowerdev;
-		ret = dev_hard_start_xmit(skb, skb->dev, NULL, vlan->fwd_priv);
+		ret = dfwd_direct_xmit(skb, skb->dev, vlan->fwd_priv);
 	} else {
 		ret = macvlan_queue_xmit(skb, dev);
 	}
@@ -366,7 +366,6 @@ static int macvlan_open(struct net_device *dev)
 		if (IS_ERR_OR_NULL(vlan->fwd_priv)) {
 			vlan->fwd_priv = NULL;
 		} else {
-			dev->features &= ~NETIF_F_LLTX;
 			return 0;
 		}
 	}
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d9a550b..dbfd476 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -975,6 +975,11 @@ struct netdev_phys_port_id {
  *	by 'ndo_dfwd_add_station'. 'pdev' is the net device backing
  *	the station and priv is the structure returned by the add
  *	operation.
+ * u16 (*ndo_dfwd_select_queue)(struct net_device *dev,
+ *				struct sk_buff *skb,
+ *				void *priv);
+ *	Called to decide which queue to xmit over the accelerated station when
+ *	device supports multiple transmit queues.
  * netdev_tx_t (*ndo_dfwd_start_xmit)(struct sk_buff *skb,
  *				      struct net_device *dev,
  *				      void *priv);
@@ -1123,6 +1128,10 @@ struct net_device_ops {
 	void			(*ndo_dfwd_del_station)(struct net_device *pdev,
 							void *priv);
 
+	u16			(*ndo_dfwd_select_queue)(struct net_device *dev,
+							 struct sk_buff *skb,
+							 void *priv);
+
 	netdev_tx_t		(*ndo_dfwd_start_xmit) (struct sk_buff *skb,
 							struct net_device *dev,
 							void *priv);
@@ -2416,6 +2425,8 @@ int dev_set_mac_address(struct net_device *, struct sockaddr *);
 int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_port_id *ppid);
+int dfwd_direct_xmit(struct sk_buff *skb, struct net_device *dev,
+		     void *accel_priv);
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq, void *accel_priv);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 4fc1722..bc2b03f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2538,6 +2538,32 @@ static inline int skb_needs_linearize(struct sk_buff *skb,
 				!(features & NETIF_F_SG)));
 }
 
+int dfwd_direct_xmit(struct sk_buff *skb, struct net_device *dev,
+		     void *accel_priv)
+{
+	struct netdev_queue *txq;
+	int ret = NETDEV_TX_BUSY;
+	int index;
+
+	BUG_ON(!dev->netdev_ops->ndo_dfwd_select_queue);
+	index =	dev->netdev_ops->ndo_dfwd_select_queue(dev, skb,
+						       accel_priv);
+
+	local_bh_disable();
+
+	skb_set_queue_mapping(skb, index);
+	txq = netdev_get_tx_queue(dev, index);
+
+	HARD_TX_LOCK(dev, txq, smp_processor_id());
+	if (!netif_xmit_frozen_or_stopped(txq))
+		ret = dev_hard_start_xmit(skb, dev, txq, accel_priv);
+	HARD_TX_UNLOCK(dev, txq);
+
+	local_bh_enable();
+	return ret;
+}
+EXPORT_SYMBOL_GPL(dfwd_direct_xmit);
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq, void *accel_priv)
 {
@@ -2611,7 +2637,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			rc = ops->ndo_start_xmit(skb, dev);
 
 		trace_net_dev_xmit(skb, rc, dev, skb_len);
-		if (rc == NETDEV_TX_OK && txq)
+		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
 		return rc;
 	}
-- 
1.7.1


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
