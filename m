From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/22] mlxsw: spectrum_router: Periodically dump active IPv6 neighbours
Date: Tue, 18 Jul 2017 10:10:17 +0200
Message-ID: <20170718081030.2781-10-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35625 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbdGRIKt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:49 -0400
Received: by mail-wr0-f196.google.com with SMTP id a10so2871177wrd.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:48 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

In addition to IPv4, periodically dump IPv6 neighbours and update the
kernel about them.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 79 +++++++++++++++++++---
 1 file changed, 69 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index a0de736..312fb67 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -968,6 +968,36 @@ static void mlxsw_sp_router_neigh_ent_ipv4_process(struct mlxsw_sp *mlxsw_sp,
 	neigh_release(n);
 }
 
+static void mlxsw_sp_router_neigh_ent_ipv6_process(struct mlxsw_sp *mlxsw_sp,
+						   char *rauhtd_pl,
+						   int rec_index)
+{
+	struct net_device *dev;
+	struct neighbour *n;
+	struct in6_addr dip;
+	u16 rif;
+
+	mlxsw_reg_rauhtd_ent_ipv6_unpack(rauhtd_pl, rec_index, &rif,
+					 (char *) &dip);
+
+	if (!mlxsw_sp->router->rifs[rif]) {
+		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Incorrect RIF in neighbour entry\n");
+		return;
+	}
+
+	dev = mlxsw_sp->router->rifs[rif]->dev;
+	n = neigh_lookup(&nd_tbl, &dip, dev);
+	if (!n) {
+		netdev_err(dev, "Failed to find matching neighbour for IP=%pI6c\n",
+			   &dip);
+		return;
+	}
+
+	netdev_dbg(dev, "Updating neighbour with IP=%pI6c\n", &dip);
+	neigh_event_send(n, NULL);
+	neigh_release(n);
+}
+
 static void mlxsw_sp_router_neigh_rec_ipv4_process(struct mlxsw_sp *mlxsw_sp,
 						   char *rauhtd_pl,
 						   int rec_index)
@@ -991,6 +1021,15 @@ static void mlxsw_sp_router_neigh_rec_ipv4_process(struct mlxsw_sp *mlxsw_sp,
 
 }
 
+static void mlxsw_sp_router_neigh_rec_ipv6_process(struct mlxsw_sp *mlxsw_sp,
+						   char *rauhtd_pl,
+						   int rec_index)
+{
+	/* One record contains one entry. */
+	mlxsw_sp_router_neigh_ent_ipv6_process(mlxsw_sp, rauhtd_pl,
+					       rec_index);
+}
+
 static void mlxsw_sp_router_neigh_rec_process(struct mlxsw_sp *mlxsw_sp,
 					      char *rauhtd_pl, int rec_index)
 {
@@ -1000,7 +1039,8 @@ static void mlxsw_sp_router_neigh_rec_process(struct mlxsw_sp *mlxsw_sp,
 						       rec_index);
 		break;
 	case MLXSW_REG_RAUHTD_TYPE_IPV6:
-		WARN_ON_ONCE(1);
+		mlxsw_sp_router_neigh_rec_ipv6_process(mlxsw_sp, rauhtd_pl,
+						       rec_index);
 		break;
 	}
 }
@@ -1025,22 +1065,20 @@ static bool mlxsw_sp_router_rauhtd_is_full(char *rauhtd_pl)
 	return false;
 }
 
-static int mlxsw_sp_router_neighs_update_rauhtd(struct mlxsw_sp *mlxsw_sp)
+static int
+__mlxsw_sp_router_neighs_update_rauhtd(struct mlxsw_sp *mlxsw_sp,
+				       char *rauhtd_pl,
+				       enum mlxsw_reg_rauhtd_type type)
 {
-	char *rauhtd_pl;
-	u8 num_rec;
-	int i, err;
-
-	rauhtd_pl = kmalloc(MLXSW_REG_RAUHTD_LEN, GFP_KERNEL);
-	if (!rauhtd_pl)
-		return -ENOMEM;
+	int i, num_rec;
+	int err;
 
 	/* Make sure the neighbour's netdev isn't removed in the
 	 * process.
 	 */
 	rtnl_lock();
 	do {
-		mlxsw_reg_rauhtd_pack(rauhtd_pl, MLXSW_REG_RAUHTD_TYPE_IPV4);
+		mlxsw_reg_rauhtd_pack(rauhtd_pl, type);
 		err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(rauhtd),
 				      rauhtd_pl);
 		if (err) {
@@ -1054,6 +1092,27 @@ static int mlxsw_sp_router_neighs_update_rauhtd(struct mlxsw_sp *mlxsw_sp)
 	} while (mlxsw_sp_router_rauhtd_is_full(rauhtd_pl));
 	rtnl_unlock();
 
+	return err;
+}
+
+static int mlxsw_sp_router_neighs_update_rauhtd(struct mlxsw_sp *mlxsw_sp)
+{
+	enum mlxsw_reg_rauhtd_type type;
+	char *rauhtd_pl;
+	int err;
+
+	rauhtd_pl = kmalloc(MLXSW_REG_RAUHTD_LEN, GFP_KERNEL);
+	if (!rauhtd_pl)
+		return -ENOMEM;
+
+	type = MLXSW_REG_RAUHTD_TYPE_IPV4;
+	err = __mlxsw_sp_router_neighs_update_rauhtd(mlxsw_sp, rauhtd_pl, type);
+	if (err)
+		goto out;
+
+	type = MLXSW_REG_RAUHTD_TYPE_IPV6;
+	err = __mlxsw_sp_router_neighs_update_rauhtd(mlxsw_sp, rauhtd_pl, type);
+out:
 	kfree(rauhtd_pl);
 	return err;
 }
-- 
2.9.3
