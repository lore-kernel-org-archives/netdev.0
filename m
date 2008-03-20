From: Roland Dreier <rdreier@cisco.com>
Subject: cxgb3: Fix lockdep problems with sge.reg_lock
Date: Thu, 20 Mar 2008 13:30:48 -0700
Message-ID: <adabq59xhmv.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Divy Le Ray <divy@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Felix Marti <felix@chelsio.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:2736 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760439AbYCTUaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 16:30:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using iWARP with a Chelsio T3 NIC generates the following lockdep warning:

    =================================
    [ INFO: inconsistent lock state ]
    2.6.25-rc6 #50
    ---------------------------------
    inconsistent {softirq-on-W} -> {in-softirq-W} usage.
    swapper/0 [HC0[0]:SC1[1]:HE0:SE0] takes:
     (&adap->sge.reg_lock){-+..}, at: [<ffffffff880e5ee2>] cxgb_offload_ctl+0x3af/0x507 [cxgb3]

The problem is that reg_lock is used with plain spin_lock() in
drivers/net/cxgb3/sge.c but is used with spin_lock_irqsave() in
drivers/net/cxgb3/cxgb3_offload.c.  This is technically a false
positive, since the uses in sge.c are only in the initialization and
cleanup paths and cannot overlap with any use in interrupt context.

The best fix is probably just to use spin_lock_irq() with reg_lock in
sge.c.  Even though it's not strictly required for correctness, it
avoids triggering lockdep and the extra overhead of disabling
interrupts is not important at all in the initialization and cleanup
slow paths.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 979f3fc..d82f864 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -557,9 +557,9 @@ static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 
 	for (i = 0; i < SGE_RXQ_PER_SET; ++i)
 		if (q->fl[i].desc) {
-			spin_lock(&adapter->sge.reg_lock);
+			spin_lock_irq(&adapter->sge.reg_lock);
 			t3_sge_disable_fl(adapter, q->fl[i].cntxt_id);
-			spin_unlock(&adapter->sge.reg_lock);
+			spin_unlock_irq(&adapter->sge.reg_lock);
 			free_rx_bufs(pdev, &q->fl[i]);
 			kfree(q->fl[i].sdesc);
 			dma_free_coherent(&pdev->dev,
@@ -570,9 +570,9 @@ static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 
 	for (i = 0; i < SGE_TXQ_PER_SET; ++i)
 		if (q->txq[i].desc) {
-			spin_lock(&adapter->sge.reg_lock);
+			spin_lock_irq(&adapter->sge.reg_lock);
 			t3_sge_enable_ecntxt(adapter, q->txq[i].cntxt_id, 0);
-			spin_unlock(&adapter->sge.reg_lock);
+			spin_unlock_irq(&adapter->sge.reg_lock);
 			if (q->txq[i].sdesc) {
 				free_tx_desc(adapter, &q->txq[i],
 					     q->txq[i].in_use);
@@ -586,9 +586,9 @@ static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 		}
 
 	if (q->rspq.desc) {
-		spin_lock(&adapter->sge.reg_lock);
+		spin_lock_irq(&adapter->sge.reg_lock);
 		t3_sge_disable_rspcntxt(adapter, q->rspq.cntxt_id);
-		spin_unlock(&adapter->sge.reg_lock);
+		spin_unlock_irq(&adapter->sge.reg_lock);
 		dma_free_coherent(&pdev->dev,
 				  q->rspq.size * sizeof(struct rsp_desc),
 				  q->rspq.desc, q->rspq.phys_addr);
@@ -2661,7 +2661,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		(16 * 1024) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) :
 		MAX_FRAME_SIZE + 2 + sizeof(struct cpl_rx_pkt);
 
-	spin_lock(&adapter->sge.reg_lock);
+	spin_lock_irq(&adapter->sge.reg_lock);
 
 	/* FL threshold comparison uses < */
 	ret = t3_sge_init_rspcntxt(adapter, q->rspq.cntxt_id, irq_vec_idx,
@@ -2705,7 +2705,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 			goto err_unlock;
 	}
 
-	spin_unlock(&adapter->sge.reg_lock);
+	spin_unlock_irq(&adapter->sge.reg_lock);
 
 	q->adap = adapter;
 	q->netdev = dev;
@@ -2722,7 +2722,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	return 0;
 
       err_unlock:
-	spin_unlock(&adapter->sge.reg_lock);
+	spin_unlock_irq(&adapter->sge.reg_lock);
       err:
 	t3_free_qset(adapter, q);
 	return ret;
