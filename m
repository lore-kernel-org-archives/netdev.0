From: Jing Huang <huangj@brocade.com>
Subject: [PATCH 5/7] bna: Remove tx tasklet
Date: Wed, 4 Apr 2012 08:43:48 -0700
Message-ID: <1333554228-22757-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <AdapterLinuxOpenSrcExtTeam@brocade.com>,
	Jing Huang <huangj@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:36619 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932288Ab2DDPoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 11:44:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The scheduling of tasklet and keeping the interrupts enabled makes interrupt
reduntant. 20% of the Tx interrupts have nothing left to process or could not
process as Tx tasklet was running.

Signed-off-by: Jing Huang <huangj@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |   73 +-----------------------------
 drivers/net/ethernet/brocade/bna/bnad.h |    1 -
 2 files changed, 3 insertions(+), 71 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 032a306..f1103e6 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -185,7 +185,6 @@ bnad_free_all_txbufs(struct bnad *bnad,
  * bnad_free_txbufs : Frees the Tx bufs on Tx completion
  * Can be called in a) Interrupt context
  *		    b) Sending context
- *		    c) Tasklet context
  */
 static u32
 bnad_free_txbufs(struct bnad *bnad,
@@ -197,13 +196,7 @@ bnad_free_txbufs(struct bnad *bnad,
 	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff		*skb;
 
-	/*
-	 * Just return if TX is stopped. This check is useful
-	 * when bnad_free_txbufs() runs out of a tasklet scheduled
-	 * before bnad_cb_tx_cleanup() cleared BNAD_TXQ_TX_STARTED bit
-	 * but this routine runs actually after the cleanup has been
-	 * executed.
-	 */
+	/* Just return if TX is stopped */
 	if (!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))
 		return 0;
 
@@ -242,55 +235,6 @@ bnad_free_txbufs(struct bnad *bnad,
 	return sent_packets;
 }
 
-/* Tx Free Tasklet function */
-/* Frees for all the tcb's in all the Tx's */
-/*
- * Scheduled from sending context, so that
- * the fat Tx lock is not held for too long
- * in the sending context.
- */
-static void
-bnad_tx_free_tasklet(unsigned long bnad_ptr)
-{
-	struct bnad *bnad = (struct bnad *)bnad_ptr;
-	struct bna_tcb *tcb;
-	u32		acked = 0;
-	int			i, j;
-
-	for (i = 0; i < bnad->num_tx; i++) {
-		for (j = 0; j < bnad->num_txq_per_tx; j++) {
-			tcb = bnad->tx_info[i].tcb[j];
-			if (!tcb)
-				continue;
-			if (((u16) (*tcb->hw_consumer_index) !=
-				tcb->consumer_index) &&
-				(!test_and_set_bit(BNAD_TXQ_FREE_SENT,
-						  &tcb->flags))) {
-				acked = bnad_free_txbufs(bnad, tcb);
-				if (likely(test_bit(BNAD_TXQ_TX_STARTED,
-					&tcb->flags)))
-					bna_ib_ack(tcb->i_dbell, acked);
-				smp_mb__before_clear_bit();
-				clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
-			}
-			if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED,
-						&tcb->flags)))
-				continue;
-			if (netif_queue_stopped(bnad->netdev)) {
-				if (acked && netif_carrier_ok(bnad->netdev) &&
-					BNA_QE_FREE_CNT(tcb, tcb->q_depth) >=
-						BNAD_NETIF_WAKE_THRESHOLD) {
-					netif_wake_queue(bnad->netdev);
-					/* TODO */
-					/* Counters for individual TxQs? */
-					BNAD_UPDATE_CTR(bnad,
-						netif_queue_wakeup);
-				}
-			}
-		}
-	}
-}
-
 static u32
 bnad_tx(struct bnad *bnad, struct bna_tcb *tcb)
 {
@@ -1789,9 +1733,6 @@ bnad_cleanup_tx(struct bnad *bnad, u32 tx_id)
 		bnad_tx_msix_unregister(bnad, tx_info,
 			bnad->num_txq_per_tx);
 
-	if (0 == tx_id)
-		tasklet_kill(&bnad->tx_free_tasklet);
-
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_tx_destroy(tx_info->tx);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -2871,9 +2812,6 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	bna_txq_prod_indx_doorbell(tcb);
 	smp_mb();
 
-	if ((u16) (*tcb->hw_consumer_index) != tcb->consumer_index)
-		tasklet_schedule(&bnad->tx_free_tasklet);
-
 	return NETDEV_TX_OK;
 }
 
@@ -3155,9 +3093,8 @@ bnad_netdev_init(struct bnad *bnad, bool using_dac)
 /*
  * 1. Initialize the bnad structure
  * 2. Setup netdev pointer in pci_dev
- * 3. Initialze Tx free tasklet
- * 4. Initialize no. of TxQ & CQs & MSIX vectors
- * 5. Initialize work queue.
+ * 3. Initialize no. of TxQ & CQs & MSIX vectors
+ * 4. Initialize work queue.
  */
 static int
 bnad_init(struct bnad *bnad,
@@ -3200,9 +3137,6 @@ bnad_init(struct bnad *bnad,
 	bnad->tx_coalescing_timeo = BFI_TX_COALESCING_TIMEO;
 	bnad->rx_coalescing_timeo = BFI_RX_COALESCING_TIMEO;
 
-	tasklet_init(&bnad->tx_free_tasklet, bnad_tx_free_tasklet,
-		     (unsigned long)bnad);
-
 	sprintf(bnad->wq_name, "%s_wq_%d", BNAD_NAME, bnad->id);
 	bnad->work_q = create_singlethread_workqueue(bnad->wq_name);
 
@@ -3345,7 +3279,6 @@ bnad_pci_probe(struct pci_dev *pdev,
 	/*
 	 * Initialize bnad structure
 	 * Setup relation between pci_dev & netdev
-	 * Init Tx free tasklet
 	 */
 	err = bnad_init(bnad, pdev, netdev);
 	if (err)
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index ff129aa..cf1d3ba 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -320,7 +320,6 @@ struct bnad {
 	/* Burnt in MAC address */
 	mac_t			perm_addr;
 
-	struct tasklet_struct	tx_free_tasklet;
 	struct workqueue_struct *work_q;
 
 	/* Statistics */
-- 
1.6.5.2
