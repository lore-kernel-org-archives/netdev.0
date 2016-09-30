From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] mlxsw: spectrum_router: avoid potential uninitialized data usage
Date: Fri, 30 Sep 2016 18:17:10 +0200
Message-ID: <20160930161734.70928-2-arnd@arndb.de>
References: <20160930161734.70928-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Yotam Gigi <yotamg@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:56240 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933082AbcI3QSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 12:18:00 -0400
In-Reply-To: <20160930161734.70928-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If fi->fib_nhs is zero, the router interface pointer is uninitialized, as shown by
this warning:

drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c: In function 'mlxsw_sp_router_fib_event':
drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:1674:21: error: 'r' may be used uninitialized in this function [-Werror=maybe-uninitialized]
drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:1643:23: note: 'r' was declared here

This changes the loop so we handle the case the same way as finding no router
interface pointer attached to one of the nexthops to ensure we always
trap here instead of using uninitialized data.

Fixes: b45f64d16d45 ("mlxsw: spectrum_router: Use FIB notifications instead of switchdev calls")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 48d50efec5e2..78fc557d6dd7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1640,7 +1640,7 @@ mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
 				struct mlxsw_sp_fib_entry *fib_entry)
 {
 	struct fib_info *fi = fen_info->fi;
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *r = NULL;
 	int nhsel;
 	int err;
 
@@ -1664,11 +1664,15 @@ mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
 			 * to us. Set trap and pass the packets for
 			 * this prefix to kernel.
 			 */
-			fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
-			return 0;
+			break;
 		}
 	}
 
+	if (!r) {
+		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
+		return 0;
+	}
+
 	if (fi->fib_scope != RT_SCOPE_UNIVERSE) {
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
 		fib_entry->rif = r->rif;
-- 
2.9.0
