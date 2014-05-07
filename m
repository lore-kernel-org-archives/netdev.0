From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 1/2] net: systemport: only update UMAC_CMD if something changed
Date: Wed,  7 May 2014 14:36:03 -0700
Message-ID: <1399498564-22037-2-git-send-email-f.fainelli@gmail.com>
References: <1399498564-22037-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:41060 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbaEGVga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:36:30 -0400
Received: by mail-pd0-f182.google.com with SMTP id v10so1514401pde.41
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 14:36:30 -0700 (PDT)
In-Reply-To: <1399498564-22037-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The link adjustment callback can be called as frequently as desired by
the PHY library, as such, let's avoid doing a Read/Modify/Write sequence
if nothing changed, which is more than likely since we are interfaced
with a switch device.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v3:
- make sure the second and third line after CMD_SPEED_MASK are aligned
  properly

Changes in v2:
- rebased

 drivers/net/ethernet/broadcom/bcmsysport.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 4dc8d1e9829b..e118e7411ca4 100644
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
