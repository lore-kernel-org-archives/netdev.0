From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/3] net: systemport: avoid unbalanced enable_irq_wake calls
Date: Thu,  9 Oct 2014 18:06:37 -0700
Message-ID: <1412903197-19193-4-git-send-email-f.fainelli@gmail.com>
References: <1412903197-19193-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:62296 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaJJBG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 21:06:58 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so674488pdb.30
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 18:06:58 -0700 (PDT)
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

After step 4), SYSTEMPORT would always wake-up the system no matter what
wake-up device we use, which is not what we want. Fix this by making
sure there are no unbalanced enable_irq_wake() calls.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 075688188644..9ae36979bdee 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -436,7 +436,8 @@ static int bcm_sysport_set_wol(struct net_device *dev,
 	/* Flag the device and relevant IRQ as wakeup capable */
 	if (wol->wolopts) {
 		device_set_wakeup_enable(kdev, 1);
-		enable_irq_wake(priv->wol_irq);
+		if (priv->wol_irq_disabled)
+			enable_irq_wake(priv->wol_irq);
 		priv->wol_irq_disabled = 0;
 	} else {
 		device_set_wakeup_enable(kdev, 0);
-- 
1.9.1
