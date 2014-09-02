From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: systemport: update UMAC_CMD only when link is detected
Date: Tue,  2 Sep 2014 11:17:07 -0700
Message-ID: <1409681827-5837-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:37463 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbaIBSSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 14:18:06 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so9129559pdb.13
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 11:18:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we bring the interface down, phy_stop() will schedule the PHY
state machine to call our link adjustment callback. By the time we do so,
we may have clock gated off the SYSTEMPORT hardware block, and this will
cause bus errors to happen in bcm_sysport_adj_link():

Make sure that we only touch the UMAC_CMD register when there is an
actual link. This is safe to do for two reasons:

- updating the Ethernet MAC registers only make sense when a physical
  link is present
- the PHY library state machine first set phydev->link = 0 before
  invoking phydev->adjust_link in the PHY_HALTED case

This is a similar fix to the GENET one:
c677ba8b3c47650358572091ed8a6af50bfca877 ("net: bcmgenet: update
UMAC_CMD only when link is detected").

Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 8f91de169663..662cf2222873 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1071,16 +1071,19 @@ static void bcm_sysport_adj_link(struct net_device *dev)
 	if (!phydev->pause)
 		cmd_bits |= CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE;
 
-	if (changed) {
+	if (!changed)
+		return;
+
+	if (phydev->link) {
 		reg = umac_readl(priv, UMAC_CMD);
 		reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
 			CMD_HD_EN | CMD_RX_PAUSE_IGNORE |
 			CMD_TX_PAUSE_IGNORE);
 		reg |= cmd_bits;
 		umac_writel(priv, reg, UMAC_CMD);
-
-		phy_print_status(priv->phydev);
 	}
+
+	phy_print_status(priv->phydev);
 }
 
 static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
-- 
1.9.1
