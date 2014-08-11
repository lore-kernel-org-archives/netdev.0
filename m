From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 4/4] net: bcmgenet: correctly resume adapter from Wake-on-LAN
Date: Mon, 11 Aug 2014 14:50:45 -0700
Message-ID: <1407793845-30895-5-git-send-email-f.fainelli@gmail.com>
References: <1407793845-30895-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:40372 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbaHKVvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 17:51:09 -0400
Received: by mail-pa0-f46.google.com with SMTP id lj1so11877958pab.33
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 14:51:08 -0700 (PDT)
In-Reply-To: <1407793845-30895-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we configured the adapter to be a wake up source from
Wake-on-LAN, but we never actually woke up using Wake-on-LAN, we will
leave the adapter in MagicPacket matching mode, which prevents any other
type of packets from reaching the RX engine. Fix this by calling
bcmgenet_power_up() with GENET_POWER_WOL_MAGIC to restore the adapter
configuration in bcmgenet_resume().

The second problem we had was an imbalanced clock disabling in
bcmgenet_wol_resume(), the Wake-on-LAN slow clock is only enabled in
bcmgenet_suspend() if we configured Wake-on-LAN, yet we unconditionally
disabled the clock in bcmgenet_wol_resume().

Fixes: 8c90db72f926 ("net: bcmgenet: suspend and resume from Wake-on-LAN")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 90eb9c4b1b2c..3f9d4de8173c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1962,7 +1962,8 @@ static void bcmgenet_set_hw_addr(struct bcmgenet_priv *priv,
 static int bcmgenet_wol_resume(struct bcmgenet_priv *priv)
 {
 	/* From WOL-enabled suspend, switch to regular clock */
-	clk_disable_unprepare(priv->clk_wol);
+	if (priv->wolopts)
+		clk_disable_unprepare(priv->clk_wol);
 
 	phy_init_hw(priv->phydev);
 	/* Speed settings must be restored */
@@ -2668,9 +2669,7 @@ static int bcmgenet_resume(struct device *d)
 	if (ret)
 		goto out_clk_disable;
 
-	if (priv->wolopts)
-		ret = bcmgenet_wol_resume(priv);
-
+	ret = bcmgenet_wol_resume(priv);
 	if (ret)
 		goto out_clk_disable;
 
@@ -2685,6 +2684,9 @@ static int bcmgenet_resume(struct device *d)
 		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
 	}
 
+	if (priv->wolopts)
+		bcmgenet_power_up(priv, GENET_POWER_WOL_MAGIC);
+
 	/* Disable RX/TX DMA and flush TX queues */
 	dma_ctrl = bcmgenet_dma_disable(priv);
 
-- 
1.9.1
