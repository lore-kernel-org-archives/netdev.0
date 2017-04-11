From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 08/10] ftgmac100: Add more register inits in ftgmac100_init_hw()
Date: Tue, 11 Apr 2017 11:04:34 +1000
Message-ID: <20170411010436.23290-9-benh@kernel.crashing.org>
References: <20170411010436.23290-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51446 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752585AbdDKBGg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 21:06:36 -0400
In-Reply-To: <20170411010436.23290-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear stale interrupts on entry, configure FIFO sizes, set FIFO
thresholds, configure interrupt mitigation.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 36 ++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 3c7a1e4..d4fe599 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -210,7 +210,11 @@ static int ftgmac100_set_mac_addr(struct net_device *dev, void *p)
 
 static void ftgmac100_init_hw(struct ftgmac100 *priv)
 {
+	u32 reg, rfifo_sz, tfifo_sz;
 
+	/* Clear stale interrupts */
+	reg = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
+	iowrite32(reg, priv->base + FTGMAC100_OFFSET_ISR);
 
 	/* Setup RX ring buffer base */
 	iowrite32(priv->descs_dma_addr +
@@ -232,6 +236,38 @@ static void ftgmac100_init_hw(struct ftgmac100 *priv)
 
 	/* Write MAC address */
 	ftgmac100_write_mac_addr(priv, priv->netdev->dev_addr);
+
+	/* Configure descriptor sizes and increase burst sizes according
+	 * to values in Aspeed SDK. The FIFO arbitration is enabled and
+	 * the thresholds set based on the recommended values in the
+	 * AST2400 specification.
+	 */
+	iowrite32(FTGMAC100_DBLAC_RXDES_SIZE(2) |   /* 2*8 bytes RX descs */
+		  FTGMAC100_DBLAC_TXDES_SIZE(2) |   /* 2*8 bytes TX descs */
+		  FTGMAC100_DBLAC_RXBURST_SIZE(3) | /* 512 bytes max RX bursts */
+		  FTGMAC100_DBLAC_TXBURST_SIZE(3) | /* 512 bytes max TX bursts */
+		  FTGMAC100_DBLAC_RX_THR_EN |       /* Enable fifo threshold arb */
+		  FTGMAC100_DBLAC_RXFIFO_HTHR(6) |  /* 6/8 of FIFO high threshold */
+		  FTGMAC100_DBLAC_RXFIFO_LTHR(2),   /* 2/8 of FIFO low threshold */
+		  priv->base + FTGMAC100_OFFSET_DBLAC);
+
+	/* Interrupt mitigation configured for 1 interrupt/packet. HW interrupt
+	 * mitigation doesn't seem to provide any benefit with NAPI so leave
+	 * it at that.
+	 */
+	iowrite32(FTGMAC100_ITC_RXINT_THR(1) |
+		  FTGMAC100_ITC_TXINT_THR(1),
+		  priv->base + FTGMAC100_OFFSET_ITC);
+
+	/* Configure FIFO sizes in the TPAFCR register */
+	reg = ioread32(priv->base + FTGMAC100_OFFSET_FEAR);
+	rfifo_sz = reg & 0x00000007;
+	tfifo_sz = (reg >> 3) & 0x00000007;
+	reg = ioread32(priv->base + FTGMAC100_OFFSET_TPAFCR);
+	reg &= ~0x3f000000;
+	reg |= (tfifo_sz << 27);
+	reg |= (rfifo_sz << 24);
+	iowrite32(reg, priv->base + FTGMAC100_OFFSET_TPAFCR);
 }
 
 static void ftgmac100_start_hw(struct ftgmac100 *priv)
-- 
2.9.3
