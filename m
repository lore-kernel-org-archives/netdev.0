From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/4] mlxsw: spectrum_router: Make mlxsw_sp_router_fib4_del return void and remove warn
Date: Thu, 20 Oct 2016 16:05:43 +0200
Message-ID: <1476972345-31568-3-git-send-email-jiri@resnulli.us>
References: <1476972345-31568-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36598 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753299AbcJTOFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 10:05:52 -0400
Received: by mail-lf0-f68.google.com with SMTP id b75so431881lfg.3
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 07:05:52 -0700 (PDT)
In-Reply-To: <1476972345-31568-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The function return value is not checked anywhere. Also, the warning
causes huge slowdown when removing large number of FIB entries which
were not offloaded, because of ordering issue. Ido's preparing
a patchset to fix the ordering issue, but that is definitelly not
net tree material.

Fixes: b45f64d16d45 ("mlxsw: spectrum_router: Use FIB notifications instead of switchdev calls")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 1b3a2cb..f3d50d3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1820,19 +1820,17 @@ static int mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
 	return err;
 }
 
-static int mlxsw_sp_router_fib4_del(struct mlxsw_sp *mlxsw_sp,
-				    struct fib_entry_notifier_info *fen_info)
+static void mlxsw_sp_router_fib4_del(struct mlxsw_sp *mlxsw_sp,
+				     struct fib_entry_notifier_info *fen_info)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
 
 	if (mlxsw_sp->router.aborted)
-		return 0;
+		return;
 
 	fib_entry = mlxsw_sp_fib_entry_find(mlxsw_sp, fen_info);
-	if (!fib_entry) {
-		dev_warn(mlxsw_sp->bus_info->dev, "Failed to find FIB4 entry being removed.\n");
-		return -ENOENT;
-	}
+	if (!fib_entry)
+		return;
 
 	if (fib_entry->ref_count == 1) {
 		mlxsw_sp_fib_entry_del(mlxsw_sp, fib_entry);
@@ -1840,7 +1838,6 @@ static int mlxsw_sp_router_fib4_del(struct mlxsw_sp *mlxsw_sp,
 	}
 
 	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
-	return 0;
 }
 
 static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
-- 
2.5.5
