From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 12/12] qlge: bugfix: Fix endian issue related to rx buffers.
Date: Mon,  9 Mar 2009 13:59:28 -0700
Message-ID: <1236632368-22079-13-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbZCIVDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:13 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was introduced in an earlier net-next patch.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 1895846..b91b700 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2526,6 +2526,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	    qdev->doorbell_area + (DB_PAGE_SIZE * (128 + rx_ring->cq_id));
 	int err = 0;
 	u16 bq_len;
+	u64 tmp;
 
 	/* Set up the shadow registers for this ring. */
 	rx_ring->prod_idx_sh_reg = shadow_reg;
@@ -2571,7 +2572,8 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	    FLAGS_LI;		/* Load irq delay values */
 	if (rx_ring->lbq_len) {
 		cqicb->flags |= FLAGS_LL;	/* Load lbq values */
-		*((u64 *) rx_ring->lbq_base_indirect) = rx_ring->lbq_base_dma;
+		tmp = (u64)rx_ring->lbq_base_dma;;
+		*((__le64 *) rx_ring->lbq_base_indirect) = cpu_to_le64(tmp);
 		cqicb->lbq_addr =
 		    cpu_to_le64(rx_ring->lbq_base_indirect_dma);
 		bq_len = (rx_ring->lbq_buf_size == 65536) ? 0 :
@@ -2587,11 +2589,12 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	}
 	if (rx_ring->sbq_len) {
 		cqicb->flags |= FLAGS_LS;	/* Load sbq values */
-		*((u64 *) rx_ring->sbq_base_indirect) = rx_ring->sbq_base_dma;
+		tmp = (u64)rx_ring->sbq_base_dma;;
+		*((__le64 *) rx_ring->sbq_base_indirect) = cpu_to_le64(tmp);
 		cqicb->sbq_addr =
 		    cpu_to_le64(rx_ring->sbq_base_indirect_dma);
 		cqicb->sbq_buf_size =
-		    cpu_to_le16(((rx_ring->sbq_buf_size / 2) + 8) & 0xfffffff8);
+		    cpu_to_le16((u16)(rx_ring->sbq_buf_size/2));
 		bq_len = (rx_ring->sbq_len == 65536) ? 0 :
 			(u16) rx_ring->sbq_len;
 		cqicb->sbq_len = cpu_to_le16(bq_len);
-- 
1.6.0.2

