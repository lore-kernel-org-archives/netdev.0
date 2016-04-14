From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/18] mlxsw: reg: Extend SBPM register for occupancy control
Date: Thu, 14 Apr 2016 18:19:27 +0200
Message-ID: <1460650770-19382-16-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36656 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964842AbcDNQTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:54 -0400
Received: by mail-wm0-f52.google.com with SMTP id v188so227626965wme.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:53 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since it is not possible to get and clear Port-Pool occupancy data using
SBSR register, there's a need to implement that using SBPM.
Extend pack helper and add unpack helper to get occupancy values.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 31 +++++++++++++++++++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c |  3 ++-
 2 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 656466a..1977e7a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3636,6 +3636,27 @@ MLXSW_ITEM32(reg, sbpm, pool, 0x00, 8, 4);
  */
 MLXSW_ITEM32(reg, sbpm, dir, 0x00, 0, 2);
 
+/* reg_sbpm_buff_occupancy
+ * Current buffer occupancy in cells.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, sbpm, buff_occupancy, 0x10, 0, 24);
+
+/* reg_sbpm_clr
+ * Clear Max Buffer Occupancy
+ * When this bit is set, max_buff_occupancy field is cleared (and a
+ * new max value is tracked from the time the clear was performed).
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, sbpm, clr, 0x14, 31, 1);
+
+/* reg_sbpm_max_buff_occupancy
+ * Maximum value of buffer occupancy in cells monitored. Cleared by
+ * writing to the clr field.
+ * Access: RO
+ */
+MLXSW_ITEM32(reg, sbpm, max_buff_occupancy, 0x14, 0, 24);
+
 /* reg_sbpm_min_buff
  * Minimum buffer size for the limiter, in cells.
  * Access: RW
@@ -3656,17 +3677,25 @@ MLXSW_ITEM32(reg, sbpm, min_buff, 0x18, 0, 24);
 MLXSW_ITEM32(reg, sbpm, max_buff, 0x1C, 0, 24);
 
 static inline void mlxsw_reg_sbpm_pack(char *payload, u8 local_port, u8 pool,
-				       enum mlxsw_reg_sbxx_dir dir,
+				       enum mlxsw_reg_sbxx_dir dir, bool clr,
 				       u32 min_buff, u32 max_buff)
 {
 	MLXSW_REG_ZERO(sbpm, payload);
 	mlxsw_reg_sbpm_local_port_set(payload, local_port);
 	mlxsw_reg_sbpm_pool_set(payload, pool);
 	mlxsw_reg_sbpm_dir_set(payload, dir);
+	mlxsw_reg_sbpm_clr_set(payload, clr);
 	mlxsw_reg_sbpm_min_buff_set(payload, min_buff);
 	mlxsw_reg_sbpm_max_buff_set(payload, max_buff);
 }
 
+static inline void mlxsw_reg_sbpm_unpack(char *payload, u32 *p_buff_occupancy,
+					 u32 *p_max_buff_occupancy)
+{
+	*p_buff_occupancy = mlxsw_reg_sbpm_buff_occupancy_get(payload);
+	*p_max_buff_occupancy = mlxsw_reg_sbpm_max_buff_occupancy_get(payload);
+}
+
 /* SBMM - Shared Buffer Multicast Management Register
  * --------------------------------------------------
  * The SBMM register configures and retrieves the shared buffer allocation
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 6042c17..639ba5a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -113,7 +113,8 @@ static int mlxsw_sp_sb_pm_write(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	struct mlxsw_sp_sb_pm *pm;
 	int err;
 
-	mlxsw_reg_sbpm_pack(sbpm_pl, local_port, pool, dir, min_buff, max_buff);
+	mlxsw_reg_sbpm_pack(sbpm_pl, local_port, pool, dir, false,
+			    min_buff, max_buff);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpm), sbpm_pl);
 	if (err)
 		return err;
-- 
2.5.5
