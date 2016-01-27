From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 10/11] mlxsw: spectrum: Compare local ports instead of pointers
Date: Wed, 27 Jan 2016 15:20:25 +0100
Message-ID: <1453904426-4960-11-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35620 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933047AbcA0OUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:43 -0500
Received: by mail-wm0-f54.google.com with SMTP id r129so146930492wmr.0
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:42 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When dumping the FDB we can't compare the actual pointers of the ports
structs, as it's possible the struct represents a vPort instead of the
underlying physical port.

Solve this by comparing the local port number instead, as it's shared
between the physical ports and all the vPorts on top of him.

Fixes: 54a732018d8e ("mlxsw: spectrum: Adjust switchdev ops for VLAN devices")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 21fc3c8..e492ca2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1053,6 +1053,7 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 				  struct net_device *orig_dev)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_port *tmp;
 	u16 vport_fid = 0;
 	char *sfd_pl;
 	char mac[ETH_ALEN];
@@ -1113,8 +1114,9 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 			case MLXSW_REG_SFD_REC_TYPE_UNICAST_LAG:
 				mlxsw_reg_sfd_uc_lag_unpack(sfd_pl, i,
 							    mac, &fid, &lag_id);
-				if (mlxsw_sp_port ==
-				    mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id)) {
+				tmp = mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id);
+				if (tmp && tmp->local_port ==
+				    mlxsw_sp_port->local_port) {
 					/* LAG records can only point to LAG
 					 * devices or VLAN devices on top.
 					 */
-- 
1.9.3
