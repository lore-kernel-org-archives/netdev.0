From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: [PATCH] net: bcmgenet: Fix internal PHY link state
Date: Fri, 19 Feb 2016 13:48:50 +0900
Message-ID: <1455857330-18092-1-git-send-email-jaedon.shin@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>, opendmb@gmail.com,
	Jaedon Shin <jaedon.shin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33243 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424911AbcBSEtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 23:49:06 -0500
Received: by mail-pf0-f169.google.com with SMTP id q63so44260899pfb.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 20:49:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY link state is not chaged in GENETv2 caused by the previous
commit 49f7a471e4d1 ("net: bcmgenet: Properly configure PHY to ignore
interrupt") was set to PHY_IGNORE_INTERRUPT in bcmgenet_mii_probe().

The internal PHY should use phy_mac_interrupt() when not in use
PHY_POLL. The statement for phy_mac_interrupt() has two conditions. The
first condition to check GENET_HAS_MDIO_INTR is not related PHY link
state, so this patch removes it.

Fixes: 49f7a471e4d1 ("net: bcmgenet: Properly configure PHY to ignore interrupt")
Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index b15a60d787c7..d7e01a74e927 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2445,8 +2445,7 @@ static void bcmgenet_irq_task(struct work_struct *work)
 	}
 
 	/* Link UP/DOWN event */
-	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
-	    (priv->irq0_stat & UMAC_IRQ_LINK_EVENT)) {
+	if (priv->irq0_stat & UMAC_IRQ_LINK_EVENT) {
 		phy_mac_interrupt(priv->phydev,
 				  !!(priv->irq0_stat & UMAC_IRQ_LINK_UP));
 		priv->irq0_stat &= ~UMAC_IRQ_LINK_EVENT;
-- 
2.7.1
