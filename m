From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/4] mlx5: Make building tc hardware offload configurable
Date: Thu, 26 Jan 2017 15:32:40 -0800
Message-ID: <20170126233241.2268449-4-tom@herbertland.com>
References: <20170126233241.2268449-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <saeedm@mellanox.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33991 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752970AbdAZXve (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 18:51:34 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v0QNIsRD003574
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 15:32:53 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 287mtts7by-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 15:32:53 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 c1468644e41f11e6a06a24be05956610-dff3a50 for <netdev@vger.kernel.org>; Thu,
 26 Jan 2017 15:32:52 -0800
In-Reply-To: <20170126233241.2268449-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a configuration option (CONFIG_MLX5_CORE_EN_TC) for controlling
whether the eswitch code is built. Change Kconfig and Makefile
accordingly.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  8 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  4 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 10 ++++++++++
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 7ade61a..b38c920 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -49,3 +49,11 @@ config MLX5_CORE_EN_SRIOV
 	  Say Y here if you want to use SR-IOV.
 
 	  If unsure, set to Y
+
+config MLX5_CORE_EN_TC
+	bool "TC offload"
+	default y
+	---help---
+	  Say Y here if you want to use TC hardware offload support.
+
+	  If unsure, set to Y
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 6d38250..c308531 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -8,10 +8,12 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
 		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
-		en_tc.o en_arfs.o en_fs_ethtool.o en_selftest.o
+		en_arfs.o en_fs_ethtool.o en_selftest.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_ESWITCH) += eswitch.o eswitch_offloads.o en_rep.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_SRIOV) += sriov.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_EN_TC) += en_tc.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1db4d98..2d2c982 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2690,6 +2690,7 @@ int mlx5e_modify_rqs_vsd(struct mlx5e_priv *priv, bool vsd)
 	return 0;
 }
 
+#ifdef CONFIG_MLX5_CORE_EN_TC
 static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
@@ -2743,6 +2744,7 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 
 	return mlx5e_setup_tc(dev, tc->tc);
 }
+#endif
 
 static void
 mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
@@ -3323,7 +3325,9 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
 	.ndo_start_xmit          = mlx5e_xmit,
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	.ndo_setup_tc            = mlx5e_ndo_setup_tc,
+#endif
 	.ndo_select_queue        = mlx5e_select_queue,
 	.ndo_get_stats64         = mlx5e_get_stats,
 	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
@@ -3349,7 +3353,9 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
 	.ndo_start_xmit          = mlx5e_xmit,
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	.ndo_setup_tc            = mlx5e_ndo_setup_tc,
+#endif
 	.ndo_select_queue        = mlx5e_select_queue,
 	.ndo_get_stats64         = mlx5e_get_stats,
 	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
@@ -3762,9 +3768,11 @@ static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
 		goto err_destroy_direct_tirs;
 	}
 
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	err = mlx5e_tc_init(priv);
 	if (err)
 		goto err_destroy_flow_steering;
+#endif
 
 	return 0;
 
@@ -3786,7 +3794,9 @@ static void mlx5e_cleanup_nic_rx(struct mlx5e_priv *priv)
 {
 	int i;
 
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	mlx5e_tc_cleanup(priv);
+#endif
 	mlx5e_destroy_flow_steering(priv);
 	mlx5e_destroy_direct_tirs(priv);
 	mlx5e_destroy_indirect_tirs(priv);
-- 
2.9.3
