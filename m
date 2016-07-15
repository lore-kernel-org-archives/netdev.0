From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 5/5] mlxsw: spectrum: Prevent invalid ingress buffer mapping
Date: Fri, 15 Jul 2016 11:15:02 +0200
Message-ID: <1468574102-26288-6-git-send-email-jiri@resnulli.us>
References: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36394 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbcGOJPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 05:15:11 -0400
Received: by mail-wm0-f68.google.com with SMTP id x83so1368553wma.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 02:15:11 -0700 (PDT)
In-Reply-To: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Packets entering the switch are mapped to a Switch Priority (SP)
according to their PCP value (untagged frames are mapped to SP 0).

The packets are classified to a priority group (PG) buffer in the port's
headroom according to their SP.

The switch maintains another mapping (SP to IEEE priority), which is
used to generate PFC frames for lossless PGs. This mapping is
initialized to IEEE = SP % 8.

Therefore, when mapping SP 'x' to PG 'y' we create a situation in which
an IEEE priority is mapped to two different PGs:

IEEE 'x' ---> SP 'x' ---> PG 'y'
IEEE 'x' ---> SP 'x + 8' ---> PG '0' (default)

Which is invalid, as a flow can use only one PG buffer.

Fix this by mapping both SP 'x' and 'x + 8' to the same PG buffer.

Fixes: 8e8dfe9fdf06 ("mlxsw: spectrum: Add IEEE 802.1Qaz ETS support")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h              | 17 ++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c     |  3 ++-
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 1977e7a..57d48da 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2718,7 +2718,7 @@ static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port,
  * Configures the switch priority to buffer table.
  */
 #define MLXSW_REG_PPTB_ID 0x500B
-#define MLXSW_REG_PPTB_LEN 0x0C
+#define MLXSW_REG_PPTB_LEN 0x10
 
 static const struct mlxsw_reg_info mlxsw_reg_pptb = {
 	.id = MLXSW_REG_PPTB_ID,
@@ -2784,6 +2784,13 @@ MLXSW_ITEM32(reg, pptb, pm_msb, 0x08, 24, 8);
  */
 MLXSW_ITEM32(reg, pptb, untagged_buff, 0x08, 0, 4);
 
+/* reg_pptb_prio_to_buff_msb
+ * Mapping of switch priority <i+8> to one of the allocated receive port
+ * buffers.
+ * Access: RW
+ */
+MLXSW_ITEM_BIT_ARRAY(reg, pptb, prio_to_buff_msb, 0x0C, 0x04, 4);
+
 #define MLXSW_REG_PPTB_ALL_PRIO 0xFF
 
 static inline void mlxsw_reg_pptb_pack(char *payload, u8 local_port)
@@ -2792,6 +2799,14 @@ static inline void mlxsw_reg_pptb_pack(char *payload, u8 local_port)
 	mlxsw_reg_pptb_mm_set(payload, MLXSW_REG_PPTB_MM_UM);
 	mlxsw_reg_pptb_local_port_set(payload, local_port);
 	mlxsw_reg_pptb_pm_set(payload, MLXSW_REG_PPTB_ALL_PRIO);
+	mlxsw_reg_pptb_pm_msb_set(payload, MLXSW_REG_PPTB_ALL_PRIO);
+}
+
+static inline void mlxsw_reg_pptb_prio_to_buff_pack(char *payload, u8 prio,
+						    u8 buff)
+{
+	mlxsw_reg_pptb_prio_to_buff_set(payload, prio, buff);
+	mlxsw_reg_pptb_prio_to_buff_msb_set(payload, prio, buff);
 }
 
 /* PBMC - Port Buffer Management Control Register
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index a3720a0..074cdda 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -194,7 +194,7 @@ static int mlxsw_sp_port_pb_prio_init(struct mlxsw_sp_port *mlxsw_sp_port)
 
 	mlxsw_reg_pptb_pack(pptb_pl, mlxsw_sp_port->local_port);
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
-		mlxsw_reg_pptb_prio_to_buff_set(pptb_pl, i, 0);
+		mlxsw_reg_pptb_prio_to_buff_pack(pptb_pl, i, 0);
 	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core, MLXSW_REG(pptb),
 			       pptb_pl);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
index 4af3f27..01cfb75 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -103,7 +103,8 @@ static int mlxsw_sp_port_pg_prio_map(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	mlxsw_reg_pptb_pack(pptb_pl, mlxsw_sp_port->local_port);
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
-		mlxsw_reg_pptb_prio_to_buff_set(pptb_pl, i, prio_tc[i]);
+		mlxsw_reg_pptb_prio_to_buff_pack(pptb_pl, i, prio_tc[i]);
+
 	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core, MLXSW_REG(pptb),
 			       pptb_pl);
 }
-- 
2.5.5
