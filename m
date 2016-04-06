From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/17] mlxsw: spectrum: Initialize egress scheduling
Date: Wed,  6 Apr 2016 17:10:08 +0200
Message-ID: <1459955416-23786-10-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35867 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbcDFPKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:31 -0400
Received: by mail-wm0-f65.google.com with SMTP id o129so4682554wmo.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:30 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Before introducing support for DCB ops we should first make sure we
initialize the relevant parts in the device correctly. Specifically, the
egress scheduling.

The device supports a superset of the 802.1Qaz standard with 4 hierarchy
levels that can be linked to each other in multiple ways and with
different transmission selection algorithms (TSA) employed between them.

However, since we only intend to support the 802.1Qaz standard we
flatten the hierarchies and let the user configure via DCB ops the TSA
and max rate shaper at the subgroup hierarchy (see figure below) and the
mapping between switch priority to traffic class. By default, all switch
priorities are mapped to traffic class 0, strict priority is employed
and max shaper is disabled.

Default configuration:

         switch priority 0      ...         switch priority 7
                 +                                  +
                 |                                  |
                 +----------------------------------+
                 |
              +--v--+                          +-----+
Traffic Class |     |                          |     |
  Hierarchy   | TC0 |           ...            | TC7 |
              |     |                          |     |
              +--+--+                          +--+--+
                 |                                |
              +--v--+                          +--v--+
  Subgroup    | SG0 |                          | SG7 |
  Hierarchy   |     |                          |     |
              +-----+                          +-----+
              | TSA |                          | TSA |
              +-----+           ...            +-----+
              | MAX |                          | MAX |
              +--+--+                          +--+--+
                 |                                |
                 +---------------+----------------+
                                 |
                              +--v--+
                      Group   |     |
                    Hierarchy | GR0 |
                              |     |
                              +--+--+
                                 |
                              +--v--+
                      Port    |     |
                    Hierarchy | PR0 |
                              |     |
                              +-----+

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 111 +++++++++++++++++++++++++
 1 file changed, 111 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4576d59..1243c74 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -49,6 +49,7 @@
 #include <linux/jiffies.h>
 #include <linux/bitops.h>
 #include <linux/list.h>
+#include <linux/dcbnl.h>
 #include <net/devlink.h>
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
@@ -1464,6 +1465,108 @@ mlxsw_sp_port_speed_by_width_set(struct mlxsw_sp_port *mlxsw_sp_port, u8 width)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
 }
 
+static int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				 enum mlxsw_reg_qeec_hr hr, u8 index,
+				 u8 next_index, bool dwrr, u8 dwrr_weight)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char qeec_pl[MLXSW_REG_QEEC_LEN];
+
+	mlxsw_reg_qeec_pack(qeec_pl, mlxsw_sp_port->local_port, hr, index,
+			    next_index);
+	mlxsw_reg_qeec_de_set(qeec_pl, true);
+	mlxsw_reg_qeec_dwrr_set(qeec_pl, dwrr);
+	mlxsw_reg_qeec_dwrr_weight_set(qeec_pl, dwrr_weight);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(qeec), qeec_pl);
+}
+
+static int mlxsw_sp_port_ets_maxrate_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					 enum mlxsw_reg_qeec_hr hr, u8 index,
+					 u8 next_index, u32 maxrate)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char qeec_pl[MLXSW_REG_QEEC_LEN];
+
+	mlxsw_reg_qeec_pack(qeec_pl, mlxsw_sp_port->local_port, hr, index,
+			    next_index);
+	mlxsw_reg_qeec_mase_set(qeec_pl, true);
+	mlxsw_reg_qeec_max_shaper_rate_set(qeec_pl, maxrate);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(qeec), qeec_pl);
+}
+
+static int mlxsw_sp_port_prio_tc_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				     u8 switch_prio, u8 tclass)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char qtct_pl[MLXSW_REG_QTCT_LEN];
+
+	mlxsw_reg_qtct_pack(qtct_pl, mlxsw_sp_port->local_port, switch_prio,
+			    tclass);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(qtct), qtct_pl);
+}
+
+static int mlxsw_sp_port_ets_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	int err, i;
+
+	/* Setup the elements hierarcy, so that each TC is linked to
+	 * one subgroup, which are all member in the same group.
+	 */
+	err = mlxsw_sp_port_ets_set(mlxsw_sp_port,
+				    MLXSW_REG_QEEC_HIERARCY_GROUP, 0, 0, false,
+				    0);
+	if (err)
+		return err;
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		err = mlxsw_sp_port_ets_set(mlxsw_sp_port,
+					    MLXSW_REG_QEEC_HIERARCY_SUBGROUP, i,
+					    0, false, 0);
+		if (err)
+			return err;
+	}
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		err = mlxsw_sp_port_ets_set(mlxsw_sp_port,
+					    MLXSW_REG_QEEC_HIERARCY_TC, i, i,
+					    false, 0);
+		if (err)
+			return err;
+	}
+
+	/* Make sure the max shaper is disabled in all hierarcies that
+	 * support it.
+	 */
+	err = mlxsw_sp_port_ets_maxrate_set(mlxsw_sp_port,
+					    MLXSW_REG_QEEC_HIERARCY_PORT, 0, 0,
+					    MLXSW_REG_QEEC_MAS_DIS);
+	if (err)
+		return err;
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		err = mlxsw_sp_port_ets_maxrate_set(mlxsw_sp_port,
+						    MLXSW_REG_QEEC_HIERARCY_SUBGROUP,
+						    i, 0,
+						    MLXSW_REG_QEEC_MAS_DIS);
+		if (err)
+			return err;
+	}
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		err = mlxsw_sp_port_ets_maxrate_set(mlxsw_sp_port,
+						    MLXSW_REG_QEEC_HIERARCY_TC,
+						    i, i,
+						    MLXSW_REG_QEEC_MAS_DIS);
+		if (err)
+			return err;
+	}
+
+	/* Map all priorities to traffic class 0. */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		err = mlxsw_sp_port_prio_tc_set(mlxsw_sp_port, i, 0);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				  bool split, u8 module, u8 width)
 {
@@ -1571,6 +1674,13 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_port_buffers_init;
 	}
 
+	err = mlxsw_sp_port_ets_init(mlxsw_sp_port);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to initialize ETS\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_ets_init;
+	}
+
 	mlxsw_sp_port_switchdev_init(mlxsw_sp_port);
 	err = register_netdev(dev);
 	if (err) {
@@ -1591,6 +1701,7 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 err_port_vlan_init:
 	unregister_netdev(dev);
 err_register_netdev:
+err_port_ets_init:
 err_port_buffers_init:
 err_port_admin_status_set:
 err_port_mtu_set:
-- 
2.5.5
