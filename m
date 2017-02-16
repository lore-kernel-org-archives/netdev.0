From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 01/21] net-next: stmmac add optional init_phy function
Date: Thu, 16 Feb 2017 13:48:39 +0100
Message-ID: <20170216124859.14346-2-clabbe.montjoie@gmail.com>
References: <20170216124859.14346-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBRGAS3CQKGQET56IM2I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170216124859.14346-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

For dwmac-sun8i, some actions must be done for enabling attached PHY.
Thoses actions must be done after stmmac_probe_config_dt() and
at start of stmmac_init_phy().

The best way to handle that is to add an optional init_phy() function.

Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/common.h      |  3 +++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 11 +++++++++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 144fe84..daaafa9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -483,6 +483,9 @@ struct stmmac_ops {
 			     bool loopback);
 	void (*pcs_rane)(void __iomem *ioaddr, bool restart);
 	void (*pcs_get_adv_lp)(void __iomem *ioaddr, struct rgmii_adv *adv);
+	/* optional function for powering/init PHY */
+	int (*init_phy)(struct net_device *ndev);
+	void (*uninit_phy)(struct net_device *ndev);
 };
 
 /* PTP and HW Timer helpers */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3cbe096..942efb7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -820,10 +820,18 @@ static int stmmac_init_phy(struct net_device *dev)
 	char bus_id[MII_BUS_ID_SIZE];
 	int interface = priv->plat->interface;
 	int max_speed = priv->plat->max_speed;
+	int ret;
+
 	priv->oldlink = 0;
 	priv->speed = SPEED_UNKNOWN;
 	priv->oldduplex = DUPLEX_UNKNOWN;
 
+	if (priv->hw->mac->init_phy) {
+		ret = priv->hw->mac->init_phy(dev);
+		if (ret)
+			return ret;
+	}
+
 	if (priv->plat->phy_node) {
 		phydev = of_phy_connect(dev, priv->plat->phy_node,
 					&stmmac_adjust_link, 0, interface);
@@ -1892,6 +1900,9 @@ static int stmmac_release(struct net_device *dev)
 		phy_disconnect(dev->phydev);
 	}
 
+	if (priv->hw->mac->uninit_phy)
+		priv->hw->mac->uninit_phy(dev);
+
 	netif_stop_queue(dev);
 
 	napi_disable(&priv->napi);
-- 
2.10.2
