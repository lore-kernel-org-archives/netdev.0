From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/4] mlx5: Make building SR-IOV configurable
Date: Thu, 26 Jan 2017 15:32:39 -0800
Message-ID: <20170126233241.2268449-3-tom@herbertland.com>
References: <20170126233241.2268449-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <saeedm@mellanox.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39155 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752379AbdAZX4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 18:56:06 -0500
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0QNIXri015864
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 15:32:51 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 287nbrh3c3-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 15:32:51 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 c0cbe402e41f11e6b26624be05956610-b7eea50 for <netdev@vger.kernel.org>; Thu,
 26 Jan 2017 15:32:51 -0800
In-Reply-To: <20170126233241.2268449-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a configuration option (CONFIG_MLX5_CORE_EN_SRIOV) for controlling
whether the eswitch code is built. Change Kconfig and Makefile
accordingly.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig  |  8 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile |  4 +++-
 drivers/net/ethernet/mellanox/mlx5/core/lag.c    |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c   | 16 ++++++++++++++++
 4 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 27aae58..7ade61a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -41,3 +41,11 @@ config MLX5_CORE_EN_ESWITCH
 	  inter-HCA ethernet l2 switching.
 
 	  If unsure, set to Y
+
+config MLX5_CORE_EN_SRIOV
+	bool "SR-IOV"
+	default y
+	---help---
+	  Say Y here if you want to use SR-IOV.
+
+	  If unsure, set to Y
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 17025d8..6d38250 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -2,7 +2,7 @@ obj-$(CONFIG_MLX5_CORE)		+= mlx5_core.o
 
 mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 		health.o mcg.o cq.o srq.o alloc.o qp.o port.o mr.o pd.o \
-		mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o \
+		mad.o transobj.o vport.o fs_cmd.o fs_core.o \
 		fs_counters.o rl.o lag.o dev.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o \
@@ -13,3 +13,5 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o \
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_ESWITCH) += eswitch.o eswitch_offloads.o en_rep.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_EN_SRIOV) += sriov.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
index 5595724..6dc3792 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
@@ -223,11 +223,13 @@ static void mlx5_do_bond(struct mlx5_lag *ldev)
 	mutex_unlock(&lag_mutex);
 
 	if (tracker.is_bonded && !mlx5_lag_is_bonded(ldev)) {
+#ifdef CONFIG_MLX5_CORE_EN_SRIOV
 		if (mlx5_sriov_is_enabled(dev0) ||
 		    mlx5_sriov_is_enabled(dev1)) {
 			mlx5_core_warn(dev0, "LAG is not supported with SRIOV");
 			return;
 		}
+#endif
 
 		for (i = 0; i < MLX5_MAX_PORTS; i++)
 			mlx5_remove_dev_by_protocol(ldev->pf[i].dev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 224f499..cd6a9c7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -949,15 +949,20 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	}
 #endif
 
+#ifdef CONFIG_MLX5_CORE_EN_SRIOV
 	err = mlx5_sriov_init(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to init sriov %d\n", err);
 		goto err_eswitch_cleanup;
 	}
+#endif
 
 	return 0;
 
+#ifdef CONFIG_MLX5_CORE_EN_SRIOV
 err_eswitch_cleanup:
+#endif
+
 #ifdef CONFIG_MLX5_CORE_EN_ESWITCH
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
 
@@ -980,7 +985,9 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 
 static void mlx5_cleanup_once(struct mlx5_core_dev *dev)
 {
+#ifdef CONFIG_MLX5_CORE_EN_SRIOV
 	mlx5_sriov_cleanup(dev);
+#endif
 #ifdef CONFIG_MLX5_CORE_EN_ESWITCH
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
 #endif
@@ -1135,11 +1142,13 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	mlx5_eswitch_attach(dev->priv.eswitch);
 #endif
 
+#ifdef CONFIG_MLX5_CORE_EN_SRIOV
 	err = mlx5_sriov_attach(dev);
 	if (err) {
 		dev_err(&pdev->dev, "sriov init failed %d\n", err);
 		goto err_sriov;
 	}
+#endif
 
 	if (mlx5_device_registered(dev)) {
 		mlx5_attach_device(dev);
@@ -1159,9 +1168,12 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	return 0;
 
 err_reg_dev:
+#ifdef CONFIG_MLX5_CORE_EN_SRIOV
 	mlx5_sriov_detach(dev);
 
 err_sriov:
+#endif
+
 #ifdef CONFIG_MLX5_CORE_EN_ESWITCH
 	mlx5_eswitch_detach(dev->priv.eswitch);
 #endif
@@ -1232,7 +1244,9 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	if (mlx5_device_registered(dev))
 		mlx5_detach_device(dev);
 
+#ifdef CONFIG_MLX5_CORE_EN_SRIOV
 	mlx5_sriov_detach(dev);
+#endif
 #ifdef CONFIG_MLX5_CORE_EN_ESWITCH
 	mlx5_eswitch_detach(dev->priv.eswitch);
 #endif
@@ -1533,7 +1547,9 @@ static struct pci_driver mlx5_core_driver = {
 	.remove         = remove_one,
 	.shutdown	= shutdown,
 	.err_handler	= &mlx5_err_handler,
+#ifdef CONFIG_MLX5_CORE_EN_SRIOV
 	.sriov_configure   = mlx5_core_sriov_configure,
+#endif
 };
 
 static void mlx5_core_verify_params(void)
-- 
2.9.3
