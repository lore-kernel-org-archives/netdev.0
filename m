From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/4] mlxsw: spectrum_buffers: Limit size of pools
Date: Mon, 28 Nov 2016 18:01:24 +0100
Message-ID: <1480352486-18518-3-git-send-email-jiri@resnulli.us>
References: <1480352486-18518-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35559 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933400AbcK1RBb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:01:31 -0500
Received: by mail-wm0-f67.google.com with SMTP id a20so20103113wme.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:01:31 -0800 (PST)
In-Reply-To: <1480352486-18518-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The shared buffer pools are containers whose size is used to calculate
the maximum usage for packets from / to a specific port / {port, PG/TC},
when dynamic threshold is employed.

While it's perfectly fine for the sum of the pools to exceed the maximum
size of the shared buffer, a single pool cannot.

Add a check when the pool size is set and forbid sizes larger than the
maximum size of the shared buffer.

Without the patch:
$ devlink sb pool set pci/0000:03:00.0 pool 0 size 999999999 thtype
dynamic
// No error is returned

With the patch:
$ devlink sb pool set pci/0000:03:00.0 pool 0 size 999999999 thtype
dynamic
devlink answers: Invalid argument

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index bcaed8a..a746826 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -611,6 +611,9 @@ int mlxsw_sp_sb_pool_set(struct mlxsw_core *mlxsw_core,
 	u32 pool_size = MLXSW_SP_BYTES_TO_CELLS(size);
 	enum mlxsw_reg_sbpr_mode mode;
 
+	if (size > MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_BUFFER_SIZE))
+		return -EINVAL;
+
 	mode = (enum mlxsw_reg_sbpr_mode) threshold_type;
 	return mlxsw_sp_sb_pr_write(mlxsw_sp, pool, dir, mode, pool_size);
 }
-- 
2.7.4
