From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [net-next PATCH 2/3] net: macb: Add support for jumbo frames
Date: Fri, 10 Apr 2015 14:47:20 +0530
Message-ID: <6680752c-a0a0-4199-af32-ba225812603c@BL2FFO11FD007.protection.gbl>
References: <1428657441-27710-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <harinik@xilinx.com>,
	<punnaia@xilinx.com>, <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428657441-27710-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check for "cdns,zynqmp-gem" compatible string and enable jumbo frame support
in NWCFG register, update descriptor length masks and registers accordingly.
Jumbo max length register should be set according to support in SoC; it is
set to 10240 for Zynq Ultrascale ZynqMPSoC.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c |   19 ++++++++++++++++---
 drivers/net/ethernet/cadence/macb.h |    8 ++++++++
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 448a323..85de91d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -779,7 +779,7 @@ static int gem_rx(struct macb *bp, int budget)
 		}
 		/* now everything is ready for receiving packet */
 		bp->rx_skbuff[entry] = NULL;
-		len = MACB_BFEXT(RX_FRMLEN, ctrl);
+		len = ctrl & bp->rx_frm_len_mask;
 
 		netdev_vdbg(bp->dev, "gem_rx %u (len %u)\n", entry, len);
 
@@ -825,7 +825,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	struct macb_dma_desc *desc;
 
 	desc = macb_rx_desc(bp, last_frag);
-	len = MACB_BFEXT(RX_FRMLEN, desc->ctrl);
+	len = desc->ctrl & bp->rx_frm_len_mask;
 
 	netdev_vdbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
 		macb_rx_ring_wrap(first_frag),
@@ -1630,7 +1630,10 @@ static void macb_init_hw(struct macb *bp)
 	config |= MACB_BF(RBOF, NET_IP_ALIGN);	/* Make eth data aligned */
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
-	config |= MACB_BIT(BIG);		/* Receive oversized frames */
+	if (bp->isjumbo)
+		config |= MACB_BIT(JFRAME);	/* Enable jumbo frames */
+	else
+		config |= MACB_BIT(BIG);	/* Receive oversized frames */
 	if (bp->dev->flags & IFF_PROMISC)
 		config |= MACB_BIT(CAF);	/* Copy All Frames */
 	else if (macb_is_gem(bp) && bp->dev->features & NETIF_F_RXCSUM)
@@ -1639,8 +1642,13 @@ static void macb_init_hw(struct macb *bp)
 		config |= MACB_BIT(NBC);	/* No BroadCast */
 	config |= macb_dbw(bp);
 	macb_writel(bp, NCFGR, config);
+	if (bp->isjumbo && bp->jumbo_max_len)
+		gem_writel(bp, JML, bp->jumbo_max_len);
 	bp->speed = SPEED_10;
 	bp->duplex = DUPLEX_HALF;
+	bp->rx_frm_len_mask = MACB_RX_FRMLEN_MASK;
+	if (bp->isjumbo)
+		bp->rx_frm_len_mask = MACB_RX_JFRMLEN_MASK;
 
 	macb_configure_dma(bp);
 
@@ -2759,6 +2767,11 @@ static int macb_probe(struct platform_device *pdev)
 	bp->pclk = pclk;
 	bp->hclk = hclk;
 	bp->tx_clk = tx_clk;
+	if (of_device_is_compatible(pdev->dev.of_node, "cdns,zynqmp-gem")) {
+		bp->isjumbo = 1;
+		bp->jumbo_max_len = GEM_ZYNQMP_JUMBO_MAX;
+	}
+
 	spin_lock_init(&bp->lock);
 
 	/* setup capabilities */
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index eb7d76f..e25f77e 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -71,6 +71,7 @@
 #define GEM_NCFGR		0x0004 /* Network Config */
 #define GEM_USRIO		0x000c /* User IO */
 #define GEM_DMACFG		0x0010 /* DMA Configuration */
+#define GEM_JML			0x0048 /* Jumbo Max Length */
 #define GEM_HRB			0x0080 /* Hash Bottom */
 #define GEM_HRT			0x0084 /* Hash Top */
 #define GEM_SA1B		0x0088 /* Specific1 Bottom */
@@ -514,6 +515,9 @@ struct macb_dma_desc {
 #define MACB_RX_BROADCAST_OFFSET		31
 #define MACB_RX_BROADCAST_SIZE			1
 
+#define MACB_RX_FRMLEN_MASK			0xFFF
+#define MACB_RX_JFRMLEN_MASK			0x3FFF
+
 /* RX checksum offload disabled: bit 24 clear in NCFGR */
 #define GEM_RX_TYPEID_MATCH_OFFSET		22
 #define GEM_RX_TYPEID_MATCH_SIZE		2
@@ -826,6 +830,10 @@ struct macb {
 	unsigned int		max_tx_length;
 
 	u64			ethtool_stats[GEM_STATS_LEN];
+
+	unsigned int		rx_frm_len_mask;
+	unsigned int		jumbo_max_len;
+	bool			isjumbo;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
1.7.9.5
