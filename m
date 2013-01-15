From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 02/10] vmxnet3: remove unnecessary bookkeeping
Date: Tue, 15 Jan 2013 09:28:27 -0800
Message-ID: <1358270915-32758-3-git-send-email-stephen@networkplumber.org>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:34295 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264Ab3AORaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:06 -0500
Received: by mail-pb0-f47.google.com with SMTP id wz17so169581pbc.20
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:06 -0800 (PST)
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The uncommitted[] array was set but never used except in a debug
message. Remove it.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    9 ++-------
 drivers/net/vmxnet3/vmxnet3_int.h |    2 --
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 3402a0c..99ef9ed 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -628,12 +628,10 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32 ring_idx,
 		num_allocated++;
 		vmxnet3_cmd_ring_adv_next2fill(ring);
 	}
-	rq->uncommitted[ring_idx] += num_allocated;
 
 	dev_dbg(&adapter->netdev->dev,
-		"alloc_rx_buf: %d allocated, next2fill %u, next2comp "
-		"%u, uncommitted %u\n", num_allocated, ring->next2fill,
-		ring->next2comp, rq->uncommitted[ring_idx]);
+		"alloc_rx_buf: %d allocated, next2fill %u, next2comp %u\n",
+		num_allocated, ring->next2fill, ring->next2comp);
 
 	/* so that the device can distinguish a full ring and an empty ring */
 	BUG_ON(num_allocated != 0 && ring->next2fill == ring->next2comp);
@@ -1331,7 +1329,6 @@ rcd_done:
 			VMXNET3_WRITE_BAR0_REG(adapter,
 					       rxprod_reg[ring_idx] + rq->qid * 8,
 					       ring->next2fill);
-			rq->uncommitted[ring_idx] = 0;
 		}
 
 		vmxnet3_comp_ring_adv_next2proc(&rq->comp_ring);
@@ -1376,7 +1373,6 @@ vmxnet3_rq_cleanup(struct vmxnet3_rx_queue *rq,
 		rq->rx_ring[ring_idx].gen = VMXNET3_INIT_GEN;
 		rq->rx_ring[ring_idx].next2fill =
 					rq->rx_ring[ring_idx].next2comp = 0;
-		rq->uncommitted[ring_idx] = 0;
 	}
 
 	rq->comp_ring.gen = VMXNET3_INIT_GEN;
@@ -1457,7 +1453,6 @@ vmxnet3_rq_init(struct vmxnet3_rx_queue *rq,
 	/* reset internal state and allocate buffers for both rings */
 	for (i = 0; i < 2; i++) {
 		rq->rx_ring[i].next2fill = rq->rx_ring[i].next2comp = 0;
-		rq->uncommitted[i] = 0;
 
 		memset(rq->rx_ring[i].base, 0, rq->rx_ring[i].size *
 		       sizeof(struct Vmxnet3_RxDesc));
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index fc46a81..55465ed 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -276,8 +276,6 @@ struct vmxnet3_rx_queue {
 	struct vmxnet3_rx_ctx     rx_ctx;
 	u32 qid;            /* rqID in RCD for buffer from 1st ring */
 	u32 qid2;           /* rqID in RCD for buffer from 2nd ring */
-	u32 uncommitted[2]; /* # of buffers allocated since last RXPROD
-				* update */
 	struct vmxnet3_rx_buf_info     *buf_info[2];
 	struct Vmxnet3_RxQueueCtrl            *shared;
 	struct vmxnet3_rq_driver_stats  stats;
-- 
1.7.10.4
