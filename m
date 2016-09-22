From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 4/9] net/mlx5: E-Switch, Allow fine tuning of eswitch vport push/pop vlan
Date: Thu, 22 Sep 2016 20:01:44 +0300
Message-ID: <1474563709-17943-5-git-send-email-saeedm@mellanox.com>
References: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirv@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49007 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964969AbcIVRCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:16 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The HW can be programmed to push vlan, pop vlan or both.

A factorization step towards using the push/pop capabilties in the
eswitch offloads mode. This patch doesn't add new functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 33 +++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  5 ++++
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 4927494..6605453 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -127,7 +127,7 @@ static int modify_esw_vport_context_cmd(struct mlx5_core_dev *dev, u16 vport,
 }
 
 static int modify_esw_vport_cvlan(struct mlx5_core_dev *dev, u32 vport,
-				  u16 vlan, u8 qos, bool set)
+				  u16 vlan, u8 qos, u8 set_flags)
 {
 	u32 in[MLX5_ST_SZ_DW(modify_esw_vport_context_in)] = {0};
 
@@ -135,14 +135,18 @@ static int modify_esw_vport_cvlan(struct mlx5_core_dev *dev, u32 vport,
 	    !MLX5_CAP_ESW(dev, vport_cvlan_insert_if_not_exist))
 		return -ENOTSUPP;
 
-	esw_debug(dev, "Set Vport[%d] VLAN %d qos %d set=%d\n",
-		  vport, vlan, qos, set);
-	if (set) {
+	esw_debug(dev, "Set Vport[%d] VLAN %d qos %d set=%x\n",
+		  vport, vlan, qos, set_flags);
+
+	if (set_flags & SET_VLAN_STRIP)
 		MLX5_SET(modify_esw_vport_context_in, in,
 			 esw_vport_context.vport_cvlan_strip, 1);
+
+	if (set_flags & SET_VLAN_INSERT) {
 		/* insert only if no vlan in packet */
 		MLX5_SET(modify_esw_vport_context_in, in,
 			 esw_vport_context.vport_cvlan_insert, 1);
+
 		MLX5_SET(modify_esw_vport_context_in, in,
 			 esw_vport_context.cvlan_pcp, qos);
 		MLX5_SET(modify_esw_vport_context_in, in,
@@ -1777,25 +1781,21 @@ int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 	return 0;
 }
 
-int mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
-				int vport, u16 vlan, u8 qos)
+int __mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
+				  int vport, u16 vlan, u8 qos, u8 set_flags)
 {
 	struct mlx5_vport *evport;
 	int err = 0;
-	int set = 0;
 
 	if (!ESW_ALLOWED(esw))
 		return -EPERM;
 	if (!LEGAL_VPORT(esw, vport) || (vlan > 4095) || (qos > 7))
 		return -EINVAL;
 
-	if (vlan || qos)
-		set = 1;
-
 	mutex_lock(&esw->state_lock);
 	evport = &esw->vports[vport];
 
-	err = modify_esw_vport_cvlan(esw->dev, vport, vlan, qos, set);
+	err = modify_esw_vport_cvlan(esw->dev, vport, vlan, qos, set_flags);
 	if (err)
 		goto unlock;
 
@@ -1813,6 +1813,17 @@ unlock:
 	return err;
 }
 
+int mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
+				int vport, u16 vlan, u8 qos)
+{
+	u8 set_flags = 0;
+
+	if (vlan || qos)
+		set_flags = SET_VLAN_STRIP | SET_VLAN_INSERT;
+
+	return __mlx5_eswitch_set_vport_vlan(esw, vport, vlan, qos, set_flags);
+}
+
 int mlx5_eswitch_set_vport_spoofchk(struct mlx5_eswitch *esw,
 				    int vport, bool spoofchk)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index ebfcde0..4f5391a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -246,6 +246,11 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 struct mlx5_flow_rule *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
 
+enum {
+	SET_VLAN_STRIP	= BIT(0),
+	SET_VLAN_INSERT	= BIT(1)
+};
+
 int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 				 struct mlx5_eswitch_rep *rep,
 				 u16 *sqns_array, int sqns_num);
-- 
2.7.4
