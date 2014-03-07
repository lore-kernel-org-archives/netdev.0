From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv4 net-next 05/32] cxgb4: use spinlock_irqsave/spinlock_irqrestore for db lock
Date: Fri,  7 Mar 2014 16:03:02 +0530
Message-ID: <1394188409-9739-6-git-send-email-hariprasad@chelsio.com>
References: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394188409-9739-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Currently ring_tx_db() can deadlock if a db_full interrupt fires and is
run on the same while ring_tx_db() has the db lock held.  It needs to
disable interrupts since it serializes with an interrupt handler.

Based on original work by Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

Signed-off-by: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 11 +++++++----
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  5 +++--
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 0ac53dd..a95668e 100644
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
index a7c56b3..c6fa96a 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
