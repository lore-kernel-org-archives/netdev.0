From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/12] mlxsw: spectrum: Default ports to non-virtual mode
Date: Tue, 16 May 2017 19:38:35 +0200
Message-ID: <20170516173835.2978-13-jiri@resnulli.us>
References: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36735 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752835AbdEPRjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:39:06 -0400
Received: by mail-wr0-f196.google.com with SMTP id v42so14918811wrc.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:39:01 -0700 (PDT)
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In virtual mode, packets are classified to FIDs based on their ingress
port and VLAN whereas in non-virtual mode only the VLAN is taken into
account.

Currently ports are initialized to use virtual mode due to the presence
of the PVID vPort. However, we're going to transition ports between both
modes based on the FIDs they use and not merely based on the presence on
a VLAN upper. Therefore, during initialization, no mode will be
explicitly set.

Since the Programmer's Reference Manual (PRM) doesn't specify a default,
explicitly set the port to non-virtual mode and later transition the
port between both modes based on the FIDs it uses.

In a follow-up patchset, this step will be moved to the common FID core
where it logically belongs.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 21227a8..8a165bb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2619,6 +2619,13 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_port_dcb_init;
 	}
 
+	err = mlxsw_sp_port_vp_mode_set(mlxsw_sp_port, false);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to set non-virtual mode\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_vp_mode_set;
+	}
+
 	err = mlxsw_sp_port_pvid_vport_create(mlxsw_sp_port);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to create PVID vPort\n",
@@ -2646,6 +2653,7 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	mlxsw_sp_port_pvid_vport_destroy(mlxsw_sp_port);
 err_port_pvid_vport_create:
+err_port_vp_mode_set:
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
 err_port_dcb_init:
 err_port_ets_init:
-- 
2.9.3
