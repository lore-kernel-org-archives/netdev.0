From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next-26] cxgb4vf: Ingress Queue Entry Size needs to be 64 bytes
Date: Thu,  9 Dec 2010 11:38:24 -0800
Message-ID: <1291923504-3589-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30055 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab0LITi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 14:38:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Was using L1_CACHE_BYTES for the Ingress Queue Entry Size but it really
needs to be 64 bytes in order to support the largest message sizes.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index d887a76..6bf464a 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2269,6 +2269,7 @@ static void __devinit cfg_queues(struct adapter *adapter)
 {
 	struct sge *s = &adapter->sge;
 	int q10g, n10g, qidx, pidx, qs;
+	size_t iqe_size;
 
 	/*
 	 * We should not be called till we know how many Queue Sets we can
@@ -2313,6 +2314,13 @@ static void __devinit cfg_queues(struct adapter *adapter)
 	s->ethqsets = qidx;
 
 	/*
+	 * The Ingress Queue Entry Size for our various Response Queues needs
+	 * to be big enough to accommodate the largest message we can receive
+	 * from the chip/firmware; which is 64 bytes ...
+	 */
+	iqe_size = 64;
+
+	/*
 	 * Set up default Queue Set parameters ...  Start off with the
 	 * shortest interrupt holdoff timer.
 	 */
@@ -2320,7 +2328,7 @@ static void __devinit cfg_queues(struct adapter *adapter)
 		struct sge_eth_rxq *rxq = &s->ethrxq[qs];
 		struct sge_eth_txq *txq = &s->ethtxq[qs];
 
-		init_rspq(&rxq->rspq, 0, 0, 1024, L1_CACHE_BYTES);
+		init_rspq(&rxq->rspq, 0, 0, 1024, iqe_size);
 		rxq->fl.size = 72;
 		txq->q.size = 1024;
 	}
@@ -2329,8 +2337,7 @@ static void __devinit cfg_queues(struct adapter *adapter)
 	 * The firmware event queue is used for link state changes and
 	 * notifications of TX DMA completions.
 	 */
-	init_rspq(&s->fw_evtq, SGE_TIMER_RSTRT_CNTR, 0, 512,
-		  L1_CACHE_BYTES);
+	init_rspq(&s->fw_evtq, SGE_TIMER_RSTRT_CNTR, 0, 512, iqe_size);
 
 	/*
 	 * The forwarded interrupt queue is used when we're in MSI interrupt
@@ -2346,7 +2353,7 @@ static void __devinit cfg_queues(struct adapter *adapter)
 	 * any time ...
 	 */
 	init_rspq(&s->intrq, SGE_TIMER_RSTRT_CNTR, 0, MSIX_ENTRIES + 1,
-		  L1_CACHE_BYTES);
+		  iqe_size);
 }
 
 /*
-- 
1.7.0.4

