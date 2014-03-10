From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv5 net-next 27/31] iw_cxgb4: wc_wmb() needed after DB writes
Date: Mon, 10 Mar 2014 22:38:24 +0530
Message-ID: <1394471308-4304-28-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

Need to do an sfence after both the WC and regular PIDX DB write.
Otherwise the host might reorder things and cause work request corruption
(seen with NFSRDMA).

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/t4.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index 67cd09ee..ace3154 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -470,12 +470,12 @@ static inline void t4_ring_sq_db(struct t4_wq *wq, u16 inc, u8 t5,
 			PDBG("%s: WC wq->sq.pidx = %d\n",
 			     __func__, wq->sq.pidx);
 			pio_copy(wq->sq.udb + 7, (void *)wqe);
-			wc_wmb();
 		} else {
 			PDBG("%s: DB wq->sq.pidx = %d\n",
 			     __func__, wq->sq.pidx);
 			writel(PIDX_T5(inc), wq->sq.udb);
 		}
+		wc_wmb();
 		return;
 	}
 	writel(QID(wq->sq.qid) | PIDX(inc), wq->db);
@@ -490,12 +490,12 @@ static inline void t4_ring_rq_db(struct t4_wq *wq, u16 inc, u8 t5,
 			PDBG("%s: WC wq->rq.pidx = %d\n",
 			     __func__, wq->rq.pidx);
 			pio_copy(wq->rq.udb + 7, (void *)wqe);
-			wc_wmb();
 		} else {
 			PDBG("%s: DB wq->rq.pidx = %d\n",
 			     __func__, wq->rq.pidx);
 			writel(PIDX_T5(inc), wq->rq.udb);
 		}
+		wc_wmb();
 		return;
 	}
 	writel(QID(wq->rq.qid) | PIDX(inc), wq->db);
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
