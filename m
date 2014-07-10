From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 09/11] net: bcmgenet: fix bcmgenet_wol_resume
Date: Thu, 10 Jul 2014 15:46:22 -0700
Message-ID: <1405032384-24006-10-git-send-email-f.fainelli@gmail.com>
References: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:47295 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbaGJWqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 18:46:37 -0400
Received: by mail-ie0-f181.google.com with SMTP id rp18so232363iec.40
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 15:46:36 -0700 (PDT)
In-Reply-To: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet_wol_resume() will create an unbalanced clock state for the
wol_clk clock pointer since everywhere else in the code, we always call
clk_prepare_enable() and clk_disable_unprepare(). This function also
calls init_umac() which is neither correct nor necessary since
bcmgenet_resume() and bcmgenet_open() already does that.

Finally calling bcmgenet_wol_resume() in bcmgenet_open() is not correct,
since the interface would not have been able to put us in Wake-on-LAN
mode if it was not UP before.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 552fba4e72da..5b2b9c546ee7 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1972,14 +1972,8 @@ static void bcmgenet_set_hw_addr(struct bcmgenet_priv *priv,
 
 static int bcmgenet_wol_resume(struct bcmgenet_priv *priv)
 {
-	int ret;
-
 	/* From WOL-enabled suspend, switch to regular clock */
-	clk_disable(priv->clk_wol);
-	/* init umac registers to synchronize s/w with h/w */
-	ret = init_umac(priv);
-	if (ret)
-		return ret;
+	clk_disable_unprepare(priv->clk_wol);
 
 	phy_init_hw(priv->phydev);
 	/* Speed settings must be restored */
@@ -2070,12 +2064,6 @@ static int bcmgenet_open(struct net_device *dev)
 
 	bcmgenet_set_hw_addr(priv, dev->dev_addr);
 
-	if (priv->wol_enabled) {
-		ret = bcmgenet_wol_resume(priv);
-		if (ret)
-			return ret;
-	}
-
 	if (phy_is_internal(priv->phydev)) {
 		reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
 		reg |= EXT_ENERGY_DET_MASK;
-- 
1.9.1
