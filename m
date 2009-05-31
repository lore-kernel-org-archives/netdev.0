From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next 2/2] cpmac: prevent fatal exception in cpmac_end_xmit
Date: Sun, 31 May 2009 22:59:15 +0200
Message-ID: <200905312259.16127.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:35237 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbZEaU7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 16:59:18 -0400
Received: by ewy24 with SMTP id 24so7431428ewy.37
        for <netdev@vger.kernel.org>; Sun, 31 May 2009 13:59:19 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Weil <weil@mail.berlios.de>

We should not be stopping the subqueues in cpmac_end_xmit
but rather test the status of them. Replace the calls to
netif_subqueue_stop by __netif_subqueue_stopped. This
fixes an unrecoverable exception from happening when
running the driver.

Signed-off-by: Stefan Weil <weil@mail.berlios.de>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 08e2f67..58afafb 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -615,13 +615,13 @@ static void cpmac_end_xmit(struct net_device *dev, int queue)
 
 		dev_kfree_skb_irq(desc->skb);
 		desc->skb = NULL;
-		if (netif_subqueue_stopped(dev, queue))
+		if (__netif_subqueue_stopped(dev, queue))
 			netif_wake_subqueue(dev, queue);
 	} else {
 		if (netif_msg_tx_err(priv) && net_ratelimit())
 			printk(KERN_WARNING
 			       "%s: end_xmit: spurious interrupt\n", dev->name);
-		if (netif_subqueue_stopped(dev, queue))
+		if (__netif_subqueue_stopped(dev, queue))
 			netif_wake_subqueue(dev, queue);
 	}
 }
