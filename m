From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 2/7] mlx5: eswitch vlan functionality is only called if SRIOV_OFFLOADS is set
Date: Fri, 26 May 2017 17:16:19 -0400
Message-ID: <20170526211624.23133-3-jsorensen@fb.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f193.google.com ([209.85.213.193]:35379 "EHLO
        mail-yb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948719AbdEZVQf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 17:16:35 -0400
Received: by mail-yb0-f193.google.com with SMTP id 130so684659ybl.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 14:16:35 -0700 (PDT)
In-Reply-To: <20170526211624.23133-1-jsorensen@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows not compiling this code if eswitch offloads are disabled.

Signed-off-by: Jes Sorensen <jsorensen@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h          | 13 +++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c |  2 ++
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index de4e5e8..2bf5299 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -338,10 +338,23 @@ void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
 				       int vport_index);
 struct net_device *mlx5_eswitch_get_uplink_netdev(struct mlx5_eswitch *esw);
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 int mlx5_eswitch_add_vlan_action(struct mlx5_eswitch *esw,
 				 struct mlx5_esw_flow_attr *attr);
 int mlx5_eswitch_del_vlan_action(struct mlx5_eswitch *esw,
 				 struct mlx5_esw_flow_attr *attr);
+#else
+static inline int mlx5_eswitch_add_vlan_action(struct mlx5_eswitch *esw,
+					       struct mlx5_esw_flow_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+static inline int mlx5_eswitch_del_vlan_action(struct mlx5_eswitch *esw,
+					       struct mlx5_esw_flow_attr *attr)
+{
+	return -EOPNOTSUPP;
+}
+#endif
 int __mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
 				  int vport, u16 vlan, u8 qos, u8 set_flags);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index e78dec1..8d0af1f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -122,6 +122,7 @@ mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
 	esw->offloads.num_flows--;
 }
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 static int esw_set_global_vlan_pop(struct mlx5_eswitch *esw, u8 val)
 {
 	struct mlx5_eswitch_rep *rep;
@@ -301,6 +302,7 @@ int mlx5_eswitch_del_vlan_action(struct mlx5_eswitch *esw,
 out:
 	return err;
 }
+#endif
 
 static struct mlx5_flow_handle *
 mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn)
-- 
2.9.4
