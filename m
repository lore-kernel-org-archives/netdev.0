From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net V3 2/2] net: core: explicitly select a txq
	before doing l2 forwarding
Date: Fri, 10 Jan 2014 16:18:26 +0800
Message-ID: <1389341906-2367-2-git-send-email-jasowang@redhat.com>
References: <1389341906-2367-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net, Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, mst@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1389341906-2367-1-git-send-email-jasowang@redhat.com>
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

- NETIF_F_LLTX were removed for macvlan, so txq lock were done for macvlan
  instead of lower device which misses the necessary txq synchronization for
  lower device such as txq stopping or frozen required by dev watchdog or
  control path.
- dev_hard_start_xmit() was called with NULL txq which bypasses the net device
  watchdog.
- dev_hard_start_xmit() does not check txq everywhere which will lead a crash
  when tso is disabled for lower device.

Fix this by explicitly introducing a new param for .ndo_select_queue() for just
selecting queues in the case of l2 forwarding offload. netdev_pick_tx() was also
extended to accept this parameter and dev_queue_xmit_accel() was used to do l2
forwarding transmission.

With this fixes, NETIF_F_LLTX could be preserved for macvlan and there's no need
to check txq against NULL in dev_hard_start_xmit(). Also there's no need to keep
a dedicated ndo_dfwd_start_xmit() and we can just reuse the code of
dev_queue_xmit() to do the transmission.

In the future, it was also required for macvtap l2 forwarding support since it
provides a necessary synchronization method.

Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: e1000-devel@lists.sourceforge.net
Signed-off-by: Jason Wang <jasowang@redhat.com>

---
Changes from V2:
- Reuse dev_queue_xmit() instead of re-inventing dfwd_direct_xmit()
- remove the unnecessary braces
Changes from V1:
- Adding a new parameter to ndo_select_queue instead of a new method to select
  queue for l2 forwarding.
- Remove the unnecessary ndo_dfwd_start_xmit() since txq was selected
  explicitly.
- Keep NETIF_F_LLTX when netdev feature is changed.
- Shape the commit log
---
 drivers/net/bonding/bond_main.c                 |    3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   33 +++++++++--------------
 drivers/net/ethernet/lantiq_etop.c              |    3 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    3 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    3 +-
 drivers/net/ethernet/tile/tilegx.c              |    3 +-
 drivers/net/macvlan.c                           |    9 ++----
 drivers/net/team/team.c                         |    3 +-
 drivers/net/tun.c                               |    3 +-
 drivers/net/wireless/mwifiex/main.c             |    3 +-
 drivers/staging/bcm/Bcmnet.c                    |    3 +-
 drivers/staging/netlogic/xlr_net.c              |    3 +-
 drivers/staging/rtl8188eu/os_dep/os_intfs.c     |    3 +-
 include/linux/netdevice.h                       |   12 +++++---
 net/core/dev.c                                  |   29 ++++++++++++--------
 net/core/flow_dissector.c                       |   10 +++++--
 net/core/netpoll.c                              |    2 +-
 net/mac80211/iface.c                            |    6 +++-
 net/sched/sch_generic.c                         |    2 +-
 21 files changed, 80 insertions(+), 62 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 398e299..4b8c58b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3732,7 +3732,8 @@ static inline int bond_slave_override(struct bonding *bond,
 }
 
 
-static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
+static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb,
+			     void *accel_priv)
 {
 	/*
 	 * This helper function exists to help dev_pick_tx get the correct
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ec96130..513fa85 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1832,7 +1832,8 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 		bnx2x_napi_disable_cnic(bp);
 }
 
-u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
+u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb,
+		       void *accel_priv)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index da8fcaa..41f3ca5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -524,7 +524,8 @@ int bnx2x_set_vf_mac(struct net_device *dev, int queue, u8 *mac);
 int bnx2x_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos);
 
 /* select_queue callback */
-u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb);
+u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb,
+		       void *accel_priv);
 
 static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
 					struct bnx2x_fastpath *fp,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cc06854..5bcc870 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6827,12 +6827,20 @@ static inline int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 	return __ixgbe_maybe_stop_tx(tx_ring, size);
 }
 
-#ifdef IXGBE_FCOE
-static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
+static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb,
+			      void *accel_priv)
 {
+	struct ixgbe_fwd_adapter *fwd_adapter = accel_priv;
+#ifdef IXGBE_FCOE
 	struct ixgbe_adapter *adapter;
 	struct ixgbe_ring_feature *f;
 	int txq;
+#endif
+
+	if (fwd_adapter)
+		return skb->queue_mapping + fwd_adapter->tx_base_queue;
+
+#ifdef IXGBE_FCOE
 
 	/*
 	 * only execute the code below if protocol is FCoE
@@ -6858,9 +6866,11 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 		txq -= f->indices;
 
 	return txq + f->offset;
+#else
+	return __netdev_pick_tx(dev, skb);
+#endif
 }
 
-#endif
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring)
@@ -7629,27 +7639,11 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	kfree(fwd_adapter);
 }
 
-static netdev_tx_t ixgbe_fwd_xmit(struct sk_buff *skb,
-				  struct net_device *dev,
-				  void *priv)
-{
-	struct ixgbe_fwd_adapter *fwd_adapter = priv;
-	unsigned int queue;
-	struct ixgbe_ring *tx_ring;
-
-	queue = skb->queue_mapping + fwd_adapter->tx_base_queue;
-	tx_ring = fwd_adapter->real_adapter->tx_ring[queue];
-
-	return __ixgbe_xmit_frame(skb, dev, tx_ring);
-}
-
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
-#ifdef IXGBE_FCOE
 	.ndo_select_queue	= ixgbe_select_queue,
-#endif
 	.ndo_set_rx_mode	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgbe_set_mac,
@@ -7689,7 +7683,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 	.ndo_dfwd_add_station	= ixgbe_fwd_add,
 	.ndo_dfwd_del_station	= ixgbe_fwd_del,
-	.ndo_dfwd_start_xmit	= ixgbe_fwd_xmit,
 };
 
 /**
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 6a6c1f7..ec94a20 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -619,7 +619,8 @@ ltq_etop_set_multicast_list(struct net_device *dev)
 }
 
 static u16
-ltq_etop_select_queue(struct net_device *dev, struct sk_buff *skb)
+ltq_etop_select_queue(struct net_device *dev, struct sk_buff *skb,
+		      void *accel_priv)
 {
 	/* we are currently only using the first queue */
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index f54ebd5..a7fcd59 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -592,7 +592,8 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 	}
 }
 
-u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
+u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
+			 void *accel_priv)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	u16 rings_p_up = priv->num_tx_rings_p_up;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index f3758de..d5758ad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -714,7 +714,8 @@ int mlx4_en_set_cq_moder(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 int mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 
 void mlx4_en_tx_irq(struct mlx4_cq *mcq);
-u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb);
+u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
+			 void *accel_priv);
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 628b736..0e9fb33 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2080,7 +2080,8 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 }
 
 /* Return subqueue id on this core (one per core). */
-static u16 tile_net_select_queue(struct net_device *dev, struct sk_buff *skb)
+static u16 tile_net_select_queue(struct net_device *dev, struct sk_buff *skb,
+				 void *accel_priv)
 {
 	return smp_processor_id();
 }
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 5360f73..bc8faae 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -299,7 +299,7 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 
 	if (vlan->fwd_priv) {
 		skb->dev = vlan->lowerdev;
-		ret = dev_hard_start_xmit(skb, skb->dev, NULL, vlan->fwd_priv);
+		ret = dev_queue_xmit_accel(skb, vlan->fwd_priv);
 	} else {
 		ret = macvlan_queue_xmit(skb, dev);
 	}
@@ -365,10 +365,8 @@ static int macvlan_open(struct net_device *dev)
 		 */
 		if (IS_ERR_OR_NULL(vlan->fwd_priv)) {
 			vlan->fwd_priv = NULL;
-		} else {
-			dev->features &= ~NETIF_F_LLTX;
+		} else
 			return 0;
-		}
 	}
 
 	err = -EBUSY;
@@ -702,8 +700,7 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
 	features = netdev_increment_features(vlan->lowerdev->features,
 					     features,
 					     mask);
-	if (!vlan->fwd_priv)
-		features |= NETIF_F_LLTX;
+	features |= NETIF_F_LLTX;
 
 	return features;
 }
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 736050d..b75ae5b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1647,7 +1647,8 @@ static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static u16 team_select_queue(struct net_device *dev, struct sk_buff *skb)
+static u16 team_select_queue(struct net_device *dev, struct sk_buff *skb,
+			     void *accel_priv)
 {
 	/*
 	 * This helper function exists to help dev_pick_tx get the correct
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7c8343a..ecec802 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -348,7 +348,8 @@ unlock:
  * different rxq no. here. If we could not get rxhash, then we would
  * hope the rxq no. may help here.
  */
-static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
+static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb,
+			    void *accel_priv)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 	struct tun_flow_entry *e;
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
index 78e8a66..8bb8988 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -746,7 +746,8 @@ static struct net_device_stats *mwifiex_get_stats(struct net_device *dev)
 }
 
 static u16
-mwifiex_netdev_select_wmm_queue(struct net_device *dev, struct sk_buff *skb)
+mwifiex_netdev_select_wmm_queue(struct net_device *dev, struct sk_buff *skb,
+				void *accel_priv)
 {
 	skb->priority = cfg80211_classify8021d(skb);
 	return mwifiex_1d_to_wmm_queue[skb->priority];
diff --git a/drivers/staging/bcm/Bcmnet.c b/drivers/staging/bcm/Bcmnet.c
index 53fee2f..8dfdd27 100644
--- a/drivers/staging/bcm/Bcmnet.c
+++ b/drivers/staging/bcm/Bcmnet.c
@@ -39,7 +39,8 @@ static INT bcm_close(struct net_device *dev)
 	return 0;
 }
 
-static u16 bcm_select_queue(struct net_device *dev, struct sk_buff *skb)
+static u16 bcm_select_queue(struct net_device *dev, struct sk_buff *skb,
+			    void *accel_priv)
 {
 	return ClassifyPacket(netdev_priv(dev), skb);
 }
diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index 235d2b1..eedffed 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -306,7 +306,8 @@ static netdev_tx_t xlr_net_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static u16 xlr_net_select_queue(struct net_device *ndev, struct sk_buff *skb)
+static u16 xlr_net_select_queue(struct net_device *ndev, struct sk_buff *skb,
+				void *accel_priv)
 {
 	return (u16)smp_processor_id();
 }
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index 17659bb..dd69e34 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -652,7 +652,8 @@ static unsigned int rtw_classify8021d(struct sk_buff *skb)
 	return dscp >> 5;
 }
 
-static u16 rtw_select_queue(struct net_device *dev, struct sk_buff *skb)
+static u16 rtw_select_queue(struct net_device *dev, struct sk_buff *skb,
+			    void *accel_priv)
 {
 	struct adapter	*padapter = rtw_netdev_priv(dev);
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5faaadb..ce2a1f5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -769,7 +769,8 @@ struct netdev_phys_port_id {
  *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
  *	Required can not be NULL.
  *
- * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb);
+ * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb,
+ *                         void *accel_priv);
  *	Called to decide which queue to when device supports multiple
  *	transmit queues.
  *
@@ -990,7 +991,8 @@ struct net_device_ops {
 	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
 						   struct net_device *dev);
 	u16			(*ndo_select_queue)(struct net_device *dev,
-						    struct sk_buff *skb);
+						    struct sk_buff *skb,
+						    void *accel_priv);
 	void			(*ndo_change_rx_flags)(struct net_device *dev,
 						       int flags);
 	void			(*ndo_set_rx_mode)(struct net_device *dev);
@@ -1529,7 +1531,8 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 }
 
 struct netdev_queue *netdev_pick_tx(struct net_device *dev,
-				    struct sk_buff *skb);
+				    struct sk_buff *skb,
+				    void *accel_priv);
 u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb);
 
 /*
@@ -1819,6 +1822,7 @@ int dev_close(struct net_device *dev);
 void dev_disable_lro(struct net_device *dev);
 int dev_loopback_xmit(struct sk_buff *newskb);
 int dev_queue_xmit(struct sk_buff *skb);
+int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv);
 int register_netdevice(struct net_device *dev);
 void unregister_netdevice_queue(struct net_device *dev, struct list_head *head);
 void unregister_netdevice_many(struct list_head *head);
@@ -2426,7 +2430,7 @@ int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_port_id *ppid);
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-			struct netdev_queue *txq, void *accel_priv);
+			struct netdev_queue *txq);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 
 extern int		netdev_budget;
diff --git a/net/core/dev.c b/net/core/dev.c
index 4fc1722..0ce469e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2539,7 +2539,7 @@ static inline int skb_needs_linearize(struct sk_buff *skb,
 }
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
-			struct netdev_queue *txq, void *accel_priv)
+			struct netdev_queue *txq)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int rc = NETDEV_TX_OK;
@@ -2605,13 +2605,10 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			dev_queue_xmit_nit(skb, dev);
 
 		skb_len = skb->len;
-		if (accel_priv)
-			rc = ops->ndo_dfwd_start_xmit(skb, dev, accel_priv);
-		else
 			rc = ops->ndo_start_xmit(skb, dev);
 
 		trace_net_dev_xmit(skb, rc, dev, skb_len);
-		if (rc == NETDEV_TX_OK && txq)
+		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
 		return rc;
 	}
@@ -2627,10 +2624,7 @@ gso:
 			dev_queue_xmit_nit(nskb, dev);
 
 		skb_len = nskb->len;
-		if (accel_priv)
-			rc = ops->ndo_dfwd_start_xmit(nskb, dev, accel_priv);
-		else
-			rc = ops->ndo_start_xmit(nskb, dev);
+		rc = ops->ndo_start_xmit(nskb, dev);
 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
@@ -2811,7 +2805,7 @@ EXPORT_SYMBOL(dev_loopback_xmit);
  *      the BH enable code must have IRQs enabled so that it will not deadlock.
  *          --BLG
  */
-int dev_queue_xmit(struct sk_buff *skb)
+int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 {
 	struct net_device *dev = skb->dev;
 	struct netdev_queue *txq;
@@ -2827,7 +2821,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 	skb_update_prio(skb);
 
-	txq = netdev_pick_tx(dev, skb);
+	txq = netdev_pick_tx(dev, skb, accel_priv);
 	q = rcu_dereference_bh(txq->qdisc);
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -2863,7 +2857,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 			if (!netif_xmit_stopped(txq)) {
 				__this_cpu_inc(xmit_recursion);
-				rc = dev_hard_start_xmit(skb, dev, txq, NULL);
+				rc = dev_hard_start_xmit(skb, dev, txq);
 				__this_cpu_dec(xmit_recursion);
 				if (dev_xmit_complete(rc)) {
 					HARD_TX_UNLOCK(dev, txq);
@@ -2892,8 +2886,19 @@ out:
 	rcu_read_unlock_bh();
 	return rc;
 }
+
+int dev_queue_xmit(struct sk_buff *skb)
+{
+	return __dev_queue_xmit(skb, NULL);
+}
 EXPORT_SYMBOL(dev_queue_xmit);
 
+int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv)
+{
+	return __dev_queue_xmit(skb, accel_priv);
+}
+EXPORT_SYMBOL(dev_queue_xmit_accel);
+
 
 /*=======================================================================
 			Receiver routines
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d6ef173..2fc5bea 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -395,17 +395,21 @@ u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 EXPORT_SYMBOL(__netdev_pick_tx);
 
 struct netdev_queue *netdev_pick_tx(struct net_device *dev,
-				    struct sk_buff *skb)
+				    struct sk_buff *skb,
+				    void *accel_priv)
 {
 	int queue_index = 0;
 
 	if (dev->real_num_tx_queues != 1) {
 		const struct net_device_ops *ops = dev->netdev_ops;
 		if (ops->ndo_select_queue)
-			queue_index = ops->ndo_select_queue(dev, skb);
+			queue_index = ops->ndo_select_queue(dev, skb,
+							    accel_priv);
 		else
 			queue_index = __netdev_pick_tx(dev, skb);
-		queue_index = dev_cap_txqueue(dev, queue_index);
+
+		if (!accel_priv)
+			queue_index = dev_cap_txqueue(dev, queue_index);
 	}
 
 	skb_set_queue_mapping(skb, queue_index);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 3030978..19fe9c7 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -375,7 +375,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
 		struct netdev_queue *txq;
 
-		txq = netdev_pick_tx(dev, skb);
+		txq = netdev_pick_tx(dev, skb, NULL);
 
 		/* try until next clock tick */
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 36c3a4c..a075791 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1061,7 +1061,8 @@ static void ieee80211_uninit(struct net_device *dev)
 }
 
 static u16 ieee80211_netdev_select_queue(struct net_device *dev,
-					 struct sk_buff *skb)
+					 struct sk_buff *skb,
+					 void *accel_priv)
 {
 	return ieee80211_select_queue(IEEE80211_DEV_TO_SUB_IF(dev), skb);
 }
@@ -1078,7 +1079,8 @@ static const struct net_device_ops ieee80211_dataif_ops = {
 };
 
 static u16 ieee80211_monitor_select_queue(struct net_device *dev,
-					  struct sk_buff *skb)
+					  struct sk_buff *skb,
+					  void *accel_priv)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local = sdata->local;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 922a094..7fc899a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -126,7 +126,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_xmit_frozen_or_stopped(txq))
-		ret = dev_hard_start_xmit(skb, dev, txq, NULL);
+		ret = dev_hard_start_xmit(skb, dev, txq);
 
 	HARD_TX_UNLOCK(dev, txq);
 
-- 
1.7.1


------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
