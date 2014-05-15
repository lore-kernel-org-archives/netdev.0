From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 1/2] net: systemport: only update UMAC_CMD if something changed
Date: Wed, 14 May 2014 19:32:13 -0700
Message-ID: <1400121134-6088-2-git-send-email-f.fainelli@gmail.com>
References: <1400121134-6088-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, David Laight <David.Laight@aculab.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:49545 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaEOCcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 22:32:31 -0400
Received: by mail-pb0-f44.google.com with SMTP id rq2so426997pbb.3
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 19:32:30 -0700 (PDT)
In-Reply-To: <1400121134-6088-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The link adjustment callback can be called as frequently as desired by
the PHY library, as such, let's avoid doing a Read/Modify/Write sequence
if nothing changed, which is more than likely since we are interfaced
with a switch device.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v5:
- respin

Changes in v4:
- re-align 2nd and 3rd lines properly according to the network style

Changes in v3:
- attempted to re-align the CMD_HD_EN lines but failed miserably

Changes in v2:
- respin

 drivers/net/ethernet/broadcom/bcmsysport.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index f66de13..3950364 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -959,15 +959,16 @@ static void bcm_sysport_adj_link(struct net_device *dev)
 	if (!phydev->pause)
 		cmd_bits |= CMD_RX_PAUSE_IGNORE | CMD_TX_PAUSE_IGNORE;
 
-	reg = umac_readl(priv, UMAC_CMD);
-	reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
+	if (changed) {
+		reg = umac_readl(priv, UMAC_CMD);
+		reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
 			CMD_HD_EN | CMD_RX_PAUSE_IGNORE |
 			CMD_TX_PAUSE_IGNORE);
-	reg |= cmd_bits;
-	umac_writel(priv, reg, UMAC_CMD);
+		reg |= cmd_bits;
+		umac_writel(priv, reg, UMAC_CMD);
 
-	if (changed)
 		phy_print_status(priv->phydev);
+	}
 }
 
 static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
-- 
1.9.1
