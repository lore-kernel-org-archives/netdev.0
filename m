From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/3] chelsio: NAPI speed improvement
Date: Fri, 15 Dec 2006 11:07:18 -0800
Message-ID: <20061215190813.718242000@osdl.org>
References: <20061215190716.956791000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:36266 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233AbWLOTMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 14:12:45 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=chelsio-napi2.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Speedup and cleanup the receive processing by eliminating the
mmio read and a lock round trip.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/chelsio/sge.c |   82 ++++++++++++++++++++--------------------------
 1 file changed, 37 insertions(+), 45 deletions(-)

--- linux-2.6.20-rc1.orig/drivers/net/chelsio/sge.c
+++ linux-2.6.20-rc1/drivers/net/chelsio/sge.c
@@ -1576,6 +1576,14 @@ static int process_responses(struct adap
 	return budget;
 }
 
+static inline int responses_pending(const struct adapter *adapter)
+{
+	const struct respQ *Q = &adapter->sge->respQ;
+	const struct respQ_e *e = &Q->entries[Q->cidx];
+
+	return (e->GenerationBit == Q->genbit);
+}
+
 #ifdef CONFIG_CHELSIO_T1_NAPI
 /*
  * A simpler version of process_responses() that handles only pure (i.e.,
@@ -1585,13 +1593,16 @@ static int process_responses(struct adap
  * which the caller must ensure is a valid pure response.  Returns 1 if it
  * encounters a valid data-carrying response, 0 otherwise.
  */
-static int process_pure_responses(struct adapter *adapter, struct respQ_e *e)
+static int process_pure_responses(struct adapter *adapter)
 {
 	struct sge *sge = adapter->sge;
 	struct respQ *q = &sge->respQ;
+	struct respQ_e *e = &q->entries[q->cidx];
 	unsigned int flags = 0;
 	unsigned int cmdq_processed[SGE_CMDQ_N] = {0, 0};
 
+	if (e->DataValid)
+		return 1;
 	do {
 		flags |= e->Qsleeping;
 
@@ -1627,22 +1638,17 @@ static int process_pure_responses(struct
 int t1_poll(struct net_device *dev, int *budget)
 {
 	struct adapter *adapter = dev->priv;
-	int effective_budget = min(*budget, dev->quota);
-	int work_done = process_responses(adapter, effective_budget);
+	int work_done;
 
+	work_done = process_responses(adapter, min(*budget, dev->quota));
 	*budget -= work_done;
 	dev->quota -= work_done;
 
-	if (work_done >= effective_budget)
+	if (unlikely(responses_pending(adapter)))
 		return 1;
 
- 	spin_lock_irq(&adapter->async_lock);
-	__netif_rx_complete(dev);
+	netif_rx_complete(dev);
 	writel(adapter->sge->respQ.cidx, adapter->regs + A_SG_SLEEPING);
-	writel(adapter->slow_intr_mask | F_PL_INTR_SGE_DATA,
-	       adapter->regs + A_PL_ENABLE);
- 	spin_unlock_irq(&adapter->async_lock);
-
 	return 0;
 }
 
@@ -1652,44 +1658,34 @@ int t1_poll(struct net_device *dev, int 
 irqreturn_t t1_interrupt(int irq, void *data)
 {
 	struct adapter *adapter = data;
- 	struct net_device *dev = adapter->sge->netdev;
 	struct sge *sge = adapter->sge;
- 	u32 cause;
-	int handled = 0;
+	int handled;
 
-	cause = readl(adapter->regs + A_PL_CAUSE);
-	if (cause == 0 || cause == ~0)
-		return IRQ_NONE;
+	if (likely(responses_pending(adapter))) {
+		struct net_device *dev = sge->netdev;
 
-	spin_lock(&adapter->async_lock);
- 	if (cause & F_PL_INTR_SGE_DATA) {
-		struct respQ *q = &adapter->sge->respQ;
-		struct respQ_e *e = &q->entries[q->cidx];
-
- 		handled = 1;
- 		writel(F_PL_INTR_SGE_DATA, adapter->regs + A_PL_CAUSE);
-
-		if (e->GenerationBit == q->genbit &&
-		    __netif_rx_schedule_prep(dev)) {
-			if (e->DataValid || process_pure_responses(adapter, e)) {
-				/* mask off data IRQ */
-				writel(adapter->slow_intr_mask,
-				       adapter->regs + A_PL_ENABLE);
-				__netif_rx_schedule(sge->netdev);
-				goto unlock;
-			}
-			/* no data, no NAPI needed */
-			netif_poll_enable(dev);
+		writel(F_PL_INTR_SGE_DATA, adapter->regs + A_PL_CAUSE);
 
+		if (__netif_rx_schedule_prep(dev)) {
+			if (process_pure_responses(adapter)) {
+				__netif_rx_schedule(dev);
+			} else {
+				/* no data, no NAPI needed */
+				writel(sge->respQ.cidx,
+				       adapter->regs + A_SG_SLEEPING);
+				netif_poll_enable(dev);	/* undo schedule_prep */
+			}
 		}
-		writel(q->cidx, adapter->regs + A_SG_SLEEPING);
-	} else
-		handled = t1_slow_intr_handler(adapter);
+		return IRQ_HANDLED;
+	}
+
+	spin_lock(&adapter->async_lock);
+	handled = t1_slow_intr_handler(adapter);
+	spin_unlock(&adapter->async_lock);
 
 	if (!handled)
 		sge->stats.unhandled_irqs++;
-unlock:
-	spin_unlock(&adapter->async_lock);
+
 	return IRQ_RETVAL(handled != 0);
 }
 
@@ -1712,17 +1708,13 @@ unlock:
 irqreturn_t t1_interrupt(int irq, void *cookie)
 {
 	int work_done;
-	struct respQ_e *e;
 	struct adapter *adapter = cookie;
-	struct respQ *Q = &adapter->sge->respQ;
 
 	spin_lock(&adapter->async_lock);
-	e = &Q->entries[Q->cidx];
-	prefetch(e);
 
 	writel(F_PL_INTR_SGE_DATA, adapter->regs + A_PL_CAUSE);
 
-	if (likely(e->GenerationBit == Q->genbit))
+	if (likely(responses_pending(adapter))
 		work_done = process_responses(adapter, -1);
 	else
 		work_done = t1_slow_intr_handler(adapter);

-- 

