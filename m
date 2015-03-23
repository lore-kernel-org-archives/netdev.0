From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 7/7] net: bcmgenet: power down and up GPHY during suspend/resume
Date: Mon, 23 Mar 2015 15:09:57 -0700
Message-ID: <1427148597-28337-8-git-send-email-f.fainelli@gmail.com>
References: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36099 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734AbbCWWL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:11:27 -0400
Received: by padcy3 with SMTP id cy3so204528565pad.3
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:11:27 -0700 (PDT)
In-Reply-To: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the interface is not used, power down the integrated GPHY during
suspend. Similarly to bcmgenet_open(), bcmgenet_resume() powers on the GPHY
prior to any UniMAC activity.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index c6b15c3cf023..c38d5429e27a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -3107,6 +3107,8 @@ static int bcmgenet_suspend(struct device *d)
 	if (device_may_wakeup(d) && priv->wolopts) {
 		ret = bcmgenet_power_down(priv, GENET_POWER_WOL_MAGIC);
 		clk_prepare_enable(priv->clk_wol);
+	} else if (phy_is_internal(priv->phydev)) {
+		ret = bcmgenet_power_down(priv, GENET_POWER_PASSIVE);
 	}
 
 	/* Turn off the clocks */
@@ -3131,6 +3133,12 @@ static int bcmgenet_resume(struct device *d)
 	if (ret)
 		return ret;
 
+	/* If this is an internal GPHY, power it back on now, before UniMAC is
+	 * brought out of reset as absolutely no UniMAC activity is allowed
+	 */
+	if (phy_is_internal(priv->phydev))
+		bcmgenet_power_up(priv, GENET_POWER_PASSIVE);
+
 	bcmgenet_umac_reset(priv);
 
 	ret = init_umac(priv);
-- 
2.1.0
