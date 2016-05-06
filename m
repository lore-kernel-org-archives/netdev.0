From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum: Add missing rollback in flood configuration
Date: Fri,  6 May 2016 22:18:40 +0200
Message-ID: <1462565920-1959-3-git-send-email-jiri@resnulli.us>
References: <1462565920-1959-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35921 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758541AbcEFUSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:18:45 -0400
Received: by mail-wm0-f68.google.com with SMTP id w143so10454197wmw.3
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 13:18:44 -0700 (PDT)
In-Reply-To: <1462565920-1959-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When we fail to set the flooding configuration for the broadcast and
unregistered multicast traffic, we should revert the flooding
configuration of the unknown unicast traffic.

Fixes: 0293038e0c36 ("mlxsw: spectrum: Add support for flood control")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index e1c74ef..9cd6f47 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -214,7 +214,15 @@ static int __mlxsw_sp_port_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, idx_begin,
 			    table_type, range, local_port, set);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+	if (err)
+		goto err_flood_bm_set;
+	else
+		goto buffer_out;
 
+err_flood_bm_set:
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_UC, idx_begin,
+			    table_type, range, local_port, !set);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
 buffer_out:
 	kfree(sftr_pl);
 	return err;
-- 
2.5.5
