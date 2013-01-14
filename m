From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 08/10] bnx2x: Clean previous IGU status before
 ack
Date: Mon, 14 Jan 2013 17:11:48 +0200
Message-ID: <1358176310-31504-9-git-send-email-yuvalmin@broadcom.com>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1999 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757245Ab3ANQKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 11:10:06 -0500
In-Reply-To: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When enabling interrupts, acknowledge the interrupt only
after configuring the IGU to the correct interrupt mode
(otherwise it would dirty selftests)

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 17 +++++++++++------
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 53a2c0e..a6f4140 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1656,7 +1656,6 @@ static int bnx2x_setup_irqs(struct bnx2x *bp)
 		if (rc)
 			return rc;
 	} else {
-		bnx2x_ack_int(bp);
 		rc = bnx2x_req_irq(bp);
 		if (rc) {
 			BNX2X_ERR("IRQ request failed  rc %d, aborting\n", rc);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b75049e..ac09abd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1528,26 +1528,31 @@ static void bnx2x_igu_int_enable(struct bnx2x *bp)
 	if (msix) {
 		val &= ~(IGU_PF_CONF_INT_LINE_EN |
 			 IGU_PF_CONF_SINGLE_ISR_EN);
-		val |= (IGU_PF_CONF_FUNC_EN |
-			IGU_PF_CONF_MSI_MSIX_EN |
+		val |= (IGU_PF_CONF_MSI_MSIX_EN |
 			IGU_PF_CONF_ATTN_BIT_EN);
 
 		if (single_msix)
 			val |= IGU_PF_CONF_SINGLE_ISR_EN;
 	} else if (msi) {
 		val &= ~IGU_PF_CONF_INT_LINE_EN;
-		val |= (IGU_PF_CONF_FUNC_EN |
-			IGU_PF_CONF_MSI_MSIX_EN |
+		val |= (IGU_PF_CONF_MSI_MSIX_EN |
 			IGU_PF_CONF_ATTN_BIT_EN |
 			IGU_PF_CONF_SINGLE_ISR_EN);
 	} else {
 		val &= ~IGU_PF_CONF_MSI_MSIX_EN;
-		val |= (IGU_PF_CONF_FUNC_EN |
-			IGU_PF_CONF_INT_LINE_EN |
+		val |= (IGU_PF_CONF_INT_LINE_EN |
 			IGU_PF_CONF_ATTN_BIT_EN |
 			IGU_PF_CONF_SINGLE_ISR_EN);
 	}
 
+	/* Clean previous status - need to configure igu prior to ack*/
+	if ((!msix) || single_msix) {
+		REG_WR(bp, IGU_REG_PF_CONFIGURATION, val);
+		bnx2x_ack_int(bp);
+	}
+
+	val |= IGU_PF_CONF_FUNC_EN;
+
 	DP(NETIF_MSG_IFUP, "write 0x%x to IGU  mode %s\n",
 	   val, (msix ? "MSI-X" : (msi ? "MSI" : "INTx")));
 
-- 
1.8.1.227.g44fe835
