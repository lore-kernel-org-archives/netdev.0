From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH 4/6] net/macb: add RX checksum offload feature
Date: Fri, 18 Jul 2014 16:21:16 +0200
Message-ID: <f29965fee23dc0de99b388373017efeffa1aac10.1405689937.git.cyrille.pitchen@atmel.com>
References: <cover.1405689937.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1405689937.git.cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 29 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/cadence/macb.h |  2 ++
 2 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 9bdcd1b..6acd6e2 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -766,6 +766,8 @@ static int gem_rx(struct macb *bp, int budget)
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		skb_checksum_none_assert(skb);
+		if (bp->dev->features & NETIF_F_RXCSUM)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		bp->stats.rx_packets++;
 		bp->stats.rx_bytes += skb->len;
@@ -1506,6 +1508,18 @@ static u32 macb_dbw(struct macb *bp)
 }
 
 /*
+ * Configure the RX checksum offload
+ */
+static u32 macb_rxcsum(struct macb *bp)
+{
+	if (macb_is_gem(bp) &&
+	    (bp->dev->features & NETIF_F_RXCSUM))
+		return GEM_BIT(RXCOEN);
+
+	return 0;
+}
+
+/*
  * Configure the receive DMA engine
  * - use the correct receive buffer size
  * - set best burst length for DMA operations
@@ -1550,6 +1564,7 @@ static void macb_init_hw(struct macb *bp)
 	if (!(bp->dev->flags & IFF_BROADCAST))
 		config |= MACB_BIT(NBC);	/* No BroadCast */
 	config |= macb_dbw(bp);
+	config |= macb_rxcsum(bp);
 	macb_writel(bp, NCFGR, config);
 	bp->speed = SPEED_10;
 	bp->duplex = DUPLEX_HALF;
@@ -1945,6 +1960,18 @@ static int macb_set_features(struct net_device *netdev,
 		gem_writel(bp, DMACFG, dmacfg);
 	}
 
+	/* RX checksum offload */
+	if ((changed & NETIF_F_RXCSUM) && macb_is_gem(bp)) {
+		u32 netcfg;
+
+		netcfg = gem_readl(bp, NCFGR);
+		if (features & NETIF_F_RXCSUM)
+			netcfg |= GEM_BIT(RXCOEN);
+		else
+			netcfg &= ~GEM_BIT(RXCOEN);
+		gem_writel(bp, NCFGR, netcfg);
+	}
+
 	return 0;
 }
 
@@ -2146,7 +2173,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	dev->hw_features = NETIF_F_SG;
 	if (macb_is_gem(bp) && !(bp->caps & MACB_CAPS_FIFO_MODE)) {
 		/* Checksum offload is only available on packet buffer design */
-		dev->hw_features |= NETIF_F_HW_CSUM;
+		dev->hw_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	}
 	if (bp->caps & MACB_CAPS_SG_DISABLED)
 		dev->hw_features &= ~NETIF_F_SG;
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 7bf8285..3678b83 100644
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
-- 
1.8.2.2
