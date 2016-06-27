From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 06/16] net/mlx5: E-Switch, Add offloads table
Date: Mon, 27 Jun 2016 19:07:19 +0300
Message-ID: <1467043649-28594-7-git-send-email-saeedm@mellanox.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36583 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752056AbcF0QKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 12:10:24 -0400
In-Reply-To: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Belongs to the NIC offloads name-space, and to be used as part of the
SRIOV offloads logic to steer packets that hit the e-switch miss rule
to the TIR of the relevant VF representor.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  5 ++++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 31 ++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index b7fabd1..32db37a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -155,6 +155,10 @@ enum {
 	SRIOV_OFFLOADS
 };
 
+struct mlx5_esw_offload {
+	struct mlx5_flow_table *ft_offloads;
+};
+
 struct mlx5_eswitch {
 	struct mlx5_core_dev    *dev;
 	struct mlx5_l2_table    l2_table;
@@ -169,6 +173,7 @@ struct mlx5_eswitch {
 	 */
 	struct mutex            state_lock;
 	struct esw_mc_addr      *mc_promisc;
+	struct mlx5_esw_offload offloads;
 	int                     mode;
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index a8be43d..3ca926b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -214,3 +214,34 @@ void esw_destroy_offloads_fdb_table(struct mlx5_eswitch *esw)
 
 	mlx5_destroy_flow_table(esw->fdb_table.fdb);
 }
+
+static int esw_create_offloads_table(struct mlx5_eswitch *esw)
+{
+	struct mlx5_flow_namespace *ns;
+	struct mlx5_flow_table *ft_offloads;
+	struct mlx5_core_dev *dev = esw->dev;
+	int err = 0;
+
+	ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_OFFLOADS);
+	if (!ns) {
+		esw_warn(esw->dev, "Failed to get offloads flow namespace\n");
+		return -ENOMEM;
+	}
+
+	ft_offloads = mlx5_create_flow_table(ns, 0, dev->priv.sriov.num_vfs + 2, 0);
+	if (IS_ERR(ft_offloads)) {
+		err = PTR_ERR(ft_offloads);
+		esw_warn(esw->dev, "Failed to create offloads table, err %d\n", err);
+		return err;
+	}
+
+	esw->offloads.ft_offloads = ft_offloads;
+	return 0;
+}
+
+static void esw_destroy_offloads_table(struct mlx5_eswitch *esw)
+{
+	struct mlx5_esw_offload *offloads = &esw->offloads;
+
+	mlx5_destroy_flow_table(offloads->ft_offloads);
+}
-- 
2.8.0
