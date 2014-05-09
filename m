From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 2/3] net: sxgbe: Added tail point update
Date: Fri, 09 May 2014 11:03:47 +0900
Message-ID: <003c01cf6b2a$e9dac1e0$bd9045a0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, "'ks.giri'" <ks.giri@samsung.com>,
	"'vipul.pandya'" <vipul.pandya@samsung.com>
To: 'netdev' <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:25241 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355AbaEICDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 22:03:49 -0400
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds tail point update function for rx path
after rx_refill function. It indicate tail point to rx
dma.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c  |   14 +++++++++++++-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h  |    4 ++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |    5 +++++
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
index 49240c9..249b0e0 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
@@ -112,7 +112,7 @@ static void sxgbe_dma_channel_init(void __iomem *ioaddr, int cha_num,
 
 	dma_addr = dma_rx + ((r_rsize - 1) * SXGBE_DESC_SIZE_BYTES);
 	writel(lower_32_bits(dma_addr),
-	       ioaddr + SXGBE_DMA_CHA_RXDESC_LADD_REG(cha_num));
+	       ioaddr + SXGBE_DMA_CHA_RXDESC_TAILPTR_REG(cha_num));
 	/* program the ring sizes */
 	writel(t_rsize - 1, ioaddr + SXGBE_DMA_CHA_TXDESC_RINGLEN_REG(cha_num));
 	writel(r_rsize - 1, ioaddr + SXGBE_DMA_CHA_RXDESC_RINGLEN_REG(cha_num));
@@ -370,6 +370,17 @@ static void sxgbe_enable_tso(void __iomem *ioaddr, u8 chan_num)
 	writel(ctrl, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(chan_num));
 }
 
+static void sxgbe_dma_update_rxdesc_tail_ptr(void __iomem *ioaddr, u8 chan_num,
+					      dma_addr_t dma_rx_phy, int cur_rx,
+					      int rxsize)
+{
+	u32 reg_val;
+
+	reg_val = (dma_rx_phy & 0xFFFFFFFF) + ((cur_rx % rxsize) *
+					       SXGBE_DESC_SIZE_BYTES);
+	writel(reg_val, ioaddr + SXGBE_DMA_CHA_RXDESC_TAILPTR_REG(chan_num));
+}
+
 static const struct sxgbe_dma_ops sxgbe_dma_ops = {
 	.init				= sxgbe_dma_init,
 	.cha_init			= sxgbe_dma_channel_init,
@@ -386,6 +397,7 @@ static const struct sxgbe_dma_ops sxgbe_dma_ops = {
 	.rx_dma_int_status		= sxgbe_rx_dma_int_status,
 	.rx_watchdog			= sxgbe_dma_rx_watchdog,
 	.enable_tso			= sxgbe_enable_tso,
+	.update_rxdesc_tail_ptr		= sxgbe_dma_update_rxdesc_tail_ptr,
 };
 
 const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
index 843fa9b..a06e01e 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
@@ -43,6 +43,10 @@ struct sxgbe_dma_ops {
 	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt);
 	/* Enable TSO for each DMA channel */
 	void (*enable_tso)(void __iomem *ioaddr, u8 chan_num);
+	void (*update_rxdesc_tail_ptr)(void __iomem *ioaddr, u8 chan_num,
+				       dma_addr_t dma_rx, int r_rentry,
+				       int r_rsize);
+
 };
 
 const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void);
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 93bf151..7dc3449 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1521,6 +1521,7 @@ static int sxgbe_rx(struct sxgbe_priv_data *priv, int limit)
 		skb_put(skb, frame_len);
 
 		skb->ip_summed = checksum;
+		skb->protocol = eth_type_trans(skb, priv->dev);
 		if (checksum == CHECKSUM_NONE)
 			netif_receive_skb(skb);
 		else
@@ -1530,6 +1531,10 @@ static int sxgbe_rx(struct sxgbe_priv_data *priv, int limit)
 	}
 
 	sxgbe_rx_refill(priv);
+	priv->hw->dma->update_rxdesc_tail_ptr(priv->ioaddr, qnum,
+					      priv->rxq[qnum]->dma_rx_phy,
+					      priv->rxq[qnum]->cur_rx,
+					      priv->dma_rx_size);
 
 	return count;
 }
-- 
1.7.10.4
