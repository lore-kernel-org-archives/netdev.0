From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 08/12] net/mlx5: E-Switch, Enable/disable ACL tables on demand
Date: Mon,  2 May 2016 19:43:40 +0300
Message-ID: <1462207424-4463-9-git-send-email-saeedm@mellanox.com>
References: <1462207424-4463-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:40206 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754512AbcEBQov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2016 12:44:51 -0400
In-Reply-To: <1462207424-4463-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Enable ingress/egress ACL tables only when we need to configure ACL
rules.
Disable ingress/egress ACL tables once all ACL rules are removed.

All VF outgoing/incoming traffic need to go through the ingress/egress ACL
tables.
Adding/Removing these tables on demand will save unnecessary hops in the
flow steering when the ACL tables are empty.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 33 ++++++++++-------------
 1 file changed, 14 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 17d093c..48c8919 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -728,7 +728,8 @@ static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 	int table_size = 2;
 	int err = 0;
 
-	if (!MLX5_CAP_ESW_EGRESS_ACL(dev, ft_support))
+	if (!MLX5_CAP_ESW_EGRESS_ACL(dev, ft_support) ||
+	    !IS_ERR_OR_NULL(vport->egress.acl))
 		return;
 
 	esw_debug(dev, "Create vport[%d] egress ACL log_max_size(%d)\n",
@@ -841,7 +842,8 @@ static void esw_vport_enable_ingress_acl(struct mlx5_eswitch *esw,
 	int table_size = 4;
 	int err = 0;
 
-	if (!MLX5_CAP_ESW_INGRESS_ACL(dev, ft_support))
+	if (!MLX5_CAP_ESW_INGRESS_ACL(dev, ft_support) ||
+	    !IS_ERR_OR_NULL(vport->ingress.acl))
 		return;
 
 	esw_debug(dev, "Create vport[%d] ingress ACL log_max_size(%d)\n",
@@ -989,13 +991,6 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 	int err = 0;
 	u8 *smac_v;
 
-	if (IS_ERR_OR_NULL(vport->ingress.acl)) {
-		esw_warn(esw->dev,
-			 "vport[%d] configure ingress rules failed, ingress acl is not initialized!\n",
-			 vport->vport);
-		return -EPERM;
-	}
-
 	if (vport->spoofchk) {
 		err = mlx5_query_nic_vport_mac_address(esw->dev, vport->vport, smac);
 		if (err) {
@@ -1015,8 +1010,12 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 
 	esw_vport_cleanup_ingress_rules(esw, vport);
 
-	if (!vport->vlan && !vport->qos && !vport->spoofchk)
+	if (!vport->vlan && !vport->qos && !vport->spoofchk) {
+		esw_vport_disable_ingress_acl(esw, vport);
 		return 0;
+	}
+
+	esw_vport_enable_ingress_acl(esw, vport);
 
 	esw_debug(esw->dev,
 		  "vport[%d] configure ingress rules, vlan(%d) qos(%d)\n",
@@ -1091,16 +1090,14 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 	u32 *match_c;
 	int err = 0;
 
-	if (IS_ERR_OR_NULL(vport->egress.acl)) {
-		esw_warn(esw->dev, "vport[%d] configure rgress rules failed, egress acl is not initialized!\n",
-			 vport->vport);
-		return -EPERM;
-	}
-
 	esw_vport_cleanup_egress_rules(esw, vport);
 
-	if (!vport->vlan && !vport->qos)
+	if (!vport->vlan && !vport->qos) {
+		esw_vport_disable_egress_acl(esw, vport);
 		return 0;
+	}
+
+	esw_vport_enable_egress_acl(esw, vport);
 
 	esw_debug(esw->dev,
 		  "vport[%d] configure egress rules, vlan(%d) qos(%d)\n",
@@ -1169,8 +1166,6 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 	esw_debug(esw->dev, "Enabling VPORT(%d)\n", vport_num);
 
 	if (vport_num) { /* Only VFs need ACLs for VST and spoofchk filtering */
-		esw_vport_enable_ingress_acl(esw, vport);
-		esw_vport_enable_egress_acl(esw, vport);
 		esw_vport_ingress_config(esw, vport);
 		esw_vport_egress_config(esw, vport);
 	}
-- 
2.8.0
