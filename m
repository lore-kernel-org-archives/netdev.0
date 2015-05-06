From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [net-next PATCH v3 3/4] net: macb: Add support for jumbo frames
Date: Wed, 6 May 2015 22:27:17 +0530
Message-ID: <1430931438-32592-3-git-send-email-harinik@xilinx.com>
References: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
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
In-Reply-To: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable jumbo frame support for Zynq Ultrascale+ MPSoC.
Update the NWCFG register and descriptor length masks accordingly.
Jumbo max length register should be set according to support in SoC; it is
set to 10240 for Zynq Ultrascale+ MPSoC.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---

v3:
Use macb_config for declaring jumbo capability and max size.

v2:
Add constant definition and update SoC name

---
 drivers/net/ethernet/cadence/macb.c |   22 ++++++++++++++++++----
 drivers/net/ethernet/cadence/macb.h |    9 +++++++++
 2 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index bbe5656..cb84587 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -782,7 +782,7 @@ static int gem_rx(struct macb *bp, int budget)
 		}
 		/* now everything is ready for receiving packet */
 		bp->rx_skbuff[entry] = NULL;
-		len = MACB_BFEXT(RX_FRMLEN, ctrl);
+		len = ctrl & bp->rx_frm_len_mask;
 
 		netdev_vdbg(bp->dev, "gem_rx %u (len %u)\n", entry, len);
 
@@ -828,7 +828,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	struct macb_dma_desc *desc;
 
 	desc = macb_rx_desc(bp, last_frag);
-	len = MACB_BFEXT(RX_FRMLEN, desc->ctrl);
+	len = desc->ctrl & bp->rx_frm_len_mask;
 
 	netdev_vdbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
 		macb_rx_ring_wrap(first_frag),
@@ -1633,7 +1633,10 @@ static void macb_init_hw(struct macb *bp)
 	config |= MACB_BF(RBOF, NET_IP_ALIGN);	/* Make eth data aligned */
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
-	config |= MACB_BIT(BIG);		/* Receive oversized frames */
+	if (bp->caps | MACB_CAPS_JUMBO)
+		config |= MACB_BIT(JFRAME);	/* Enable jumbo frames */
+	else
+		config |= MACB_BIT(BIG);	/* Receive oversized frames */
 	if (bp->dev->flags & IFF_PROMISC)
 		config |= MACB_BIT(CAF);	/* Copy All Frames */
 	else if (macb_is_gem(bp) && bp->dev->features & NETIF_F_RXCSUM)
@@ -1642,8 +1645,13 @@ static void macb_init_hw(struct macb *bp)
 		config |= MACB_BIT(NBC);	/* No BroadCast */
 	config |= macb_dbw(bp);
 	macb_writel(bp, NCFGR, config);
+	if ((bp->caps | MACB_CAPS_JUMBO) && bp->jumbo_max_len)
+		gem_writel(bp, JML, bp->jumbo_max_len);
 	bp->speed = SPEED_10;
 	bp->duplex = DUPLEX_HALF;
+	bp->rx_frm_len_mask = MACB_RX_FRMLEN_MASK;
+	if (bp->caps | MACB_CAPS_JUMBO)
+		bp->rx_frm_len_mask = MACB_RX_JFRMLEN_MASK;
 
 	macb_configure_dma(bp);
 
@@ -2685,10 +2693,12 @@ static const struct macb_config emac_config = {
 };
 
 static const struct macb_config zynqmp_config = {
-	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
+	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE |
+		MACB_CAPS_JUMBO,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
+	.jumbo_max_len = 10240,
 };
 
 static const struct of_device_id macb_dt_ids[] = {
@@ -2770,6 +2780,10 @@ static int macb_probe(struct platform_device *pdev)
 	bp->pclk = pclk;
 	bp->hclk = hclk;
 	bp->tx_clk = tx_clk;
+	if (macb_config->jumbo_max_len) {
+		bp->jumbo_max_len = macb_config->jumbo_max_len;
+	}
+
 	spin_lock_init(&bp->lock);
 
 	/* setup capabilities */
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index eb7d76f..7d4ef51 100644
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
@@ -397,6 +398,7 @@
 #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
 #define MACB_CAPS_SG_DISABLED			0x40000000
 #define MACB_CAPS_MACB_IS_GEM			0x80000000
+#define MACB_CAPS_JUMBO				0x00000008
 
 /* Bit manipulation macros */
 #define MACB_BIT(name)					\
@@ -514,6 +516,9 @@ struct macb_dma_desc {
 #define MACB_RX_BROADCAST_OFFSET		31
 #define MACB_RX_BROADCAST_SIZE			1
 
+#define MACB_RX_FRMLEN_MASK			0xFFF
+#define MACB_RX_JFRMLEN_MASK			0x3FFF
+
 /* RX checksum offload disabled: bit 24 clear in NCFGR */
 #define GEM_RX_TYPEID_MATCH_OFFSET		22
 #define GEM_RX_TYPEID_MATCH_SIZE		2
@@ -757,6 +762,7 @@ struct macb_config {
 	int	(*clk_init)(struct platform_device *pdev, struct clk **pclk,
 			    struct clk **hclk, struct clk **tx_clk);
 	int	(*init)(struct platform_device *pdev);
+	int	jumbo_max_len;
 };
 
 struct macb_queue {
@@ -826,6 +832,9 @@ struct macb {
 	unsigned int		max_tx_length;
 
 	u64			ethtool_stats[GEM_STATS_LEN];
+
+	unsigned int		rx_frm_len_mask;
+	unsigned int		jumbo_max_len;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
1.7.9.5
