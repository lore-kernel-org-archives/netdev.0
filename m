From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH v3 1/2] net/macb: unify clock management
Date: Fri,  6 Mar 2015 11:48:40 +0100
Message-ID: <1425638921-9768-2-git-send-email-boris.brezillon@free-electrons.com>
References: <1425638921-9768-1-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Boris Brezillon <boris.brezillon@free-electrons.com>,
 Nicolas Ferre <nicolas.ferre@atmel.com>, linux-kernel@vger.kernel.org,
 Rob Herring <robh+dt@kernel.org>,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 Kumar Gala <galak@codeaurora.org>, Cyrille Pitchen <cyrille.pitchen@atmel.com>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1425638921-9768-1-git-send-email-boris.brezillon@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
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
index 86e915f..d8748c5 100644
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
@@ -2435,8 +2436,7 @@ err_out_unregister_netdev:
 err_out_free_netdev:
 	free_netdev(dev);
 err_out_disable_clocks:
-	if (!IS_ERR(tx_clk))
-		clk_disable_unprepare(tx_clk);
+	clk_disable_unprepare(tx_clk);
 err_out_disable_hclk:
 	clk_disable_unprepare(hclk);
 err_out_disable_pclk:
@@ -2460,8 +2460,7 @@ static int macb_remove(struct platform_device *pdev)
 		kfree(bp->mii_bus->irq);
 		mdiobus_free(bp->mii_bus);
 		unregister_netdev(dev);
-		if (!IS_ERR(bp->tx_clk))
-			clk_disable_unprepare(bp->tx_clk);
+		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
 		clk_disable_unprepare(bp->pclk);
 		free_netdev(dev);
@@ -2479,8 +2478,7 @@ static int __maybe_unused macb_suspend(struct device *dev)
 	netif_carrier_off(netdev);
 	netif_device_detach(netdev);
 
-	if (!IS_ERR(bp->tx_clk))
-		clk_disable_unprepare(bp->tx_clk);
+	clk_disable_unprepare(bp->tx_clk);
 	clk_disable_unprepare(bp->hclk);
 	clk_disable_unprepare(bp->pclk);
 
@@ -2495,8 +2493,7 @@ static int __maybe_unused macb_resume(struct device *dev)
 
 	clk_prepare_enable(bp->pclk);
 	clk_prepare_enable(bp->hclk);
-	if (!IS_ERR(bp->tx_clk))
-		clk_prepare_enable(bp->tx_clk);
+	clk_prepare_enable(bp->tx_clk);
 
 	netif_device_attach(netdev);
 
-- 
1.9.1
