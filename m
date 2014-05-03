From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: systemport: only update UMAC_CMD if something changed
Date: Sat,  3 May 2014 11:31:13 -0700
Message-ID: <1399141874-12003-2-git-send-email-f.fainelli@gmail.com>
References: <1399141874-12003-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:58779 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbaECSbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 14:31:33 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so7156154pab.41
        for <netdev@vger.kernel.org>; Sat, 03 May 2014 11:31:32 -0700 (PDT)
In-Reply-To: <1399141874-12003-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The link adjustment callback can be called as frequently as desired by
the PHY library, as such, let's avoid doing a Read/Modify/Write sequence
if nothing changed, which is more than likely since we are interfaced
with a switch device.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 4dc8d1e..e118e74 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -959,15 +959,16 @@ static void bcm_sysport_adj_link(struct net_device *dev)
 	if (!phydev->pause)
 		cmd_bits |= CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE;
 
-	reg = umac_readl(priv, UMAC_CMD);
-	reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
-			CMD_HD_EN | CMD_RX_PAUSE_IGNORE |
-			CMD_TX_PAUSE_IGNORE);
-	reg |= cmd_bits;
-	umac_writel(priv, reg, UMAC_CMD);
+	if (changed) {
+		reg = umac_readl(priv, UMAC_CMD);
+		reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
+				CMD_HD_EN | CMD_RX_PAUSE_IGNORE |
+				CMD_TX_PAUSE_IGNORE);
+		reg |= cmd_bits;
+		umac_writel(priv, reg, UMAC_CMD);
 
-	if (changed)
 		phy_print_status(priv->phydev);
+	}
 }
 
 static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
-- 
1.9.1
