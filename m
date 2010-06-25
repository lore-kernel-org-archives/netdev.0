From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/6] cnic: Unify IRQ code for all hardware
 types.
Date: Thu, 24 Jun 2010 17:58:38 -0700
Message-ID: <1277427522-17306-2-git-send-email-mchan@broadcom.com>
References: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3199 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754029Ab0FYA4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 20:56:19 -0400
In-Reply-To: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By creating a common cnic_doirq().

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   33 ++++++++++++++++++++-------------
 1 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 23395fa..bd92a24 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2188,6 +2188,9 @@ static void cnic_chk_pkt_rings(struct cnic_local *cp)
 	u16 tx_cons = *cp->tx_cons_ptr;
 	int comp = 0;
 
+	if (!test_bit(CNIC_F_CNIC_UP, &cp->dev->flags))
+		return;
+
 	if (cp->tx_cons != tx_cons || cp->rx_cons != rx_cons) {
 		if (test_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags))
 			comp = cnic_l2_completion(cp);
@@ -2284,20 +2287,28 @@ done:
 		BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID | cp->last_status_idx);
 }
 
+static void cnic_doirq(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u16 prod = cp->kcq_prod_idx & MAX_KCQ_IDX;
+
+	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags))) {
+		prefetch(cp->status_blk.gen);
+		prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
+
+		tasklet_schedule(&cp->cnic_irq_task);
+	}
+}
+
 static irqreturn_t cnic_irq(int irq, void *dev_instance)
 {
 	struct cnic_dev *dev = dev_instance;
 	struct cnic_local *cp = dev->cnic_priv;
-	u16 prod = cp->kcq_prod_idx & MAX_KCQ_IDX;
 
 	if (cp->ack_int)
 		cp->ack_int(dev);
 
-	prefetch(cp->status_blk.gen);
-	prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
-
-	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags)))
-		tasklet_schedule(&cp->cnic_irq_task);
+	cnic_doirq(dev);
 
 	return IRQ_HANDLED;
 }
@@ -2373,15 +2384,11 @@ static int cnic_service_bnx2x(void *data, void *status_blk)
 {
 	struct cnic_dev *dev = data;
 	struct cnic_local *cp = dev->cnic_priv;
-	u16 prod = cp->kcq_prod_idx & MAX_KCQ_IDX;
 
-	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags))) {
-		prefetch(cp->status_blk.bnx2x);
-		prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
+	if (!(cp->ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX))
+		cnic_doirq(dev);
 
-		tasklet_schedule(&cp->cnic_irq_task);
-		cnic_chk_pkt_rings(cp);
-	}
+	cnic_chk_pkt_rings(cp);
 
 	return 0;
 }
-- 
1.6.4.GIT


