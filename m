From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 02/15] drivers: net: cpsw: check return code from pm runtime calls
Date: Wed, 15 Jun 2016 14:55:50 +0300
Message-ID: <20160615115603.4897-3-grygorii.strashko@ti.com>
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
Received: from devils.ext.ti.com ([198.47.26.153]:36421 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932728AbcFOL4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 07:56:23 -0400
In-Reply-To: <20160615115603.4897-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missed check of return codes from PM runtime get() calls.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 736c77a..c76f9db 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1253,7 +1253,11 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	int i, ret;
 	u32 reg;
 
-	pm_runtime_get_sync(&priv->pdev->dev);
+	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(&priv->pdev->dev);
+		return ret;
+	}
 
 	if (!cpsw_common_res_usage_state(priv))
 		cpsw_intr_disable(priv);
@@ -2322,7 +2326,11 @@ static int cpsw_probe(struct platform_device *pdev)
 	/* Need to enable clocks with runtime PM api to access module
 	 * registers
 	 */
-	pm_runtime_get_sync(&pdev->dev);
+	ret = pm_runtime_get_sync(&pdev->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(&pdev->dev);
+		goto clean_runtime_disable_ret;
+	}
 	priv->version = readl(&priv->regs->id_ver);
 	pm_runtime_put_sync(&pdev->dev);
 
-- 
2.8.4
