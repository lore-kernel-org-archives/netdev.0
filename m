From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 2/2] net: davinci_mdio: use devm_* api
Date: Fri, 4 Apr 2014 16:40:25 +0300
Message-ID: <1396618825-4241-3-git-send-email-grygorii.strashko@ti.com>
References: <1396618825-4241-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <santosh.shilimkar-l0cyMroinI0@public.gmane.org>,
        "David S. Miller"
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Jonathan Cameron <jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1396618825-4241-1-git-send-email-grygorii.strashko-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Use devm_* API for memory allocation and to get device's clock
to simplify driver's code.

Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
---
 drivers/net/ethernet/ti/davinci_mdio.c |   21 ++++-----------------
 1 file changed, 4 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 0cca9de..f0f7128 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -321,15 +321,14 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	struct phy_device *phy;
 	int ret, addr;
 
-	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	data = devm_kzalloc(dev, sizeof(*data), GFP_KERNEL);
 	if (!data)
 		return -ENOMEM;
 
-	data->bus = mdiobus_alloc();
+	data->bus = devm_mdiobus_alloc(dev, 0);
 	if (!data->bus) {
 		dev_err(dev, "failed to alloc mii bus\n");
-		ret = -ENOMEM;
-		goto bail_out;
+		return -ENOMEM;
 	}
 
 	if (dev->of_node) {
@@ -354,7 +353,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_get_sync(&pdev->dev);
-	data->clk = clk_get(&pdev->dev, "fck");
+	data->clk = devm_clk_get(dev, "fck");
 	if (IS_ERR(data->clk)) {
 		dev_err(dev, "failed to get device clock\n");
 		ret = PTR_ERR(data->clk);
@@ -406,16 +405,9 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	return 0;
 
 bail_out:
-	if (data->bus)
-		mdiobus_free(data->bus);
-
-	if (data->clk)
-		clk_put(data->clk);
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 
-	kfree(data);
-
 	return ret;
 }
 
@@ -425,16 +417,11 @@ static int davinci_mdio_remove(struct platform_device *pdev)
 
 	if (data->bus) {
 		mdiobus_unregister(data->bus);
-		mdiobus_free(data->bus);
 	}
 
-	if (data->clk)
-		clk_put(data->clk);
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 
-	kfree(data);
-
 	return 0;
 }
 
-- 
1.7.9.5
