From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/3] net: bcmgenet: avoid unbalanced enable_irq_wake calls
Date: Thu,  9 Oct 2014 18:06:36 -0700
Message-ID: <1412903197-19193-3-git-send-email-f.fainelli@gmail.com>
References: <1412903197-19193-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:41735 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaJJBGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 21:06:55 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so715092pac.0
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 18:06:55 -0700 (PDT)
In-Reply-To: <1412903197-19193-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multiple enable_irq_wake() calls will keep increasing the IRQ
wake_depth, which ultimately leads to the following types of
situation:

1) enable Wake-on-LAN interrupt w/o password
2) enable Wake-on-LAN interrupt w/ password
3) enable Wake-on-LAN interrupt w/o password
4) disable Wake-on-LAN interrupt

After step 4), GENET would always wake-up the system no matter what
wake-up device we use, which is not what we want. Fix this by making
sure there are no unbalanced enable_irq_wake() calls.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c b/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
index b82b7e4e06b2..149a0d70c108 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
@@ -86,7 +86,9 @@ int bcmgenet_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	/* Flag the device and relevant IRQ as wakeup capable */
 	if (wol->wolopts) {
 		device_set_wakeup_enable(kdev, 1);
-		enable_irq_wake(priv->wol_irq);
+		/* Avoid unbalanced enable_irq_wake calls */
+		if (priv->wol_irq_disabled)
+			enable_irq_wake(priv->wol_irq);
 		priv->wol_irq_disabled = false;
 	} else {
 		device_set_wakeup_enable(kdev, 0);
-- 
1.9.1
