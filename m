From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 5/9] mlxsw: spectrum_router: Associate RIFs with correct VR
Date: Thu, 16 Mar 2017 09:08:16 +0100
Message-ID: <1489651700-3586-6-git-send-email-jiri@resnulli.us>
References: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36757 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdCPIIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 04:08:46 -0400
Received: by mail-wr0-f195.google.com with SMTP id l37so4805099wrc.3
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 01:08:28 -0700 (PDT)
In-Reply-To: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a router interface (RIF) is created due to a netdev being enslaved
to a VRF master, then it should be associated with the appropriate
virtual router (VR) and not the default one.

If netdev is a VRF slave, lookup the VR based on the VRF's table ID.
Otherwise default to the MAIN table.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 9ab41c4..5aad0ae 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -46,6 +46,7 @@
 #include <net/arp.h>
 #include <net/ip_fib.h>
 #include <net/fib_rules.h>
+#include <net/l3mdev.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -2762,6 +2763,7 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 			     struct net_device *l3_dev)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	u32 tb_id = l3mdev_fib_table(l3_dev);
 	struct mlxsw_sp_vr *vr;
 	struct mlxsw_sp_fid *f;
 	struct mlxsw_sp_rif *r;
@@ -2772,7 +2774,7 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 	if (rif == MLXSW_SP_INVALID_RIF)
 		return ERR_PTR(-ERANGE);
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, RT_TABLE_MAIN);
+	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
 
@@ -3010,6 +3012,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 				      struct net_device *l3_dev,
 				      struct mlxsw_sp_fid *f)
 {
+	u32 tb_id = l3mdev_fib_table(l3_dev);
 	struct mlxsw_sp_vr *vr;
 	struct mlxsw_sp_rif *r;
 	u16 rif;
@@ -3019,7 +3022,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (rif == MLXSW_SP_INVALID_RIF)
 		return -ERANGE;
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, RT_TABLE_MAIN);
+	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
 	if (IS_ERR(vr))
 		return PTR_ERR(vr);
 
-- 
2.7.4
