From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: [PATCH 20/33] net: Convert to devm_ioremap_resource()
Date: Mon, 21 Jan 2013 11:09:13 +0100
Message-ID: <1358762966-20791-21-git-send-email-thierry.reding@avionic-design.de>
References: <1358762966-20791-1-git-send-email-thierry.reding@avionic-design.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Wolfram Sang <w.sang@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358762966-20791-1-git-send-email-thierry.reding@avionic-design.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert all uses of devm_request_and_ioremap() to the newly introduced
devm_ioremap_resource() which provides more consistent error handling.

devm_ioremap_resource() provides its own error messages so all explicit
error messages can be removed from the failure code paths.

Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/can/grcan.c                               | 8 ++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 9 ++++-----
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index 17fbc7a..4c3a7dd 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -26,6 +26,7 @@
  * Contributors: Andreas Larsson <andreas@gaisler.com>
  */
 
+#include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/interrupt.h>
@@ -1683,10 +1684,9 @@ static int grcan_probe(struct platform_device *ofdev)
 	}
 
 	res = platform_get_resource(ofdev, IORESOURCE_MEM, 0);
-	base = devm_request_and_ioremap(&ofdev->dev, res);
-	if (!base) {
-		dev_err(&ofdev->dev, "couldn't map IO resource\n");
-		err = -EADDRNOTAVAIL;
+	base = devm_ioremap_resource(&ofdev->dev, res);
+	if (IS_ERR(base)) {
+		err = PTR_ERR(base);
 		goto exit_error;
 	}
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index b43d68b..a3431aa 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -22,6 +22,7 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
+#include <linux/err.h>
 #include <linux/platform_device.h>
 #include <linux/io.h>
 #include <linux/of.h>
@@ -88,11 +89,9 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	if (!res)
 		return -ENODEV;
 
-	addr = devm_request_and_ioremap(dev, res);
-	if (!addr) {
-		pr_err("%s: ERROR: memory mapping failed", __func__);
-		return -ENOMEM;
-	}
+	addr = devm_ioremap_resource(dev, res);
+	if (IS_ERR(addr))
+		return PTR_ERR(addr);
 
 	if (pdev->dev.of_node) {
 		plat_dat = devm_kzalloc(&pdev->dev,
-- 
1.8.1.1
