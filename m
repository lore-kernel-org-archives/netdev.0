From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] mlxsw: spectrum_buffers: Query shared buffer size from firmware
Date: Fri, 24 Mar 2017 08:02:49 +0100
Message-ID: <1490338971-2687-4-git-send-email-jiri@resnulli.us>
References: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34746 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-FAIL-OK-OK)
        by vger.kernel.org with ESMTP id S1755962AbdCXHDr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 03:03:47 -0400
Received: by mail-wr0-f196.google.com with SMTP id y90so716172wrb.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 00:03:45 -0700 (PDT)
In-Reply-To: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Instead of hard coding the size of the shared buffer in the driver,
query it from the firmware, as it may change in future devices.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 3ab853d..7e67d0e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -536,12 +536,15 @@ static int mlxsw_sp_sb_mms_init(struct mlxsw_sp *mlxsw_sp)
 	return 0;
 }
 
-#define MLXSW_SP_SB_SIZE (16 * 1024 * 1024)
-
 int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
 {
+	u64 sb_size;
 	int err;
 
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_BUFFER_SIZE))
+		return -EIO;
+	sb_size = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_BUFFER_SIZE);
+
 	err = mlxsw_sp_sb_ports_init(mlxsw_sp);
 	if (err)
 		return err;
@@ -554,8 +557,7 @@ int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
 	err = mlxsw_sp_sb_mms_init(mlxsw_sp);
 	if (err)
 		goto err_sb_mms_init;
-	err = devlink_sb_register(priv_to_devlink(mlxsw_sp->core), 0,
-				  MLXSW_SP_SB_SIZE,
+	err = devlink_sb_register(priv_to_devlink(mlxsw_sp->core), 0, sb_size,
 				  MLXSW_SP_SB_POOL_COUNT,
 				  MLXSW_SP_SB_POOL_COUNT,
 				  MLXSW_SP_SB_TC_COUNT,
-- 
2.7.4
