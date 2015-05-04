From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [net-next PATCH v2 2/3] net: macb: Add support for jumbo frames
Date: Mon, 4 May 2015 13:22:39 +0530
Message-ID: <b7d968f7-1eb8-4a37-ae28-e7b841d6b178@BY2FFO11FD038.protection.gbl>
References: <1430725960-8441-1-git-send-email-harinik@xilinx.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0076.outbound.protection.outlook.com ([157.56.110.76]:30421
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751954AbbEDHxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 03:53:01 -0400
In-Reply-To: <1430725960-8441-1-git-send-email-harinik@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for "cdns,zynqmp-gem" compatible string and enable jumbo frame support
in NWCFG register, update descriptor length masks and registers accordingly.
Jumbo max length register should be set according to support in SoC; it is
set to 10240 for Zynq Ultrascale+ MPSoC.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---

On v1, Michal commented that I should use macb_config for jumbo parameters
instead of defining them by reading the compatible string directly.
I can use .caps for isjumbo. But jumbo-max-length needs to be defined.
Can I add this to the structure? Any suggestions on how to handle this?

v2:
Add constant definition and update SoC name

---
 drivers/net/ethernet/cadence/macb.c |   21 ++++++++++++++++++---
 drivers/net/ethernet/cadence/macb.h |    8 ++++++++
 2 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4104d49..a065283 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -54,6 +54,8 @@
 #define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
 #define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
 
+#define GEM_ZYNQMP_JUMBO_MAX	10240
+
 /*
  * Graceful stop timeouts in us. We should allow up to
  * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
@@ -782,7 +784,7 @@ static int gem_rx(struct macb *bp, int budget)
 		}
 		/* now everything is ready for receiving packet */
 		bp->rx_skbuff[entry] = NULL;
-		len = MACB_BFEXT(RX_FRMLEN, ctrl);
+		len = ctrl & bp->rx_frm_len_mask;
 
 		netdev_vdbg(bp->dev, "gem_rx %u (len %u)\n", entry, len);
 
@@ -828,7 +830,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	struct macb_dma_desc *desc;
 
 	desc = macb_rx_desc(bp, last_frag);
-	len = MACB_BFEXT(RX_FRMLEN, desc->ctrl);
+	len = desc->ctrl & bp->rx_frm_len_mask;
 
 	netdev_vdbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
 		macb_rx_ring_wrap(first_frag),
@@ -1633,7 +1635,10 @@ static void macb_init_hw(struct macb *bp)
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
@@ -1642,8 +1647,13 @@ static void macb_init_hw(struct macb *bp)
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
 
@@ -2762,6 +2772,11 @@ static int macb_probe(struct platform_device *pdev)
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
