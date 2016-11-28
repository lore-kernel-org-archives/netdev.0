From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH net 14/16] net: ethernet: dwc_eth_qos: fix fixed-link phydev leaks
Date: Mon, 28 Nov 2016 19:25:07 +0100
Message-ID: <1480357509-28074-15-git-send-email-johan@kernel.org>
References: <1480357509-28074-1-git-send-email-johan@kernel.org>
Cc: Vince Bridgers <vbridger-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Fugang Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>,
        Pantelis Antoniou <pantelis.antoniou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Vitaly Bordug <vbordug-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>,
        Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
        Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
        John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
        Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Vivien Didelot <
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480357509-28074-1-git-send-email-johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make sure to deregister and free any fixed-link PHY registered using
of_phy_register_fixed_link() on probe errors and on driver unbind.

Fixes: 077742dac2c7 ("dwc_eth_qos: Add support for Synopsys DWC Ethernet
QoS")
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 4ba2421e625d..97d64bfed465 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2881,7 +2881,7 @@ static int dwceqos_probe(struct platform_device *pdev)
 	ret = of_get_phy_mode(lp->pdev->dev.of_node);
 	if (ret < 0) {
 		dev_err(&lp->pdev->dev, "error in getting phy i/f\n");
-		goto err_out_clk_dis_phy;
+		goto err_out_deregister_fixed_link;
 	}
 
 	lp->phy_interface = ret;
@@ -2889,14 +2889,14 @@ static int dwceqos_probe(struct platform_device *pdev)
 	ret = dwceqos_mii_init(lp);
 	if (ret) {
 		dev_err(&lp->pdev->dev, "error in dwceqos_mii_init\n");
-		goto err_out_clk_dis_phy;
+		goto err_out_deregister_fixed_link;
 	}
 
 	ret = dwceqos_mii_probe(ndev);
 	if (ret != 0) {
 		netdev_err(ndev, "mii_probe fail.\n");
 		ret = -ENXIO;
-		goto err_out_clk_dis_phy;
+		goto err_out_deregister_fixed_link;
 	}
 
 	dwceqos_set_umac_addr(lp, lp->ndev->dev_addr, 0);
@@ -2914,7 +2914,7 @@ static int dwceqos_probe(struct platform_device *pdev)
 	if (ret) {
 		dev_err(&lp->pdev->dev, "Unable to retrieve DT, error %d\n",
 			ret);
-		goto err_out_clk_dis_phy;
+		goto err_out_deregister_fixed_link;
 	}
 	dev_info(&lp->pdev->dev, "pdev->id %d, baseaddr 0x%08lx, irq %d\n",
 		 pdev->id, ndev->base_addr, ndev->irq);
@@ -2924,7 +2924,7 @@ static int dwceqos_probe(struct platform_device *pdev)
 	if (ret) {
 		dev_err(&lp->pdev->dev, "Unable to request IRQ %d, error %d\n",
 			ndev->irq, ret);
-		goto err_out_clk_dis_phy;
+		goto err_out_deregister_fixed_link;
 	}
 
 	if (netif_msg_probe(lp))
@@ -2935,11 +2935,14 @@ static int dwceqos_probe(struct platform_device *pdev)
 	ret = register_netdev(ndev);
 	if (ret) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-			goto err_out_clk_dis_phy;
+		goto err_out_deregister_fixed_link;
 	}
 
 	return 0;
 
+err_out_deregister_fixed_link:
+	if (of_phy_is_fixed_link(pdev->dev.of_node))
+		of_phy_deregister_fixed_link(pdev->dev.of_node);
 err_out_clk_dis_phy:
 	clk_disable_unprepare(lp->phy_ref_clk);
 err_out_clk_dis_aper:
@@ -2959,8 +2962,11 @@ static int dwceqos_remove(struct platform_device *pdev)
 	if (ndev) {
 		lp = netdev_priv(ndev);
 
-		if (ndev->phydev)
+		if (ndev->phydev) {
 			phy_disconnect(ndev->phydev);
+			if (of_phy_is_fixed_link(pdev->dev.of_node))
+				of_phy_deregister_fixed_link(pdev->dev.of_node);
+		}
 		mdiobus_unregister(lp->mii_bus);
 		mdiobus_free(lp->mii_bus);
 
-- 
2.7.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
