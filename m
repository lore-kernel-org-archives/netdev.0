From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH REPOST net 1/2] net/mlx4: Move the tunnel steering helper function to mlx4_core
Date: Wed, 27 Aug 2014 16:47:48 +0300
Message-ID: <1409147269-21472-2-git-send-email-ogerlitz@mellanox.com>
References: <1409147269-21472-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49038 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933661AbaH0Nr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 09:47:56 -0400
In-Reply-To: <1409147269-21472-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the function which we use to set VXLAN DMFS (flow-steering) rules
from mlx4_en to mlx4_core. This refactoring will allow the mlx4_ib driver
to call the helper for the use case of user-space RAW Ethernet QPs, such
that they can serve VXLAN traffic too.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   31 +------------------
 drivers/net/ethernet/mellanox/mlx4/mcg.c       |   38 ++++++++++++++++++++++++
 include/linux/mlx4/device.h                    |    3 ++
 3 files changed, 43 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index bb536aa..abddcf8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -474,39 +474,12 @@ static int mlx4_en_tunnel_steer_add(struct mlx4_en_priv *priv, unsigned char *ad
 				    int qpn, u64 *reg_id)
 {
 	int err;
-	struct mlx4_spec_list spec_eth_outer = { {NULL} };
-	struct mlx4_spec_list spec_vxlan     = { {NULL} };
-	struct mlx4_spec_list spec_eth_inner = { {NULL} };
-
-	struct mlx4_net_trans_rule rule = {
-		.queue_mode = MLX4_NET_TRANS_Q_FIFO,
-		.exclusive = 0,
-		.allow_loopback = 1,
-		.promisc_mode = MLX4_FS_REGULAR,
-		.priority = MLX4_DOMAIN_NIC,
-	};
-
-	__be64 mac_mask = cpu_to_be64(MLX4_MAC_MASK << 16);
 
 	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
 		return 0; /* do nothing */
 
-	rule.port = priv->port;
-	rule.qpn = qpn;
-	INIT_LIST_HEAD(&rule.list);
-
-	spec_eth_outer.id = MLX4_NET_TRANS_RULE_ID_ETH;
-	memcpy(spec_eth_outer.eth.dst_mac, addr, ETH_ALEN);
-	memcpy(spec_eth_outer.eth.dst_mac_msk, &mac_mask, ETH_ALEN);
-
-	spec_vxlan.id = MLX4_NET_TRANS_RULE_ID_VXLAN;    /* any vxlan header */
-	spec_eth_inner.id = MLX4_NET_TRANS_RULE_ID_ETH;	 /* any inner eth header */
-
-	list_add_tail(&spec_eth_outer.list, &rule.list);
-	list_add_tail(&spec_vxlan.list,     &rule.list);
-	list_add_tail(&spec_eth_inner.list, &rule.list);
-
-	err = mlx4_flow_attach(priv->mdev->dev, &rule, reg_id);
+	err = mlx4_tunnel_steer_add(priv->mdev->dev, addr, priv->port, qpn,
+				    MLX4_DOMAIN_NIC, reg_id);
 	if (err) {
 		en_err(priv, "failed to add vxlan steering rule, err %d\n", err);
 		return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index d80e7a6..ca0f98c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1020,6 +1020,44 @@ int mlx4_flow_detach(struct mlx4_dev *dev, u64 reg_id)
 }
 EXPORT_SYMBOL_GPL(mlx4_flow_detach);
 
+int mlx4_tunnel_steer_add(struct mlx4_dev *dev, unsigned char *addr,
+			  int port, int qpn, u16 prio, u64 *reg_id)
+{
+	int err;
+	struct mlx4_spec_list spec_eth_outer = { {NULL} };
+	struct mlx4_spec_list spec_vxlan     = { {NULL} };
+	struct mlx4_spec_list spec_eth_inner = { {NULL} };
+
+	struct mlx4_net_trans_rule rule = {
+		.queue_mode = MLX4_NET_TRANS_Q_FIFO,
+		.exclusive = 0,
+		.allow_loopback = 1,
+		.promisc_mode = MLX4_FS_REGULAR,
+	};
+
+	__be64 mac_mask = cpu_to_be64(MLX4_MAC_MASK << 16);
+
+	rule.port = port;
+	rule.qpn = qpn;
+	rule.priority = prio;
+	INIT_LIST_HEAD(&rule.list);
+
+	spec_eth_outer.id = MLX4_NET_TRANS_RULE_ID_ETH;
+	memcpy(spec_eth_outer.eth.dst_mac, addr, ETH_ALEN);
+	memcpy(spec_eth_outer.eth.dst_mac_msk, &mac_mask, ETH_ALEN);
+
+	spec_vxlan.id = MLX4_NET_TRANS_RULE_ID_VXLAN;    /* any vxlan header */
+	spec_eth_inner.id = MLX4_NET_TRANS_RULE_ID_ETH;	 /* any inner eth header */
+
+	list_add_tail(&spec_eth_outer.list, &rule.list);
+	list_add_tail(&spec_vxlan.list,     &rule.list);
+	list_add_tail(&spec_eth_inner.list, &rule.list);
+
+	err = mlx4_flow_attach(dev, &rule, reg_id);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_tunnel_steer_add);
+
 int mlx4_FLOW_STEERING_IB_UC_QP_RANGE(struct mlx4_dev *dev, u32 min_range_qpn,
 				      u32 max_range_qpn)
 {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 071f6b2..511c6e0 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1196,6 +1196,9 @@ int mlx4_map_sw_to_hw_steering_id(struct mlx4_dev *dev,
 				  enum mlx4_net_trans_rule_id id);
 int mlx4_hw_rule_sz(struct mlx4_dev *dev, enum mlx4_net_trans_rule_id id);
 
+int mlx4_tunnel_steer_add(struct mlx4_dev *dev, unsigned char *addr,
+			  int port, int qpn, u16 prio, u64 *reg_id);
+
 void mlx4_sync_pkey_table(struct mlx4_dev *dev, int slave, int port,
 			  int i, int val);
 
-- 
1.7.1
