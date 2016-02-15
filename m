From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum: Set STP state when leaving 802.1D bridge
Date: Mon, 15 Feb 2016 13:19:54 +0100
Message-ID: <1455538794-2823-3-git-send-email-jiri@resnulli.us>
References: <1455538794-2823-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36036 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbcBOMT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 07:19:59 -0500
Received: by mail-wm0-f42.google.com with SMTP id g62so56046839wme.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 04:19:59 -0800 (PST)
In-Reply-To: <1455538794-2823-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a VLAN device leaves a bridge its STP state is set to DISABLED,
which causes the hardware to discard any packets coming through the port
with this VLAN.

Fix that by setting STP state to FORWARDING when the device leaves its
bridge and allow traffic to be directed to CPU.

Fixes: 26f0e7fb15de ("mlxsw: spectrum: Add support for VLAN devices bridging")
Reported-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 217856b..0fa8da5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2746,6 +2746,13 @@ static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 		goto err_vport_flood_set;
 	}
 
+	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_vport, vid,
+					  MLXSW_REG_SPMS_STATE_FORWARDING);
+	if (err) {
+		netdev_err(dev, "Failed to set STP state\n");
+		goto err_port_stp_state_set;
+	}
+
 	if (flush_fdb && mlxsw_sp_vport_fdb_flush(mlxsw_sp_vport))
 		netdev_err(dev, "Failed to flush FDB\n");
 
@@ -2763,6 +2770,7 @@ static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 	return 0;
 
+err_port_stp_state_set:
 err_vport_flood_set:
 err_port_vid_learning_set:
 err_port_vid_to_fid_validate:
-- 
1.9.3
