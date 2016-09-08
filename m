From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum_router: Fix error path in mlxsw_sp_router_init
Date: Thu,  8 Sep 2016 08:16:01 +0200
Message-ID: <1473315362-1984-2-git-send-email-jiri@resnulli.us>
References: <1473315362-1984-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35424 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751905AbcIHGQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 02:16:07 -0400
Received: by mail-wm0-f67.google.com with SMTP id a6so6226844wmc.2
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 23:16:07 -0700 (PDT)
In-Reply-To: <1473315362-1984-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

When neigh_init fails, we have to do proper cleanup including
router_fini call.

Fixes: 6cf3c971dc84cb ("mlxsw: spectrum_router: Add private neigh table")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 352259b..3f5c51d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1517,7 +1517,14 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 		return err;
 	mlxsw_sp_lpm_init(mlxsw_sp);
 	mlxsw_sp_vrs_init(mlxsw_sp);
-	return mlxsw_sp_neigh_init(mlxsw_sp);
+	err = mlxsw_sp_neigh_init(mlxsw_sp);
+	if (err)
+		goto err_neigh_init;
+	return 0;
+
+err_neigh_init:
+	__mlxsw_sp_router_fini(mlxsw_sp);
+	return err;
 }
 
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
-- 
2.5.5
