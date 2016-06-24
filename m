From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 06/15] drivers: net: davinci_mdio: do pm runtime initialization later in probe
Date: Fri, 24 Jun 2016 21:23:46 +0300
Message-ID: <20160624182355.23515-7-grygorii.strashko@ti.com>
References: <20160624182355.23515-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624182355.23515-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do PM runtime initialization later in probe - this allows to simplify
error handling a bit.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 4e7c9b9..2e19dd1 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -356,14 +356,10 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	data->bus->parent	= dev;
 	data->bus->priv		= data;
 
-	pm_runtime_enable(&pdev->dev);
-	pm_runtime_get_sync(&pdev->dev);
 	data->clk = devm_clk_get(dev, "fck");
 	if (IS_ERR(data->clk)) {
 		dev_err(dev, "failed to get device clock\n");
-		ret = PTR_ERR(data->clk);
-		data->clk = NULL;
-		goto bail_out;
+		return PTR_ERR(data->clk);
 	}
 
 	dev_set_drvdata(dev, data);
@@ -372,10 +368,11 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	data->regs = devm_ioremap_resource(dev, res);
-	if (IS_ERR(data->regs)) {
-		ret = PTR_ERR(data->regs);
-		goto bail_out;
-	}
+	if (IS_ERR(data->regs))
+		return PTR_ERR(data->regs);
+
+	pm_runtime_enable(&pdev->dev);
+	pm_runtime_get_sync(&pdev->dev);
 
 	/* register the mii bus
 	 * Create PHYs from DT only in case if PHY child nodes are explicitly
-- 
2.9.0
