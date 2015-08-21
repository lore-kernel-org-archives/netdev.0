From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: [PATCH v2] net: bcmgenet: fix uncleaned dma flags
Date: Fri, 21 Aug 2015 10:08:26 +0900
Message-ID: <1440119306-6789-1-git-send-email-jaedon.shin@gmail.com>
Cc: Jaedon Shin <jaedon.shin@gmail.com>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36509 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbbHUBNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 21:13:00 -0400
Received: by pawq9 with SMTP id q9so39835096paw.3
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 18:13:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean the dma flags of multiq ring buffer int the interface stop
process. This patch fixes that the genet is not running while the
interface is re-enabled.

$ ifup eth0 - running after booting
$ ifdown eth0
$ ifup eth0 - not running and occur tx_timeout

The bcmgenet_dma_disable() in bcmgenet_open() do clean ring16 dma flag
only. If the genet has multiq, the dma register is not cleaned. and
bcmgenet_init_dma() is not done correctly. in case
GENET_V2(tx_queues=4), tdma_ctrl has 0x1e after running
bcmgenet_dma_disable().

Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 64c1e9db6b0b..4812565c783e 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2126,6 +2126,8 @@ static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
 	int ret = 0;
 	int timeout = 0;
 	u32 reg;
+	u32 dma_ctrl;
+	int i;
 
 	/* Disable TDMA to stop add more frames in TX DMA */
 	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
@@ -2169,6 +2171,20 @@ static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
 		ret = -ETIMEDOUT;
 	}
 
+	dma_ctrl = 0;
+	for (i = 0; i < priv->hw_params->rx_queues; i++)
+		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
+	reg = bcmgenet_rdma_readl(priv, DMA_CTRL);
+	reg &= ~dma_ctrl;
+	bcmgenet_rdma_writel(priv, reg, DMA_CTRL);
+
+	dma_ctrl = 0;
+	for (i = 0; i < priv->hw_params->tx_queues; i++)
+		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
+	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
+	reg &= ~dma_ctrl;
+	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
+
 	return ret;
 }
 
-- 
2.5.0
