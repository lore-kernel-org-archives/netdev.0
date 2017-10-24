From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] mlxsw: spectrum: mr: Fix various endianness issues
Date: Tue, 24 Oct 2017 11:17:15 +0200
Message-ID: <20171024091717.1180-2-jiri@resnulli.us>
References: <20171024091717.1180-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:45710 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751372AbdJXJRU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:17:20 -0400
Received: by mail-wm0-f68.google.com with SMTP id q124so14329668wmb.0
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:17:20 -0700 (PDT)
In-Reply-To: <20171024091717.1180-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Fix various endianness issues in comparisons and assignments. The fix is
entirely cosmetic as all the values fixed are endianness-agnostic.

Cleans up sparse warnings:
spectrum_mr.c:156:49: warning: restricted __be32 degrades to integer
spectrum_mr.c:206:26: warning: restricted __be32 degrades to integer
spectrum_mr.c:212:31: warning: incorrect type in assignment (different
  base types)
spectrum_mr.c:212:31:    expected restricted __be32 [usertype] addr4
spectrum_mr.c:212:31:    got unsigned int
spectrum_mr.c:214:32: warning: incorrect type in assignment (different
  base types)
spectrum_mr.c:214:32:    expected restricted __be32 [usertype] addr4
spectrum_mr.c:214:32:    got unsigned int
spectrum_mr.c:461:16: warning: restricted __be32 degrades to integer
spectrum_mr.c:461:49: warning: restricted __be32 degrades to integer

Fixes: c011ec1bbfd6 ("mlxsw: spectrum: Add the multicast routing offloading logic")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
index 1f84bb8..3f7d2d1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
@@ -153,7 +153,7 @@ static bool mlxsw_sp_mr_route_starg(const struct mlxsw_sp_mr_route *mr_route)
 {
 	switch (mr_route->mr_table->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
-		return mr_route->key.source_mask.addr4 == INADDR_ANY;
+		return mr_route->key.source_mask.addr4 == htonl(INADDR_ANY);
 	case MLXSW_SP_L3_PROTO_IPV6:
 		/* fall through */
 	default:
@@ -203,15 +203,15 @@ static void mlxsw_sp_mr_route4_key(struct mlxsw_sp_mr_table *mr_table,
 				   struct mlxsw_sp_mr_route_key *key,
 				   const struct mfc_cache *mfc)
 {
-	bool starg = (mfc->mfc_origin == INADDR_ANY);
+	bool starg = (mfc->mfc_origin == htonl(INADDR_ANY));
 
 	memset(key, 0, sizeof(*key));
 	key->vrid = mr_table->vr_id;
 	key->proto = mr_table->proto;
 	key->group.addr4 = mfc->mfc_mcastgrp;
-	key->group_mask.addr4 = 0xffffffff;
+	key->group_mask.addr4 = htonl(0xffffffff);
 	key->source.addr4 = mfc->mfc_origin;
-	key->source_mask.addr4 = starg ? 0 : 0xffffffff;
+	key->source_mask.addr4 = htonl(starg ? 0 : 0xffffffff);
 }
 
 static int mlxsw_sp_mr_route_evif_link(struct mlxsw_sp_mr_route *mr_route,
@@ -458,7 +458,8 @@ int mlxsw_sp_mr_route4_add(struct mlxsw_sp_mr_table *mr_table,
 	/* If the route is a (*,*) route, abort, as these kind of routes are
 	 * used for proxy routes.
 	 */
-	if (mfc->mfc_origin == INADDR_ANY && mfc->mfc_mcastgrp == INADDR_ANY) {
+	if (mfc->mfc_origin == htonl(INADDR_ANY) &&
+	    mfc->mfc_mcastgrp == htonl(INADDR_ANY)) {
 		dev_warn(mr_table->mlxsw_sp->bus_info->dev,
 			 "Offloading proxy routes is not supported.\n");
 		return -EINVAL;
-- 
2.9.5
