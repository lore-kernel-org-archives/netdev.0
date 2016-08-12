From: Shubhrajyoti Datta <shubhrajyoti.datta-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC] net: ethernet: macb: Add support for rx_clk
Date: Fri, 12 Aug 2016 14:41:45 +0530
Message-ID: <1470993105-17051-1-git-send-email-shubhrajyoti.datta@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <shubhrajyoti.datta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Shubhrajyoti Datta <shubhrajyoti.datta-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some of the platforms like zynqmp ultrascale+ has a
separate clock gate for the rx clock. Add an optional
rx_clk so that the clock can be enabled.

Signed-off-by: Shubhrajyoti Datta <shubhrajyoti.datta-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
---
 Documentation/devicetree/bindings/net/macb.txt |  2 +-
 drivers/net/ethernet/cadence/macb.c            | 27 ++++++++++++++++++++++----
 drivers/net/ethernet/cadence/macb.h            |  4 +++-
 3 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index b5a42df..315beda 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -20,7 +20,7 @@ Required properties:
 - phy-mode: See ethernet.txt file in the same directory.
 - clock-names: Tuple listing input clock names.
 	Required elements: 'pclk', 'hclk'
-	Optional elements: 'tx_clk'
+	Optional elements: 'tx_clk', 'rx_clk'
 - clocks: Phandles to input clocks.
 
 Optional properties for PHY child node:
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 89c0cfa..1e9fd5c 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2303,7 +2303,8 @@ static void macb_probe_queues(void __iomem *mem,
 }
 
 static int macb_clk_init(struct platform_device *pdev, struct clk **pclk,
-			 struct clk **hclk, struct clk **tx_clk)
+			 struct clk **hclk, struct clk **tx_clk,
+			 struct clk **rx_clk)
 {
 	int err;
 
@@ -2325,6 +2326,10 @@ static int macb_clk_init(struct platform_device *pdev, struct clk **pclk,
 	if (IS_ERR(*tx_clk))
 		*tx_clk = NULL;
 
+	*rx_clk = devm_clk_get(&pdev->dev, "rx_clk");
+	if (IS_ERR(*rx_clk))
+		*rx_clk = NULL;
+
 	err = clk_prepare_enable(*pclk);
 	if (err) {
 		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
@@ -2343,8 +2348,17 @@ static int macb_clk_init(struct platform_device *pdev, struct clk **pclk,
 		goto err_disable_hclk;
 	}
 
+	err = clk_prepare_enable(*rx_clk);
+	if (err) {
+		dev_err(&pdev->dev, "failed to enable rx_clk (%u)\n", err);
+		goto err_disable_txclk;
+	}
+
 	return 0;
 
+err_disable_txclk:
+	clk_disable_unprepare(*tx_clk);
+
 err_disable_hclk:
 	clk_disable_unprepare(*hclk);
 
@@ -2857,13 +2871,13 @@ MODULE_DEVICE_TABLE(of, macb_dt_ids);
 static int macb_probe(struct platform_device *pdev)
 {
 	int (*clk_init)(struct platform_device *, struct clk **,
-			struct clk **, struct clk **)
+			struct clk **, struct clk **,  struct clk **)
 					      = macb_clk_init;
 	int (*init)(struct platform_device *) = macb_init;
 	struct device_node *np = pdev->dev.of_node;
 	struct device_node *phy_node;
 	const struct macb_config *macb_config = NULL;
-	struct clk *pclk, *hclk = NULL, *tx_clk = NULL;
+	struct clk *pclk, *hclk = NULL, *tx_clk = NULL, *rx_clk = NULL;
 	unsigned int queue_mask, num_queues;
 	struct macb_platform_data *pdata;
 	bool native_io;
@@ -2891,7 +2905,7 @@ static int macb_probe(struct platform_device *pdev)
 		}
 	}
 
-	err = clk_init(pdev, &pclk, &hclk, &tx_clk);
+	err = clk_init(pdev, &pclk, &hclk, &tx_clk, &rx_clk);
 	if (err)
 		return err;
 
@@ -2927,6 +2941,7 @@ static int macb_probe(struct platform_device *pdev)
 	bp->pclk = pclk;
 	bp->hclk = hclk;
 	bp->tx_clk = tx_clk;
+	bp->rx_clk = rx_clk;
 	if (macb_config)
 		bp->jumbo_max_len = macb_config->jumbo_max_len;
 
@@ -3020,6 +3035,7 @@ err_disable_clocks:
 	clk_disable_unprepare(tx_clk);
 	clk_disable_unprepare(hclk);
 	clk_disable_unprepare(pclk);
+	clk_disable_unprepare(rx_clk);
 
 	return err;
 }
@@ -3046,6 +3062,7 @@ static int macb_remove(struct platform_device *pdev)
 		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
 		clk_disable_unprepare(bp->pclk);
+		clk_disable_unprepare(bp->rx_clk);
 		free_netdev(dev);
 	}
 
@@ -3069,6 +3086,7 @@ static int __maybe_unused macb_suspend(struct device *dev)
 		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
 		clk_disable_unprepare(bp->pclk);
+		clk_disable_unprepare(bp->rx_clk);
 	}
 
 	return 0;
@@ -3088,6 +3106,7 @@ static int __maybe_unused macb_resume(struct device *dev)
 		clk_prepare_enable(bp->pclk);
 		clk_prepare_enable(bp->hclk);
 		clk_prepare_enable(bp->tx_clk);
+		clk_prepare_enable(bp->rx_clk);
 	}
 
 	netif_device_attach(netdev);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 36893d8..10485b6 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -763,7 +763,8 @@ struct macb_config {
 	u32			caps;
 	unsigned int		dma_burst_length;
 	int	(*clk_init)(struct platform_device *pdev, struct clk **pclk,
-			    struct clk **hclk, struct clk **tx_clk);
+			    struct clk **hclk, struct clk **tx_clk,
+			    struct clk **rx_clk);
 	int	(*init)(struct platform_device *pdev);
 	int	jumbo_max_len;
 };
@@ -809,6 +810,7 @@ struct macb {
 	struct clk		*pclk;
 	struct clk		*hclk;
 	struct clk		*tx_clk;
+	struct clk		*rx_clk;
 	struct net_device	*dev;
 	struct napi_struct	napi;
 	struct net_device_stats	stats;
-- 
2.1.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
