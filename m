From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH v2 1/2] net/macb: unify clock management
Date: Fri,  6 Mar 2015 07:13:58 +0100
Message-ID: <1425622439-2372-2-git-send-email-boris.brezillon@free-electrons.com>
References: <1425622439-2372-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425622439-2372-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrille Pitchen <cyrille.pitchen@atmel.com>

Most of the functions from the Common Clk Framework handle NULL pointer as
input argument.

Since the TX clock is optional, we now set tx_clk to NULL value
instead of ERR_PTR(-ENOENT) when this clock is not available. This simplifies
the clock management and avoid the need to test tx_clk value.

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Acked-by: Boris Brezillon <boris.brezillon@free-electrons.com>
Acked-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 drivers/net/ethernet/cadence/macb.c | 31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a7dbf04..a429cf8 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -213,6 +213,9 @@ static void macb_set_tx_clk(struct clk *clk, int speed, struct net_device *dev)
 {
 	long ferr, rate, rate_rounded;
 
+	if (!clk)
+		return;
+
 	switch (speed) {
 	case SPEED_10:
 		rate = 2500000;
@@ -292,8 +295,7 @@ static void macb_handle_link_change(struct net_device *dev)
 
 	spin_unlock_irqrestore(&bp->lock, flags);
 
-	if (!IS_ERR(bp->tx_clk))
-		macb_set_tx_clk(bp->tx_clk, phydev->speed, dev);
+	macb_set_tx_clk(bp->tx_clk, phydev->speed, dev);
 
 	if (status_change) {
 		if (phydev->link) {
@@ -2244,6 +2246,8 @@ static int macb_probe(struct platform_device *pdev)
 	}
 
 	tx_clk = devm_clk_get(&pdev->dev, "tx_clk");
+	if (IS_ERR(tx_clk))
+		tx_clk = NULL;
 
 	err = clk_prepare_enable(pclk);
 	if (err) {
@@ -2257,13 +2261,10 @@ static int macb_probe(struct platform_device *pdev)
 		goto err_out_disable_pclk;
 	}
 
-	if (!IS_ERR(tx_clk)) {
-		err = clk_prepare_enable(tx_clk);
-		if (err) {
-			dev_err(&pdev->dev, "failed to enable tx_clk (%u)\n",
-				err);
-			goto err_out_disable_hclk;
-		}
+	err = clk_prepare_enable(tx_clk);
+	if (err) {
+		dev_err(&pdev->dev, "failed to enable tx_clk (%u)\n", err);
+		goto err_out_disable_hclk;
 	}
 
 	err = -ENOMEM;
@@ -2436,8 +2437,7 @@ err_out_unregister_netdev:
 err_out_free_netdev:
 	free_netdev(dev);
 err_out_disable_clocks:
-	if (!IS_ERR(tx_clk))
-		clk_disable_unprepare(tx_clk);
+	clk_disable_unprepare(tx_clk);
 err_out_disable_hclk:
 	clk_disable_unprepare(hclk);
 err_out_disable_pclk:
@@ -2461,8 +2461,7 @@ static int macb_remove(struct platform_device *pdev)
 		kfree(bp->mii_bus->irq);
 		mdiobus_free(bp->mii_bus);
 		unregister_netdev(dev);
-		if (!IS_ERR(bp->tx_clk))
-			clk_disable_unprepare(bp->tx_clk);
+		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
 		clk_disable_unprepare(bp->pclk);
 		free_netdev(dev);
@@ -2480,8 +2479,7 @@ static int __maybe_unused macb_suspend(struct device *dev)
 	netif_carrier_off(netdev);
 	netif_device_detach(netdev);
 
-	if (!IS_ERR(bp->tx_clk))
-		clk_disable_unprepare(bp->tx_clk);
+	clk_disable_unprepare(bp->tx_clk);
 	clk_disable_unprepare(bp->hclk);
 	clk_disable_unprepare(bp->pclk);
 
@@ -2496,8 +2494,7 @@ static int __maybe_unused macb_resume(struct device *dev)
 
 	clk_prepare_enable(bp->pclk);
 	clk_prepare_enable(bp->hclk);
-	if (!IS_ERR(bp->tx_clk))
-		clk_prepare_enable(bp->tx_clk);
+	clk_prepare_enable(bp->tx_clk);
 
 	netif_device_attach(netdev);
 
-- 
1.9.1
