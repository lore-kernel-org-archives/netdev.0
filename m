From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 1/7] mlx5: Allow support for eswitch offloads to be disabled
Date: Fri, 26 May 2017 17:16:18 -0400
Message-ID: <20170526211624.23133-2-jsorensen@fb.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34793 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948720AbdEZVQf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 17:16:35 -0400
Received: by mail-yw0-f194.google.com with SMTP id 17so1356119ywk.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 14:16:35 -0700 (PDT)
In-Reply-To: <20170526211624.23133-1-jsorensen@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows users to disable eswitch offloads. Follow-on patches will
clean up how the eswitch_offloads code is being called and get rid of all
the #ifdefs.

Signed-off-by: Jes Sorensen <jsorensen@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig            | 10 ++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h          | 11 +++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c |  8 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c             |  2 +-
 4 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 27251a7..27b409e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -32,6 +32,16 @@ config MLX5_CORE_EN_DCB
 
 	  If unsure, set to Y
 
+config MLX5_CORE_EN_ESWITCH_OFFLOADS
+	bool "Enable support for Mellanox ESwitch Offload Support"
+	default y
+	depends on MLX5_CORE_EN
+	---help---
+	  Say Y here if you want to use Mellanox ESwitch offload support.
+	  If set to N, the driver will use the kernel's software implementation.
+
+	  If unsure, set to Y
+
 config MLX5_CORE_IPOIB
 	bool "Mellanox Technologies ConnectX-4 IPoIB offloads support"
 	depends on MLX5_CORE_EN
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index b746f62..de4e5e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -243,8 +243,19 @@ struct mlx5_eswitch {
 	int                     mode;
 };
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports);
 int esw_offloads_init(struct mlx5_eswitch *esw, int nvports);
+#else
+static inline void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
+{
+	return;
+}
+static inline int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
+{
+	return -EOPNOTSUPP;
+}
+#endif
 
 /* E-Switch API */
 int mlx5_eswitch_init(struct mlx5_core_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index f991f66..e78dec1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -393,6 +393,7 @@ int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 	return err;
 }
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 {
 	struct mlx5_flow_act flow_act = {0};
@@ -425,6 +426,7 @@ static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 	kvfree(spec);
 	return err;
 }
+#endif
 
 #define ESW_OFFLOADS_NUM_GROUPS  4
 
@@ -475,6 +477,7 @@ static void esw_destroy_offloads_fast_fdb_table(struct mlx5_eswitch *esw)
 
 #define MAX_PF_SQ 256
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 static int esw_create_offloads_fdb_tables(struct mlx5_eswitch *esw, int nvports)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
@@ -665,6 +668,7 @@ static void esw_destroy_vport_rx_group(struct mlx5_eswitch *esw)
 {
 	mlx5_destroy_flow_group(esw->offloads.vport_rx_group);
 }
+#endif
 
 struct mlx5_flow_handle *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
@@ -733,6 +737,7 @@ static int esw_offloads_start(struct mlx5_eswitch *esw)
 	return err;
 }
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 {
 	struct mlx5_eswitch_rep *rep;
@@ -791,6 +796,7 @@ int esw_offloads_init(struct mlx5_eswitch *esw, int nvports)
 
 	return err;
 }
+#endif
 
 static int esw_offloads_stop(struct mlx5_eswitch *esw)
 {
@@ -813,6 +819,7 @@ static int esw_offloads_stop(struct mlx5_eswitch *esw)
 	return err;
 }
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
 {
 	struct mlx5_eswitch_rep *rep;
@@ -829,6 +836,7 @@ void esw_offloads_cleanup(struct mlx5_eswitch *esw, int nvports)
 	esw_destroy_offloads_table(esw);
 	esw_destroy_offloads_fdb_tables(esw);
 }
+#endif
 
 static int esw_mode_from_devlink(u16 mode, u16 *mlx5_mode)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 0c123d5..3d8a41a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1275,7 +1275,7 @@ struct mlx5_core_event_handler {
 };
 
 static const struct devlink_ops mlx5_devlink_ops = {
-#ifdef CONFIG_MLX5_CORE_EN
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 	.eswitch_mode_set = mlx5_devlink_eswitch_mode_set,
 	.eswitch_mode_get = mlx5_devlink_eswitch_mode_get,
 	.eswitch_inline_mode_set = mlx5_devlink_eswitch_inline_mode_set,
-- 
2.9.4
