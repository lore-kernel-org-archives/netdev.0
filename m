From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/5] qlge: bugfix: Fix ring length setting for rx ring, large/small
Date: Tue, 30 Dec 2008 13:12:24 -0800
Message-ID: <1230671545-19084-4-git-send-email-ron.mercer@qlogic.com>
References: <20081230211122.GD16018@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, bhutchings@solarflare.com, hch@infradead.org
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:38470 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbYL3VMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 16:12:24 -0500
In-Reply-To: <20081230211122.GD16018@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The length field for these rings is 16-bits.  If the length is
the max supported 65536 then the setting should be zero.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c0e43c5..ffa2100 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2491,7 +2491,8 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	memset((void *)cqicb, 0, sizeof(struct cqicb));
 	cqicb->msix_vect = rx_ring->irq;
 
-	cqicb->len = cpu_to_le16(rx_ring->cq_len | LEN_V | LEN_CPP_CONT);
+	bq_len = (rx_ring->cq_len == 65536) ? 0 : (u16) rx_ring->cq_len;
+	cqicb->len = cpu_to_le16(bq_len | LEN_V | LEN_CPP_CONT);
 
 	cqicb->addr_lo = cpu_to_le32(rx_ring->cq_base_dma);
 	cqicb->addr_hi = cpu_to_le32((u64) rx_ring->cq_base_dma >> 32);
@@ -2513,8 +2514,11 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		    cpu_to_le32(rx_ring->lbq_base_indirect_dma);
 		cqicb->lbq_addr_hi =
 		    cpu_to_le32((u64) rx_ring->lbq_base_indirect_dma >> 32);
-		cqicb->lbq_buf_size = cpu_to_le32(rx_ring->lbq_buf_size);
-		bq_len = (u16) rx_ring->lbq_len;
+		bq_len = (rx_ring->lbq_buf_size == 65536) ? 0 :
+			(u16) rx_ring->lbq_buf_size;
+		cqicb->lbq_buf_size = cpu_to_le16(bq_len);
+		bq_len = (rx_ring->lbq_len == 65536) ? 0 :
+			(u16) rx_ring->lbq_len;
 		cqicb->lbq_len = cpu_to_le16(bq_len);
 		rx_ring->lbq_prod_idx = rx_ring->lbq_len - 16;
 		rx_ring->lbq_curr_idx = 0;
@@ -2530,7 +2534,8 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		    cpu_to_le32((u64) rx_ring->sbq_base_indirect_dma >> 32);
 		cqicb->sbq_buf_size =
 		    cpu_to_le16(((rx_ring->sbq_buf_size / 2) + 8) & 0xfffffff8);
-		bq_len = (u16) rx_ring->sbq_len;
+		bq_len = (rx_ring->sbq_len == 65536) ? 0 :
+			(u16) rx_ring->sbq_len;
 		cqicb->sbq_len = cpu_to_le16(bq_len);
 		rx_ring->sbq_prod_idx = rx_ring->sbq_len - 16;
 		rx_ring->sbq_curr_idx = 0;
-- 
1.6.0

