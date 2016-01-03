From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 3/7] bnxt_en: Check for NULL rx or tx ring.
Date: Sat, 2 Jan 2016 23:45:00 -0500
Message-ID: <1451796304-23220-4-git-send-email-mchan@broadcom.com>
References: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:4198 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbcACEpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 23:45:08 -0500
In-Reply-To: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each bnxt_napi structure may no longer be having both an rx ring and
a tx ring.  Check for a valid ring before using it.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 27 ++++++++++++++++++++++-----
 1 file changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8635e03..11478c9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1867,6 +1867,9 @@ static void bnxt_init_ring_struct(struct bnxt *bp)
 		ring->vmem_size = 0;
 
 		rxr = bnapi->rx_ring;
+		if (!rxr)
+			goto skip_rx;
+
 		ring = &rxr->rx_ring_struct;
 		ring->nr_pages = bp->rx_nr_pages;
 		ring->page_size = HW_RXBD_RING_SIZE;
@@ -1883,7 +1886,11 @@ static void bnxt_init_ring_struct(struct bnxt *bp)
 		ring->vmem_size = SW_RXBD_AGG_RING_SIZE * bp->rx_agg_nr_pages;
 		ring->vmem = (void **)&rxr->rx_agg_ring;
 
+skip_rx:
 		txr = bnapi->tx_ring;
+		if (!txr)
+			continue;
+
 		ring = &txr->tx_ring_struct;
 		ring->nr_pages = bp->tx_nr_pages;
 		ring->page_size = HW_RXBD_RING_SIZE;
@@ -2400,13 +2407,17 @@ static void bnxt_clear_ring_indices(struct bnxt *bp)
 		cpr->cp_raw_cons = 0;
 
 		txr = bnapi->tx_ring;
-		txr->tx_prod = 0;
-		txr->tx_cons = 0;
+		if (txr) {
+			txr->tx_prod = 0;
+			txr->tx_cons = 0;
+		}
 
 		rxr = bnapi->rx_ring;
-		rxr->rx_prod = 0;
-		rxr->rx_agg_prod = 0;
-		rxr->rx_sw_agg_prod = 0;
+		if (rxr) {
+			rxr->rx_prod = 0;
+			rxr->rx_agg_prod = 0;
+			rxr->rx_sw_agg_prod = 0;
+		}
 	}
 }
 
@@ -4999,6 +5010,9 @@ static void bnxt_dump_tx_sw_state(struct bnxt_napi *bnapi)
 	struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
 	int i = bnapi->index;
 
+	if (!txr)
+		return;
+
 	netdev_info(bnapi->bp->dev, "[%d]: tx{fw_ring: %d prod: %x cons: %x}\n",
 		    i, txr->tx_ring_struct.fw_ring_id, txr->tx_prod,
 		    txr->tx_cons);
@@ -5009,6 +5023,9 @@ static void bnxt_dump_rx_sw_state(struct bnxt_napi *bnapi)
 	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 	int i = bnapi->index;
 
+	if (!rxr)
+		return;
+
 	netdev_info(bnapi->bp->dev, "[%d]: rx{fw_ring: %d prod: %x} rx_agg{fw_ring: %d agg_prod: %x sw_agg_prod: %x}\n",
 		    i, rxr->rx_ring_struct.fw_ring_id, rxr->rx_prod,
 		    rxr->rx_agg_ring_struct.fw_ring_id, rxr->rx_agg_prod,
-- 
1.8.3.1
