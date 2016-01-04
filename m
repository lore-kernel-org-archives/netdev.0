From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/4] mlxsw: spectrum: Change bridge port attributes only when bridged
Date: Mon,  4 Jan 2016 10:42:26 +0100
Message-ID: <1451900546-2006-5-git-send-email-jiri@resnulli.us>
References: <1451900546-2006-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35319 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137AbcADJme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 04:42:34 -0500
Received: by mail-wm0-f49.google.com with SMTP id f206so133501181wmf.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 01:42:33 -0800 (PST)
In-Reply-To: <1451900546-2006-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Bridge port attributes are offloaded to hardware when invoked with SELF
flag set, but it really makes no sense to reflect them when port is not
bridged.

Allow a user to change these attribute only when port is bridged and
initialize them correctly when joining or leaving a bridge.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c          | 17 +++++++++++------
 .../net/ethernet/mellanox/mlxsw/spectrum_switchdev.c    |  3 +++
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ed2eb7b..74ff011 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1364,9 +1364,6 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port->dev = dev;
 	mlxsw_sp_port->mlxsw_sp = mlxsw_sp;
 	mlxsw_sp_port->local_port = local_port;
-	mlxsw_sp_port->learning = 1;
-	mlxsw_sp_port->learning_sync = 1;
-	mlxsw_sp_port->uc_flood = 1;
 	bytes = DIV_ROUND_UP(VLAN_N_VID, BITS_PER_BYTE);
 	mlxsw_sp_port->active_vlans = kzalloc(bytes, GFP_KERNEL);
 	if (!mlxsw_sp_port->active_vlans) {
@@ -1989,16 +1986,24 @@ static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port)
 	 * own VLANs.
 	 */
 	err = mlxsw_sp_port_kill_vid(dev, 0, 1);
-	if (!err)
-		mlxsw_sp_port->bridged = 1;
+	if (err)
+		return err;
 
-	return err;
+	mlxsw_sp_port->learning = 1;
+	mlxsw_sp_port->learning_sync = 1;
+	mlxsw_sp_port->uc_flood = 1;
+	mlxsw_sp_port->bridged = 1;
+
+	return 0;
 }
 
 static int mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
 
+	mlxsw_sp_port->learning = 0;
+	mlxsw_sp_port->learning_sync = 0;
+	mlxsw_sp_port->uc_flood = 0;
 	mlxsw_sp_port->bridged = 0;
 
 	/* Add implicit VLAN interface in the device, so that untagged
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 9476ff9..6215954 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -252,6 +252,9 @@ static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	bool set;
 	int err;
 
+	if (!mlxsw_sp_port->bridged)
+		return -EINVAL;
+
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
 
-- 
1.9.3
