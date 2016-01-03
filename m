From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 1/7] bnxt_en: Refactor bnxt_dbg_dump_states().
Date: Sat, 2 Jan 2016 23:44:58 -0500
Message-ID: <1451796304-23220-2-git-send-email-mchan@broadcom.com>
References: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:14464 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbcACEpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 23:45:08 -0500
In-Reply-To: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By adding 3 separate functions to dump the different ring states.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 50 ++++++++++++++++++++-----------
 1 file changed, 33 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 319653a..3f053de 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5015,31 +5015,47 @@ static int bnxt_set_features(struct net_device *dev, netdev_features_t features)
 	return rc;
 }
 
+static void bnxt_dump_tx_sw_state(struct bnxt_napi *bnapi)
+{
+	struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
+	int i = bnapi->index;
+
+	netdev_info(bnapi->bp->dev, "[%d]: tx{fw_ring: %d prod: %x cons: %x}\n",
+		    i, txr->tx_ring_struct.fw_ring_id, txr->tx_prod,
+		    txr->tx_cons);
+}
+
+static void bnxt_dump_rx_sw_state(struct bnxt_napi *bnapi)
+{
+	struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+	int i = bnapi->index;
+
+	netdev_info(bnapi->bp->dev, "[%d]: rx{fw_ring: %d prod: %x} rx_agg{fw_ring: %d agg_prod: %x sw_agg_prod: %x}\n",
+		    i, rxr->rx_ring_struct.fw_ring_id, rxr->rx_prod,
+		    rxr->rx_agg_ring_struct.fw_ring_id, rxr->rx_agg_prod,
+		    rxr->rx_sw_agg_prod);
+}
+
+static void bnxt_dump_cp_sw_state(struct bnxt_napi *bnapi)
+{
+	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
+	int i = bnapi->index;
+
+	netdev_info(bnapi->bp->dev, "[%d]: cp{fw_ring: %d raw_cons: %x}\n",
+		    i, cpr->cp_ring_struct.fw_ring_id, cpr->cp_raw_cons);
+}
+
 static void bnxt_dbg_dump_states(struct bnxt *bp)
 {
 	int i;
 	struct bnxt_napi *bnapi;
-	struct bnxt_tx_ring_info *txr;
-	struct bnxt_rx_ring_info *rxr;
-	struct bnxt_cp_ring_info *cpr;
 
 	for (i = 0; i < bp->cp_nr_rings; i++) {
 		bnapi = bp->bnapi[i];
-		txr = &bnapi->tx_ring;
-		rxr = &bnapi->rx_ring;
-		cpr = &bnapi->cp_ring;
 		if (netif_msg_drv(bp)) {
-			netdev_info(bp->dev, "[%d]: tx{fw_ring: %d prod: %x cons: %x}\n",
-				    i, txr->tx_ring_struct.fw_ring_id,
-				    txr->tx_prod, txr->tx_cons);
-			netdev_info(bp->dev, "[%d]: rx{fw_ring: %d prod: %x} rx_agg{fw_ring: %d agg_prod: %x sw_agg_prod: %x}\n",
-				    i, rxr->rx_ring_struct.fw_ring_id,
-				    rxr->rx_prod,
-				    rxr->rx_agg_ring_struct.fw_ring_id,
-				    rxr->rx_agg_prod, rxr->rx_sw_agg_prod);
-			netdev_info(bp->dev, "[%d]: cp{fw_ring: %d raw_cons: %x}\n",
-				    i, cpr->cp_ring_struct.fw_ring_id,
-				    cpr->cp_raw_cons);
+			bnxt_dump_tx_sw_state(bnapi);
+			bnxt_dump_rx_sw_state(bnapi);
+			bnxt_dump_cp_sw_state(bnapi);
 		}
 	}
 }
-- 
1.8.3.1
