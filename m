From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 20/23] mlxsw: spectrum: Don't count on FID being present
Date: Mon, 20 Jun 2016 23:04:18 +0200
Message-ID: <1466456661-5260-21-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:33026 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbcFTVSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:18:18 -0400
Received: by mail-lb0-f194.google.com with SMTP id o4so245091lbp.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:17:21 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Not all vPorts will have FIDs assigned to them, so make sure functions
first test for FID presence.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           |  4 +++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           |  4 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 11 ++++++-----
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ea007f0..0c42515 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3323,7 +3323,9 @@ mlxsw_sp_port_master_bridge_check(const struct mlxsw_sp_port *mlxsw_sp_port,
 
 	list_for_each_entry(mlxsw_sp_vport, &mlxsw_sp_port->vports_list,
 			    vport.list) {
-		if (mlxsw_sp_vport_br_get(mlxsw_sp_vport) == br_dev)
+		struct net_device *dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
+
+		if (dev && dev == br_dev)
 			return false;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index a6dd295..f419535 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -290,7 +290,7 @@ mlxsw_sp_vport_br_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
 	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
-	return f->dev;
+	return f ? f->dev : NULL;
 }
 
 static inline struct mlxsw_sp_port *
@@ -317,7 +317,7 @@ mlxsw_sp_port_vport_find_by_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
 			    vport.list) {
 		struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
-		if (f->fid == fid)
+		if (f && f->fid == fid)
 			return mlxsw_sp_vport;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index b31b2ce..fc34c46 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -55,10 +55,10 @@
 static u16 mlxsw_sp_port_vid_to_fid_get(struct mlxsw_sp_port *mlxsw_sp_port,
 					u16 vid)
 {
+	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_port);
 	u16 fid = vid;
 
-	if (mlxsw_sp_port_is_vport(mlxsw_sp_port))
-		fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port)->fid;
+	fid = f ? f->fid : fid;
 
 	if (!fid)
 		fid = mlxsw_sp_port->pvid;
@@ -1196,7 +1196,8 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_port *tmp;
-	u16 vport_fid = 0;
+	struct mlxsw_sp_fid *f;
+	u16 vport_fid;
 	char *sfd_pl;
 	char mac[ETH_ALEN];
 	u16 fid;
@@ -1211,8 +1212,8 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!sfd_pl)
 		return -ENOMEM;
 
-	if (mlxsw_sp_port_is_vport(mlxsw_sp_port))
-		vport_fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port)->fid;
+	f = mlxsw_sp_vport_fid_get(mlxsw_sp_port);
+	vport_fid = f ? f->fid : 0;
 
 	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
 	do {
-- 
2.5.5
