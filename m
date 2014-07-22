From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: only update UMAC_CMD if something changed
Date: Mon, 21 Jul 2014 17:42:16 -0700
Message-ID: <1405989736-1409-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:53562 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbaGVAmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 20:42:31 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so10830870pad.35
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 17:42:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The link adjustment callback can be called as frequently as desired
by the PHY library, as such, let's avoid doing a Read/Modify/Write
sequence if nothing changed, since these register accesses can be
expensive.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmmii.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index add8d8596084..b1338c9e8abb 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -136,17 +136,18 @@ static void bcmgenet_mii_setup(struct net_device *dev)
 		/* pause capability */
 		if (!phydev->pause)
 			cmd_bits |= CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE;
+	}
 
+	if (status_changed) {
 		reg = bcmgenet_umac_readl(priv, UMAC_CMD);
 		reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
 			       CMD_HD_EN |
 			       CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE);
 		reg |= cmd_bits;
 		bcmgenet_umac_writel(priv, reg, UMAC_CMD);
-	}
 
-	if (status_changed)
 		phy_print_status(phydev);
+	}
 }
 
 void bcmgenet_mii_reset(struct net_device *dev)
-- 
1.9.1
