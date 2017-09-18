From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net 1/3] net: mvpp2: fix the dma_mask and coherent_dma_mask settings for PPv2.2
Date: Mon, 18 Sep 2017 15:04:06 +0200
Message-ID: <20170918130408.23114-2-antoine.tenart@free-electrons.com>
References: <20170918130408.23114-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918130408.23114-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dev->dma_mask usually points to dev->coherent_dma_mask. This is an
issue as setting both of them will override the other. This is
problematic here as the PPv2 driver uses a 32-bit-mask for coherent
accesses (txq, rxq, bm) and a 40-bit mask for all other accesses due to
an hardware limitation.

This can lead to a memory remap for all dma_map_single() calls when
dealing with memory above 4GB.

Fixes: 2067e0a13cfe ("net: mvpp2: set dma mask and coherent dma mask on PPv2.2")
Reported-by: Stefan Chulski <stefanc@marvell.com>
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index dd0ee2691c86..7024d4dbb461 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -7969,9 +7969,25 @@ static int mvpp2_probe(struct platform_device *pdev)
 	priv->tclk = clk_get_rate(priv->pp_clk);
 
 	if (priv->hw_version == MVPP22) {
+		/* If dma_mask points to coherent_dma_mask, setting both will
+		 * override the value of the other. This is problematic as the
+		 * PPv2 driver uses a 32-bit-mask for coherent accesses (txq,
+		 * rxq, bm) and a 40-bit mask for all other accesses.
+		 */
+		if (pdev->dev.dma_mask == &pdev->dev.coherent_dma_mask) {
+			pdev->dev.dma_mask = devm_kzalloc(&pdev->dev,
+							  sizeof(*pdev->dev.dma_mask),
+							  GFP_KERNEL);
+			if (!pdev->dev.dma_mask) {
+				err = -ENOMEM;
+				goto err_mg_clk;
+			}
+		}
+
 		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(40));
 		if (err)
 			goto err_mg_clk;
+
 		/* Sadly, the BM pools all share the same register to
 		 * store the high 32 bits of their address. So they
 		 * must all have the same high 32 bits, which forces
-- 
2.13.5
