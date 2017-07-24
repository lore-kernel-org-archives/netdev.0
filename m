From: Robin Murphy <robin.murphy-5wv7dgnIgG8@public.gmane.org>
Subject: [PATCH] qtfnmac: Tidy up DMA mask setting
Date: Mon, 24 Jul 2017 18:41:30 +0100
Message-ID: <2c3f47792b2e38d5584d641d98e82f8318fefc72.1500917445.git.robin.murphy@arm.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: imitsyanko-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org, avinashp-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org,
        smatyukevich-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

As the only caller of dma_supported() outside of DMA API internals, the
qtfnmac driver stands out and invites scrutiny. Thankfully, it's not
being used for evil, but it is entirely redundant, since it open-codes a
check that the DMA mask setting functions are going to perform anyway.
In fact, the whole qtnf_pcie_init_dma_mask() function is nothing more
than a rather long-winded implementation of dma_set_mask_and_coherent(),
so let's just use that directly.

Signed-off-by: Robin Murphy <robin.murphy-5wv7dgnIgG8@public.gmane.org>
---
 .../net/wireless/quantenna/qtnfmac/pearl/pcie.c    | 28 +---------------------
 1 file changed, 1 insertion(+), 27 deletions(-)

diff --git a/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c b/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
index 7fc4f0d6a9ad..2c065ffda070 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
+++ b/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
@@ -274,32 +274,6 @@ static int qtnf_pcie_init_memory(struct qtnf_pcie_bus_priv *priv)
 	return 0;
 }
 
-static int
-qtnf_pcie_init_dma_mask(struct qtnf_pcie_bus_priv *priv, u64 dma_mask)
-{
-	int ret;
-
-	ret = dma_supported(&priv->pdev->dev, dma_mask);
-	if (!ret) {
-		pr_err("DMA mask %llu not supported\n", dma_mask);
-		return ret;
-	}
-
-	ret = pci_set_dma_mask(priv->pdev, dma_mask);
-	if (ret) {
-		pr_err("failed to set DMA mask %llu\n", dma_mask);
-		return ret;
-	}
-
-	ret = pci_set_consistent_dma_mask(priv->pdev, dma_mask);
-	if (ret) {
-		pr_err("failed to set consistent DMA mask %llu\n", dma_mask);
-		return ret;
-	}
-
-	return ret;
-}
