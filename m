From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 5/7] net: stmmac: Program RX queue size and flow control
Date: Thu, 23 Feb 2017 18:24:36 +0100
Message-ID: <20170223172438.14770-6-thierry.reding@gmail.com>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Alexandre Courbot <gnurou@gmail.com>,
        Jon Hunter <jonathanh@nvidia.com>, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223172438.14770-1-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Program the receive queue size based on the RX FIFO size and enable
hardware flow control for large FIFOs.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h     | 12 +++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c | 43 ++++++++++++++++++++++--
 2 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index db45134fddf0..9acc1f1252b3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -180,6 +180,7 @@ enum power_event {
 #define MTL_OP_MODE_TSF			BIT(1)
 
 #define MTL_OP_MODE_TQS_MASK		GENMASK(24, 16)
+#define MTL_OP_MODE_TQS_SHIFT		16
 
 #define MTL_OP_MODE_TTC_MASK		0x70
 #define MTL_OP_MODE_TTC_SHIFT		4
@@ -193,6 +194,17 @@ enum power_event {
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
index 8d249f3b34c8..03d230201960 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -185,8 +185,9 @@ static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt)
 }
 
 static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
-				    int rxmode, u32 channel)
+				    int rxmode, u32 channel, int rxfifosz)
 {
+	unsigned int rqs = rxfifosz / 256 - 1;
 	u32 mtl_tx_op, mtl_rx_op, mtl_rx_int;
 
 	/* Following code only done for channel 0, other channels not yet
@@ -252,6 +253,44 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
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
+		switch (rxfifosz) {
+		case 4096:
+			rfd = 0x03;
+			rfa = 0x01;
+			break;
+
+		case 8192:
+			rfd = 0x06;
+			rfa = 0x0a;
+			break;
+
+		case 16384:
+			rfd = 0x06;
+			rfa = 0x12;
+			break;
+
+		default:
+			rfd = 0x06;
+			rfa = 0x1e;
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
@@ -264,7 +303,7 @@ static void dwmac4_dma_operation_mode(void __iomem *ioaddr, int txmode,
 				      int rxmode, int rxfifosz)
 {
 	/* Only Channel 0 is actually configured and used */
-	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0);
+	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0, rxfifosz);
 }
 
 static void dwmac4_get_hw_feature(void __iomem *ioaddr,
-- 
2.11.1
