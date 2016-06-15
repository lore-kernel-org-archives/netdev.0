From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 10/15] drivers: net: davinci_mdio: add pm runtime callbacks
Date: Wed, 15 Jun 2016 14:55:58 +0300
Message-ID: <20160615115603.4897-11-grygorii.strashko@ti.com>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:50004 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563AbcFOL4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 07:56:34 -0400
In-Reply-To: <20160615115603.4897-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PM runtime .runtime_suspend()/.runtime_resume() callbacks and
perform Davinci MDIO enabling/disabling from these callbacks. This
allows to reuse pm_runtime_force_suspend/resume() APIs during System
suspend and required for further implementation of PM runtime
autosuspend.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 31 +++++++++++++++++++++++++++----
 1 file changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index b206fd3..13f5080 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -406,8 +406,8 @@ static int davinci_mdio_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM_SLEEP
-static int davinci_mdio_suspend(struct device *dev)
+#ifdef CONFIG_PM
+static int davinci_mdio_runtime_suspend(struct device *dev)
 {
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
 	u32 ctrl;
@@ -418,6 +418,28 @@ static int davinci_mdio_suspend(struct device *dev)
 	__raw_writel(ctrl, &data->regs->control);
 	wait_for_idle(data);
 
+	return 0;
+}
+
+static int davinci_mdio_runtime_resume(struct device *dev)
+{
+	struct davinci_mdio_data *data = dev_get_drvdata(dev);
+
+	davinci_mdio_enable(data);
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_PM_SLEEP
+static int davinci_mdio_suspend(struct device *dev)
+{
+	struct davinci_mdio_data *data = dev_get_drvdata(dev);
+	int ret = 0;
+
+	ret = pm_runtime_force_suspend(dev);
+	if (ret < 0)
+		return ret;
+
 	/* Select sleep pin state */
 	pinctrl_pm_select_sleep_state(dev);
 
@@ -431,14 +453,15 @@ static int davinci_mdio_resume(struct device *dev)
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(dev);
 
-	/* restart the scan state machine */
-	davinci_mdio_enable(data);
+	pm_runtime_force_resume(dev);
 
 	return 0;
 }
 #endif
 
 static const struct dev_pm_ops davinci_mdio_pm_ops = {
+	SET_RUNTIME_PM_OPS(davinci_mdio_runtime_suspend,
+			   davinci_mdio_runtime_resume, NULL)
 	SET_LATE_SYSTEM_SLEEP_PM_OPS(davinci_mdio_suspend, davinci_mdio_resume)
 };
 
-- 
2.8.4
