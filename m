From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH net 13/16] net: ethernet: renesas: ravb: fix fixed-link phydev
 leaks
Date: Mon, 28 Nov 2016 19:25:06 +0100
Message-ID: <1480357509-28074-14-git-send-email-johan@kernel.org>
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
of_phy_register_fixed_link() on initialisation errors and on device
close after having disconnected the PHY.

Fixes: b4bc88a868ed ("ravb: Add fixed-link support")
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/renesas/ravb_main.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 630536bc72f9..f1f3be2cfe21 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1008,7 +1008,8 @@ static int ravb_phy_init(struct net_device *ndev)
 	of_node_put(pn);
 	if (!phydev) {
 		netdev_err(ndev, "failed to connect PHY\n");
-		return -ENOENT;
+		err = -ENOENT;
+		goto err_deregister_fixed_link;
 	}
 
 	/* This driver only support 10/100Mbit speeds on Gen3
@@ -1020,8 +1021,7 @@ static int ravb_phy_init(struct net_device *ndev)
 		err = phy_set_max_speed(phydev, SPEED_100);
 		if (err) {
 			netdev_err(ndev, "failed to limit PHY to 100Mbit/s\n");
-			phy_disconnect(phydev);
-			return err;
+			goto err_phy_disconnect;
 		}
 
 		netdev_info(ndev, "limited PHY to 100Mbit/s\n");
@@ -1033,6 +1033,14 @@ static int ravb_phy_init(struct net_device *ndev)
 	phy_attached_info(phydev);
 
 	return 0;
+
+err_phy_disconnect:
+	phy_disconnect(phydev);
+err_deregister_fixed_link:
+	if (of_phy_is_fixed_link(np))
+		of_phy_deregister_fixed_link(np);
+
+	return err;
 }
 
 /* PHY control start function */
@@ -1634,6 +1642,7 @@ static void ravb_set_rx_mode(struct net_device *ndev)
 /* Device close function for Ethernet AVB */
 static int ravb_close(struct net_device *ndev)
 {
+	struct device_node *np = ndev->dev.parent->of_node;
 	struct ravb_private *priv = netdev_priv(ndev);
 	struct ravb_tstamp_skb *ts_skb, *ts_skb2;
 
@@ -1663,6 +1672,8 @@ static int ravb_close(struct net_device *ndev)
 	if (ndev->phydev) {
 		phy_stop(ndev->phydev);
 		phy_disconnect(ndev->phydev);
+		if (of_phy_is_fixed_link(np))
+			of_phy_deregister_fixed_link(np);
 	}
 
 	if (priv->chip_id != RCAR_GEN2) {
-- 
2.7.3
