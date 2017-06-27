From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 03/16] net/mlx5: Add support for multiple RoCE enable
Date: Tue, 27 Jun 2017 17:28:43 +0300
Message-ID: <20170627142856.9448-4-saeedm@mellanox.com>
References: <20170627142856.9448-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50374 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752396AbdF0OaH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 10:30:07 -0400
In-Reply-To: <20170627142856.9448-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Previously, only mlx5_ib enabled RoCE on the port, but FPGA needs it as
well.
Add support for counting number of enables, so that FPGA and IB can work
in parallel and independently.
Program the HW to enable RoCE on the first enable call, and program to
disable RoCE on the last disable call.

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Reviewed-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/vport.c | 4 ++++
 include/linux/mlx5/driver.h                     | 1 +
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 06019d00ab7b..5abfec1c3399 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -926,12 +926,16 @@ static int mlx5_nic_vport_update_roce_state(struct mlx5_core_dev *mdev,
 
 int mlx5_nic_vport_enable_roce(struct mlx5_core_dev *mdev)
 {
+	if (atomic_inc_return(&mdev->roce.roce_en) != 1)
+		return 0;
 	return mlx5_nic_vport_update_roce_state(mdev, MLX5_VPORT_ROCE_ENABLED);
 }
 EXPORT_SYMBOL_GPL(mlx5_nic_vport_enable_roce);
 
 int mlx5_nic_vport_disable_roce(struct mlx5_core_dev *mdev)
 {
+	if (atomic_dec_return(&mdev->roce.roce_en) != 0)
+		return 0;
 	return mlx5_nic_vport_update_roce_state(mdev, MLX5_VPORT_ROCE_DISABLED);
 }
 EXPORT_SYMBOL_GPL(mlx5_nic_vport_disable_roce);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 08e99bd2cd77..32b0835d4491 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -777,6 +777,7 @@ struct mlx5_core_dev {
 	struct mlx5e_resources  mlx5e_res;
 	struct {
 		struct mlx5_rsvd_gids	reserved_gids;
+		atomic_t                roce_en;
 	} roce;
 #ifdef CONFIG_MLX5_FPGA
 	struct mlx5_fpga_device *fpga;
-- 
2.11.0
