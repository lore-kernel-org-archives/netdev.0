From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/9] mlxsw: spectrum: Unmap local port from module during teardown
Date: Mon, 22 Feb 2016 19:32:01 +0100
Message-ID: <1456165924-14399-7-git-send-email-jiri@resnulli.us>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35772 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbcBVScP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 13:32:15 -0500
Received: by mail-wm0-f51.google.com with SMTP id c200so185679645wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 10:32:14 -0800 (PST)
In-Reply-To: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When splitting a port we replace it with 2 or 4 other ports. To be able
to do that we need to remove the original port netdev and unmap it from
its module. However, we first mark it as disabled, as active ports
cannot be unmapped.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 9d4b06c..1d6f1ef 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -320,6 +320,15 @@ static int mlxsw_sp_port_module_check(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
+static int mlxsw_sp_port_module_unmap(struct mlxsw_sp *mlxsw_sp, u8 local_port)
+{
+	char pmlp_pl[MLXSW_REG_PMLP_LEN];
+
+	mlxsw_reg_pmlp_pack(pmlp_pl, local_port);
+	mlxsw_reg_pmlp_width_set(pmlp_pl, 0);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pmlp), pmlp_pl);
+}
+
 static int mlxsw_sp_port_open(struct net_device *dev)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
@@ -1531,6 +1540,8 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	devlink_port_unregister(devlink_port);
 	mlxsw_sp_port_vports_fini(mlxsw_sp_port);
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
+	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
+	mlxsw_sp_port_module_unmap(mlxsw_sp, mlxsw_sp_port->local_port);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 	kfree(mlxsw_sp_port->untagged_vlans);
 	kfree(mlxsw_sp_port->active_vlans);
-- 
2.5.0
