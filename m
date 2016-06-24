From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 09/15] drivers: net: davinci_mdio: split reset function on init_clk and enable
Date: Fri, 24 Jun 2016 21:23:49 +0300
Message-ID: <20160624182355.23515-10-grygorii.strashko@ti.com>
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

The Davinci MDIO MDIO_CONTROL.CLKDIV can be calculated only once
during probe, hence split __davinci_mdio_reset() on
davinci_mdio_init_clk() and davinci_mdio_enable(). Initialize and
save CLKDIV in .probe(). Then just use saved value.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index b6d0059..b206fd3 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -98,9 +98,10 @@ struct davinci_mdio_data {
 	 * if MDIO bus is registered from DT.
 	 */
 	bool		skip_scan;
+	u32		clk_div;
 };
 
-static void __davinci_mdio_reset(struct davinci_mdio_data *data)
+static void davinci_mdio_init_clk(struct davinci_mdio_data *data)
 {
 	u32 mdio_in, div, mdio_out_khz, access_time;
 
@@ -109,9 +110,7 @@ static void __davinci_mdio_reset(struct davinci_mdio_data *data)
 	if (div > CONTROL_MAX_DIV)
 		div = CONTROL_MAX_DIV;
 
-	/* set enable and clock divider */
-	__raw_writel(div | CONTROL_ENABLE, &data->regs->control);
-
+	data->clk_div = div;
 	/*
 	 * One mdio transaction consists of:
 	 *	32 bits of preamble
@@ -132,12 +131,18 @@ static void __davinci_mdio_reset(struct davinci_mdio_data *data)
 		data->access_time = 1;
 }
 
+static void davinci_mdio_enable(struct davinci_mdio_data *data)
+{
+	/* set enable and clock divider */
+	__raw_writel(data->clk_div | CONTROL_ENABLE, &data->regs->control);
+}
+
 static int davinci_mdio_reset(struct mii_bus *bus)
 {
 	struct davinci_mdio_data *data = bus->priv;
 	u32 phy_mask, ver;
 
-	__davinci_mdio_reset(data);
+	davinci_mdio_enable(data);
 
 	/* wait for scan logic to settle */
 	msleep(PHY_MAX_ADDR * data->access_time);
@@ -188,7 +193,7 @@ static inline int wait_for_user_access(struct davinci_mdio_data *data)
 		 * operation
 		 */
 		dev_warn(data->dev, "resetting idled controller\n");
-		__davinci_mdio_reset(data);
+		davinci_mdio_enable(data);
 		return -EAGAIN;
 	}
 
@@ -350,6 +355,8 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	if (IS_ERR(data->regs))
 		return PTR_ERR(data->regs);
 
+	davinci_mdio_init_clk(data);
+
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_get_sync(&pdev->dev);
 
@@ -425,7 +432,7 @@ static int davinci_mdio_resume(struct device *dev)
 	pinctrl_pm_select_default_state(dev);
 
 	/* restart the scan state machine */
-	__davinci_mdio_reset(data);
+	davinci_mdio_enable(data);
 
 	return 0;
 }
-- 
2.9.0
