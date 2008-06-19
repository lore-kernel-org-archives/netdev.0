From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/8] bnx2: Use one handler for all MSI-X vectors.
Date: Wed, 18 Jun 2008 17:25:28 -0700
Message-ID: <1213835132-5698-5-git-send-email-mchan@broadcom.com>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2163 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756264AbYFSAXr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 20:23:47 -0400
In-Reply-To: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the same MSI-X handler to schedule NAPI.  Change the dev_instance
void pointer to the bnx2_napi struct instead so we can have the proper
context for each MSI-X vector.

Add a new bnx2_poll_msix() that is optimized for handling MSI-X
NAPI polling of rx/tx work only.  Remove the old bnx2_tx_poll() that
is no longer needed.  Each MSI-X vector handles 1 tx and 1 rx ring.
The first vector handles link events as well.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   99 +++++++++++++++++++++-------------------------------
 1 files changed, 40 insertions(+), 59 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index cc70bdb..587d6bc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2996,9 +2996,9 @@ next_rx:
 static irqreturn_t
 bnx2_msi(int irq, void *dev_instance)
 {
-	struct net_device *dev = dev_instance;
-	struct bnx2 *bp = netdev_priv(dev);
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	struct bnx2_napi *bnapi = dev_instance;
+	struct bnx2 *bp = bnapi->bp;
+	struct net_device *dev = bp->dev;
 
 	prefetch(bnapi->status_blk.msi);
 	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
@@ -3017,9 +3017,9 @@ bnx2_msi(int irq, void *dev_instance)
 static irqreturn_t
 bnx2_msi_1shot(int irq, void *dev_instance)
 {
-	struct net_device *dev = dev_instance;
-	struct bnx2 *bp = netdev_priv(dev);
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	struct bnx2_napi *bnapi = dev_instance;
+	struct bnx2 *bp = bnapi->bp;
+	struct net_device *dev = bp->dev;
 
 	prefetch(bnapi->status_blk.msi);
 
@@ -3035,9 +3035,9 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 static irqreturn_t
 bnx2_interrupt(int irq, void *dev_instance)
 {
-	struct net_device *dev = dev_instance;
-	struct bnx2 *bp = netdev_priv(dev);
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	struct bnx2_napi *bnapi = dev_instance;
+	struct bnx2 *bp = bnapi->bp;
+	struct net_device *dev = bp->dev;
 	struct status_block *sblk = bnapi->status_blk.msi;
 
 	/* When using INTx, it is possible for the interrupt to arrive
@@ -3072,23 +3072,6 @@ bnx2_interrupt(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t
-bnx2_tx_msix(int irq, void *dev_instance)
-{
-	struct net_device *dev = dev_instance;
-	struct bnx2 *bp = netdev_priv(dev);
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[BNX2_TX_VEC];
-
-	prefetch(bnapi->status_blk.msix);
-
-	/* Return here if interrupt is disabled. */
-	if (unlikely(atomic_read(&bp->intr_sem) != 0))
-		return IRQ_HANDLED;
-
-	netif_rx_schedule(dev, &bnapi->napi);
-	return IRQ_HANDLED;
-}
-
 static inline int
 bnx2_has_fast_work(struct bnx2_napi *bnapi)
 {
@@ -3119,30 +3102,6 @@ bnx2_has_work(struct bnx2_napi *bnapi)
 	return 0;
 }
 
-static int bnx2_tx_poll(struct napi_struct *napi, int budget)
-{
-	struct bnx2_napi *bnapi = container_of(napi, struct bnx2_napi, napi);
-	struct bnx2 *bp = bnapi->bp;
-	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
-	int work_done = 0;
-	struct status_block_msix *sblk = bnapi->status_blk.msix;
-
-	do {
-		work_done += bnx2_tx_int(bp, bnapi, budget - work_done);
-		if (unlikely(work_done >= budget))
-			return work_done;
-
-		bnapi->last_status_idx = sblk->status_idx;
-		rmb();
-	} while (bnx2_get_hw_tx_cons(bnapi) != txr->hw_tx_cons);
-
-	netif_rx_complete(bp->dev, napi);
-	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
-	       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-	       bnapi->last_status_idx);
-	return work_done;
-}
-
 static int bnx2_poll_link(struct bnx2 *bp, struct bnx2_napi *bnapi)
 {
 	struct status_block *sblk = bnapi->status_blk.msi;
@@ -3178,6 +3137,33 @@ static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 	return work_done;
 }
 
+static int bnx2_poll_msix(struct napi_struct *napi, int budget)
+{
+	struct bnx2_napi *bnapi = container_of(napi, struct bnx2_napi, napi);
+	struct bnx2 *bp = bnapi->bp;
+	int work_done = 0;
+	struct status_block_msix *sblk = bnapi->status_blk.msix;
+
+	while (1) {
+		work_done = bnx2_poll_work(bp, bnapi, work_done, budget);
+		if (unlikely(work_done >= budget))
+			break;
+
+		bnapi->last_status_idx = sblk->status_idx;
+		/* status idx must be read before checking for more work. */
+		rmb();
+		if (likely(!bnx2_has_fast_work(bnapi))) {
+
+			netif_rx_complete(bp->dev, napi);
+			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
+			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+			       bnapi->last_status_idx);
+			break;
+		}
+	}
+	return work_done;
+}
+
 static int bnx2_poll(struct napi_struct *napi, int budget)
 {
 	struct bnx2_napi *bnapi = container_of(napi, struct bnx2_napi, napi);
@@ -5636,7 +5622,6 @@ bnx2_restart_timer:
 static int
 bnx2_request_irq(struct bnx2 *bp)
 {
-	struct net_device *dev = bp->dev;
 	unsigned long flags;
 	struct bnx2_irq *irq;
 	int rc = 0, i;
@@ -5649,7 +5634,7 @@ bnx2_request_irq(struct bnx2 *bp)
 	for (i = 0; i < bp->irq_nvecs; i++) {
 		irq = &bp->irq_tbl[i];
 		rc = request_irq(irq->vector, irq->handler, flags, irq->name,
-				 dev);
+				 &bp->bnx2_napi[i]);
 		if (rc)
 			break;
 		irq->requested = 1;
@@ -5660,14 +5645,13 @@ bnx2_request_irq(struct bnx2 *bp)
 static void
 bnx2_free_irq(struct bnx2 *bp)
 {
-	struct net_device *dev = bp->dev;
 	struct bnx2_irq *irq;
 	int i;
 
 	for (i = 0; i < bp->irq_nvecs; i++) {
 		irq = &bp->irq_tbl[i];
 		if (irq->requested)
-			free_irq(irq->vector, dev);
+			free_irq(irq->vector, &bp->bnx2_napi[i]);
 		irq->requested = 0;
 	}
 	if (bp->flags & BNX2_FLAG_USING_MSI)
@@ -5694,10 +5678,7 @@ bnx2_enable_msix(struct bnx2 *bp)
 		msix_ent[i].vector = 0;
 
 		strcpy(bp->irq_tbl[i].name, bp->dev->name);
-		if (i == 0)
-			bp->irq_tbl[i].handler = bnx2_msi_1shot;
-		else
-			bp->irq_tbl[i].handler = bnx2_tx_msix;
+		bp->irq_tbl[i].handler = bnx2_msi_1shot;
 	}
 
 	rc = pci_enable_msix(bp->pdev, msix_ent, BNX2_MAX_MSIX_VEC);
@@ -7567,7 +7548,7 @@ bnx2_init_napi(struct bnx2 *bp)
 		if (i == 0)
 			poll = bnx2_poll;
 		else
-			poll = bnx2_tx_poll;
+			poll = bnx2_poll_msix;
 
 		netif_napi_add(bp->dev, &bp->bnx2_napi[i].napi, poll, 64);
 		bnapi->bp = bp;
-- 
1.5.5.GIT



