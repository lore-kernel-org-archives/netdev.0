From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 09/11] net: bcmgenet: fix bcmgenet_wol_resume
Date: Mon, 21 Jul 2014 15:29:27 -0700
Message-ID: <1405981769-24618-10-git-send-email-f.fainelli@gmail.com>
References: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35115 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754923AbaGUW35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:29:57 -0400
Received: by mail-pd0-f179.google.com with SMTP id ft15so9974988pdb.38
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:29:56 -0700 (PDT)
In-Reply-To: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
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
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 319b94381d2e..1925ae1dc1e6 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1965,14 +1965,8 @@ static void bcmgenet_set_hw_addr(struct bcmgenet_priv *priv,
 
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
-- 
1.9.1
