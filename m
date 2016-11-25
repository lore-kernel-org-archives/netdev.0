From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/19] mlxsw: core: Change emad trap group settings
Date: Fri, 25 Nov 2016 10:33:40 +0100
Message-ID: <1480066427-3961-13-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36224 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752625AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wj0-f196.google.com with SMTP id jb2so4927052wjb.3
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:04 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Currently, the emad trap init was done in the core. In the future we will
want to add some changes to the traps groups, according to device type.
This commit create a driver function to create the trap group for the
emad, so later it can be changed by devices. It also changes the emad
registration to use the new generic functions.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 49 ++++++--------------------
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  9 +++++
 drivers/net/ethernet/mellanox/mlxsw/switchib.c | 10 ++++++
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  9 +++++
 5 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index d3b82d6..b21f88c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -572,28 +572,9 @@ static void mlxsw_emad_rx_listener_func(struct sk_buff *skb, u8 local_port,
 	dev_kfree_skb(skb);
 }
 
-static const struct mlxsw_rx_listener mlxsw_emad_rx_listener = {
-	.func = mlxsw_emad_rx_listener_func,
-	.local_port = MLXSW_PORT_DONT_CARE,
-	.trap_id = MLXSW_TRAP_ID_ETHEMAD,
-};
-
-static int mlxsw_emad_traps_set(struct mlxsw_core *mlxsw_core)
-{
-	char htgt_pl[MLXSW_REG_HTGT_LEN];
-	char hpkt_pl[MLXSW_REG_HPKT_LEN];
-	int err;
-
-	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD);
-	err = mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
-	if (err)
-		return err;
-
-	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,
-			    MLXSW_TRAP_ID_ETHEMAD,
-			    MLXSW_REG_HTGT_TRAP_GROUP_EMAD, false);
-	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
-}
+static const struct mlxsw_listener mlxsw_emad_rx_listener =
+	MLXSW_RXL(mlxsw_emad_rx_listener_func, ETHEMAD, TRAP_TO_CPU, false,
+		  EMAD, DISCARD);
 
 static int mlxsw_emad_init(struct mlxsw_core *mlxsw_core)
 {
@@ -614,43 +595,33 @@ static int mlxsw_emad_init(struct mlxsw_core *mlxsw_core)
 	INIT_LIST_HEAD(&mlxsw_core->emad.trans_list);
 	spin_lock_init(&mlxsw_core->emad.trans_list_lock);
 
-	err = mlxsw_core_rx_listener_register(mlxsw_core,
-					      &mlxsw_emad_rx_listener,
-					      mlxsw_core);
+	err = mlxsw_core_trap_register(mlxsw_core, &mlxsw_emad_rx_listener,
+				       mlxsw_core);
 	if (err)
 		return err;
 
-	err = mlxsw_emad_traps_set(mlxsw_core);
+	err = mlxsw_core->driver->basic_trap_groups_set(mlxsw_core);
 	if (err)
 		goto err_emad_trap_set;
-
 	mlxsw_core->emad.use_emad = true;
 
 	return 0;
 
 err_emad_trap_set:
-	mlxsw_core_rx_listener_unregister(mlxsw_core,
-					  &mlxsw_emad_rx_listener,
-					  mlxsw_core);
+	mlxsw_core_trap_unregister(mlxsw_core, &mlxsw_emad_rx_listener,
+				   mlxsw_core);
 	return err;
 }
 
 static void mlxsw_emad_fini(struct mlxsw_core *mlxsw_core)
 {
-	char hpkt_pl[MLXSW_REG_HPKT_LEN];
 
 	if (!(mlxsw_core->bus->features & MLXSW_BUS_F_TXRX))
 		return;
 
 	mlxsw_core->emad.use_emad = false;
-	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_DISCARD,
-			    MLXSW_TRAP_ID_ETHEMAD,
-			    MLXSW_REG_HTGT_TRAP_GROUP_EMAD, false);
-	mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
-
-	mlxsw_core_rx_listener_unregister(mlxsw_core,
-					  &mlxsw_emad_rx_listener,
-					  mlxsw_core);
+	mlxsw_core_trap_unregister(mlxsw_core, &mlxsw_emad_rx_listener,
+				   mlxsw_core);
 }
 
 static struct sk_buff *mlxsw_emad_alloc(const struct mlxsw_core *mlxsw_core,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index d663b8e..e856b49 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -265,6 +265,7 @@ struct mlxsw_driver {
 	int (*init)(struct mlxsw_core *mlxsw_core,
 		    const struct mlxsw_bus_info *mlxsw_bus_info);
 	void (*fini)(struct mlxsw_core *mlxsw_core);
+	int (*basic_trap_groups_set)(struct mlxsw_core *mlxsw_core);
 	int (*port_type_set)(struct mlxsw_core *mlxsw_core, u8 local_port,
 			     enum devlink_port_type new_type);
 	int (*port_split)(struct mlxsw_core *mlxsw_core, u8 local_port,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 44243a4..79c0a01 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2890,6 +2890,14 @@ static void mlxsw_sp_lag_fini(struct mlxsw_sp *mlxsw_sp)
 	kfree(mlxsw_sp->lags);
 }
 
+static int mlxsw_sp_basic_trap_groups_set(struct mlxsw_core *mlxsw_core)
+{
+	char htgt_pl[MLXSW_REG_HTGT_LEN];
+
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD);
+	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
+}
+
 static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 			 const struct mlxsw_bus_info *mlxsw_bus_info)
 {
@@ -3026,6 +3034,7 @@ static struct mlxsw_driver mlxsw_sp_driver = {
 	.priv_size			= sizeof(struct mlxsw_sp),
 	.init				= mlxsw_sp_init,
 	.fini				= mlxsw_sp_fini,
+	.basic_trap_groups_set		= mlxsw_sp_basic_trap_groups_set,
 	.port_split			= mlxsw_sp_port_split,
 	.port_unsplit			= mlxsw_sp_port_unsplit,
 	.sb_pool_get			= mlxsw_sp_sb_pool_get,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchib.c b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
index b798711..9a5f829 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchib.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
@@ -447,6 +447,14 @@ static void mlxsw_sib_traps_fini(struct mlxsw_sib *mlxsw_sib)
 	}
 }
 
+static int mlxsw_sib_basic_trap_groups_set(struct mlxsw_core *mlxsw_core)
+{
+	char htgt_pl[MLXSW_REG_HTGT_LEN];
+
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD);
+	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
+}
+
 static int mlxsw_sib_init(struct mlxsw_core *mlxsw_core,
 			  const struct mlxsw_bus_info *mlxsw_bus_info)
 {
@@ -504,6 +512,7 @@ static struct mlxsw_driver mlxsw_sib_driver = {
 	.priv_size		= sizeof(struct mlxsw_sib),
 	.init			= mlxsw_sib_init,
 	.fini			= mlxsw_sib_fini,
+	.basic_trap_groups_set	= mlxsw_sib_basic_trap_groups_set,
 	.txhdr_construct	= mlxsw_sib_tx_v1_hdr_construct,
 	.txhdr_len		= MLXSW_TXHDR_LEN,
 	.profile		= &mlxsw_sib_config_profile,
@@ -514,6 +523,7 @@ static struct mlxsw_driver mlxsw_sib2_driver = {
 	.priv_size		= sizeof(struct mlxsw_sib),
 	.init			= mlxsw_sib_init,
 	.fini			= mlxsw_sib_fini,
+	.basic_trap_groups_set	= mlxsw_sib_basic_trap_groups_set,
 	.txhdr_construct	= mlxsw_sib_tx_v1_hdr_construct,
 	.txhdr_len		= MLXSW_TXHDR_LEN,
 	.profile		= &mlxsw_sib_config_profile,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 1bcb391..8caa962 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1584,6 +1584,14 @@ static int mlxsw_sx_flood_init(struct mlxsw_sx *mlxsw_sx)
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(sgcr), sgcr_pl);
 }
 
+static int mlxsw_sx_basic_trap_groups_set(struct mlxsw_core *mlxsw_core)
+{
+	char htgt_pl[MLXSW_REG_HTGT_LEN];
+
+	mlxsw_reg_htgt_pack(htgt_pl, MLXSW_REG_HTGT_TRAP_GROUP_EMAD);
+	return mlxsw_reg_write(mlxsw_core, MLXSW_REG(htgt), htgt_pl);
+}
+
 static int mlxsw_sx_init(struct mlxsw_core *mlxsw_core,
 			 const struct mlxsw_bus_info *mlxsw_bus_info)
 {
@@ -1674,6 +1682,7 @@ static struct mlxsw_driver mlxsw_sx_driver = {
 	.priv_size		= sizeof(struct mlxsw_sx),
 	.init			= mlxsw_sx_init,
 	.fini			= mlxsw_sx_fini,
+	.basic_trap_groups_set	= mlxsw_sx_basic_trap_groups_set,
 	.txhdr_construct	= mlxsw_sx_txhdr_construct,
 	.txhdr_len		= MLXSW_TXHDR_LEN,
 	.profile		= &mlxsw_sx_config_profile,
-- 
2.7.4
