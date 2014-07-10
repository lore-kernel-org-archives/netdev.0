From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 08/11] net: bcmgenet: handle UMAC_IRQ_MPD_R interrupt bit
Date: Thu, 10 Jul 2014 15:46:21 -0700
Message-ID: <1405032384-24006-9-git-send-email-f.fainelli@gmail.com>
References: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:57642 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301AbaGJWqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 18:46:36 -0400
Received: by mail-ig0-f176.google.com with SMTP id r10so3639507igi.9
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 15:46:35 -0700 (PDT)
In-Reply-To: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle UMAC_IRQ_MPD_R interrupt bit in our workqueue to make sure that
we properly re-configure the GENET adapter from Wake-on-LAN.

bcmgenet_power_up() makes sure that we will not leave the UniMAC
hardware in MagicPacket matching mode, since that would prevent any
other packet from being received.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index b010637ee69f..552fba4e72da 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1843,6 +1843,13 @@ static void bcmgenet_irq_task(struct work_struct *work)
 
 	netif_dbg(priv, intr, priv->dev, "%s\n", __func__);
 
+	if (priv->irq0_stat & UMAC_IRQ_MPD_R) {
+		priv->irq0_stat &= ~UMAC_IRQ_MPD_R;
+		netif_dbg(priv, wol, priv->dev,
+			  "magic packet detected, waking up\n");
+		bcmgenet_power_up(priv, GENET_POWER_WOL_MAGIC);
+	}
+
 	/* Link UP/DOWN event */
 	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
 		(priv->irq0_stat & (UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN))) {
-- 
1.9.1
