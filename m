From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH net 05/16] net: ethernet: bcmsysport: fix fixed-link phydev
 leaks
Date: Mon, 28 Nov 2016 19:24:58 +0100
Message-ID: <1480357509-28074-6-git-send-email-johan@kernel.org>
References: <1480357509-28074-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Pantelis Antoniou <pantelis.antoniou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
 Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
 Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Lars Persson <lars.persson-VrBV9hrLPhE@public.gmane.org>,
 Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
 Fugang Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>,
 Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
 Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1480357509-28074-1-git-send-email-johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Make sure to deregister and free any fixed-link PHY registered using
of_phy_register_fixed_link() on probe errors and on driver unbind.

Fixes: 186534a3f832 ("net: systemport: use the new fixed PHY helpers")
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index c3354b9941d1..25d1eb4933d0 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1755,13 +1755,13 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	if (priv->irq0 <= 0 || priv->irq1 <= 0) {
 		dev_err(&pdev->dev, "invalid interrupts\n");
 		ret = -EINVAL;
-		goto err;
+		goto err_free_netdev;
 	}
 
 	priv->base = devm_ioremap_resource(&pdev->dev, r);
 	if (IS_ERR(priv->base)) {
 		ret = PTR_ERR(priv->base);
-		goto err;
+		goto err_free_netdev;
 	}
 
 	priv->netdev = dev;
@@ -1779,7 +1779,7 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 		ret = of_phy_register_fixed_link(dn);
 		if (ret) {
 			dev_err(&pdev->dev, "failed to register fixed PHY\n");
-			goto err;
+			goto err_free_netdev;
 		}
 
 		priv->phy_dn = dn;
@@ -1821,7 +1821,7 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	ret = register_netdev(dev);
 	if (ret) {
 		dev_err(&pdev->dev, "failed to register net_device\n");
-		goto err;
+		goto err_deregister_fixed_link;
 	}
 
 	priv->rev = topctrl_readl(priv, REV_CNTL) & REV_MASK;
@@ -1832,7 +1832,11 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 		 priv->base, priv->irq0, priv->irq1, txq, rxq);
 
 	return 0;
-err:
+
+err_deregister_fixed_link:
+	if (of_phy_is_fixed_link(dn))
+		of_phy_deregister_fixed_link(dn);
+err_free_netdev:
 	free_netdev(dev);
 	return ret;
 }
@@ -1840,11 +1844,14 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 static int bcm_sysport_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = dev_get_drvdata(&pdev->dev);
+	struct device_node *dn = pdev->dev.of_node;
 
 	/* Not much to do, ndo_close has been called
 	 * and we use managed allocations
 	 */
 	unregister_netdev(dev);
+	if (of_phy_is_fixed_link(dn))
+		of_phy_deregister_fixed_link(dn);
 	free_netdev(dev);
 	dev_set_drvdata(&pdev->dev, NULL);
 
-- 
2.7.3
