From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] pxa168: fix double deallocation of managed resources
Date: Sat, 25 Apr 2015 04:07:03 +0300
Message-ID: <1429924023-11543-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Arnd Bergmann <arnd@arndb.de>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Antoine=20T=C3=A9nart?=
	<antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 43d3ddf87a57 ("net: pxa168_eth: add device tree support") starts
to use managed resources by adding devm_clk_get() and
devm_ioremap_resource(), but it leaves explicit iounmap() and clock_put()
in pxa168_eth_remove() and in failure handling code of pxa168_eth_probe().
As a result double free can happen.

The patch removes explicit resource deallocation. Also it converts
clk_disable() to clk_disable_unprepare() to make it symmetrical with
clk_prepare_enable().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index af829c578400..7ace07dad6a3 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1508,7 +1508,8 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 		np = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
 		if (!np) {
 			dev_err(&pdev->dev, "missing phy-handle\n");
-			return -EINVAL;
+			err = -EINVAL;
+			goto err_netdev;
 		}
 		of_property_read_u32(np, "reg", &pep->phy_addr);
 		pep->phy_intf = of_get_phy_mode(pdev->dev.of_node);
@@ -1526,7 +1527,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	pep->smi_bus = mdiobus_alloc();
 	if (pep->smi_bus == NULL) {
 		err = -ENOMEM;
-		goto err_base;
+		goto err_netdev;
 	}
 	pep->smi_bus->priv = pep;
 	pep->smi_bus->name = "pxa168_eth smi";
@@ -1551,13 +1552,10 @@ err_mdiobus:
 	mdiobus_unregister(pep->smi_bus);
 err_free_mdio:
 	mdiobus_free(pep->smi_bus);
-err_base:
-	iounmap(pep->base);
 err_netdev:
 	free_netdev(dev);
 err_clk:
-	clk_disable(clk);
-	clk_put(clk);
+	clk_disable_unprepare(clk);
 	return err;
 }
 
@@ -1574,13 +1572,9 @@ static int pxa168_eth_remove(struct platform_device *pdev)
 	if (pep->phy)
 		phy_disconnect(pep->phy);
 	if (pep->clk) {
-		clk_disable(pep->clk);
-		clk_put(pep->clk);
-		pep->clk = NULL;
+		clk_disable_unprepare(pep->clk);
 	}
 
-	iounmap(pep->base);
-	pep->base = NULL;
 	mdiobus_unregister(pep->smi_bus);
 	mdiobus_free(pep->smi_bus);
 	unregister_netdev(dev);
-- 
1.9.1
