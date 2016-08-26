From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ravb: avoid unused function warnings
Date: Fri, 26 Aug 2016 17:30:29 +0200
Message-ID: <20160826153108.680850-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Yoshihiro Kaneko <ykaneko0929@gmail.com>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Masaru Nagai <masaru.nagai.vx@renesas.com>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_PM_SLEEP is disabled, we get a couple of harmless warnings:

drivers/net/ethernet/renesas/ravb_main.c:2117:12: error: 'ravb_resume' defined but not used [-Werror=unused-function]
drivers/net/ethernet/renesas/ravb_main.c:2104:12: error: 'ravb_suspend' defined but not used [-Werror=unused-function]

The simplest solution here is to replace the #ifdef with __maybe_unused
annotations, which lets the compiler do the right thing by itself.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 0184165b2f42 ("ravb: add sleep PM suspend/resume support")
---
 drivers/net/ethernet/renesas/ravb_main.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index cad23ba06904..630536bc72f9 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -2100,8 +2100,7 @@ static int ravb_remove(struct platform_device *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
-static int ravb_suspend(struct device *dev)
+static int __maybe_unused ravb_suspend(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	int ret = 0;
@@ -2114,7 +2113,7 @@ static int ravb_suspend(struct device *dev)
 	return ret;
 }
 
-static int ravb_resume(struct device *dev)
+static int __maybe_unused ravb_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct ravb_private *priv = netdev_priv(ndev);
@@ -2149,7 +2148,7 @@ static int ravb_resume(struct device *dev)
 	return ret;
 }
 
-static int ravb_runtime_nop(struct device *dev)
+static int __maybe_unused ravb_runtime_nop(struct device *dev)
 {
 	/* Runtime PM callback shared between ->runtime_suspend()
 	 * and ->runtime_resume(). Simply returns success.
@@ -2166,17 +2165,12 @@ static const struct dev_pm_ops ravb_dev_pm_ops = {
 	SET_RUNTIME_PM_OPS(ravb_runtime_nop, ravb_runtime_nop, NULL)
 };
 
-#define RAVB_PM_OPS (&ravb_dev_pm_ops)
-#else
-#define RAVB_PM_OPS NULL
-#endif
-
 static struct platform_driver ravb_driver = {
 	.probe		= ravb_probe,
 	.remove		= ravb_remove,
 	.driver = {
 		.name	= "ravb",
-		.pm	= RAVB_PM_OPS,
+		.pm	= &ravb_dev_pm_ops,
 		.of_match_table = ravb_match_table,
 	},
 };
-- 
2.9.0
