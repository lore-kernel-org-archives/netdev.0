From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 01/13] bnx2x: revised and corrected SPIO access
Date: Sun, 2 Dec 2012 16:05:45 +0200
Message-ID: <1354457157-4730-2-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2488 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068Ab2LBOFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:04 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed naming convention of SPIO macros, and prevented access to invalid SPIOs.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   43 ++++++++++------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |   10 +++++
 2 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b4659c4..5a22e19 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2032,40 +2032,39 @@ int bnx2x_set_gpio_int(struct bnx2x *bp, int gpio_num, u32 mode, u8 port)
 	return 0;
 }
 
-static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
+static int bnx2x_set_spio(struct bnx2x *bp, int spio, u32 mode)
 {
-	u32 spio_mask = (1 << spio_num);
 	u32 spio_reg;
 
-	if ((spio_num < MISC_REGISTERS_SPIO_4) ||
-	    (spio_num > MISC_REGISTERS_SPIO_7)) {
-		BNX2X_ERR("Invalid SPIO %d\n", spio_num);
+	/* Only 2 SPIOs are configurable */
+	if ((spio != MISC_SPIO_SPIO4) && (spio != MISC_SPIO_SPIO5)) {
+		BNX2X_ERR("Invalid SPIO 0x%x\n", spio);
 		return -EINVAL;
 	}
 
 	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_SPIO);
 	/* read SPIO and mask except the float bits */
-	spio_reg = (REG_RD(bp, MISC_REG_SPIO) & MISC_REGISTERS_SPIO_FLOAT);
+	spio_reg = (REG_RD(bp, MISC_REG_SPIO) & MISC_SPIO_FLOAT);
 
 	switch (mode) {
-	case MISC_REGISTERS_SPIO_OUTPUT_LOW:
-		DP(NETIF_MSG_HW, "Set SPIO %d -> output low\n", spio_num);
+	case MISC_SPIO_OUTPUT_LOW:
+		DP(NETIF_MSG_HW, "Set SPIO 0x%x -> output low\n", spio);
 		/* clear FLOAT and set CLR */
-		spio_reg &= ~(spio_mask << MISC_REGISTERS_SPIO_FLOAT_POS);
-		spio_reg |=  (spio_mask << MISC_REGISTERS_SPIO_CLR_POS);
+		spio_reg &= ~(spio << MISC_SPIO_FLOAT_POS);
+		spio_reg |=  (spio << MISC_SPIO_CLR_POS);
 		break;
 
-	case MISC_REGISTERS_SPIO_OUTPUT_HIGH:
-		DP(NETIF_MSG_HW, "Set SPIO %d -> output high\n", spio_num);
+	case MISC_SPIO_OUTPUT_HIGH:
+		DP(NETIF_MSG_HW, "Set SPIO 0x%x -> output high\n", spio);
 		/* clear FLOAT and set SET */
-		spio_reg &= ~(spio_mask << MISC_REGISTERS_SPIO_FLOAT_POS);
-		spio_reg |=  (spio_mask << MISC_REGISTERS_SPIO_SET_POS);
+		spio_reg &= ~(spio << MISC_SPIO_FLOAT_POS);
+		spio_reg |=  (spio << MISC_SPIO_SET_POS);
 		break;
 
-	case MISC_REGISTERS_SPIO_INPUT_HI_Z:
-		DP(NETIF_MSG_HW, "Set SPIO %d -> input\n", spio_num);
+	case MISC_SPIO_INPUT_HI_Z:
+		DP(NETIF_MSG_HW, "Set SPIO 0x%x -> input\n", spio);
 		/* set FLOAT */
-		spio_reg |= (spio_mask << MISC_REGISTERS_SPIO_FLOAT_POS);
+		spio_reg |= (spio << MISC_SPIO_FLOAT_POS);
 		break;
 
 	default:
@@ -6196,18 +6195,16 @@ static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
 		return;
 
 	/* Fan failure is indicated by SPIO 5 */
-	bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
-		       MISC_REGISTERS_SPIO_INPUT_HI_Z);
+	bnx2x_set_spio(bp, MISC_SPIO_SPIO5, MISC_SPIO_INPUT_HI_Z);
 
 	/* set to active low mode */
 	val = REG_RD(bp, MISC_REG_SPIO_INT);
-	val |= ((1 << MISC_REGISTERS_SPIO_5) <<
-					MISC_REGISTERS_SPIO_INT_OLD_SET_POS);
+	val |= (MISC_SPIO_SPIO5 << MISC_SPIO_INT_OLD_SET_POS);
 	REG_WR(bp, MISC_REG_SPIO_INT, val);
 
 	/* enable interrupt to signal the IGU */
 	val = REG_RD(bp, MISC_REG_SPIO_EVENT_EN);
-	val |= (1 << MISC_REGISTERS_SPIO_5);
+	val |= MISC_SPIO_SPIO5;
 	REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
 }
 
@@ -6969,7 +6966,7 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 
 	/* If SPIO5 is set to generate interrupts, enable it for this port */
 	val = REG_RD(bp, MISC_REG_SPIO_EVENT_EN);
-	if (val & (1 << MISC_REGISTERS_SPIO_5)) {
+	if (val & MISC_SPIO_SPIO5) {
 		u32 reg_addr = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
 				       MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
 		val = REG_RD(bp, reg_addr);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index f8d432a..87cf37c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -5942,6 +5942,16 @@
 #define MISC_REGISTERS_SPIO_OUTPUT_HIGH 			 1
 #define MISC_REGISTERS_SPIO_OUTPUT_LOW				 0
 #define MISC_REGISTERS_SPIO_SET_POS				 8
+#define MISC_SPIO_CLR_POS					 16
+#define MISC_SPIO_FLOAT					 (0xffL<<24)
+#define MISC_SPIO_FLOAT_POS					 24
+#define MISC_SPIO_INPUT_HI_Z					 2
+#define MISC_SPIO_INT_OLD_SET_POS				 16
+#define MISC_SPIO_OUTPUT_HIGH					 1
+#define MISC_SPIO_OUTPUT_LOW					 0
+#define MISC_SPIO_SET_POS					 8
+#define MISC_SPIO_SPIO4					 0x10
+#define MISC_SPIO_SPIO5					 0x20
 #define HW_LOCK_MAX_RESOURCE_VALUE				 31
 #define HW_LOCK_RESOURCE_DCBX_ADMIN_MIB				 13
 #define HW_LOCK_RESOURCE_DRV_FLAGS				 10
-- 
1.7.1
