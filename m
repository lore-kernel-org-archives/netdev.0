From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH net 03/16] net: ethernet: altera: fix fixed-link phydev leaks
Date: Mon, 28 Nov 2016 19:24:56 +0100
Message-ID: <1480357509-28074-4-git-send-email-johan@kernel.org>
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

Fixes: 7cdbc6f74f8e ("altera tse: add support for fixed-links.")
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index bda31f308cc2..6532829b70d2 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -819,6 +819,8 @@ static int init_phy(struct net_device *dev)
 
 	if (!phydev) {
 		netdev_err(dev, "Could not find the PHY\n");
+		if (fixed_link)
+			of_phy_deregister_fixed_link(priv->device->of_node);
 		return -ENODEV;
 	}
 
@@ -1545,10 +1547,15 @@ static int altera_tse_probe(struct platform_device *pdev)
 static int altera_tse_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct altera_tse_private *priv = netdev_priv(ndev);
 
-	if (ndev->phydev)
+	if (ndev->phydev) {
 		phy_disconnect(ndev->phydev);
 
+		if (of_phy_is_fixed_link(priv->device->of_node))
+			of_phy_deregister_fixed_link(priv->device->of_node);
+	}
+
 	platform_set_drvdata(pdev, NULL);
 	altera_tse_mdio_destroy(ndev);
 	unregister_netdev(ndev);
-- 
2.7.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
