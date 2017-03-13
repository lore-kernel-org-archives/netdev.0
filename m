From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 14/25] net/mlx5: Enable flow-steering for IB link
Date: Mon, 13 Mar 2017 20:31:25 +0200
Message-ID: <1489429896-10781-15-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49770 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752991AbdCMScC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:02 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Get the relevant capabilities if supports ipoib_enhanced_offloads and
init the flow steering table accordingly.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 10 +++++-----
 drivers/net/ethernet/mellanox/mlx5/core/fw.c      |  3 ++-
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index fa4edd88daf1..dd21fc557281 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1991,9 +1991,6 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 	struct mlx5_flow_steering *steering;
 	int err = 0;
 
-	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
-		return 0;
-
 	err = mlx5_init_fc_stats(dev);
 	if (err)
 		return err;
@@ -2004,8 +2001,11 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 	steering->dev = dev;
 	dev->priv.steering = steering;
 
-	if (MLX5_CAP_GEN(dev, nic_flow_table) &&
-	    MLX5_CAP_FLOWTABLE_NIC_RX(dev, ft_support)) {
+	if ((((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_ETH) &&
+	      (MLX5_CAP_GEN(dev, nic_flow_table))) ||
+	     ((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_IB) &&
+	      MLX5_CAP_GEN(dev, ipoib_enhanced_offloads)))
+	    && MLX5_CAP_FLOWTABLE_NIC_RX(dev, ft_support)) {
 		err = init_root_ns(steering);
 		if (err)
 			goto err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 5718aada6605..f95bc78b02f2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -123,7 +123,8 @@ int mlx5_query_hca_caps(struct mlx5_core_dev *dev)
 			return err;
 	}
 
-	if (MLX5_CAP_GEN(dev, nic_flow_table)) {
+	if (MLX5_CAP_GEN(dev, nic_flow_table) ||
+	    MLX5_CAP_GEN(dev, ipoib_enhanced_offloads)) {
 		err = mlx5_core_get_caps(dev, MLX5_CAP_FLOW_TABLE);
 		if (err)
 			return err;
-- 
1.8.3.1
