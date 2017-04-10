From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 08/12] ftgmac100: Move the barrier out of ftgmac100_txdes_set_dma_own()
Date: Mon, 10 Apr 2017 11:15:22 +1000
Message-ID: <20170410011526.4509-9-benh@kernel.crashing.org>
References: <20170410011526.4509-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56942 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752315AbdDJBQC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 21:16:02 -0400
In-Reply-To: <20170410011526.4509-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'll use variants of this accessor without barriers when
building series of descriptors for fragmented sends

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 8078d65..bdec14f 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -483,11 +483,6 @@ static bool ftgmac100_txdes_owned_by_dma(struct ftgmac100_txdes *txdes)
 
 static void ftgmac100_txdes_set_dma_own(struct ftgmac100_txdes *txdes)
 {
-	/*
-	 * Make sure dma own bit will not be set before any other
-	 * descriptor fields.
-	 */
-	wmb();
 	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_TXDMA_OWN);
 }
 
@@ -677,6 +672,10 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 		}
 	}
 
+	/* Order the previous packet and descriptor udpates
+	 * before setting the OWN bit.
+	 */
+	dma_wmb();
 	ftgmac100_txdes_set_dma_own(txdes);
 
 	/* Update next TX pointer */
-- 
2.9.3
