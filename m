From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH net 15/16] net: ethernet: ti: davinci_emac: fix fixed-link phydev and of-node leaks
Date: Mon, 28 Nov 2016 19:25:08 +0100
Message-ID: <1480357509-28074-16-git-send-email-johan@kernel.org>
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

Also remember to put the of-node reference on probe errors.

Fixes: 1bb6aa56bb38 ("net: davinci_emac: Add support for fixed-link
PHY")
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/ti/davinci_emac.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 84fbe5714f8b..481c7bf0395b 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1767,6 +1767,7 @@ static int davinci_emac_try_get_mac(struct platform_device *pdev,
  */
 static int davinci_emac_probe(struct platform_device *pdev)
 {
+	struct device_node *np = pdev->dev.of_node;
 	int rc = 0;
 	struct resource *res, *res_ctrl;
 	struct net_device *ndev;
@@ -1805,7 +1806,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	if (!pdata) {
 		dev_err(&pdev->dev, "no platform data\n");
 		rc = -ENODEV;
-		goto no_pdata;
+		goto err_free_netdev;
 	}
 
 	/* MAC addr and PHY mask , RMII enable info from platform_data */
@@ -1941,6 +1942,10 @@ static int davinci_emac_probe(struct platform_device *pdev)
 		cpdma_chan_destroy(priv->rxchan);
 	cpdma_ctlr_destroy(priv->dma);
 no_pdata:
+	if (of_phy_is_fixed_link(np))
+		of_phy_deregister_fixed_link(np);
+	of_node_put(priv->phy_node);
+err_free_netdev:
 	free_netdev(ndev);
 	return rc;
 }
@@ -1956,6 +1961,7 @@ static int davinci_emac_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct emac_priv *priv = netdev_priv(ndev);
+	struct device_node *np = pdev->dev.of_node;
 
 	dev_notice(&ndev->dev, "DaVinci EMAC: davinci_emac_remove()\n");
 
@@ -1968,6 +1974,8 @@ static int davinci_emac_remove(struct platform_device *pdev)
 	unregister_netdev(ndev);
 	of_node_put(priv->phy_node);
 	pm_runtime_disable(&pdev->dev);
+	if (of_phy_is_fixed_link(np))
+		of_phy_deregister_fixed_link(np);
 	free_netdev(ndev);
 
 	return 0;
-- 
2.7.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
