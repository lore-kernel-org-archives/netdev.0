From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 09/11] tlan: Don't disable internal PHY on cards that use it in 10 Mbps mode
Date: Sat, 21 Jun 2014 16:47:54 +0200
Message-ID: <1403362076-7777-10-git-send-email-linux@rainbow-software.org>
References: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In tlan_reset_adapter, we disable internal PHY when an external one is used.
On cards which use internal PHY in 10 Mbps mode, we enable it later when
setting 10 Mbps mode but it does not really work (PHY fails to reset).
Leave it enabled instead.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index f5af196..ef32e5f 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -2238,7 +2238,9 @@ tlan_reset_adapter(struct net_device *dev)
 		}
 	}
 
-	if (priv->phy_num == 0)
+	/* don't power down internal PHY if we're going to use it */
+	if (priv->phy_num == 0 ||
+	   (priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10))
 		data |= TLAN_NET_CFG_PHY_EN;
 	tlan_dio_write16(dev->base_addr, TLAN_NET_CONFIG, (u16) data);
 
@@ -2689,7 +2691,6 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
 	struct tlan_priv	*priv = netdev_priv(dev);
 	u16		an_adv;
 	u16		an_lpa;
-	u16		data;
 	u16		mode;
 	u16		phy;
 	u16		status;
@@ -2722,9 +2723,6 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
 	    (priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10) &&
 	    (priv->phy_num != 0)) {
 		priv->phy_num = 0;
-		data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN
-			| TLAN_NET_CFG_PHY_EN;
-		tlan_dio_write16(dev->base_addr, TLAN_NET_CONFIG, data);
 		tlan_set_timer(dev, (400*HZ/1000), TLAN_TIMER_PHY_PDOWN);
 		return;
 	}
-- 
Ondrej Zary
