From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [PATCH 3/3] can: m_can: Add PM Runtime
Date: Wed, 19 Jul 2017 18:09:26 -0500
Message-ID: <20170719230926.10872-4-fcooper@ti.com>
References: <20170719230926.10872-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170719230926.10872-1-fcooper@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for PM Runtime which is the new way to handle managing clocks.
However, to avoid breaking SoCs not using PM_RUNTIME leave the old clk
management approach in place.

PM_RUNTIME is required by OMAP based devices to handle clock management.
Therefore, this allows future Texas Instruments SoCs that have the MCAN IP
to work with this driver.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
 drivers/net/can/m_can/m_can.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 7fe9145..eb45cd5 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -23,6 +23,7 @@
 #include <linux/of.h>
 #include <linux/of_device.h>
 #include <linux/platform_device.h>
+#include <linux/pm_runtime.h>
 #include <linux/iopoll.h>
 #include <linux/can/dev.h>
 
@@ -633,11 +634,15 @@ static int m_can_clk_start(struct m_can_priv *priv)
 	if (err)
 		clk_disable_unprepare(priv->hclk);
 
+	pm_runtime_get_sync(priv->device);
+
 	return err;
 }
 
 static void m_can_clk_stop(struct m_can_priv *priv)
 {
+	pm_runtime_put_sync(priv->device);
+
 	clk_disable_unprepare(priv->cclk);
 	clk_disable_unprepare(priv->hclk);
 }
@@ -1582,6 +1587,8 @@ static int m_can_plat_probe(struct platform_device *pdev)
 	/* Enable clocks. Necessary to read Core Release in order to determine
 	 * M_CAN version
 	 */
+	pm_runtime_enable(&pdev->dev);
+
 	ret = clk_prepare_enable(hclk);
 	if (ret)
 		goto disable_hclk_ret;
@@ -1626,6 +1633,8 @@ static int m_can_plat_probe(struct platform_device *pdev)
 	 */
 	tx_fifo_size = mram_config_vals[7];
 
+	pm_runtime_get_sync(&pdev->dev);
+
 	/* allocate the m_can device */
 	dev = alloc_m_can_dev(pdev, addr, tx_fifo_size);
 	if (!dev) {
@@ -1670,6 +1679,7 @@ static int m_can_plat_probe(struct platform_device *pdev)
 disable_hclk_ret:
 	clk_disable_unprepare(hclk);
 failed_ret:
+	pm_runtime_put_sync(&pdev->dev);
 	return ret;
 }
 
@@ -1726,6 +1736,9 @@ static int m_can_plat_remove(struct platform_device *pdev)
 	struct net_device *dev = platform_get_drvdata(pdev);
 
 	unregister_m_can_dev(dev);
+
+	pm_runtime_disable(&pdev->dev);
+
 	platform_set_drvdata(pdev, NULL);
 
 	free_m_can_dev(dev);
-- 
2.10.0

