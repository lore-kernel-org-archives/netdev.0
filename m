From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net] qede: Fix out-of-bound fastpath memory access
Date: Sat, 29 Oct 2016 17:04:35 +0300
Message-ID: <1477749875-30529-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40367 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966390AbcJ2OEp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 10:04:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver allocates a shadow array for transmitted SKBs with X entries;
That means valid indices are {0,...,X - 1}. [X == 8191]
Problem is the driver also uses X as a mask for a
producer/consumer in order to choose the right entry in the
array which allows access to entry X which is out of bounds.

To fix this, simply allocate X + 1 entries in the shadow array.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 444b271..7def29a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2940,7 +2940,7 @@ static int qede_alloc_mem_txq(struct qede_dev *edev, struct qede_tx_queue *txq)
 	txq->num_tx_buffers = edev->q_num_tx_buffers;
 
 	/* Allocate the parallel driver ring for Tx buffers */
-	size = sizeof(*txq->sw_tx_ring) * NUM_TX_BDS_MAX;
+	size = sizeof(*txq->sw_tx_ring) * TX_RING_SIZE;
 	txq->sw_tx_ring = kzalloc(size, GFP_KERNEL);
 	if (!txq->sw_tx_ring) {
 		DP_NOTICE(edev, "Tx buffers ring allocation failed\n");
@@ -2951,7 +2951,7 @@ static int qede_alloc_mem_txq(struct qede_dev *edev, struct qede_tx_queue *txq)
 					    QED_CHAIN_USE_TO_CONSUME_PRODUCE,
 					    QED_CHAIN_MODE_PBL,
 					    QED_CHAIN_CNT_TYPE_U16,
-					    NUM_TX_BDS_MAX,
+					    TX_RING_SIZE,
 					    sizeof(*p_virt), &txq->tx_pbl);
 	if (rc)
 		goto err;
-- 
1.9.3
