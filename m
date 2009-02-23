From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/5] [net-next] qlge: Optimize rx buffer refill process.
Date: Mon, 23 Feb 2009 12:42:16 -0800
Message-ID: <1235421737-32296-4-git-send-email-ron.mercer@qlogic.com>
References: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:3006 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbZBWUpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 15:45:39 -0500
In-Reply-To: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX Buffers are refilled in chunks of 16 at a time before notifying the
hardware with a register write.  This can cause several writes to take
place in a given napi poll call.  This change causes the write to take place
only once at the end of the call.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 16c056a..1719845 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -863,7 +863,8 @@ static void ql_write_cq_idx(struct rx_ring *rx_ring)
 /* Process (refill) a large buffer queue. */
 static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
-	int clean_idx = rx_ring->lbq_clean_idx;
+	u32 clean_idx = rx_ring->lbq_clean_idx;
+	u32 start_idx = clean_idx;
 	struct bq_desc *lbq_desc;
 	u64 map;
 	int i;
@@ -910,19 +911,23 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		rx_ring->lbq_prod_idx += 16;
 		if (rx_ring->lbq_prod_idx == rx_ring->lbq_len)
 			rx_ring->lbq_prod_idx = 0;
+		rx_ring->lbq_free_cnt -= 16;
+	}
+
+	if (start_idx != clean_idx) {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"lbq: updating prod idx = %d.\n",
 			rx_ring->lbq_prod_idx);
 		ql_write_db_reg(rx_ring->lbq_prod_idx,
 				rx_ring->lbq_prod_idx_db_reg);
-		rx_ring->lbq_free_cnt -= 16;
 	}
 }
 
 /* Process (refill) a small buffer queue. */
 static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
-	int clean_idx = rx_ring->sbq_clean_idx;
+	u32 clean_idx = rx_ring->sbq_clean_idx;
+	u32 start_idx = clean_idx;
 	struct bq_desc *sbq_desc;
 	u64 map;
 	int i;
@@ -972,13 +977,15 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		rx_ring->sbq_prod_idx += 16;
 		if (rx_ring->sbq_prod_idx == rx_ring->sbq_len)
 			rx_ring->sbq_prod_idx = 0;
+		rx_ring->sbq_free_cnt -= 16;
+	}
+
+	if (start_idx != clean_idx) {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"sbq: updating prod idx = %d.\n",
 			rx_ring->sbq_prod_idx);
 		ql_write_db_reg(rx_ring->sbq_prod_idx,
 				rx_ring->sbq_prod_idx_db_reg);
-
-		rx_ring->sbq_free_cnt -= 16;
 	}
 }
 
-- 
1.6.0.2

