From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH v2 7/9] net: stmmac: Program RX queue size and flow control
Date: Fri, 10 Mar 2017 17:34:59 +0100
Message-ID: <20170310163501.31811-8-thierry.reding@gmail.com>
References: <20170310163501.31811-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Jon Hunter <jonathanh@nvidia.com>,
        Mikko Perttunen <cyndis@kapsi.fi>, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310163501.31811-1-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Program the receive queue size based on the RX FIFO size and enable
hardware flow control for large FIFOs.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Changes in v2:
- add comments to clarify flow control threshold programming

 drivers/net/ethernet/stmicro/stmmac/dwmac4.h     | 12 ++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c | 52 +++++++++++++++++++++++-
 2 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 83f5e953e291..3b1828b4d294 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -182,6 +182,7 @@ enum power_event {
 #define MTL_OP_MODE_TSF			BIT(1)
 
 #define MTL_OP_MODE_TQS_MASK		GENMASK(24, 16)
+#define MTL_OP_MODE_TQS_SHIFT		16
 
 #define MTL_OP_MODE_TTC_MASK		0x70
 #define MTL_OP_MODE_TTC_SHIFT		4
@@ -195,6 +196,17 @@ enum power_event {
 #define MTL_OP_MODE_TTC_384		(6 << MTL_OP_MODE_TTC_SHIFT)
 #define MTL_OP_MODE_TTC_512		(7 << MTL_OP_MODE_TTC_SHIFT)
 
+#define MTL_OP_MODE_RQS_MASK		GENMASK(29, 20)
+#define MTL_OP_MODE_RQS_SHIFT		20
+
+#define MTL_OP_MODE_RFD_MASK		GENMASK(19, 14)
+#define MTL_OP_MODE_RFD_SHIFT		14
+
+#define MTL_OP_MODE_RFA_MASK		GENMASK(13, 8)
+#define MTL_OP_MODE_RFA_SHIFT		8
+
+#define MTL_OP_MODE_EHFC		BIT(7)
+
 #define MTL_OP_MODE_RTC_MASK		0x18
 #define MTL_OP_MODE_RTC_SHIFT		3
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 55270933bae1..6ac6b2600a7c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -183,8 +183,9 @@ static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt)
 }
 
 static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
-				    int rxmode, u32 channel)
+				    int rxmode, u32 channel, int rxfifosz)
 {
+	unsigned int rqs = rxfifosz / 256 - 1;
 	u32 mtl_tx_op, mtl_rx_op, mtl_rx_int;
 
 	/* Following code only done for channel 0, other channels not yet
@@ -250,6 +251,53 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 			mtl_rx_op |= MTL_OP_MODE_RTC_128;
 	}
 
+	mtl_rx_op &= ~MTL_OP_MODE_RQS_MASK;
+	mtl_rx_op |= rqs << MTL_OP_MODE_RQS_SHIFT;
+
+	/* enable flow control only if each channel gets 4 KiB or more FIFO */
+	if (rxfifosz >= 4096) {
+		unsigned int rfd, rfa;
+
+		mtl_rx_op |= MTL_OP_MODE_EHFC;
+
+		/* Set Threshold for Activating Flow Control to min 2 frames,
+		 * i.e. 1500 * 2 = 3000 bytes.
+		 *
+		 * Set Threshold for Deactivating Flow Control to min 1 frame,
+		 * i.e. 1500 bytes.
+		 */
+		switch (rxfifosz) {
+		case 4096:
+			/* This violates the above formula because of FIFO size
+			 * limit therefore overflow may occur in spite of this.
+			 */
+			rfd = 0x03; /* Full-2.5K */
+			rfa = 0x01; /* Full-1.5K */
+			break;
+
+		case 8192:
+			rfd = 0x06; /* Full-4K */
+			rfa = 0x0a; /* Full-6K */
+			break;
+
+		case 16384:
+			rfd = 0x06; /* Full-4K */
+			rfa = 0x12; /* Full-10K */
+			break;
+
+		default:
+			rfd = 0x06; /* Full-4K */
+			rfa = 0x1e; /* Full-16K */
+			break;
+		}
+
+		mtl_rx_op &= ~MTL_OP_MODE_RFD_MASK;
+		mtl_rx_op |= rfd << MTL_OP_MODE_RFD_SHIFT;
+
+		mtl_rx_op &= ~MTL_OP_MODE_RFA_MASK;
+		mtl_rx_op |= rfa << MTL_OP_MODE_RFA_SHIFT;
+	}
+
 	writel(mtl_rx_op, ioaddr + MTL_CHAN_RX_OP_MODE(channel));
 
 	/* Enable MTL RX overflow */
@@ -262,7 +310,7 @@ static void dwmac4_dma_operation_mode(void __iomem *ioaddr, int txmode,
 				      int rxmode, int rxfifosz)
 {
 	/* Only Channel 0 is actually configured and used */
-	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0);
+	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0, rxfifosz);
 }
 
 static void dwmac4_get_hw_feature(void __iomem *ioaddr,
-- 
2.12.0
