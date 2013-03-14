From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH v2 net-next 18/22] RDMA/cxgb4: Fix onchip queue support for T5
Date: Thu, 14 Mar 2013 20:39:04 +0530
Message-ID: <1363273748-25330-19-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com, vipul@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12138 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757893Ab3CNPQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:16:24 -0400
In-Reply-To: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T5 adapter does not support onchip queue memory. Present logic fails to
allocate QP for T5 and returns an error. Also, if module parameter ocqp_support
is zero then we are unable to allocate QP which should not be the case. Ideally
if ocqp_support parameter is 0 or onchip queue support is disable then host QP
should be allocated before returning an error.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

 drivers/infiniband/hw/cxgb4/qp.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 90833d7..9fe6f1e 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -140,7 +140,7 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	int wr_len;
 	struct c4iw_wr_wait wr_wait;
 	struct sk_buff *skb;
-	int ret;
+	int ret = 0;
 	int eqsize;
 
 	wq->sq.qid = c4iw_get_qpid(rdev, uctx);
@@ -180,17 +180,14 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	}
 
 	if (user) {
-		ret = alloc_oc_sq(rdev, &wq->sq);
-		if (ret)
+		if (alloc_oc_sq(rdev, &wq->sq) && alloc_host_sq(rdev, &wq->sq))
 			goto free_hwaddr;
-
-		ret = alloc_host_sq(rdev, &wq->sq);
-		if (ret)
-			goto free_sq;
-	} else
+	} else {
 		ret = alloc_host_sq(rdev, &wq->sq);
 		if (ret)
 			goto free_hwaddr;
+	}
+
 	memset(wq->sq.queue, 0, wq->sq.memsize);
 	dma_unmap_addr_set(&wq->sq, mapping, wq->sq.dma_addr);
 
-- 
1.7.1
