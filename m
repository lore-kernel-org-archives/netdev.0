From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/17] mlxsw: spectrum: Add IEEE 802.1Qaz ETS support
Date: Wed,  6 Apr 2016 17:10:10 +0200
Message-ID: <1459955416-23786-12-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35925 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250AbcDFPKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:34 -0400
Received: by mail-wm0-f67.google.com with SMTP id o129so4682975wmo.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:33 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Implement the appropriate DCB ops and allow a user to configure:
	* Priority to traffic class (TC) mapping with a total of 8
	  supported TCs
	* Transmission selection algorithm (TSA) for each TC and the
	  corresponding weights in case of weighted round robin (WRR)

As previously explained, we treat the priority group (PG) buffer in the
port's headroom as the ingress counterpart of the egress TC. Therefore,
when a certain priority to TC mapping is configured, we also configure
the port's headroom buffer.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  53 ++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  11 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 229 +++++++++++++++++++++
 3 files changed, 283 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index baaa9ea..1498e6a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -450,22 +450,55 @@ static int mlxsw_sp_port_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				      int mtu)
+static void mlxsw_sp_pg_buf_pack(char *pbmc_pl, int pg_index, int mtu)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u16 pg_size = 2 * MLXSW_SP_BYTES_TO_CELLS(mtu);
+
+	mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pg_index, pg_size);
+}
+
+int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
+				 u8 *prio_tc)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char pbmc_pl[MLXSW_REG_PBMC_LEN];
-	int err;
+	int i, j, err;
 
 	mlxsw_reg_pbmc_pack(pbmc_pl, mlxsw_sp_port->local_port, 0, 0);
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
 	if (err)
 		return err;
-	mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, 0, pg_size);
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		bool configure = false;
+
+		for (j = 0; j < IEEE_8021QAZ_MAX_TCS; j++) {
+			if (prio_tc[j] == i) {
+				configure = true;
+				break;
+			}
+		}
+
+		if (!configure)
+			continue;
+		mlxsw_sp_pg_buf_pack(pbmc_pl, i, mtu);
+	}
+
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
 }
 
+static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				      int mtu)
+{
+	u8 def_prio_tc[IEEE_8021QAZ_MAX_TCS] = {0};
+	bool dcb_en = !!mlxsw_sp_port->dcb.ets;
+	u8 *prio_tc;
+
+	prio_tc = dcb_en ? mlxsw_sp_port->dcb.ets->prio_tc : def_prio_tc;
+
+	return __mlxsw_sp_port_headroom_set(mlxsw_sp_port, mtu, prio_tc);
+}
+
 static int mlxsw_sp_port_change_mtu(struct net_device *dev, int mtu)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
@@ -1465,9 +1498,9 @@ mlxsw_sp_port_speed_by_width_set(struct mlxsw_sp_port *mlxsw_sp_port, u8 width)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
 }
 
-static int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				 enum mlxsw_reg_qeec_hr hr, u8 index,
-				 u8 next_index, bool dwrr, u8 dwrr_weight)
+int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
+			  enum mlxsw_reg_qeec_hr hr, u8 index, u8 next_index,
+			  bool dwrr, u8 dwrr_weight)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char qeec_pl[MLXSW_REG_QEEC_LEN];
@@ -1494,8 +1527,8 @@ static int mlxsw_sp_port_ets_maxrate_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(qeec), qeec_pl);
 }
 
-static int mlxsw_sp_port_prio_tc_set(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u8 switch_prio, u8 tclass)
+int mlxsw_sp_port_prio_tc_set(struct mlxsw_sp_port *mlxsw_sp_port,
+			      u8 switch_prio, u8 tclass)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char qtct_pl[MLXSW_REG_QTCT_LEN];
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 1f50af8..ef02081 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -42,6 +42,7 @@
 #include <linux/bitops.h>
 #include <linux/if_vlan.h>
 #include <linux/list.h>
+#include <linux/dcbnl.h>
 #include <net/switchdev.h>
 #include <net/devlink.h>
 
@@ -170,6 +171,9 @@ struct mlxsw_sp_port {
 		struct mlxsw_sp_vfid *vfid;
 		u16 vid;
 	} vport;
+	struct {
+		struct ieee_ets *ets;
+	} dcb;
 	/* 802.1Q bridge VLANs */
 	unsigned long *active_vlans;
 	unsigned long *untagged_vlans;
@@ -269,6 +273,13 @@ int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
 			     bool set, bool only_uc);
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
 int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
+int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
+			  enum mlxsw_reg_qeec_hr hr, u8 index, u8 next_index,
+			  bool dwrr, u8 dwrr_weight);
+int mlxsw_sp_port_prio_tc_set(struct mlxsw_sp_port *mlxsw_sp_port,
+			      u8 switch_prio, u8 tclass);
+int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
+				 u8 *prio_tc);
 
 #ifdef CONFIG_MLXSW_SPECTRUM_DCB
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
index 631e980..aa5b73a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -33,9 +33,11 @@
  */
 
 #include <linux/netdevice.h>
+#include <linux/string.h>
 #include <net/dcbnl.h>
 
 #include "spectrum.h"
+#include "reg.h"
 
 static u8 mlxsw_sp_dcbnl_getdcbx(struct net_device __always_unused *dev)
 {
@@ -48,13 +50,239 @@ static u8 mlxsw_sp_dcbnl_setdcbx(struct net_device __always_unused *dev,
 	return (mode != (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE)) ? 1 : 0;
 }
 
+static int mlxsw_sp_dcbnl_ieee_getets(struct net_device *dev,
+				      struct ieee_ets *ets)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+
+	memcpy(ets, mlxsw_sp_port->dcb.ets, sizeof(*ets));
+
+	return 0;
+}
+
+static int mlxsw_sp_port_ets_validate(struct mlxsw_sp_port *mlxsw_sp_port,
+				      struct ieee_ets *ets)
+{
+	struct net_device *dev = mlxsw_sp_port->dev;
+	bool has_ets_tc = false;
+	int i, tx_bw_sum = 0;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_STRICT:
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			has_ets_tc = true;
+			tx_bw_sum += ets->tc_tx_bw[i];
+			break;
+		default:
+			netdev_err(dev, "Only strict priority and ETS are supported\n");
+			return -EINVAL;
+		}
+
+		if (ets->prio_tc[i] >= IEEE_8021QAZ_MAX_TCS) {
+			netdev_err(dev, "Invalid TC\n");
+			return -EINVAL;
+		}
+	}
+
+	if (has_ets_tc && tx_bw_sum != 100) {
+		netdev_err(dev, "Total ETS bandwidth should equal 100\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int mlxsw_sp_port_pg_prio_map(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u8 *prio_tc)
+{
+	char pptb_pl[MLXSW_REG_PPTB_LEN];
+	int i;
+
+	mlxsw_reg_pptb_pack(pptb_pl, mlxsw_sp_port->local_port);
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		mlxsw_reg_pptb_prio_to_buff_set(pptb_pl, i, prio_tc[i]);
+	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core, MLXSW_REG(pptb),
+			       pptb_pl);
+}
+
+static bool mlxsw_sp_ets_has_pg(u8 *prio_tc, u8 pg)
+{
+	int i;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		if (prio_tc[i] == pg)
+			return true;
+	return false;
+}
+
+static int mlxsw_sp_port_pg_destroy(struct mlxsw_sp_port *mlxsw_sp_port,
+				    u8 *old_prio_tc, u8 *new_prio_tc)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char pbmc_pl[MLXSW_REG_PBMC_LEN];
+	int err, i;
+
+	mlxsw_reg_pbmc_pack(pbmc_pl, mlxsw_sp_port->local_port, 0, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
+	if (err)
+		return err;
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		u8 pg = old_prio_tc[i];
+
+		if (!mlxsw_sp_ets_has_pg(new_prio_tc, pg))
+			mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pg, 0);
+	}
+
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
+}
+
+static int mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				      struct ieee_ets *ets)
+{
+	struct ieee_ets *my_ets = mlxsw_sp_port->dcb.ets;
+	struct net_device *dev = mlxsw_sp_port->dev;
+	int err;
+
+	/* Create the required PGs, but don't destroy existing ones, as
+	 * traffic is still directed to them.
+	 */
+	err = __mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu,
+					   ets->prio_tc);
+	if (err) {
+		netdev_err(dev, "Failed to configure port's headroom\n");
+		return err;
+	}
+
+	err = mlxsw_sp_port_pg_prio_map(mlxsw_sp_port, ets->prio_tc);
+	if (err) {
+		netdev_err(dev, "Failed to set PG-priority mapping\n");
+		goto err_port_prio_pg_map;
+	}
+
+	err = mlxsw_sp_port_pg_destroy(mlxsw_sp_port, my_ets->prio_tc,
+				       ets->prio_tc);
+	if (err)
+		netdev_warn(dev, "Failed to remove ununsed PGs\n");
+
+	return 0;
+
+err_port_prio_pg_map:
+	mlxsw_sp_port_pg_destroy(mlxsw_sp_port, ets->prio_tc, my_ets->prio_tc);
+	return err;
+}
+
+static int __mlxsw_sp_dcbnl_ieee_setets(struct mlxsw_sp_port *mlxsw_sp_port,
+					struct ieee_ets *ets)
+{
+	struct ieee_ets *my_ets = mlxsw_sp_port->dcb.ets;
+	struct net_device *dev = mlxsw_sp_port->dev;
+	int i, err;
+
+	/* Egress configuration. */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		bool dwrr = ets->tc_tsa[i] == IEEE_8021QAZ_TSA_ETS;
+		u8 weight = ets->tc_tx_bw[i];
+
+		err = mlxsw_sp_port_ets_set(mlxsw_sp_port,
+					    MLXSW_REG_QEEC_HIERARCY_SUBGROUP, i,
+					    0, dwrr, weight);
+		if (err) {
+			netdev_err(dev, "Failed to link subgroup ETS element %d to group\n",
+				   i);
+			goto err_port_ets_set;
+		}
+	}
+
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		err = mlxsw_sp_port_prio_tc_set(mlxsw_sp_port, i,
+						ets->prio_tc[i]);
+		if (err) {
+			netdev_err(dev, "Failed to map prio %d to TC %d\n", i,
+				   ets->prio_tc[i]);
+			goto err_port_prio_tc_set;
+		}
+	}
+
+	/* Ingress configuration. */
+	err = mlxsw_sp_port_headroom_set(mlxsw_sp_port, ets);
+	if (err)
+		goto err_port_headroom_set;
+
+	return 0;
+
+err_port_headroom_set:
+	i = IEEE_8021QAZ_MAX_TCS;
+err_port_prio_tc_set:
+	for (i--; i >= 0; i--)
+		mlxsw_sp_port_prio_tc_set(mlxsw_sp_port, i, my_ets->prio_tc[i]);
+	i = IEEE_8021QAZ_MAX_TCS;
+err_port_ets_set:
+	for (i--; i >= 0; i--) {
+		bool dwrr = my_ets->tc_tsa[i] == IEEE_8021QAZ_TSA_ETS;
+		u8 weight = my_ets->tc_tx_bw[i];
+
+		err = mlxsw_sp_port_ets_set(mlxsw_sp_port,
+					    MLXSW_REG_QEEC_HIERARCY_SUBGROUP, i,
+					    0, dwrr, weight);
+	}
+	return err;
+}
+
+static int mlxsw_sp_dcbnl_ieee_setets(struct net_device *dev,
+				      struct ieee_ets *ets)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	int err;
+
+	err = mlxsw_sp_port_ets_validate(mlxsw_sp_port, ets);
+	if (err)
+		return err;
+
+	err = __mlxsw_sp_dcbnl_ieee_setets(mlxsw_sp_port, ets);
+	if (err)
+		return err;
+
+	memcpy(mlxsw_sp_port->dcb.ets, ets, sizeof(*ets));
+
+	return 0;
+}
+
 static const struct dcbnl_rtnl_ops mlxsw_sp_dcbnl_ops = {
+	.ieee_getets		= mlxsw_sp_dcbnl_ieee_getets,
+	.ieee_setets		= mlxsw_sp_dcbnl_ieee_setets,
+
 	.getdcbx		= mlxsw_sp_dcbnl_getdcbx,
 	.setdcbx		= mlxsw_sp_dcbnl_setdcbx,
 };
 
+static int mlxsw_sp_port_ets_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	mlxsw_sp_port->dcb.ets = kzalloc(sizeof(*mlxsw_sp_port->dcb.ets),
+					 GFP_KERNEL);
+	if (!mlxsw_sp_port->dcb.ets)
+		return -ENOMEM;
+
+	mlxsw_sp_port->dcb.ets->ets_cap = IEEE_8021QAZ_MAX_TCS;
+
+	return 0;
+}
+
+static void mlxsw_sp_port_ets_fini(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	kfree(mlxsw_sp_port->dcb.ets);
+}
+
 int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
+	int err;
+
+	err = mlxsw_sp_port_ets_init(mlxsw_sp_port);
+	if (err)
+		return err;
+
 	mlxsw_sp_port->dev->dcbnl_ops = &mlxsw_sp_dcbnl_ops;
 
 	return 0;
@@ -62,4 +290,5 @@ int mlxsw_sp_port_dcb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 
 void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 {
+	mlxsw_sp_port_ets_fini(mlxsw_sp_port);
 }
-- 
2.5.5
