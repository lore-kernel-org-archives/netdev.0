From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 1/3] netdevice: add queue selection fallback handler for ndo_select_queue
Date: Sun, 16 Feb 2014 15:55:20 +0100
Message-ID: <1392562522-15585-2-git-send-email-dborkman@redhat.com>
References: <1392562522-15585-1-git-send-email-dborkman@redhat.com>
Cc: brouer@redhat.com, mathias.kretschmer@fokus.fraunhofer.de,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290AbaBPOza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Feb 2014 09:55:30 -0500
In-Reply-To: <1392562522-15585-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new argument for ndo_select_queue() callback that passes a
fallback handler. This gets invoked through netdev_pick_tx();
fallback handler is currently __netdev_pick_tx() as most drivers
invoke this function within their customized implementation in
case for skbs that don't need any special handling. This fallback
handler can then be replaced on other call-sites with different
queue selection methods (e.g. in packet sockets, pktgen etc).

This also has the nice side-effect that __netdev_pick_tx() is
then only invoked from netdev_pick_tx() and export of that
function to modules can be undone.

Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/bonding/bond_main.c                 | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 6 +++---
 drivers/net/ethernet/lantiq_etop.c              | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    | 2 +-
 drivers/net/ethernet/tile/tilegx.c              | 2 +-
 drivers/net/team/team.c                         | 2 +-
 drivers/net/tun.c                               | 2 +-
 drivers/net/wireless/mwifiex/main.c             | 2 +-
 drivers/staging/bcm/Bcmnet.c                    | 2 +-
 drivers/staging/netlogic/xlr_net.c              | 2 +-
 drivers/staging/rtl8188eu/os_dep/os_intfs.c     | 2 +-
 include/linux/netdevice.h                       | 9 ++++++---
 net/core/flow_dissector.c                       | 7 +++----
 net/mac80211/iface.c                            | 6 ++++--
 17 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8676649..1c6104d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3707,7 +3707,7 @@ static inline int bond_slave_override(struct bonding *bond,
 
 
 static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb,
-			     void *accel_priv)
+			     void *accel_priv, select_queue_fallback_t fallback)
 {
 	/*
 	 * This helper function exists to help dev_pick_tx get the correct
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9d7419e..66c0df7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1873,7 +1873,7 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 }
 
 u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb,
-		       void *accel_priv)
+		       void *accel_priv, select_queue_fallback_t fallback)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
@@ -1895,7 +1895,7 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb,
 	}
 
 	/* select a non-FCoE queue */
-	return __netdev_pick_tx(dev, skb) % BNX2X_NUM_ETH_QUEUES(bp);
+	return fallback(dev, skb) % BNX2X_NUM_ETH_QUEUES(bp);
 }
 
 void bnx2x_set_num_queues(struct bnx2x *bp)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index bfc58d4..a89a40f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -496,7 +496,7 @@ int bnx2x_set_vf_vlan(struct net_device *netdev, int vf, u16 vlan, u8 qos);
 
 /* select_queue callback */
 u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb,
-		       void *accel_priv);
+		       void *accel_priv, select_queue_fallback_t fallback);
 
 static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
 					struct bnx2x_fastpath *fp,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6d4ada7..18076c4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6881,7 +6881,7 @@ static inline int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 }
 
 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb,
-			      void *accel_priv)
+			      void *accel_priv, select_queue_fallback_t fallback)
 {
 	struct ixgbe_fwd_adapter *fwd_adapter = accel_priv;
 #ifdef IXGBE_FCOE
@@ -6907,7 +6907,7 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb,
 		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
 			break;
 	default:
-		return __netdev_pick_tx(dev, skb);
+		return fallback(dev, skb);
 	}
 
 	f = &adapter->ring_feature[RING_F_FCOE];
@@ -6920,7 +6920,7 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb,
 
 	return txq + f->offset;
 #else
-	return __netdev_pick_tx(dev, skb);
+	return fallback(dev, skb);
 #endif
 }
 
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 8f9266c..fd4b6ae 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -619,7 +619,7 @@ ltq_etop_set_multicast_list(struct net_device *dev)
 
 static u16
 ltq_etop_select_queue(struct net_device *dev, struct sk_buff *skb,
-		      void *accel_priv)
+		      void *accel_priv, select_queue_fallback_t fallback)
 {
 	/* we are currently only using the first queue */
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 8e8a7eb..1345703 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -629,7 +629,7 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 }
 
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
-			 void *accel_priv)
+			 void *accel_priv, select_queue_fallback_t fallback)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	u16 rings_p_up = priv->num_tx_rings_p_up;
@@ -641,7 +641,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 	if (vlan_tx_tag_present(skb))
 		up = vlan_tx_tag_get(skb) >> VLAN_PRIO_SHIFT;
 
-	return __netdev_pick_tx(dev, skb) % rings_p_up + up * rings_p_up;
+	return fallback(dev, skb) % rings_p_up + up * rings_p_up;
 }
 
 static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 3af04c3..9ca223b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -723,7 +723,7 @@ int mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 
 void mlx4_en_tx_irq(struct mlx4_cq *mcq);
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
-			 void *accel_priv);
+			 void *accel_priv, select_queue_fallback_t fallback);
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 023237a..17503da 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2071,7 +2071,7 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 
 /* Return subqueue id on this core (one per core). */
 static u16 tile_net_select_queue(struct net_device *dev, struct sk_buff *skb,
-				 void *accel_priv)
+				 void *accel_priv, select_queue_fallback_t fallback)
 {
 	return smp_processor_id();
 }
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2840742..c8624a8 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1648,7 +1648,7 @@ static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static u16 team_select_queue(struct net_device *dev, struct sk_buff *skb,
-			     void *accel_priv)
+			     void *accel_priv, select_queue_fallback_t fallback)
 {
 	/*
 	 * This helper function exists to help dev_pick_tx get the correct
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 44c4db8..8fe9cb7 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -366,7 +366,7 @@ static inline void tun_flow_save_rps_rxhash(struct tun_flow_entry *e, u32 hash)
  * hope the rxq no. may help here.
  */
 static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb,
-			    void *accel_priv)
+			    void *accel_priv, select_queue_fallback_t fallback)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 	struct tun_flow_entry *e;
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
index 4d79761..9d3d275 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -748,7 +748,7 @@ static struct net_device_stats *mwifiex_get_stats(struct net_device *dev)
 
 static u16
 mwifiex_netdev_select_wmm_queue(struct net_device *dev, struct sk_buff *skb,
-				void *accel_priv)
+				void *accel_priv, select_queue_fallback_t fallback)
 {
 	skb->priority = cfg80211_classify8021d(skb, NULL);
 	return mwifiex_1d_to_wmm_queue[skb->priority];
diff --git a/drivers/staging/bcm/Bcmnet.c b/drivers/staging/bcm/Bcmnet.c
index 8dfdd27..95a2358 100644
--- a/drivers/staging/bcm/Bcmnet.c
+++ b/drivers/staging/bcm/Bcmnet.c
@@ -40,7 +40,7 @@ static INT bcm_close(struct net_device *dev)
 }
 
 static u16 bcm_select_queue(struct net_device *dev, struct sk_buff *skb,
-			    void *accel_priv)
+			    void *accel_priv, select_queue_fallback_t fallback)
 {
 	return ClassifyPacket(netdev_priv(dev), skb);
 }
diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index eedffed..6f9ac27 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -307,7 +307,7 @@ static netdev_tx_t xlr_net_start_xmit(struct sk_buff *skb,
 }
 
 static u16 xlr_net_select_queue(struct net_device *ndev, struct sk_buff *skb,
-				void *accel_priv)
+				void *accel_priv, select_queue_fallback_t fallback)
 {
 	return (u16)smp_processor_id();
 }
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index 68f98fa..7c9ee58 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -653,7 +653,7 @@ static unsigned int rtw_classify8021d(struct sk_buff *skb)
 }
 
 static u16 rtw_select_queue(struct net_device *dev, struct sk_buff *skb,
-			    void *accel_priv)
+			    void *accel_priv, select_queue_fallback_t fallback)
 {
 	struct adapter	*padapter = rtw_netdev_priv(dev);
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 21d4e6b..1de9c13 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -752,6 +752,9 @@ struct netdev_phys_port_id {
 	unsigned char id_len;
 };
 
+typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
+				       struct sk_buff *skb);
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -783,7 +786,7 @@ struct netdev_phys_port_id {
  *	Required can not be NULL.
  *
  * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb,
- *                         void *accel_priv);
+ *                         void *accel_priv, select_queue_fallback_t fallback);
  *	Called to decide which queue to when device supports multiple
  *	transmit queues.
  *
@@ -1005,7 +1008,8 @@ struct net_device_ops {
 						   struct net_device *dev);
 	u16			(*ndo_select_queue)(struct net_device *dev,
 						    struct sk_buff *skb,
-						    void *accel_priv);
+						    void *accel_priv,
+						    select_queue_fallback_t fallback);
 	void			(*ndo_change_rx_flags)(struct net_device *dev,
 						       int flags);
 	void			(*ndo_set_rx_mode)(struct net_device *dev);
@@ -1551,7 +1555,6 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 				    struct sk_buff *skb,
 				    void *accel_priv);
-u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb);
 
 /*
  * Net namespace inlines
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 87577d4..75fe83f 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -372,7 +372,7 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 #endif
 }
 
-u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
+static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 	int queue_index = sk_tx_queue_get(sk);
@@ -392,7 +392,6 @@ u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 
 	return queue_index;
 }
-EXPORT_SYMBOL(__netdev_pick_tx);
 
 struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 				    struct sk_buff *skb,
@@ -403,8 +402,8 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 	if (dev->real_num_tx_queues != 1) {
 		const struct net_device_ops *ops = dev->netdev_ops;
 		if (ops->ndo_select_queue)
-			queue_index = ops->ndo_select_queue(dev, skb,
-							    accel_priv);
+			queue_index = ops->ndo_select_queue(dev, skb, accel_priv,
+							    __netdev_pick_tx);
 		else
 			queue_index = __netdev_pick_tx(dev, skb);
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index d6d1f1d..ce1c443 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1057,7 +1057,8 @@ static void ieee80211_uninit(struct net_device *dev)
 
 static u16 ieee80211_netdev_select_queue(struct net_device *dev,
 					 struct sk_buff *skb,
-					 void *accel_priv)
+					 void *accel_priv,
+					 select_queue_fallback_t fallback)
 {
 	return ieee80211_select_queue(IEEE80211_DEV_TO_SUB_IF(dev), skb);
 }
@@ -1075,7 +1076,8 @@ static const struct net_device_ops ieee80211_dataif_ops = {
 
 static u16 ieee80211_monitor_select_queue(struct net_device *dev,
 					  struct sk_buff *skb,
-					  void *accel_priv)
+					  void *accel_priv,
+					  select_queue_fallback_t fallback)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local = sdata->local;
-- 
1.7.11.7
