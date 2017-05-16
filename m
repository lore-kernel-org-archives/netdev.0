From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/12] mlxsw: spectrum_switchdev: Don't batch STP operations
Date: Tue, 16 May 2017 19:38:32 +0200
Message-ID: <20170516173835.2978-10-jiri@resnulli.us>
References: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35484 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752790AbdEPRiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:38:51 -0400
Received: by mail-wm0-f65.google.com with SMTP id v4so39871249wmb.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:38:51 -0700 (PDT)
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Simplify the code by using the common function that sets an STP state
for a Port-VLAN and remove the existing one that tries to batch it for
several VLANs.

This will help us in a follow-up patchset to introduce a unified
infrastructure for bridge ports, regardless if the bridge is VLAN-aware
or not.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 59 +++++++---------------
 1 file changed, 17 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 8a31bf90..ad5eefa 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -146,58 +146,33 @@ static int mlxsw_sp_port_attr_get(struct net_device *dev,
 	return 0;
 }
 
-static int mlxsw_sp_port_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				       u8 state)
+static int mlxsw_sp_port_attr_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					    struct switchdev_trans *trans,
+					    u8 state)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	enum mlxsw_reg_spms_state spms_state;
-	char *spms_pl;
 	u16 vid;
 	int err;
 
-	switch (state) {
-	case BR_STATE_FORWARDING:
-		spms_state = MLXSW_REG_SPMS_STATE_FORWARDING;
-		break;
-	case BR_STATE_LEARNING:
-		spms_state = MLXSW_REG_SPMS_STATE_LEARNING;
-		break;
-	case BR_STATE_LISTENING: /* fall-through */
-	case BR_STATE_DISABLED: /* fall-through */
-	case BR_STATE_BLOCKING:
-		spms_state = MLXSW_REG_SPMS_STATE_DISCARDING;
-		break;
-	default:
-		BUG();
-	}
-
-	spms_pl = kmalloc(MLXSW_REG_SPMS_LEN, GFP_KERNEL);
-	if (!spms_pl)
-		return -ENOMEM;
-	mlxsw_reg_spms_pack(spms_pl, mlxsw_sp_port->local_port);
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
 
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
 		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
-		mlxsw_reg_spms_vid_pack(spms_pl, vid, spms_state);
-	} else {
-		for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID)
-			mlxsw_reg_spms_vid_pack(spms_pl, vid, spms_state);
-	}
-
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(spms), spms_pl);
-	kfree(spms_pl);
-	return err;
-}
-
-static int mlxsw_sp_port_attr_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
-					    struct switchdev_trans *trans,
-					    u8 state)
-{
-	if (switchdev_trans_ph_prepare(trans))
+		err = mlxsw_sp_port_vid_stp_set(mlxsw_sp_port, vid, state);
+		if (err)
+			return err;
+		mlxsw_sp_port->stp_state = state;
 		return 0;
+	}
 
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID) {
+		err = mlxsw_sp_port_vid_stp_set(mlxsw_sp_port, vid, state);
+		if (err)
+			return err;
+	}
 	mlxsw_sp_port->stp_state = state;
-	return mlxsw_sp_port_stp_state_set(mlxsw_sp_port, state);
+
+	return 0;
 }
 
 static int __mlxsw_sp_port_flood_table_set(struct mlxsw_sp_port *mlxsw_sp_port,
-- 
2.9.3
