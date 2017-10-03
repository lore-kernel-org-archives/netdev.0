From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 7/7] mlxsw: spectrum: mr: Support trap-and-forward routes
Date: Tue,  3 Oct 2017 09:58:12 +0200
Message-ID: <20171003075812.1540-8-jiri@resnulli.us>
References: <20171003075812.1540-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, f.fainelli@gmail.com, fw@strlen.de,
        gfree.wind@vip.163.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33000 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdJCH6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 03:58:21 -0400
Received: by mail-wr0-f194.google.com with SMTP id z96so4082693wrb.0
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 00:58:20 -0700 (PDT)
In-Reply-To: <20171003075812.1540-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Add the support of trap-and-forward route action in the multicast routing
offloading logic. A route will be set to trap-and-forward action if one (or
more) of its output interfaces is not offload-able, i.e. does not have a
valid Spectrum RIF.

This way, a route with mixed output VIFs list, which contains both
offload-able and un-offload-able devices can go through partial offloading
in hardware, and the rest will be done in the kernel ipmr module.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
index 4aaf6ca..1f84bb8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
@@ -114,9 +114,9 @@ static bool mlxsw_sp_mr_vif_valid(const struct mlxsw_sp_mr_vif *vif)
 	return mlxsw_sp_mr_vif_regular(vif) && vif->dev && vif->rif;
 }
 
-static bool mlxsw_sp_mr_vif_rif_invalid(const struct mlxsw_sp_mr_vif *vif)
+static bool mlxsw_sp_mr_vif_exists(const struct mlxsw_sp_mr_vif *vif)
 {
-	return mlxsw_sp_mr_vif_regular(vif) && vif->dev && !vif->rif;
+	return vif->dev;
 }
 
 static bool
@@ -182,14 +182,13 @@ mlxsw_sp_mr_route_action(const struct mlxsw_sp_mr_route *mr_route)
 	if (!mlxsw_sp_mr_route_valid_evifs_num(mr_route))
 		return MLXSW_SP_MR_ROUTE_ACTION_TRAP;
 
-	/* If either one of the eVIFs is not regular (VIF of type pimreg or
-	 * tunnel) or one of the VIFs has no matching RIF, trap the packet.
+	/* If one of the eVIFs has no RIF, trap-and-forward the route as there
+	 * is some more routing to do in software too.
 	 */
-	list_for_each_entry(rve, &mr_route->evif_list, route_node) {
-		if (!mlxsw_sp_mr_vif_regular(rve->mr_vif) ||
-		    mlxsw_sp_mr_vif_rif_invalid(rve->mr_vif))
-			return MLXSW_SP_MR_ROUTE_ACTION_TRAP;
-	}
+	list_for_each_entry(rve, &mr_route->evif_list, route_node)
+		if (mlxsw_sp_mr_vif_exists(rve->mr_vif) && !rve->mr_vif->rif)
+			return MLXSW_SP_MR_ROUTE_ACTION_TRAP_AND_FORWARD;
+
 	return MLXSW_SP_MR_ROUTE_ACTION_FORWARD;
 }
 
-- 
2.9.5
