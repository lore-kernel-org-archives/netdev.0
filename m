From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V5 4/8] net/mlx4_en: sk_prio <=> UP for untagged traffic
Date: Tue,  3 Apr 2012 14:10:03 +0300
Message-ID: <1333451407-5293-5-git-send-email-amirv@mellanox.com>
References: <1333451407-5293-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:45601 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752029Ab2DCLKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 07:10:24 -0400
In-Reply-To: <1333451407-5293-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since vlan egress map is only good for tagged traffic, need to have other
mapping to be used by untagged traffic.
For that, the driver uses sch_mqprio mapping. This mapping could be set by
using tc tool from iproute2 package.
Mapped UP will be used by the HW for QoS purposes, but won't go out on the
wire.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   18 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    2 +-
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 107f005..35003ad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -45,6 +45,14 @@
 #include "mlx4_en.h"
 #include "en_port.h"
 
+static int mlx4_en_setup_tc(struct net_device *dev, u8 up)
+{
+	if (up != MLX4_EN_NUM_UP)
+		return -EINVAL;
+
+	return 0;
+}
+
 static int mlx4_en_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -1038,6 +1046,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_poll_controller	= mlx4_en_netpoll,
 #endif
 	.ndo_set_features	= mlx4_en_set_features,
+	.ndo_setup_tc		= mlx4_en_setup_tc,
 };
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
@@ -1119,6 +1128,15 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
+	netdev_set_num_tc(dev, MLX4_EN_NUM_UP);
+
+	/* First 9 rings are for UP 0 */
+	netdev_set_tc_queue(dev, 0, MLX4_EN_NUM_TX_RINGS + 1, 0);
+
+	/* Partition Tx queues evenly amongst UP's 1-7 */
+	for (i = 1; i < MLX4_EN_NUM_UP; i++)
+		netdev_set_tc_queue(dev, i, 1, MLX4_EN_NUM_TX_RINGS + i);
+
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
 	/* Set defualt MAC */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 94a605a..d9bab53 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -577,7 +577,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 		return MLX4_EN_NUM_TX_RINGS + (vlan_tag >> 13);
 	}
 
-	return __skb_tx_hash(dev, skb, MLX4_EN_NUM_TX_RINGS);
+	return skb_tx_hash(dev, skb);
 }
 
 static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
-- 
1.7.8.2
