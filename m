From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/17] mlxsw: spectrum: Allow setting maximum rate for a TC
Date: Wed,  6 Apr 2016 17:10:11 +0200
Message-ID: <1459955416-23786-13-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35950 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381AbcDFPKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:40 -0400
Received: by mail-wm0-f65.google.com with SMTP id o129so4683226wmo.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:39 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Allow a user to set maximum rate for a particular TC using DCB ops.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  6 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 70 ++++++++++++++++++++++
 3 files changed, 77 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1498e6a..5f4d44e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1513,9 +1513,9 @@ int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(qeec), qeec_pl);
 }
 
-static int mlxsw_sp_port_ets_maxrate_set(struct mlxsw_sp_port *mlxsw_sp_port,
-					 enum mlxsw_reg_qeec_hr hr, u8 index,
-					 u8 next_index, u32 maxrate)
+int mlxsw_sp_port_ets_maxrate_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				  enum mlxsw_reg_qeec_hr hr, u8 index,
+				  u8 next_index, u32 maxrate)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char qeec_pl[MLXSW_REG_QEEC_LEN];
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index ef02081..9e1e4fe 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -173,6 +173,7 @@ struct mlxsw_sp_port {
 	} vport;
 	struct {
 		struct ieee_ets *ets;
+		struct ieee_maxrate *maxrate;
 	} dcb;
 	/* 802.1Q bridge VLANs */
 	unsigned long *active_vlans;
@@ -280,6 +281,9 @@ int mlxsw_sp_port_prio_tc_set(struct mlxsw_sp_port *mlxsw_sp_port,
 			      u8 switch_prio, u8 tclass);
 int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
 				 u8 *prio_tc);
+int mlxsw_sp_port_ets_maxrate_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				  enum mlxsw_reg_qeec_hr hr, u8 index,
+				  u8 next_index, u32 maxrate);
 
 #ifdef CONFIG_MLXSW_SPECTRUM_DCB
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
index aa5b73a..257e2d4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -250,9 +250,51 @@ static int mlxsw_sp_dcbnl_ieee_setets(struct net_device *dev,
 	return 0;
 }
 
+static int mlxsw_sp_dcbnl_ieee_getmaxrate(struct net_device *dev,
+					  struct ieee_maxrate *maxrate)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+
+	memcpy(maxrate, mlxsw_sp_port->dcb.maxrate, sizeof(*maxrate));
+
+	return 0;
+}
+
+static int mlxsw_sp_dcbnl_ieee_setmaxrate(struct net_device *dev,
+					  struct ieee_maxrate *maxrate)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct ieee_maxrate *my_maxrate = mlxsw_sp_port->dcb.maxrate;
+	int err, i;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		err = mlxsw_sp_port_ets_maxrate_set(mlxsw_sp_port,
+						    MLXSW_REG_QEEC_HIERARCY_SUBGROUP,
+						    i, 0,
+						    maxrate->tc_maxrate[i]);
+		if (err) {
+			netdev_err(dev, "Failed to set maxrate for TC %d\n", i);
+			goto err_port_ets_maxrate_set;
+		}
+	}
+
+	memcpy(mlxsw_sp_port->dcb.maxrate, maxrate, sizeof(*maxrate));
+
+	return 0;
+
+err_port_ets_maxrate_set:
+	for (i--; i >= 0; i--)
+		mlxsw_sp_port_ets_maxrate_set(mlxsw_sp_port,
+					      MLXSW_REG_QEEC_HIERARCY_SUBGROUP,
+					      i, 0, my_maxrate->tc_maxrate[i]);
+	return err;
+}
+
 static const struct dcbnl_rtnl_ops mlxsw_sp_dcbnl_ops = {
 	.ieee_getets		= mlxsw_sp_dcbnl_ieee_getets,
 	.ieee_setets		= mlxsw_sp_dcbnl_ieee_setets,
+	.ieee_getmaxrate	= mlxsw_sp_dcbnl_ieee_getmaxrate,
+	.ieee_setmaxrate	= mlxsw_sp_dcbnl_ieee_setmaxrate,
 
 	.getdcbx		= mlxsw_sp_dcbnl_getdcbx,
 	.setdcbx		= mlxsw_sp_dcbnl_setdcbx,
@@ -275,6 +317,26 @@ static void mlxsw_sp_port_ets_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 	kfree(mlxsw_sp_port->dcb.ets);
 }
 
+static int mlxsw_sp_port_maxrate_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	int i;
+
+	mlxsw_sp_port->dcb.maxrate = kmalloc(sizeof(*mlxsw_sp_port->dcb.maxrate),
+					     GFP_KERNEL);
+	if (!mlxsw_sp_port->dcb.maxrate)
+		return -ENOMEM;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		mlxsw_sp_port->dcb.maxrate->tc_maxrate[i] = MLXSW_REG_QEEC_MAS_DIS;
+
+	return 0;
+}
+
+static void mlxsw_sp_port_maxrate_fini(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	kfree(mlxsw_sp_port->dcb.maxrate);
+}
+
 int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	int err;
@@ -282,13 +344,21 @@ int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	err = mlxsw_sp_port_ets_init(mlxsw_sp_port);
 	if (err)
 		return err;
+	err = mlxsw_sp_port_maxrate_init(mlxsw_sp_port);
+	if (err)
+		goto err_port_maxrate_init;
 
 	mlxsw_sp_port->dev->dcbnl_ops = &mlxsw_sp_dcbnl_ops;
 
 	return 0;
+
+err_port_maxrate_init:
+	mlxsw_sp_port_ets_fini(mlxsw_sp_port);
+	return err;
 }
 
 void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 {
+	mlxsw_sp_port_maxrate_fini(mlxsw_sp_port);
 	mlxsw_sp_port_ets_fini(mlxsw_sp_port);
 }
-- 
2.5.5
