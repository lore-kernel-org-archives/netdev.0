From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/5] qlge: bugfix: Fix rx ring and large and small rx buffer length settings.
Date: Wed, 24 Dec 2008 10:21:35 -0800
Message-ID: <1230142896-15533-4-git-send-email-ron.mercer@qlogic.com>
References: <20081224181834.GA15470@susedev.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:27618 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbYLXSVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 13:21:36 -0500
In-Reply-To: <20081224181834.GA15470@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The length field for rx ring and buffer rings is 16-bits.  To indicate
a maximum length of 65536 the value should be set to zero.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 92dc3f7..b58f5df 100755
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2491,8 +2491,9 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 
 	memset((void *)cqicb, 0, sizeof(struct cqicb));
 	cqicb->msix_vect = rx_ring->irq;
+	bq_len = (rx_ring->cq_len == 65536) ? 0 : (u16)rx_ring->cq_len;
 
-	cqicb->len = cpu_to_le16(rx_ring->cq_len | LEN_V | LEN_CPP_CONT);
+	cqicb->len = cpu_to_le16(bq_len | LEN_V | LEN_CPP_CONT);
 
 	cqicb->addr_lo = cpu_to_le32(rx_ring->cq_base_dma);
 	cqicb->addr_hi = cpu_to_le32((u64) rx_ring->cq_base_dma >> 32);
@@ -2514,8 +2515,9 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		    cpu_to_le32(rx_ring->lbq_base_indirect_dma);
 		cqicb->lbq_addr_hi =
 		    cpu_to_le32((u64) rx_ring->lbq_base_indirect_dma >> 32);
-		cqicb->lbq_buf_size = cpu_to_le32(rx_ring->lbq_buf_size);
-		bq_len = (u16) rx_ring->lbq_len;
+		bq_len = (rx_ring->lbq_buf_size == 65536) ? 0 : (u16)rx_ring->lbq_buf_size;
+		cqicb->lbq_buf_size = cpu_to_le16(bq_len);
+		bq_len = (rx_ring->lbq_len == 65536) ? 0 : (u16)rx_ring->lbq_len;
 		cqicb->lbq_len = cpu_to_le16(bq_len);
 		rx_ring->lbq_prod_idx = rx_ring->lbq_len - 16;
 		rx_ring->lbq_curr_idx = 0;
@@ -2530,8 +2532,8 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		cqicb->sbq_addr_hi =
 		    cpu_to_le32((u64) rx_ring->sbq_base_indirect_dma >> 32);
 		cqicb->sbq_buf_size =
-		    cpu_to_le16(((rx_ring->sbq_buf_size / 2) + 8) & 0xfffffff8);
-		bq_len = (u16) rx_ring->sbq_len;
+		    cpu_to_le16((u16)(rx_ring->sbq_buf_size/2));
+		bq_len = (rx_ring->sbq_len == 65536) ? 0 : (u16)rx_ring->sbq_len;
 		cqicb->sbq_len = cpu_to_le16(bq_len);
 		rx_ring->sbq_prod_idx = rx_ring->sbq_len - 16;
 		rx_ring->sbq_curr_idx = 0;
-- 
1.6.0

