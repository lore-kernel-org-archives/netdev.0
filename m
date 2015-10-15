From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/15] mlxsw: Remove multicast ID configuration
Date: Thu, 15 Oct 2015 17:43:15 +0200
Message-ID: <1444923809-20785-2-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:35271 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524AbbJOPne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:34 -0400
Received: by lbwr8 with SMTP id r8so73573940lbw.2
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:33 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

With respect to a firmware change, the Switch Multicast ID (SMID)
register is no longer needed, so the related configuration code can be
removed.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 53 --------------------------
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 11 ------
 2 files changed, 64 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 096e1c1..5e0c957 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -99,57 +99,6 @@ static const struct mlxsw_reg_info mlxsw_reg_spad = {
  */
 MLXSW_ITEM_BUF(reg, spad, base_mac, 0x02, 6);
 
-/* SMID - Switch Multicast ID
- * --------------------------
- * In multi-chip configuration, each device should maintain mapping between
- * Multicast ID (MID) into a list of local ports. This mapping is used in all
- * the devices other than the ingress device, and is implemented as part of the
- * FDB. The MID record maps from a MID, which is a unique identi- fier of the
- * multicast group within the stacking domain, into a list of local ports into
- * which the packet is replicated.
- */
-#define MLXSW_REG_SMID_ID 0x2007
-#define MLXSW_REG_SMID_LEN 0x420
-
-static const struct mlxsw_reg_info mlxsw_reg_smid = {
-	.id = MLXSW_REG_SMID_ID,
-	.len = MLXSW_REG_SMID_LEN,
-};
-
-/* reg_smid_swid
- * Switch partition ID.
- * Access: Index
- */
-MLXSW_ITEM32(reg, smid, swid, 0x00, 24, 8);
-
-/* reg_smid_mid
- * Multicast identifier - global identifier that represents the multicast group
- * across all devices
- * Access: Index
- */
-MLXSW_ITEM32(reg, smid, mid, 0x00, 0, 16);
-
-/* reg_smid_port
- * Local port memebership (1 bit per port).
- * Access: RW
- */
-MLXSW_ITEM_BIT_ARRAY(reg, smid, port, 0x20, 0x20, 1);
-
-/* reg_smid_port_mask
- * Local port mask (1 bit per port).
- * Access: W
- */
-MLXSW_ITEM_BIT_ARRAY(reg, smid, port_mask, 0x220, 0x20, 1);
-
-static inline void mlxsw_reg_smid_pack(char *payload, u16 mid)
-{
-	MLXSW_REG_ZERO(smid, payload);
-	mlxsw_reg_smid_swid_set(payload, 0);
-	mlxsw_reg_smid_mid_set(payload, mid);
-	mlxsw_reg_smid_port_set(payload, MLXSW_PORT_CPU_PORT, 1);
-	mlxsw_reg_smid_port_mask_set(payload, MLXSW_PORT_CPU_PORT, 1);
-}
-
 /* SSPR - Switch System Port Record Register
  * -----------------------------------------
  * Configures the system port to local port mapping.
@@ -1272,8 +1221,6 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SGCR";
 	case MLXSW_REG_SPAD_ID:
 		return "SPAD";
-	case MLXSW_REG_SMID_ID:
-		return "SMID";
 	case MLXSW_REG_SSPR_ID:
 		return "SSPR";
 	case MLXSW_REG_SPMS_ID:
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 633f3e7..4dadc46 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1371,20 +1371,9 @@ static int mlxsw_sx_flood_init(struct mlxsw_sx *mlxsw_sx)
 {
 	char sfgc_pl[MLXSW_REG_SFGC_LEN];
 	char sgcr_pl[MLXSW_REG_SGCR_LEN];
-	char *smid_pl;
 	char *sftr_pl;
 	int err;
 
-	/* Due to FW bug, we must configure SMID. */
-	smid_pl = kmalloc(MLXSW_REG_SMID_LEN, GFP_KERNEL);
-	if (!smid_pl)
-		return -ENOMEM;
-	mlxsw_reg_smid_pack(smid_pl, MLXSW_PORT_MID);
-	err = mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(smid), smid_pl);
-	kfree(smid_pl);
-	if (err)
-		return err;
-
 	/* Configure a flooding table, which includes only CPU port. */
 	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
 	if (!sftr_pl)
-- 
1.9.3
