From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum_router: Move VRF refcounting
Date: Mon,  2 Oct 2017 12:14:56 +0200
Message-ID: <20171002101457.1462-2-jiri@resnulli.us>
References: <20171002101457.1462-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:44968 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750978AbdJBKPA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 06:15:00 -0400
Received: by mail-wm0-f66.google.com with SMTP id 196so2042974wma.1
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 03:15:00 -0700 (PDT)
In-Reply-To: <20171002101457.1462-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

When creating a new RIF, bumping RIF count of the containing VR is the
last thing to be done. Symmetrically, when destroying a RIF, RIF count
is first dropped and only then the rest of the cleanup proceeds.

That's a problem for loopback RIFs. Those hold two VR references: one
for overlay and one for underlay. mlxsw_sp_rif_destroy() releases the
overlay one, and the deconfigure() callback the underlay one. But if
both overlay and underlay are the same, and if there are no other
artifacts holding the VR alive, this put actually destroys the VR. Later
on, when mlxsw_sp_rif_destroy() calls mlxsw_sp_vr_put() for the same VR,
the VR will already have been released and the kernel crashes with NULL
pointer dereference.

The underlying problem is that the RIF under destruction ends up
referencing the overlay VR much longer than it claims: all the way until
the call to mlxsw_sp_vr_put(). So line up the reference counting
properly to reflect this. Make corresponding changes in
mlxsw_sp_rif_create() as well for symmetry.

Fixes: 6ddb7426a7d4 ("mlxsw: spectrum_router: Introduce loopback RIFs")
Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2cfb3f5..3917b4d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5068,6 +5068,7 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
+	vr->rif_count++;
 
 	err = mlxsw_sp_rif_index_alloc(mlxsw_sp, &rif_index);
 	if (err)
@@ -5099,7 +5100,6 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_sp_rif_counters_alloc(rif);
 	mlxsw_sp->router->rifs[rif_index] = rif;
-	vr->rif_count++;
 
 	return rif;
 
@@ -5110,6 +5110,7 @@ mlxsw_sp_rif_create(struct mlxsw_sp *mlxsw_sp,
 	kfree(rif);
 err_rif_alloc:
 err_rif_index_alloc:
+	vr->rif_count--;
 	mlxsw_sp_vr_put(vr);
 	return ERR_PTR(err);
 }
@@ -5124,7 +5125,6 @@ void mlxsw_sp_rif_destroy(struct mlxsw_sp_rif *rif)
 	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, rif);
 	vr = &mlxsw_sp->router->vrs[rif->vr_id];
 
-	vr->rif_count--;
 	mlxsw_sp->router->rifs[rif->rif_index] = NULL;
 	mlxsw_sp_rif_counters_free(rif);
 	ops->deconfigure(rif);
@@ -5132,6 +5132,7 @@ void mlxsw_sp_rif_destroy(struct mlxsw_sp_rif *rif)
 		/* Loopback RIFs are not associated with a FID. */
 		mlxsw_sp_fid_put(fid);
 	kfree(rif);
+	vr->rif_count--;
 	mlxsw_sp_vr_put(vr);
 }
 
-- 
2.9.5
