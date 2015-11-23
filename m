From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 12/18] net/mlx5: E-Switch, Introduce FDB hardware capabilities
Date: Mon, 23 Nov 2015 13:11:45 +0200
Message-ID: <1448277111-16474-13-git-send-email-ogerlitz@mellanox.com>
References: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37331 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752860AbbKWLNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 06:13:55 -0500
In-Reply-To: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Define needed hardware structures and capabilities needed
for E-Switch FDB flow tables and read them on driver load.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fw.c | 13 +++++++++++++
 include/linux/mlx5/device.h                  | 15 +++++++++++++++
 include/linux/mlx5/mlx5_ifc.h                | 13 +++++++++++++
 3 files changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 9335e5a..bf6e3df 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -160,6 +160,19 @@ int mlx5_query_hca_caps(struct mlx5_core_dev *dev)
 		if (err)
 			return err;
 	}
+
+	if (MLX5_CAP_GEN(dev, vport_group_manager) &&
+	    MLX5_CAP_GEN(dev, eswitch_flow_table)) {
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ESWITCH_FLOW_TABLE,
+					 HCA_CAP_OPMOD_GET_CUR);
+		if (err)
+			return err;
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ESWITCH_FLOW_TABLE,
+					 HCA_CAP_OPMOD_GET_MAX);
+		if (err)
+			return err;
+	}
+
 	return 0;
 }
 
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 90a4cb6..bce9cae 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1138,6 +1138,7 @@ enum mlx5_cap_type {
 	MLX5_CAP_IPOIB_OFFLOADS,
 	MLX5_CAP_EOIB_OFFLOADS,
 	MLX5_CAP_FLOW_TABLE,
+	MLX5_CAP_ESWITCH_FLOW_TABLE,
 	/* NUM OF CAP Types */
 	MLX5_CAP_NUM
 };
@@ -1175,6 +1176,20 @@ enum mlx5_cap_type {
 #define MLX5_CAP_FLOWTABLE_MAX(mdev, cap) \
 	MLX5_GET(flow_table_nic_cap, mdev->hca_caps_max[MLX5_CAP_FLOW_TABLE], cap)
 
+#define MLX5_CAP_ESW_FLOWTABLE(mdev, cap) \
+	MLX5_GET(flow_table_eswitch_cap, \
+		 mdev->hca_caps_cur[MLX5_CAP_ESWITCH_FLOW_TABLE], cap)
+
+#define MLX5_CAP_ESW_FLOWTABLE_MAX(mdev, cap) \
+	MLX5_GET(flow_table_eswitch_cap, \
+		 mdev->hca_caps_max[MLX5_CAP_ESWITCH_FLOW_TABLE], cap)
+
+#define MLX5_CAP_ESW_FLOWTABLE_FDB(mdev, cap) \
+	MLX5_CAP_ESW_FLOWTABLE(mdev, flow_table_properties_nic_esw_fdb.cap)
+
+#define MLX5_CAP_ESW_FLOWTABLE_FDB_MAX(mdev, cap) \
+	MLX5_CAP_ESW_FLOWTABLE_MAX(mdev, flow_table_properties_nic_esw_fdb.cap)
+
 #define MLX5_CAP_ODP(mdev, cap)\
 	MLX5_GET(odp_cap, mdev->hca_caps_cur[MLX5_CAP_ODP], cap)
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 39487d0..ae7c08a 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -447,6 +447,18 @@ struct mlx5_ifc_flow_table_nic_cap_bits {
 	u8         reserved_3[0x7200];
 };
 
+struct mlx5_ifc_flow_table_eswitch_cap_bits {
+	u8     reserved_0[0x200];
+
+	struct mlx5_ifc_flow_table_prop_layout_bits flow_table_properties_nic_esw_fdb;
+
+	struct mlx5_ifc_flow_table_prop_layout_bits flow_table_properties_esw_acl_ingress;
+
+	struct mlx5_ifc_flow_table_prop_layout_bits flow_table_properties_esw_acl_egress;
+
+	u8      reserved_1[0x7800];
+};
+
 struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
 	u8         csum_cap[0x1];
 	u8         vlan_cap[0x1];
@@ -1846,6 +1858,7 @@ union mlx5_ifc_hca_cap_union_bits {
 	struct mlx5_ifc_roce_cap_bits roce_cap;
 	struct mlx5_ifc_per_protocol_networking_offload_caps_bits per_protocol_networking_offload_caps;
 	struct mlx5_ifc_flow_table_nic_cap_bits flow_table_nic_cap;
+	struct mlx5_ifc_flow_table_eswitch_cap_bits flow_table_eswitch_cap;
 	u8         reserved_0[0x8000];
 };
 
-- 
2.3.7
