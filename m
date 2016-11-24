From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH] net: stmmac: enable tx queue 0 for gmac4 IPs synthesized with multiple TX queues
Date: Thu, 24 Nov 2016 15:36:33 +0100
Message-ID: <1479998194-7113-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

The dwmac4 IP can synthesized with 1-8 number of tx queues.
On an IP synthesized with DWC_EQOS_NUM_TXQ > 1, all txqueues are disabled
by default. For these IPs, the bitfield TXQEN is R/W.

Always enable tx queue 0. The write will have no effect on IPs synthesized
with DWC_EQOS_NUM_TXQ == 1.

The driver does still not utilize more than one tx queue in the IP.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h     |  3 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c | 12 +++++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 6f4f5ce25114..3e8d4fefa5e0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -155,8 +155,11 @@ enum power_event {
 #define MTL_CHAN_RX_DEBUG(x)		(MTL_CHANX_BASE_ADDR(x) + 0x38)
 
 #define MTL_OP_MODE_RSF			BIT(5)
+#define MTL_OP_MODE_TXQEN		BIT(3)
 #define MTL_OP_MODE_TSF			BIT(1)
 
+#define MTL_OP_MODE_TQS_MASK		GENMASK(24, 16)
+
 #define MTL_OP_MODE_TTC_MASK		0x70
 #define MTL_OP_MODE_TTC_SHIFT		4
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 116151cd6a95..577316de6ba8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -213,7 +213,17 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 		else
 			mtl_tx_op |= MTL_OP_MODE_TTC_512;
 	}
-
+	/* For an IP with DWC_EQOS_NUM_TXQ == 1, the fields TXQEN and TQS are RO
+	 * with reset values: TXQEN on, TQS == DWC_EQOS_TXFIFO_SIZE.
+	 * For an IP with DWC_EQOS_NUM_TXQ > 1, the fields TXQEN and TQS are R/W
+	 * with reset values: TXQEN off, TQS 256 bytes.
+	 *
+	 * Write the bits in both cases, since it will have no effect when RO.
+	 * For DWC_EQOS_NUM_TXQ > 1, the top bits in MTL_OP_MODE_TQS_MASK might
+	 * be RO, however, writing the whole TQS field will result in a value
+	 * equal to DWC_EQOS_TXFIFO_SIZE, just like for DWC_EQOS_NUM_TXQ == 1.
+	 */
+	mtl_tx_op |= MTL_OP_MODE_TXQEN | MTL_OP_MODE_TQS_MASK;
 	writel(mtl_tx_op, ioaddr +  MTL_CHAN_TX_OP_MODE(channel));
 
 	mtl_rx_op = readl(ioaddr + MTL_CHAN_RX_OP_MODE(channel));
-- 
2.1.4
