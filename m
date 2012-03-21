From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V1 5/6] net/mlx4_en: sk_prio <=> UP for untagged traffic
Date: Wed, 21 Mar 2012 11:25:02 +0200
Message-ID: <1332321903-11704-6-git-send-email-amirv@mellanox.com>
References: <1332321903-11704-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:45532 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756851Ab2CUJZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 05:25:37 -0400
In-Reply-To: <1332321903-11704-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Since vlan egress map is only good for tagged traffic, need to have other
mapping to be used by untagged traffic.
For that, the driver uses sch_mqprio mapping. This mapping could be set by
using tc tool from iproute2 package.
Mapped UP will be used by the HW for QoS purposes, but won't go out on the
wire.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   15 +++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   16 ++++++++--------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f45d544..22c4da6 100644
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
@@ -1055,6 +1063,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_poll_controller	= mlx4_en_netpoll,
 #endif
 	.ndo_set_features	= mlx4_en_set_features,
+	.ndo_setup_tc		= mlx4_en_setup_tc,
 };
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
@@ -1143,6 +1152,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
+	netdev_set_num_tc(dev, MLX4_EN_NUM_UP);
+
+	/* Partition Tx queues evenly amongst UP's */
+	for (i = 0; i < MLX4_EN_NUM_UP; i++)
+		netdev_set_tc_queue(dev, i, 1, MLX4_EN_NUM_TX_RINGS + i);
+
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
 	/* Set defualt MAC */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 445a771..f228728 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -570,15 +570,15 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	u16 vlan_tag = 0;
+	int up = -1;
 
-	/* If we support per priority flow control and the packet contains
-	 * a vlan tag, send the packet to the TX ring assigned to that priority
-	 */
-	if (vlan_tx_tag_present(skb)) {
-		vlan_tag = vlan_tx_tag_get(skb);
-		return MLX4_EN_NUM_TX_RINGS + (vlan_tag >> 13);
-	}
+	if (vlan_tx_tag_present(skb))
+		up = (vlan_tx_tag_get(skb) >> 13);
+	else if (dev->num_tc)
+		up = netdev_get_prio_tc_map(dev, skb->priority);
+
+	if (up >= 0)
+		return MLX4_EN_NUM_TX_RINGS + up;
 
 	return __skb_tx_hash(dev, skb, MLX4_EN_NUM_TX_RINGS);
 }
-- 
1.7.8.2
