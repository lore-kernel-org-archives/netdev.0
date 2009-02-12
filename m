From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 05/41]bnx2x: Disabling interrupts after iSCSI-boot
Date: Thu, 12 Feb 2009 20:36:23 +0200
Message-ID: <1234463783.1863.136.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4954 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758246AbZBLShX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 05/41]bnx2x: Disabling interrupts after iSCSI-boot
Before initializing the chip after iSCSI boot, the interrupts of the function
that was used to boot must be disabled. That means that the driver needs to set
the chip as if it is the iSCSI PCI function - this bug is exposed only with MSI

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   61 ++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/bnx2x_reg.h  |   13 ++++++++++
 2 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 312f652..ea7d86d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7006,6 +7006,64 @@ reset_task_exit:
  * Init service functions
  */
 
+static inline u32 bnx2x_get_pretend_reg(struct bnx2x *bp, int func)
+{
+	switch (func) {
+	case 0: return PXP2_REG_PGL_PRETEND_FUNC_F0;
+	case 1:	return PXP2_REG_PGL_PRETEND_FUNC_F1;
+	case 2:	return PXP2_REG_PGL_PRETEND_FUNC_F2;
+	case 3:	return PXP2_REG_PGL_PRETEND_FUNC_F3;
+	case 4:	return PXP2_REG_PGL_PRETEND_FUNC_F4;
+	case 5:	return PXP2_REG_PGL_PRETEND_FUNC_F5;
+	case 6:	return PXP2_REG_PGL_PRETEND_FUNC_F6;
+	case 7:	return PXP2_REG_PGL_PRETEND_FUNC_F7;
+	default:
+		BNX2X_ERR("Unsupported function index: %d\n", func);
+		return (u32)(-1);
+	}
+}
+
+static void bnx2x_undi_int_disable_e1h(struct bnx2x *bp, int orig_func)
+{
+	u32 reg = bnx2x_get_pretend_reg(bp, orig_func), new_val;
+
+	/* Flush all outstanding writes */
+	mmiowb();
+
+	/* Pretend to be function 0 */
+	REG_WR(bp, reg, 0);
+	/* Flush the GRC transaction (in the chip) */
+	new_val = REG_RD(bp, reg);
+	if (new_val != 0) {
+		BNX2X_ERR("Hmmm... Pretend register wasn't updated: (0,%d)!\n",
+			  new_val);
+		BUG();
+	}
+
+	/* From now we are in the "like-E1" mode */
+	bnx2x_int_disable(bp);
+
+	/* Flush all outstanding writes */
+	mmiowb();
+
+	/* Restore the original funtion settings */
+	REG_WR(bp, reg, orig_func);
+	new_val = REG_RD(bp, reg);
+	if (new_val != orig_func) {
+		BNX2X_ERR("Hmmm... Pretend register wasn't updated: (%d,%d)!\n",
+			  orig_func, new_val);
+		BUG();
+	}
+}
+
+static inline void bnx2x_undi_int_disable(struct bnx2x *bp, int func)
+{
+	if (CHIP_IS_E1H(bp))
+		bnx2x_undi_int_disable_e1h(bp, func);
+	else
+		bnx2x_int_disable(bp);
+}
+
 static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 {
 	u32 val;
@@ -7056,8 +7114,7 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			/* now it's safe to release the lock */
 			bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 
-			REG_WR(bp, (BP_PORT(bp) ? HC_REG_CONFIG_1 :
-				    HC_REG_CONFIG_0), 0x1000);
+			bnx2x_undi_int_disable(bp, func);
 
 			/* close input traffic and wait for it */
 			/* Do not rcv packets to BRB */
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 0be77c5..b654d5d 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -2061,6 +2061,19 @@
 #define PXP2_REG_PGL_INT_XSDM_5 				 0x1204e8
 #define PXP2_REG_PGL_INT_XSDM_6 				 0x1204ec
 #define PXP2_REG_PGL_INT_XSDM_7 				 0x1204f0
+/* [RW 3] this field allows one function to pretend being another function
+   when accessing any BAR mapped resource within the device. the value of
+   the field is the number of the function that will be accessed
+   effectively. after software write to this bit it must read it in order to
+   know that the new value is updated */
+#define PXP2_REG_PGL_PRETEND_FUNC_F0				 0x120674
+#define PXP2_REG_PGL_PRETEND_FUNC_F1				 0x120678
+#define PXP2_REG_PGL_PRETEND_FUNC_F2				 0x12067c
+#define PXP2_REG_PGL_PRETEND_FUNC_F3				 0x120680
+#define PXP2_REG_PGL_PRETEND_FUNC_F4				 0x120684
+#define PXP2_REG_PGL_PRETEND_FUNC_F5				 0x120688
+#define PXP2_REG_PGL_PRETEND_FUNC_F6				 0x12068c
+#define PXP2_REG_PGL_PRETEND_FUNC_F7				 0x120690
 /* [R 1] this bit indicates that a read request was blocked because of
    bus_master_en was deasserted */
 #define PXP2_REG_PGL_READ_BLOCKED				 0x120568
-- 
1.5.4.3




