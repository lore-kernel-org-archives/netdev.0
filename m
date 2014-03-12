From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv6 net-next 27/31] iw_cxgb4: wc_wmb() needed after DB writes
Date: Wed, 12 Mar 2014 21:20:42 +0530
Message-ID: <1394639446-6504-28-git-send-email-hariprasad@chelsio.com>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13088 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755398AbaCLQA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 12:00:29 -0400
In-Reply-To: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Need to do an sfence after both the WC and regular PIDX DB write.
Otherwise the host might reorder things and cause work request corruption
(seen with NFSRDMA).

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
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
