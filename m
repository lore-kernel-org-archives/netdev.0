From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/4] net: bcmgenet: update UMAC_CMD only when link is detected
Date: Mon, 11 Aug 2014 14:50:44 -0700
Message-ID: <1407793845-30895-4-git-send-email-f.fainelli@gmail.com>
References: <1407793845-30895-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:38579 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbaHKVvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 17:51:07 -0400
Received: by mail-pd0-f175.google.com with SMTP id r10so11423814pdi.20
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 14:51:07 -0700 (PDT)
In-Reply-To: <1407793845-30895-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we bring the interface down, phy_stop() will schedule the PHY state
machine to call our link adjustment callback. By the time we do so, we
may have clock gated off the GENET hardware block, and this will cause
bus errors to happen in bcmgenet_mii_setup():

Make sure that we only touch the UMAC_CMD register when there is an
actual link. This is safe to do for two reasons:

- updating the Ethernet MAC registers only make sense when a physical
  link is present
- the PHY library state machine first set phydev->link = 0 before
  invoking phydev->adjust_link in the PHY_HALTED case

Fixes: 240524089d7a ("net: bcmgenet: only update UMAC_CMD if something changed")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index b56f1bbb17bf..c88f7ae99636 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -129,7 +129,10 @@ static void bcmgenet_mii_setup(struct net_device *dev)
 			cmd_bits |= CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE;
 	}
 
-	if (status_changed) {
+	if (!status_changed)
+		return;
+
+	if (phydev->link) {
 		reg = bcmgenet_umac_readl(priv, UMAC_CMD);
 		reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
 			       CMD_HD_EN |
@@ -137,8 +140,9 @@ static void bcmgenet_mii_setup(struct net_device *dev)
 		reg |= cmd_bits;
 		bcmgenet_umac_writel(priv, reg, UMAC_CMD);
 
-		phy_print_status(phydev);
 	}
+
+	phy_print_status(phydev);
 }
 
 void bcmgenet_mii_reset(struct net_device *dev)
-- 
1.9.1
