From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] vmxnet3: prevent receive getting out of sequence on napi poll
Date: Tue,  7 Jul 2015 14:02:18 -0400
Message-ID: <1436292138-18190-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54836 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932515AbbGGSCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 14:02:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vmxnet3's current napi path is built to count every rx descriptor we recieve,
and use that as a count of the napi budget.  That means its possible to return
from a napi poll halfway through recieving a fragmented packet accross multiple
dma descriptors.  If that happens, the next napi poll will start with the
descriptor ring in an improper state (e.g. the first descriptor we look at may
have the end-of-packet bit set), which will cause a BUG halt in the driver.

Fix the issue by only counting whole received packets in the napi poll and
returning that value, rather than the descriptor count.

Tested by the reporter and myself, successfully

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Shreyas Bhatewara <sbhatewara@vmware.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index da11bb5..46f4cad 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1216,7 +1216,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 	static const u32 rxprod_reg[2] = {
 		VMXNET3_REG_RXPROD, VMXNET3_REG_RXPROD2
 	};
-	u32 num_rxd = 0;
+	u32 num_pkts = 0;
 	bool skip_page_frags = false;
 	struct Vmxnet3_RxCompDesc *rcd;
 	struct vmxnet3_rx_ctx *ctx = &rq->rx_ctx;
@@ -1235,13 +1235,12 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 		struct Vmxnet3_RxDesc *rxd;
 		u32 idx, ring_idx;
 		struct vmxnet3_cmd_ring	*ring = NULL;
-		if (num_rxd >= quota) {
+		if (num_pkts >= quota) {
 			/* we may stop even before we see the EOP desc of
 			 * the current pkt
 			 */
 			break;
 		}
-		num_rxd++;
 		BUG_ON(rcd->rqID != rq->qid && rcd->rqID != rq->qid2);
 		idx = rcd->rxdIdx;
 		ring_idx = rcd->rqID < adapter->num_rx_queues ? 0 : 1;
@@ -1413,6 +1412,7 @@ not_lro:
 				napi_gro_receive(&rq->napi, skb);
 
 			ctx->skb = NULL;
+			num_pkts++;
 		}
 
 rcd_done:
@@ -1443,7 +1443,7 @@ rcd_done:
 				  &rq->comp_ring.base[rq->comp_ring.next2proc].rcd, &rxComp);
 	}
 
-	return num_rxd;
+	return num_pkts;
 }
 
 
-- 
2.1.0
