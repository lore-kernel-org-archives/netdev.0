From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH net 10/16] net: ethernet: ucc_geth: fix fixed-link phydev leaks
Date: Mon, 28 Nov 2016 19:25:03 +0100
Message-ID: <1480357509-28074-11-git-send-email-johan@kernel.org>
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

Fixes: 87009814cdbb ("ucc_geth: use the new fixed PHY helpers")
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 186ef8f16c80..f76d33279454 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3868,9 +3868,8 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 	dev = alloc_etherdev(sizeof(*ugeth));
 
 	if (dev == NULL) {
-		of_node_put(ug_info->tbi_node);
-		of_node_put(ug_info->phy_node);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto err_deregister_fixed_link;
 	}
 
 	ugeth = netdev_priv(dev);
@@ -3907,10 +3906,7 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 		if (netif_msg_probe(ugeth))
 			pr_err("%s: Cannot register net device, aborting\n",
 			       dev->name);
-		free_netdev(dev);
-		of_node_put(ug_info->tbi_node);
-		of_node_put(ug_info->phy_node);
-		return err;
+		goto err_free_netdev;
 	}
 
 	mac_addr = of_get_mac_address(np);
@@ -3923,16 +3919,29 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 	ugeth->node = np;
 
 	return 0;
+
+err_free_netdev:
+	free_netdev(dev);
+err_deregister_fixed_link:
+	if (of_phy_is_fixed_link(np))
+		of_phy_deregister_fixed_link(np);
+	of_node_put(ug_info->tbi_node);
+	of_node_put(ug_info->phy_node);
+
+	return err;
 }
 
 static int ucc_geth_remove(struct platform_device* ofdev)
 {
 	struct net_device *dev = platform_get_drvdata(ofdev);
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	struct device_node *np = ofdev->dev.of_node;
 
 	unregister_netdev(dev);
 	free_netdev(dev);
 	ucc_geth_memclean(ugeth);
+	if (of_phy_is_fixed_link(np))
+		of_phy_deregister_fixed_link(np);
 	of_node_put(ugeth->ug_info->tbi_node);
 	of_node_put(ugeth->ug_info->phy_node);
 
-- 
2.7.3
