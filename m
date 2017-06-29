From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_en: Do not allocate redundant TX queues when TC is disabled
Date: Thu, 29 Jun 2017 14:07:57 +0300
Message-ID: <1498734477-26111-3-git-send-email-tariqt@mellanox.com>
References: <1498734477-26111-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Inbar Karmy <inbark@mellanox.com>,
        Tarick Bedeir <tarick@google.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55780 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751837AbdF2LIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 07:08:44 -0400
In-Reply-To: <1498734477-26111-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inbar Karmy <inbark@mellanox.com>

Currently the number of TX queues that are allocated doesn't depend
on the number of TCs, the module always loads with max num of UP
per channel.
In order to prevent the allocation of unnecessary memory, the
module will load with minimum number of UPs per channel, and the
user will be able to control the number of TX queues per channel
by changing the number of TC to 8 using the tc command.
The variable num_up will hold the information about the current
number of UPs.
Due to the change, needed to remove the lines that set the value of
UP to be different than zero in the func "mlx4_en_select_queue",
since now the num of TX queues that are allocated is only one per channel
in default.
In order not to force the UP to be zero in case of only one TC, added
a condition before forcing it in the func "mlx4_en_fill_qp_context".

Tested:
After the module is loaded with minimum number of UP per channel, to
increase num of TCs to 8, use:
tc qdisc add dev ens8 root mqprio num_tc 8
In order to decrease the number of TCs to minimum number of UP per channel,
use:
tc qdisc del dev ens8 root

Signed-off-by: Inbar Karmy <inbark@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: Tarick Bedeir <tarick@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c    |  6 +--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c   |  7 +--
 drivers/net/ethernet/mellanox/mlx4/en_main.c      |  3 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    | 54 +++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |  3 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |  6 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |  2 +
 7 files changed, 65 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 91481f117daa..5f41dc92aa68 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -238,7 +238,7 @@ static u8 mlx4_en_dcbnl_set_state(struct net_device *dev, u8 state)
 		priv->flags &= ~MLX4_EN_FLAG_DCB_ENABLED;
 	}
 
-	if (mlx4_en_setup_tc(dev, num_tcs))
+	if (mlx4_en_alloc_tx_queue_per_tc(dev, num_tcs))
 		return 1;
 
 	return 0;
@@ -303,7 +303,7 @@ static int mlx4_en_ets_validate(struct mlx4_en_priv *priv, struct ieee_ets *ets)
 	int has_ets_tc = 0;
 
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
-		if (ets->prio_tc[i] >= priv->prof->num_up) {
+		if (ets->prio_tc[i] >= MLX4_EN_NUM_UP_HIGH) {
 			en_err(priv, "Bad priority in UP <=> TC mapping. TC: %d, UP: %d\n",
 					i, ets->prio_tc[i]);
 			return -EINVAL;
@@ -472,7 +472,7 @@ static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 			goto err;
 		if (mlx4_en_dcbnl_ieee_setpfc(dev, &pfc))
 			goto err;
-		if (mlx4_en_setup_tc(dev, 0))
+		if (mlx4_en_alloc_tx_queue_per_tc(dev, 0))
 			goto err;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 2b80a4a9945c..c751a1d434ad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1764,6 +1764,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	int port_up = 0;
 	int xdp_count;
 	int err = 0;
+	u8 up;
 
 	if (!channel->tx_count || !channel->rx_count)
 		return -EINVAL;
@@ -1801,11 +1802,11 @@ static int mlx4_en_set_channels(struct net_device *dev,
 
 	mlx4_en_safe_replace_resources(priv, tmp);
 
-	netif_set_real_num_tx_queues(dev, priv->tx_ring_num[TX]);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
-	if (netdev_get_num_tc(dev))
-		mlx4_en_setup_tc(dev, priv->prof->num_up);
+	up = (priv->prof->num_up == MLX4_EN_NUM_UP_LOW) ?
+				    0 : priv->prof->num_up;
+	mlx4_en_setup_tc(dev, up);
 
 	en_warn(priv, "Using %d TX rings\n", priv->tx_ring_num[TX]);
 	en_warn(priv, "Using %d RX rings\n", priv->rx_ring_num);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index a8eb856b0158..2b0cbca4beb5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -169,7 +169,8 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].tx_ppp = pfctx;
 		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
 		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
-		params->prof[i].num_up = MLX4_EN_NUM_UP_HIGH;
+		params->prof[i].num_up = MLX4_EN_NUM_UP_LOW;
+		params->prof[i].num_tx_rings_p_up = params->num_tx_rings_p_up;
 		params->prof[i].tx_ring_num[TX] = params->num_tx_rings_p_up *
 			params->prof[i].num_up;
 		params->prof[i].rss_rings = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e7f654623eab..3a291fc1780a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -64,7 +64,7 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 		return -EINVAL;
 
 	netdev_set_num_tc(dev, up);
-
+	netif_set_real_num_tx_queues(dev, priv->tx_ring_num[TX]);
 	/* Partition Tx queues evenly amongst UP's */
 	for (i = 0; i < up; i++) {
 		netdev_set_tc_queue(dev, i, priv->num_tx_rings_p_up, offset);
@@ -86,6 +86,50 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 	return 0;
 }
 
+int mlx4_en_alloc_tx_queue_per_tc(struct net_device *dev, u8 tc)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_port_profile new_prof;
+	struct mlx4_en_priv *tmp;
+	int port_up = 0;
+	int err = 0;
+
+	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
+	if (!tmp)
+		return -ENOMEM;
+
+	mutex_lock(&mdev->state_lock);
+	memcpy(&new_prof, priv->prof, sizeof(struct mlx4_en_port_profile));
+	new_prof.num_up = (tc == 0) ? MLX4_EN_NUM_UP_LOW :
+				      MLX4_EN_NUM_UP_HIGH;
+	new_prof.tx_ring_num[TX] = new_prof.num_tx_rings_p_up *
+				   new_prof.num_up;
+	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof, true);
+	if (err)
+		goto out;
+
+	if (priv->port_up) {
+		port_up = 1;
+		mlx4_en_stop_port(dev, 1);
+	}
+
+	mlx4_en_safe_replace_resources(priv, tmp);
+	if (port_up) {
+		err = mlx4_en_start_port(dev);
+		if (err) {
+			en_err(priv, "Failed starting port for setup TC\n");
+			goto out;
+		}
+	}
+
+	err = mlx4_en_setup_tc(dev, tc);
+out:
+	mutex_unlock(&mdev->state_lock);
+	kfree(tmp);
+	return err;
+}
+
 static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle,
 			      u32 chain_index, __be16 proto,
 			      struct tc_to_netdev *tc)
@@ -93,9 +137,12 @@ static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle,
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
+	if (tc->mqprio->num_tc && tc->mqprio->num_tc != MLX4_EN_NUM_UP_HIGH)
+		return -EINVAL;
+
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
-	return mlx4_en_setup_tc(dev, tc->mqprio->num_tc);
+	return mlx4_en_alloc_tx_queue_per_tc(dev, tc->mqprio->num_tc);
 }
 
 #ifdef CONFIG_RFS_ACCEL
@@ -2144,7 +2191,7 @@ static int mlx4_en_copy_priv(struct mlx4_en_priv *dst,
 
 	memcpy(&dst->hwtstamp_config, &prof->hwtstamp_config,
 	       sizeof(dst->hwtstamp_config));
-	dst->num_tx_rings_p_up = src->mdev->profile.num_tx_rings_p_up;
+	dst->num_tx_rings_p_up = prof->num_tx_rings_p_up;
 	dst->rx_ring_num = prof->rx_ring_num;
 	dst->flags = prof->flags;
 	dst->mdev = src->mdev;
@@ -2197,6 +2244,7 @@ static void mlx4_en_update_priv(struct mlx4_en_priv *dst,
 		dst->tx_ring[t] = src->tx_ring[t];
 		dst->tx_cq[t] = src->tx_cq[t];
 	}
+	dst->num_tx_rings_p_up = src->num_tx_rings_p_up;
 	dst->rx_ring_num = src->rx_ring_num;
 	memcpy(dst->prof, src->prof, sizeof(struct mlx4_en_port_profile));
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index a6b0db0e0383..86d2d42d658d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -63,7 +63,8 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	context->local_qpn = cpu_to_be32(qpn);
 	context->pri_path.ackto = 1 & 0x07;
 	context->pri_path.sched_queue = 0x83 | (priv->port - 1) << 6;
-	if (user_prio >= 0) {
+	/* force user priority per tx ring */
+	if (user_prio >= 0 && priv->prof->num_up == MLX4_EN_NUM_UP_HIGH) {
 		context->pri_path.sched_queue |= user_prio << 3;
 		context->pri_path.feup = MLX4_FEUP_FORCE_ETH_UP;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 7d69d939ee2d..4f3a9b27ce4a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -691,15 +691,11 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	u16 rings_p_up = priv->num_tx_rings_p_up;
-	u8 up = 0;
 
 	if (netdev_get_num_tc(dev))
 		return skb_tx_hash(dev, skb);
 
-	if (skb_vlan_tag_present(skb))
-		up = skb_vlan_tag_get(skb) >> VLAN_PRIO_SHIFT;
-
-	return fallback(dev, skb) % rings_p_up + up * rings_p_up;
+	return fallback(dev, skb) % rings_p_up;
 }
 
 static void mlx4_bf_copy(void __iomem *dst, const void *src,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 89885281d489..d350b2158104 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -115,6 +115,7 @@
 #define MLX4_EN_SMALL_PKT_SIZE		64
 #define MLX4_EN_MIN_TX_RING_P_UP	1
 #define MLX4_EN_MAX_TX_RING_P_UP	32
+#define MLX4_EN_NUM_UP_LOW		1
 #define MLX4_EN_NUM_UP_HIGH		8
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
 #define MLX4_EN_DEF_TX_RING_SIZE	MLX4_EN_DEF_RX_RING_SIZE
@@ -762,6 +763,7 @@ int mlx4_en_change_mcast_lb(struct mlx4_en_priv *priv, struct mlx4_qp *qp,
 #endif
 
 int mlx4_en_setup_tc(struct net_device *dev, u8 up);
+int mlx4_en_alloc_tx_queue_per_tc(struct net_device *dev, u8 tc);
 
 #ifdef CONFIG_RFS_ACCEL
 void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv);
-- 
1.8.3.1
