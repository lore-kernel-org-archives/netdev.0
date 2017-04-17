From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v3 8/9] ftgmac100: Fix potential ordering issue in NAPI poll
Date: Tue, 18 Apr 2017 08:37:05 +1000
Message-ID: <20170417223706.16483-9-benh@kernel.crashing.org>
References: <20170417223706.16483-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51420 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755661AbdDQWl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 18:41:27 -0400
In-Reply-To: <20170417223706.16483-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to ensure the loads from the descriptor are done after the
MMIO store clearing the interrupts has completed, otherwise we
might still miss work.

A read back from the MMIO register will "push" the posted store and
ioread32 has a barrier on weakly aordered architectures that will
order subsequent accesses.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 45b8267..95bf5e8 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1349,6 +1349,13 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 		 */
 		iowrite32(FTGMAC100_INT_RXTX,
 			  priv->base + FTGMAC100_OFFSET_ISR);
+
+		/* Push the above (and provides a barrier vs. subsequent
+		 * reads of the descriptor).
+		 */
+		ioread32(priv->base + FTGMAC100_OFFSET_ISR);
+
+		/* Check RX and TX descriptors for more work to do */
 		if (ftgmac100_check_rx(priv) ||
 		    ftgmac100_tx_buf_cleanable(priv))
 			return budget;
-- 
2.9.3
