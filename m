From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH v2 4/6] net/macb: add RX checksum offload feature
Date: Thu, 24 Jul 2014 13:51:01 +0200
Message-ID: <b828f928b2a3477a10d0ec15b85f957bab3b3ca6.1406192657.git.cyrille.pitchen@atmel.com>
References: <cover.1406192657.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1406192657.git.cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When RX checksum offload is enabled at GEM level (bit 24 set in the Network
Control Register), frames with invalid IP, TCP or UDP checksums are
discarted even if promiscuous mode is enabled (bit 4 set in the Network Control
Register).

This was verified with a simple userspace program, which corrupts UDP checksum
using libnetfilter_queue.

Then both IFF_PROMISC bit must be clear in dev->flags and NETIF_F_RXCSUM bit
must be set in dev->features to enable RX checksum offload at GEM level. This
way tcpdump is still able to capture corrupted frames.

Also skb->ip_summed is set to CHECKSUM_UNNECESSARY only when both TCP/IP or
UDP/IP checksums were verified by the GEM. Indeed the GEM may verify only IP
checksum but not the one for ICMP (or other protocol than TCP or UDP).

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 36 ++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/cadence/macb.h | 19 +++++++++++++++++++
 2 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index cc36269..6836f88 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -765,6 +765,10 @@ static int gem_rx(struct macb *bp, int budget)
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		skb_checksum_none_assert(skb);
+		if (bp->dev->features & NETIF_F_RXCSUM &&
+		    !(bp->dev->flags & IFF_PROMISC) &&
+		    GEM_BFEXT(RX_CSUM, ctrl) & GEM_RX_CSUM_CHECKED_MASK)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		bp->stats.rx_packets++;
 		bp->stats.rx_bytes += skb->len;
@@ -1549,6 +1553,8 @@ static void macb_init_hw(struct macb *bp)
 	config |= MACB_BIT(BIG);		/* Receive oversized frames */
 	if (bp->dev->flags & IFF_PROMISC)
 		config |= MACB_BIT(CAF);	/* Copy All Frames */
+	else if (macb_is_gem(bp) && bp->dev->features & NETIF_F_RXCSUM)
+		config |= GEM_BIT(RXCOEN);
 	if (!(bp->dev->flags & IFF_BROADCAST))
 		config |= MACB_BIT(NBC);	/* No BroadCast */
 	config |= macb_dbw(bp);
@@ -1662,13 +1668,22 @@ void macb_set_rx_mode(struct net_device *dev)
 
 	cfg = macb_readl(bp, NCFGR);
 
-	if (dev->flags & IFF_PROMISC)
+	if (dev->flags & IFF_PROMISC) {
 		/* Enable promiscuous mode */
 		cfg |= MACB_BIT(CAF);
-	else if (dev->flags & (~IFF_PROMISC))
-		 /* Disable promiscuous mode */
+
+		/* Disable RX checksum offload */
+		if (macb_is_gem(bp))
+			cfg &= ~GEM_BIT(RXCOEN);
+	} else {
+		/* Disable promiscuous mode */
 		cfg &= ~MACB_BIT(CAF);
 
+		/* Enable RX checksum offload only if requested */
+		if (macb_is_gem(bp) && dev->features & NETIF_F_RXCSUM)
+			cfg |= GEM_BIT(RXCOEN);
+	}
+
 	if (dev->flags & IFF_ALLMULTI) {
 		/* Enable all multicast mode */
 		macb_or_gem_writel(bp, HRB, -1);
@@ -1947,6 +1962,19 @@ static int macb_set_features(struct net_device *netdev,
 		gem_writel(bp, DMACFG, dmacfg);
 	}
 
+	/* RX checksum offload */
+	if ((changed & NETIF_F_RXCSUM) && macb_is_gem(bp)) {
+		u32 netcfg;
+
+		netcfg = gem_readl(bp, NCFGR);
+		if (features & NETIF_F_RXCSUM &&
+		    !(netdev->flags & IFF_PROMISC))
+			netcfg |= GEM_BIT(RXCOEN);
+		else
+			netcfg &= ~GEM_BIT(RXCOEN);
+		gem_writel(bp, NCFGR, netcfg);
+	}
+
 	return 0;
 }
 
@@ -2150,7 +2178,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	dev->hw_features = NETIF_F_SG;
 	/* Checksum offload is only available on gem with packet buffer */
 	if (macb_is_gem(bp) && !(bp->caps & MACB_CAPS_FIFO_MODE))
-		dev->hw_features |= NETIF_F_HW_CSUM;
+		dev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	if (bp->caps & MACB_CAPS_SG_DISABLED)
 		dev->hw_features &= ~NETIF_F_SG;
 	dev->features = dev->hw_features;
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 7bf8285..517c09d 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -164,6 +164,8 @@
 #define GEM_CLK_SIZE				3
 #define GEM_DBW_OFFSET				21
 #define GEM_DBW_SIZE				2
+#define GEM_RXCOEN_OFFSET			24
+#define GEM_RXCOEN_SIZE				1
 
 /* Constants for data bus width. */
 #define GEM_DBW32				0
@@ -452,6 +454,14 @@ struct macb_dma_desc {
 #define MACB_RX_BROADCAST_OFFSET		31
 #define MACB_RX_BROADCAST_SIZE			1
 
+/* RX checksum offload disabled: bit 24 clear in NCFGR */
+#define GEM_RX_TYPEID_MATCH_OFFSET		22
+#define GEM_RX_TYPEID_MATCH_SIZE		2
+
+/* RX checksum offload enabled: bit 24 set in NCFGR */
+#define GEM_RX_CSUM_OFFSET			22
+#define GEM_RX_CSUM_SIZE			2
+
 #define MACB_TX_FRMLEN_OFFSET			0
 #define MACB_TX_FRMLEN_SIZE			11
 #define MACB_TX_LAST_OFFSET			15
@@ -472,6 +482,15 @@ struct macb_dma_desc {
 #define GEM_TX_FRMLEN_OFFSET			0
 #define GEM_TX_FRMLEN_SIZE			14
 
+/* Buffer descriptor constants */
+#define GEM_RX_CSUM_NONE			0
+#define GEM_RX_CSUM_IP_ONLY			1
+#define GEM_RX_CSUM_IP_TCP			2
+#define GEM_RX_CSUM_IP_UDP			3
+
+/* limit RX checksum offload to TCP and UDP packets */
+#define GEM_RX_CSUM_CHECKED_MASK		2
+
 /**
  * struct macb_tx_skb - data about an skb which is being transmitted
  * @skb: skb currently being transmitted, only set for the last buffer
-- 
1.8.2.2
