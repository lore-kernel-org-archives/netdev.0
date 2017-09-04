From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Ignore MPS_TX_INT_CAUSE[Bubble] for T6
Date: Mon,  4 Sep 2017 11:25:34 +0530
Message-ID: <1504504534-22115-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:22983 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750805AbdIDF4b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 01:56:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPS_TX_INT_CAUSE[Bubble] is a normal condition for T6, hence
ignore this interrupt for T6.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 08624db..b0f9aea 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4548,6 +4548,18 @@ static void mps_intr_handler(struct adapter *adapter)
 		{ FRMERR_F, "MPS Tx framing error", -1, 1 },
 		{ 0 }
 	};
+	static const struct intr_info t6_mps_tx_intr_info[] = {
+		{ TPFIFO_V(TPFIFO_M), "MPS Tx TP FIFO parity error", -1, 1 },
+		{ NCSIFIFO_F, "MPS Tx NC-SI FIFO parity error", -1, 1 },
+		{ TXDATAFIFO_V(TXDATAFIFO_M), "MPS Tx data FIFO parity error",
+		  -1, 1 },
+		{ TXDESCFIFO_V(TXDESCFIFO_M), "MPS Tx desc FIFO parity error",
+		  -1, 1 },
+		/* MPS Tx Bubble is normal for T6 */
+		{ SECNTERR_F, "MPS Tx SOP/EOP error", -1, 1 },
+		{ FRMERR_F, "MPS Tx framing error", -1, 1 },
+		{ 0 }
+	};
 	static const struct intr_info mps_trc_intr_info[] = {
 		{ FILTMEM_V(FILTMEM_M), "MPS TRC filter parity error", -1, 1 },
 		{ PKTFIFO_V(PKTFIFO_M), "MPS TRC packet FIFO parity error",
@@ -4579,7 +4591,9 @@ static void mps_intr_handler(struct adapter *adapter)
 	fat = t4_handle_intr_status(adapter, MPS_RX_PERR_INT_CAUSE_A,
 				    mps_rx_intr_info) +
 	      t4_handle_intr_status(adapter, MPS_TX_INT_CAUSE_A,
-				    mps_tx_intr_info) +
+				    is_t6(adapter->params.chip)
+				    ? t6_mps_tx_intr_info
+				    : mps_tx_intr_info) +
 	      t4_handle_intr_status(adapter, MPS_TRC_INT_CAUSE_A,
 				    mps_trc_intr_info) +
 	      t4_handle_intr_status(adapter, MPS_STAT_PERR_INT_CAUSE_SRAM_A,
-- 
2.1.0
