From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] mlxsw: spectrum_switchdev: Add support for router port in SMID entries
Date: Thu,  5 Oct 2017 12:36:41 +0200
Message-ID: <20171005103642.1414-6-jiri@resnulli.us>
References: <20171005103642.1414-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:48408 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751776AbdJEKgx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:36:53 -0400
Received: by mail-wm0-f68.google.com with SMTP id i124so1226277wmf.3
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 03:36:53 -0700 (PDT)
In-Reply-To: <20171005103642.1414-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

In Spectrum, MDB entries point to MID entries, that indicate which ports a
packet should be forwarded to. Add the support in creating MID entries that
forward the packet to the Spectrum router port.

This will be later used to handle the bridge mrouter port switchdev
notifications.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 0f9eac5..092231a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -48,6 +48,7 @@
 #include <linux/rtnetlink.h>
 #include <net/switchdev.h>
 
+#include "spectrum_router.h"
 #include "spectrum.h"
 #include "core.h"
 #include "reg.h"
@@ -1241,7 +1242,8 @@ static int mlxsw_sp_port_mdb_op(struct mlxsw_sp *mlxsw_sp, const char *addr,
 }
 
 static int mlxsw_sp_port_smid_full_entry(struct mlxsw_sp *mlxsw_sp, u16 mid_idx,
-					 long *ports_bitmap)
+					 long *ports_bitmap,
+					 bool set_router_port)
 {
 	char *smid_pl;
 	int err, i;
@@ -1256,9 +1258,15 @@ static int mlxsw_sp_port_smid_full_entry(struct mlxsw_sp *mlxsw_sp, u16 mid_idx,
 			mlxsw_reg_smid_port_mask_set(smid_pl, i, 1);
 	}
 
+	mlxsw_reg_smid_port_mask_set(smid_pl,
+				     mlxsw_sp_router_port(mlxsw_sp), 1);
+
 	for_each_set_bit(i, ports_bitmap, mlxsw_core_max_ports(mlxsw_sp->core))
 		mlxsw_reg_smid_port_set(smid_pl, i, 1);
 
+	mlxsw_reg_smid_port_set(smid_pl, mlxsw_sp_router_port(mlxsw_sp),
+				set_router_port);
+
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(smid), smid_pl);
 	kfree(smid_pl);
 	return err;
@@ -1362,7 +1370,8 @@ mlxsw_sp_mc_write_mdb_entry(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_mc_get_mrouters_bitmap(flood_bitmap, bridge_device, mlxsw_sp);
 
 	mid->mid = mid_idx;
-	err = mlxsw_sp_port_smid_full_entry(mlxsw_sp, mid_idx, flood_bitmap);
+	err = mlxsw_sp_port_smid_full_entry(mlxsw_sp, mid_idx, flood_bitmap,
+					    false);
 	kfree(flood_bitmap);
 	if (err)
 		return false;
-- 
2.9.5
