From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 4/4][net-next] gianfar: Refactor config coalescing calls for all queues
Date: Tue, 19 Mar 2013 19:40:05 +0200
Message-ID: <1363714805-9142-5-git-send-email-claudiu.manoil@freescale.com>
References: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:40147
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757206Ab3CSRlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:41:50 -0400
In-Reply-To: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only place where gfar_configure_coalescing is called
with an actual bitmask (other than 0xff) is in gfar_poll
(on the hot path). So make gfar_configure_coalescing()
static for the buffer processing path, and export
gfar_configure_coalescing_all() for the remaining cases
that require to set coalescing for all the queues at once
(on the slow path).

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c         | 11 ++++++++---
 drivers/net/ethernet/freescale/gianfar.h         |  3 +--
 drivers/net/ethernet/freescale/gianfar_ethtool.c |  2 +-
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index e28b3e6..49ce83b 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -341,7 +341,7 @@ static void gfar_init_mac(struct net_device *ndev)
 	gfar_init_tx_rx_base(priv);
 
 	/* Configure the coalescing support */
-	gfar_configure_coalescing(priv, 0xFF, 0xFF);
+	gfar_configure_coalescing_all(priv);
 
 	/* set this when rx hw offload (TOE) functions are being used */
 	priv->uses_rxfcb = 0;
@@ -1816,7 +1816,7 @@ void gfar_start(struct net_device *dev)
 	dev->trans_start = jiffies; /* prevent tx timeout */
 }
 
-void gfar_configure_coalescing(struct gfar_private *priv,
+static void gfar_configure_coalescing(struct gfar_private *priv,
 			       unsigned long tx_mask, unsigned long rx_mask)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
@@ -1851,6 +1851,11 @@ void gfar_configure_coalescing(struct gfar_private *priv,
 	}
 }
 
+void gfar_configure_coalescing_all(struct gfar_private *priv)
+{
+	gfar_configure_coalescing(priv, 0xFF, 0xFF);
+}
+
 static int register_grp_irqs(struct gfar_priv_grp *grp)
 {
 	struct gfar_private *priv = grp->priv;
@@ -1940,7 +1945,7 @@ int startup_gfar(struct net_device *ndev)
 
 	phy_start(priv->phydev);
 
-	gfar_configure_coalescing(priv, 0xFF, 0xFF);
+	gfar_configure_coalescing_all(priv);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index b1d0c1c..eec87ea 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1182,8 +1182,7 @@ extern void stop_gfar(struct net_device *dev);
 extern void gfar_halt(struct net_device *dev);
 extern void gfar_phy_test(struct mii_bus *bus, struct phy_device *phydev,
 		int enable, u32 regnum, u32 read);
-extern void gfar_configure_coalescing(struct gfar_private *priv,
-		unsigned long tx_mask, unsigned long rx_mask);
+extern void gfar_configure_coalescing_all(struct gfar_private *priv);
 void gfar_init_sysfs(struct net_device *dev);
 int gfar_set_features(struct net_device *dev, netdev_features_t features);
 extern void gfar_check_rx_parser_mode(struct gfar_private *priv);
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 75e89ac..8248df7 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -436,7 +436,7 @@ static int gfar_scoalesce(struct net_device *dev,
 			gfar_usecs2ticks(priv, cvals->tx_coalesce_usecs));
 	}
 
-	gfar_configure_coalescing(priv, 0xFF, 0xFF);
+	gfar_configure_coalescing_all(priv);
 
 	return 0;
 }
-- 
1.7.11.3
