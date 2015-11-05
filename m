From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 3/5] bnxt_en: map CAG_REG_LEGACY_INT_STATUS_MASK to GRC window #4
Date: Thu, 5 Nov 2015 16:25:49 -0500
Message-ID: <1446758751-27999-4-git-send-email-mchan@broadcom.com>
References: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jeffrey Huang <huangjw@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:29804 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756992AbbKEVZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:25:53 -0500
In-Reply-To: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

In order to use offset 0x4014 for reading CAG interrupt status,
the actual CAG register must be mapped to GRC bar0 window #4.
Otherwise, the driver is reading garbage. This patch corrects
this issue.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 19 ++++++++++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  4 ++++
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 6c2e0c6..a62deff 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1292,8 +1292,6 @@ static inline int bnxt_has_work(struct bnxt *bp, struct bnxt_cp_ring_info *cpr)
 	return TX_CMP_VALID(txcmp, raw_cons);
 }
 
-#define CAG_LEGACY_INT_STATUS	0x2014
-
 static irqreturn_t bnxt_inta(int irq, void *dev_instance)
 {
 	struct bnxt_napi *bnapi = dev_instance;
@@ -1305,7 +1303,7 @@ static irqreturn_t bnxt_inta(int irq, void *dev_instance)
 	prefetch(&cpr->cp_desc_ring[CP_RING(cons)][CP_IDX(cons)]);
 
 	if (!bnxt_has_work(bp, cpr)) {
-		int_status = readl(bp->bar0 + CAG_LEGACY_INT_STATUS);
+		int_status = readl(bp->bar0 + BNXT_CAG_REG_LEGACY_INT_STATUS);
 		/* return if erroneous interrupt */
 		if (!(int_status & (0x10000 << cpr->cp_ring_struct.fw_ring_id)))
 			return IRQ_NONE;
@@ -4527,10 +4525,25 @@ static int bnxt_update_phy_setting(struct bnxt *bp)
 	return rc;
 }
 
+/* Common routine to pre-map certain register block to different GRC window.
+ * A PF has 16 4K windows and a VF has 4 4K windows. However, only 15 windows
+ * in PF and 3 windows in VF that can be customized to map in different
+ * register blocks.
+ */
+static void bnxt_preset_reg_win(struct bnxt *bp)
+{
+	if (BNXT_PF(bp)) {
+		/* CAG registers map to GRC window #4 */
+		writel(BNXT_CAG_REG_BASE,
+		       bp->bar0 + BNXT_GRCPF_REG_WINDOW_BASE_OUT + 12);
+	}
+}
+
 static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 {
 	int rc = 0;
 
+	bnxt_preset_reg_win(bp);
 	netif_carrier_off(bp->dev);
 	if (irq_re_init) {
 		rc = bnxt_setup_int_mode(bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 5afe65d..674bc51 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -841,6 +841,10 @@ struct bnxt_queue_info {
 	u8	queue_profile;
 };
 
+#define BNXT_GRCPF_REG_WINDOW_BASE_OUT	0x400
+#define BNXT_CAG_REG_LEGACY_INT_STATUS	0x4014
+#define BNXT_CAG_REG_BASE		0x300000
+
 struct bnxt {
 	void __iomem		*bar0;
 	void __iomem		*bar1;
-- 
1.8.3.1
