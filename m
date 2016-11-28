From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH net 07/16] net: ethernet: fec: fix fixed-link phydev leaks
Date: Mon, 28 Nov 2016 19:25:00 +0100
Message-ID: <1480357509-28074-8-git-send-email-johan@kernel.org>
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

Fixes: 407066f8f371 ("net: fec: Support phys probed from devicetree and
fixed-link")
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/freescale/fec_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 5aa9d4ded214..74dcdf097348 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3475,6 +3475,8 @@ fec_probe(struct platform_device *pdev)
 failed_clk_ipg:
 	fec_enet_clk_enable(ndev, false);
 failed_clk:
+	if (of_phy_is_fixed_link(np))
+		of_phy_deregister_fixed_link(np);
 failed_phy:
 	of_node_put(phy_node);
 failed_ioremap:
@@ -3488,6 +3490,7 @@ fec_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct device_node *np = pdev->dev.of_node;
 
 	cancel_work_sync(&fep->tx_timeout_work);
 	fec_ptp_stop(pdev);
@@ -3495,6 +3498,8 @@ fec_drv_remove(struct platform_device *pdev)
 	fec_enet_mii_remove(fep);
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
+	if (of_phy_is_fixed_link(np))
+		of_phy_deregister_fixed_link(np);
 	of_node_put(fep->phy_node);
 	free_netdev(ndev);
 
-- 
2.7.3
