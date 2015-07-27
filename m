From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/4] net/mlx4_en: Add support for hardware accelerated 802.1ad vlan
Date: Mon, 27 Jul 2015 14:46:34 +0300
Message-ID: <1437997594-8506-5-git-send-email-amirv@mellanox.com>
References: <1437997594-8506-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56735 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751688AbbG0LrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 07:47:04 -0400
In-Reply-To: <1437997594-8506-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

To enable device support in accelerated 802.1ad vlan, the port
capability "packet has vlan enable" (phv_en) should be set.
Firmware won't work properly, in case phv_en is not set.

The user can enable "phv_en" port capability with the new ethtool
private flag phv-bit. The phv-bit private flag default value is OFF,
users who are interested in 802.1ad hardware acceleration should turn ON
the phv-bit private flag:
$ ethtool --set-priv-flags eth1 phv-bit on

Once the private flag is set, the device is ready for 802.1ad vlan
acceleration.

The user should also change the interface device features and turn on
"tx-vlan-stag-hw-insert" which is off by default:
$ ethtool -K eth1  tx-vlan-stag-hw-insert on

"phv-bit" private flag setting is available only for Physical
Functions(PF), the Virtual Function (VF) will be able to use the feature
by setting "tx-vlan-stag-hw-insert" ethtool device feature only if the
feature was enabled by the Hypervisor.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 16 +++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 46 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 16 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 13 ++++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  1 +
 include/linux/mlx4/cq.h                         |  1 +
 include/linux/mlx4/qp.h                         |  1 +
 7 files changed, 89 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 70f6553..f79d812 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -102,6 +102,7 @@ mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 
 static const char mlx4_en_priv_flags[][ETH_GSTRING_LEN] = {
 	"blueflame",
+	"phv-bit"
 };
 
 static const char main_strings[][ETH_GSTRING_LEN] = {
@@ -1797,9 +1798,13 @@ static int mlx4_en_get_ts_info(struct net_device *dev,
 static int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
 	bool bf_enabled_new = !!(flags & MLX4_EN_PRIV_FLAGS_BLUEFLAME);
 	bool bf_enabled_old = !!(priv->pflags & MLX4_EN_PRIV_FLAGS_BLUEFLAME);
+	bool phv_enabled_new = !!(flags & MLX4_EN_PRIV_FLAGS_PHV);
+	bool phv_enabled_old = !!(priv->pflags & MLX4_EN_PRIV_FLAGS_PHV);
 	int i;
+	int ret = 0;
 
 	if (bf_enabled_new != bf_enabled_old) {
 		if (bf_enabled_new) {
@@ -1825,6 +1830,17 @@ static int mlx4_en_set_priv_flags(struct net_device *dev, u32 flags)
 			bf_enabled_new ?  "Enabled" : "Disabled");
 	}
 
+	if (phv_enabled_new != phv_enabled_old) {
+		ret = set_phv_bit(mdev->dev, priv->port, (int)phv_enabled_new);
+		if (ret)
+			return ret;
+		else if (phv_enabled_new)
+			priv->pflags |= MLX4_EN_PRIV_FLAGS_PHV;
+		else
+			priv->pflags &= ~MLX4_EN_PRIV_FLAGS_PHV;
+		en_info(priv, "PHV bit %s\n",
+			phv_enabled_new ?  "Enabled" : "Disabled");
+	}
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e0de2fd..4726122 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2184,6 +2184,25 @@ static int mlx4_en_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	}
 }
 
+static netdev_features_t mlx4_en_fix_features(struct net_device *netdev,
+					      netdev_features_t features)
+{
+	struct mlx4_en_priv *en_priv = netdev_priv(netdev);
+	struct mlx4_en_dev *mdev = en_priv->mdev;
+
+	/* Since there is no support for separate RX C-TAG/S-TAG vlan accel
+	 * enable/disable make sure S-TAG flag is always in same state as
+	 * C-TAG.
+	 */
+	if (features & NETIF_F_HW_VLAN_CTAG_RX &&
+	    !(mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_SKIP_OUTER_VLAN))
+		features |= NETIF_F_HW_VLAN_STAG_RX;
+	else
+		features &= ~NETIF_F_HW_VLAN_STAG_RX;
+
+	return features;
+}
+
 static int mlx4_en_set_features(struct net_device *netdev,
 		netdev_features_t features)
 {
@@ -2218,6 +2237,10 @@ static int mlx4_en_set_features(struct net_device *netdev,
 		en_info(priv, "Turn %s TX vlan strip offload\n",
 			(features & NETIF_F_HW_VLAN_CTAG_TX) ? "ON" : "OFF");
 
+	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_HW_VLAN_STAG_TX))
+		en_info(priv, "Turn %s TX S-VLAN strip offload\n",
+			(features & NETIF_F_HW_VLAN_STAG_TX) ? "ON" : "OFF");
+
 	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_LOOPBACK)) {
 		en_info(priv, "Turn %s loopback\n",
 			(features & NETIF_F_LOOPBACK) ? "ON" : "OFF");
@@ -2460,6 +2483,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_poll_controller	= mlx4_en_netpoll,
 #endif
 	.ndo_set_features	= mlx4_en_set_features,
+	.ndo_fix_features	= mlx4_en_fix_features,
 	.ndo_setup_tc		= mlx4_en_setup_tc,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
@@ -2500,6 +2524,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_poll_controller	= mlx4_en_netpoll,
 #endif
 	.ndo_set_features	= mlx4_en_set_features,
+	.ndo_fix_features	= mlx4_en_fix_features,
 	.ndo_setup_tc		= mlx4_en_setup_tc,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
@@ -2931,6 +2956,27 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->hw_features |= NETIF_F_LOOPBACK |
 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 
+	if (!(mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_SKIP_OUTER_VLAN)) {
+		dev->features |= NETIF_F_HW_VLAN_STAG_RX |
+			NETIF_F_HW_VLAN_STAG_FILTER;
+		dev->hw_features |= NETIF_F_HW_VLAN_STAG_RX;
+	}
+
+	if (mlx4_is_slave(mdev->dev)) {
+		int phv;
+
+		err = get_phv_bit(mdev->dev, port, &phv);
+		if (!err && phv) {
+			dev->hw_features |= NETIF_F_HW_VLAN_STAG_TX;
+			priv->pflags |= MLX4_EN_PRIV_FLAGS_PHV;
+		}
+	} else {
+		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PHV_EN &&
+		    !(mdev->dev->caps.flags2 &
+		      MLX4_DEV_CAP_FLAG2_SKIP_OUTER_VLAN))
+			dev->hw_features |= NETIF_F_HW_VLAN_STAG_TX;
+	}
+
 	if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_FCS_KEEP)
 		dev->hw_features |= NETIF_F_RXFCS;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 10f6c2f..a67fbb9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -912,6 +912,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				u16 vid = be16_to_cpu(cqe->sl_vid);
 
 				__vlan_hwaccel_put_tag(gro_skb, htons(ETH_P_8021Q), vid);
+			} else if ((be32_to_cpu(cqe->vlan_my_qpn) &
+				  MLX4_CQE_SVLAN_PRESENT_MASK) &&
+				 (dev->features & NETIF_F_HW_VLAN_STAG_RX)) {
+				__vlan_hwaccel_put_tag(gro_skb,
+						       htons(ETH_P_8021AD),
+						       be16_to_cpu(cqe->sl_vid));
 			}
 
 			if (dev->features & NETIF_F_RXHASH)
@@ -973,6 +979,11 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		    MLX4_CQE_CVLAN_PRESENT_MASK) &&
 		    (dev->features & NETIF_F_HW_VLAN_CTAG_RX))
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), be16_to_cpu(cqe->sl_vid));
+		else if ((be32_to_cpu(cqe->vlan_my_qpn) &
+			  MLX4_CQE_SVLAN_PRESENT_MASK) &&
+			 (dev->features & NETIF_F_HW_VLAN_STAG_RX))
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021AD),
+					       be16_to_cpu(cqe->sl_vid));
 
 		if (ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL) {
 			timestamp = mlx4_en_get_cqe_ts(cqe);
@@ -1070,7 +1081,10 @@ static const int frag_sizes[] = {
 void mlx4_en_calc_rx_buf(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int eff_mtu = dev->mtu + ETH_HLEN + VLAN_HLEN;
+	/* VLAN_HLEN is added twice,to support skb vlan tagged with multiple
+	 * headers. (For example: ETH_P_8021Q and ETH_P_8021AD).
+	 */
+	int eff_mtu = dev->mtu + ETH_HLEN + (2 * VLAN_HLEN);
 	int buf_size = 0;
 	int i = 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 7c858f6..494e776 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -718,6 +718,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 index, bf_index;
 	__be32 op_own;
 	u16 vlan_tag = 0;
+	u16 vlan_proto = 0;
 	int i_frag;
 	int lso_header_size;
 	void *fragptr = NULL;
@@ -750,9 +751,10 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_drop;
 	}
 
-	if (skb_vlan_tag_present(skb))
+	if (skb_vlan_tag_present(skb)) {
 		vlan_tag = skb_vlan_tag_get(skb);
-
+		vlan_proto = be16_to_cpu(skb->vlan_proto);
+	}
 
 	netdev_txq_bql_enqueue_prefetchw(ring->tx_queue);
 
@@ -958,8 +960,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		ring->bf.offset ^= ring->bf.buf_size;
 	} else {
 		tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
-		tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_CVLAN *
-			!!skb_vlan_tag_present(skb);
+		if (vlan_proto == ETH_P_8021AD)
+			tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_SVLAN;
+		else if (vlan_proto == ETH_P_8021Q)
+			tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_CVLAN;
+
 		tx_desc->ctrl.fence_size = real_size;
 
 		/* Ensure new descriptor hits memory
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 666d166..defcf8c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -95,6 +95,7 @@
  */
 
 #define MLX4_EN_PRIV_FLAGS_BLUEFLAME 1
+#define MLX4_EN_PRIV_FLAGS_PHV	     2
 
 #define MLX4_EN_WATCHDOG_TIMEOUT	(15 * HZ)
 
diff --git a/include/linux/mlx4/cq.h b/include/linux/mlx4/cq.h
index 899a97b..09cebe5 100644
--- a/include/linux/mlx4/cq.h
+++ b/include/linux/mlx4/cq.h
@@ -89,6 +89,7 @@ struct mlx4_ts_cqe {
 enum {
 	MLX4_CQE_L2_TUNNEL_IPOK		= 1 << 31,
 	MLX4_CQE_CVLAN_PRESENT_MASK	= 1 << 29,
+	MLX4_CQE_SVLAN_PRESENT_MASK	= 1 << 30,
 	MLX4_CQE_L2_TUNNEL		= 1 << 27,
 	MLX4_CQE_L2_TUNNEL_CSUM		= 1 << 26,
 	MLX4_CQE_L2_TUNNEL_IPV4		= 1 << 25,
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 6c61900..de45a51 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -273,6 +273,7 @@ enum {
 	MLX4_WQE_CTRL_IP_CSUM		= 1 << 4,
 	MLX4_WQE_CTRL_TCP_UDP_CSUM	= 1 << 5,
 	MLX4_WQE_CTRL_INS_CVLAN		= 1 << 6,
+	MLX4_WQE_CTRL_INS_SVLAN		= 1 << 7,
 	MLX4_WQE_CTRL_STRONG_ORDER	= 1 << 7,
 	MLX4_WQE_CTRL_FORCE_LOOPBACK	= 1 << 0,
 };
-- 
2.4.3.413.ga5fe668
