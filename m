From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 1/6] bnx2x: Add support for Multi-Function UNDI
Date: Mon, 23 Dec 2013 20:44:38 +0200
Message-ID: <1387824283-15687-2-git-send-email-yuvalmin@broadcom.com>
References: <1387824283-15687-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:33513 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433Ab3LWSos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 13:44:48 -0500
In-Reply-To: <1387824283-15687-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the ability for bnx2x to load after UNDI is used in the
preboot environment on a multi-function interface which is not the first
interface of a given device.
Notice a side-effect is that the order by which the functions are probed and
thus interfaces appear might change, as this patch utilizes the EPROBE_DEFER
return value (and mechanism).

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 12 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 83 ++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |  1 +
 4 files changed, 87 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index a1f66e2..f09fde6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2436,7 +2436,8 @@ void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 
 #define GOOD_ME_REG(me_reg) (((me_reg) & ME_REG_VF_VALID) && \
 			    (!((me_reg) & ME_REG_VF_ERR)))
-int bnx2x_nic_load_analyze_req(struct bnx2x *bp, u32 load_code);
+int bnx2x_compare_fw_ver(struct bnx2x *bp, u32 load_code, bool print_err);
+
 /* Congestion management fairness mode */
 #define CMNG_FNS_NONE			0
 #define CMNG_FNS_MINMAX			1
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ec96130..d040ebf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2263,7 +2263,7 @@ static int bnx2x_nic_load_request(struct bnx2x *bp, u32 *load_code)
  * virtualized environments a pf from another VM may have already
  * initialized the device including loading FW
  */
-int bnx2x_nic_load_analyze_req(struct bnx2x *bp, u32 load_code)
+int bnx2x_compare_fw_ver(struct bnx2x *bp, u32 load_code, bool print_err)
 {
 	/* is another pf loaded on this engine? */
 	if (load_code != FW_MSG_CODE_DRV_LOAD_COMMON_CHIP &&
@@ -2282,8 +2282,12 @@ int bnx2x_nic_load_analyze_req(struct bnx2x *bp, u32 load_code)
 
 		/* abort nic load if version mismatch */
 		if (my_fw != loaded_fw) {
-			BNX2X_ERR("bnx2x with FW %x was already loaded which mismatches my %x FW. Aborting\n",
-				  loaded_fw, my_fw);
+			if (print_err)
+				BNX2X_ERR("bnx2x with FW %x was already loaded which mismatches my %x FW. Aborting\n",
+					  loaded_fw, my_fw);
+			else
+				BNX2X_DEV_INFO("bnx2x with FW %x was already loaded which mismatches my %x FW, possibly due to MF UNDI\n",
+					       loaded_fw, my_fw);
 			return -EBUSY;
 		}
 	}
@@ -2598,7 +2602,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 				LOAD_ERROR_EXIT(bp, load_error1);
 
 			/* what did mcp say? */
-			rc = bnx2x_nic_load_analyze_req(bp, load_code);
+			rc = bnx2x_compare_fw_ver(bp, load_code, true);
 			if (rc) {
 				bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
 				LOAD_ERROR_EXIT(bp, load_error2);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 814d0ec..5910413 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9854,6 +9854,64 @@ static void bnx2x_prev_unload_close_mac(struct bnx2x *bp,
 #define BNX2X_PREV_UNDI_BD(val)		((val) >> 16 & 0xffff)
 #define BNX2X_PREV_UNDI_PROD(rcq, bd)	((bd) << 16 | (rcq))
 
+#define BCM_5710_UNDI_FW_MF_MAJOR	(0x07)
+#define BCM_5710_UNDI_FW_MF_MINOR	(0x08)
+#define BCM_5710_UNDI_FW_MF_VERS	(0x05)
+#define BNX2X_PREV_UNDI_MF_PORT(p)	(0x1a150c + ((p) << 4))
+#define BNX2X_PREV_UNDI_MF_FUNC(f)	(0x1a184c + ((f) << 4))
+static bool bnx2x_prev_unload_undi_fw_supports_mf(struct bnx2x *bp)
+{
+	u8 major, minor, version;
+	u32 fw;
+
+	/* Must check that FW is loaded */
+	if (!(REG_RD(bp, MISC_REG_RESET_REG_1) &
+	     MISC_REGISTERS_RESET_REG_1_RST_XSEM)) {
+		BNX2X_DEV_INFO("XSEM is reset - UNDI MF FW is not loaded\n");
+		return false;
+	}
+
+	/* Read Currently loaded FW version */
+	fw = REG_RD(bp, XSEM_REG_PRAM);
+	major = fw & 0xff;
+	minor = (fw >> 0x8) & 0xff;
+	version = (fw >> 0x10) & 0xff;
+	BNX2X_DEV_INFO("Loaded FW: 0x%08x: Major 0x%02x Minor 0x%02x Version 0x%02x\n",
+		       fw, major, minor, version);
+
+	if (major > BCM_5710_UNDI_FW_MF_MAJOR)
+		return true;
+
+	if ((major == BCM_5710_UNDI_FW_MF_MAJOR) &&
+	    (minor > BCM_5710_UNDI_FW_MF_MINOR))
+		return true;
+
+	if ((major == BCM_5710_UNDI_FW_MF_MAJOR) &&
+	    (minor == BCM_5710_UNDI_FW_MF_MINOR) &&
+	    (version >= BCM_5710_UNDI_FW_MF_VERS))
+		return true;
+
+	return false;
+}
+
+static void bnx2x_prev_unload_undi_mf(struct bnx2x *bp)
+{
+	int i;
+
+	/* Due to legacy (FW) code, the first function on each engine has a
+	 * different offset macro from the rest of the functions.
+	 * Setting this for all 8 functions is harmless regardless of whether
+	 * this is actually a multi-function device.
+	 */
+	for (i = 0; i < 2; i++)
+		REG_WR(bp, BNX2X_PREV_UNDI_MF_PORT(i), 1);
+
+	for (i = 2; i < 8; i++)
+		REG_WR(bp, BNX2X_PREV_UNDI_MF_FUNC(i - 2), 1);
+
+	BNX2X_DEV_INFO("UNDI FW (MF) set to discard\n");
+}
+
 static void bnx2x_prev_unload_undi_inc(struct bnx2x *bp, u8 port, u8 inc)
 {
 	u16 rcq, bd;
@@ -10054,7 +10112,7 @@ static int bnx2x_prev_unload_uncommon(struct bnx2x *bp)
 	 * the one required, then FLR will be sufficient to clean any residue
 	 * left by previous driver
 	 */
-	rc = bnx2x_nic_load_analyze_req(bp, FW_MSG_CODE_DRV_LOAD_FUNCTION);
+	rc = bnx2x_compare_fw_ver(bp, FW_MSG_CODE_DRV_LOAD_FUNCTION, false);
 
 	if (!rc) {
 		/* fw version is good */
@@ -10142,10 +10200,17 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 			else
 				timer_count--;
 
-			/* If UNDI resides in memory, manually increment it */
-			if (prev_undi)
+			/* New UNDI FW supports MF and contains better
+			 * cleaning methods - might be redundant but harmless.
+			 */
+			if (bnx2x_prev_unload_undi_fw_supports_mf(bp)) {
+				bnx2x_prev_unload_undi_mf(bp);
+			} else if (prev_undi) {
+				/* If UNDI resides in memory,
+				 * manually increment it
+				 */
 				bnx2x_prev_unload_undi_inc(bp, BP_PORT(bp), 1);
-
+			}
 			udelay(10);
 		}
 
@@ -10265,8 +10330,8 @@ static int bnx2x_prev_unload(struct bnx2x *bp)
 	} while (--time_counter);
 
 	if (!time_counter || rc) {
-		BNX2X_ERR("Failed unloading previous driver, aborting\n");
-		rc = -EBUSY;
+		BNX2X_DEV_INFO("Unloading previous driver did not occur, Possibly due to MF UNDI\n");
+		rc = -EPROBE_DEFER;
 	}
 
 	/* Mark function if its port was used to boot from SAN */
@@ -11636,7 +11701,11 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 							DRV_MSG_SEQ_NUMBER_MASK;
 		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
 
-		bnx2x_prev_unload(bp);
+		rc = bnx2x_prev_unload(bp);
+		if (rc) {
+			bnx2x_free_mem_bp(bp);
+			return rc;
+		}
 	}
 
 	if (CHIP_REV_IS_FPGA(bp))
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 3efbb35..08f8047 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -5932,6 +5932,7 @@
 #define MISC_REGISTERS_RESET_REG_1_RST_NIG			 (0x1<<7)
 #define MISC_REGISTERS_RESET_REG_1_RST_PXP			 (0x1<<26)
 #define MISC_REGISTERS_RESET_REG_1_RST_PXPV			 (0x1<<27)
+#define MISC_REGISTERS_RESET_REG_1_RST_XSEM			 (0x1<<22)
 #define MISC_REGISTERS_RESET_REG_1_SET				 0x584
 #define MISC_REGISTERS_RESET_REG_2_CLEAR			 0x598
 #define MISC_REGISTERS_RESET_REG_2_MSTAT0			 (0x1<<24)
-- 
1.8.1.227.g44fe835
