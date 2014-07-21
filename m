From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 08/11] net: bcmgenet: handle UMAC_IRQ_MPD_R interrupt bit
Date: Mon, 21 Jul 2014 15:29:26 -0700
Message-ID: <1405981769-24618-9-git-send-email-f.fainelli@gmail.com>
References: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:56579 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755016AbaGUW34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:29:56 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so10538998pad.25
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:29:55 -0700 (PDT)
In-Reply-To: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
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
index f5118f4cccf3..319b94381d2e 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1836,6 +1836,13 @@ static void bcmgenet_irq_task(struct work_struct *work)
 
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
