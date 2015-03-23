From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/7] net: bcmgenet: propagate errors from bcmgenet_power_down
Date: Mon, 23 Mar 2015 15:03:45 -0700
Message-ID: <1427148231-18902-2-git-send-email-f.fainelli@gmail.com>
References: <1427148231-18902-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33983 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400AbbCWWEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:04:37 -0400
Received: by pdbni2 with SMTP id ni2so200352074pdb.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:04:36 -0700 (PDT)
In-Reply-To: <1427148231-18902-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bcmgenet_power_down() fails, we would want to propagate a return
value from bcmgenet_wol_power_down_cfg() to know about this.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 12956b143b11..f86837f1656a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -847,9 +847,10 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 };
 
 /* Power down the unimac, based on mode. */
-static void bcmgenet_power_down(struct bcmgenet_priv *priv,
+static int bcmgenet_power_down(struct bcmgenet_priv *priv,
 				enum bcmgenet_power_mode mode)
 {
+	int ret = 0;
 	u32 reg;
 
 	switch (mode) {
@@ -858,7 +859,7 @@ static void bcmgenet_power_down(struct bcmgenet_priv *priv,
 		break;
 
 	case GENET_POWER_WOL_MAGIC:
-		bcmgenet_wol_power_down_cfg(priv, mode);
+		ret = bcmgenet_wol_power_down_cfg(priv, mode);
 		break;
 
 	case GENET_POWER_PASSIVE:
@@ -873,6 +874,8 @@ static void bcmgenet_power_down(struct bcmgenet_priv *priv,
 	default:
 		break;
 	}
+
+	return 0;
 }
 
 static void bcmgenet_power_up(struct bcmgenet_priv *priv,
@@ -2606,12 +2609,12 @@ static int bcmgenet_close(struct net_device *dev)
 	free_irq(priv->irq1, priv);
 
 	if (phy_is_internal(priv->phydev))
-		bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
+		ret = bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
 
 	if (!IS_ERR(priv->clk))
 		clk_disable_unprepare(priv->clk);
 
-	return 0;
+	return ret;
 }
 
 static void bcmgenet_timeout(struct net_device *dev)
@@ -3097,14 +3100,14 @@ static int bcmgenet_suspend(struct device *d)
 
 	/* Prepare the device for Wake-on-LAN and switch to the slow clock */
 	if (device_may_wakeup(d) && priv->wolopts) {
-		bcmgenet_power_down(priv, GENET_POWER_WOL_MAGIC);
+		ret = bcmgenet_power_down(priv, GENET_POWER_WOL_MAGIC);
 		clk_prepare_enable(priv->clk_wol);
 	}
 
 	/* Turn off the clocks */
 	clk_disable_unprepare(priv->clk);
 
-	return 0;
+	return ret;
 }
 
 static int bcmgenet_resume(struct device *d)
-- 
2.1.0
