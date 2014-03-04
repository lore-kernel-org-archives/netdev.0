From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 05/31] cxgb4: use spinlock_irqsave/spinlock_irqrestore for db lock.
Date: Tue,  4 Mar 2014 18:11:31 +0530
Message-ID: <1393936917-25847-6-git-send-email-hariprasad@chelsio.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, kumaras@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, hariprasad@chelsio.com, nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12637 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932121AbaCDMnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 07:43:22 -0500
In-Reply-To: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Currently ring_tx_db() can deadlock if a db_full interrupt fires and is
run on the same while ring_tx_db() has the db lock held.  It needs to
disable interrupts since it serializes with an interrupt handler.

Based on original work by Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 11 +++++++----
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  5 +++--
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index da4edc1..73dbf81 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3585,9 +3585,11 @@ static void disable_txq_db(struct sge_txq *q)
 
 static void enable_txq_db(struct sge_txq *q)
 {
-	spin_lock_irq(&q->db_lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&q->db_lock, flags);
 	q->db_disabled = 0;
-	spin_unlock_irq(&q->db_lock);
+	spin_unlock_irqrestore(&q->db_lock, flags);
 }
 
 static void disable_dbs(struct adapter *adap)
@@ -3617,9 +3619,10 @@ static void enable_dbs(struct adapter *adap)
 static void sync_txq_pidx(struct adapter *adap, struct sge_txq *q)
 {
 	u16 hw_pidx, hw_cidx;
+	unsigned long flags;
 	int ret;
 
-	spin_lock_bh(&q->db_lock);
+	spin_lock_irqsave(&q->db_lock, flags);
 	ret = read_eq_indices(adap, (u16)q->cntxt_id, &hw_pidx, &hw_cidx);
 	if (ret)
 		goto out;
@@ -3636,7 +3639,7 @@ static void sync_txq_pidx(struct adapter *adap, struct sge_txq *q)
 	}
 out:
 	q->db_disabled = 0;
-	spin_unlock_bh(&q->db_lock);
+	spin_unlock_irqrestore(&q->db_lock, flags);
 	if (ret)
 		CH_WARN(adap, "DB drop recovery failed.\n");
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index e0376cd..392baee 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -860,9 +860,10 @@ static void cxgb_pio_copy(u64 __iomem *dst, u64 *src)
 static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 {
 	unsigned int *wr, index;
+	unsigned long flags;
 
 	wmb();            /* write descriptors before telling HW */
-	spin_lock(&q->db_lock);
+	spin_lock_irqsave(&q->db_lock, flags);
 	if (!q->db_disabled) {
 		if (is_t4(adap->params.chip)) {
 			t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
@@ -880,7 +881,7 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
 		}
 	}
 	q->db_pidx = q->pidx;
-	spin_unlock(&q->db_lock);
+	spin_unlock_irqrestore(&q->db_lock, flags);
 }
 
 /**
-- 
1.8.4
