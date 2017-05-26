From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 3/7] mlx5: Disable {add,del}_offloaded_rule() code if eswitch offloads are disabled
Date: Fri, 26 May 2017 17:16:20 -0400
Message-ID: <20170526211624.23133-4-jsorensen@fb.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:33279 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948717AbdEZVQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 17:16:34 -0400
Received: by mail-yw0-f195.google.com with SMTP id y64so1358382ywe.0
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 14:16:34 -0700 (PDT)
In-Reply-To: <20170526211624.23133-1-jsorensen@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code will not be called if CONFIG_MLX5_EN_ESWITCH_OFFLOADS is disabled.

Signed-off-by: Jes Sorensen <jsorensen@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h       | 17 +++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/eswitch_offloads.c  |  2 +-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 2bf5299..c2b0c02 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -286,6 +286,7 @@ int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 struct mlx5_flow_spec;
 struct mlx5_esw_flow_attr;
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 struct mlx5_flow_handle *
 mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_spec *spec,
@@ -294,6 +295,22 @@ void
 mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_handle *rule,
 				struct mlx5_esw_flow_attr *attr);
+#else
+static inline struct mlx5_flow_handle *
+mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
+				struct mlx5_flow_spec *spec,
+				struct mlx5_esw_flow_attr *attr)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+static inline void
+mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
+				struct mlx5_flow_handle *rule,
+				struct mlx5_esw_flow_attr *attr)
+{
+	return;
+}
+#endif
 
 struct mlx5_flow_handle *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 8d0af1f..12505ba 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -43,6 +43,7 @@ enum {
 	FDB_SLOW_PATH
 };
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 struct mlx5_flow_handle *
 mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_spec *spec,
@@ -122,7 +123,6 @@ mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
 	esw->offloads.num_flows--;
 }
 
-#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 static int esw_set_global_vlan_pop(struct mlx5_eswitch *esw, u8 val)
 {
 	struct mlx5_eswitch_rep *rep;
-- 
2.9.4
