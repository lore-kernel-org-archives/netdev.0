From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum_buffers: Fix pool value handling in mlxsw_sp_sb_tc_pool_bind_set
Date: Fri, 19 Aug 2016 14:43:48 +0200
Message-ID: <1471610628-4287-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33636 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754030AbcHSMoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 08:44:22 -0400
Received: by mail-wm0-f65.google.com with SMTP id o80so3316492wme.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 05:43:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Pool index has to be converted by get_pool helper to work correctly for
egress pool. In mlxsw the egress pool index starts from 0.

Fixes: 0f433fa0ecc ("mlxsw: spectrum_buffers: Implement shared buffer configuration")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 237418a..953b214 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -717,22 +717,18 @@ int mlxsw_sp_sb_tc_pool_bind_set(struct mlxsw_core_port *mlxsw_core_port,
 	u8 local_port = mlxsw_sp_port->local_port;
 	u8 pg_buff = tc_index;
 	enum mlxsw_reg_sbxx_dir dir = pool_type;
-	u8 pool = pool_index;
+	u8 pool = pool_get(pool_index);
 	u32 max_buff;
 	int err;
 
+	if (dir != dir_get(pool_index))
+		return -EINVAL;
+
 	err = mlxsw_sp_sb_threshold_in(mlxsw_sp, pool, dir,
 				       threshold, &max_buff);
 	if (err)
 		return err;
 
-	if (pool_type == DEVLINK_SB_POOL_TYPE_EGRESS) {
-		if (pool < MLXSW_SP_SB_POOL_COUNT)
-			return -EINVAL;
-		pool -= MLXSW_SP_SB_POOL_COUNT;
-	} else if (pool >= MLXSW_SP_SB_POOL_COUNT) {
-		return -EINVAL;
-	}
 	return mlxsw_sp_sb_cm_write(mlxsw_sp, local_port, pg_buff, dir,
 				    0, max_buff, pool);
 }
-- 
2.5.5
