From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum_acl_tcam: Get tcam_region_info returned by FW on PTAR
Date: Wed, 19 Apr 2017 09:54:30 +0200
Message-ID: <1492588470-1951-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, leonro@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33267 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760665AbdDSHyd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 03:54:33 -0400
Received: by mail-wm0-f67.google.com with SMTP id o81so3429029wmb.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 00:54:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

During PTAR register access, FW processes tcam_region_info passed by
driver and also returns modified tcam_region_info back. This needs to be
stored by driver for any future calls.

Fixes: 22a677661f56 ("mlxsw: spectrum: Introduce ACL core with simple TCAM implementation")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
index 7382832..2f192f5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
@@ -497,10 +497,15 @@ mlxsw_sp_acl_tcam_region_resize(struct mlxsw_sp *mlxsw_sp,
 				u16 new_size)
 {
 	char ptar_pl[MLXSW_REG_PTAR_LEN];
+	int err;
 
 	mlxsw_reg_ptar_pack(ptar_pl, MLXSW_REG_PTAR_OP_RESIZE,
 			    new_size, region->id, region->tcam_region_info);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptar), ptar_pl);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptar), ptar_pl);
+	if (err)
+		return err;
+	mlxsw_reg_ptar_unpack(ptar_pl, region->tcam_region_info);
+	return err;
 }
 
 static int
-- 
2.7.4
