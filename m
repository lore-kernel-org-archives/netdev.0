From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH net-next 3/5] net: sh_eth: modify a condition of ioremap for TSU
Date: Thu, 16 Feb 2012 12:55:01 +0900
Message-ID: <4F3C7E15.7020504@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:47400 "EHLO
	relmlor2.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab2BPDzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 22:55:16 -0500
Received: from relmlir4.idc.renesas.com ([10.200.68.154])
 by relmlor2.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZG00D61W7PYT40@relmlor2.idc.renesas.com> for
 netdev@vger.kernel.org; Thu, 16 Feb 2012 12:55:01 +0900 (JST)
Received: from relmlac4.idc.renesas.com ([10.200.69.24])
 by relmlir4.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZG000OJW7PNWC0@relmlir4.idc.renesas.com> for
 netdev@vger.kernel.org; Thu, 16 Feb 2012 12:55:01 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the controller has TSU, the each channel needs TSU registers.
This patch also fixes the iounmap condition in the sh_eth_drv_remove().

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 5a5afbc..8bd0e58 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1859,18 +1859,20 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	/* read and set MAC address */
 	read_mac_address(ndev, pd->mac_addr);

+	/* ioremap the TSU registers */
+	if (mdp->cd->tsu) {
+		struct resource *rtsu;
+		rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+		if (!rtsu) {
+			dev_err(&pdev->dev, "Not found TSU resource\n");
+			goto out_release;
+		}
+		mdp->tsu_addr = ioremap(rtsu->start,
+					resource_size(rtsu));
+	}
+
 	/* initialize first or needed device */
 	if (!devno || pd->needs_init) {
-		if (mdp->cd->tsu) {
-			struct resource *rtsu;
-			rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-			if (!rtsu) {
-				dev_err(&pdev->dev, "Not found TSU resource\n");
-				goto out_release;
-			}
-			mdp->tsu_addr = ioremap(rtsu->start,
-						resource_size(rtsu));
-		}
 		if (mdp->cd->chip_reset)
 			mdp->cd->chip_reset(ndev);

@@ -1919,7 +1921,8 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct sh_eth_private *mdp = netdev_priv(ndev);

-	iounmap(mdp->tsu_addr);
+	if (mdp->cd->tsu)
+		iounmap(mdp->tsu_addr);
 	sh_mdio_release(ndev);
 	unregister_netdev(ndev);
 	pm_runtime_disable(&pdev->dev);
-- 
1.7.1
