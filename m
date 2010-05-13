From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/6] sky2: Avoid race in sky2_change_mtu
Date: Thu, 13 May 2010 09:12:49 -0700
Message-ID: <20100513161351.090405345@vyatta.com>
References: <20100513161247.833356588@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39382 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758006Ab0EMXaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 19:30:25 -0400
Content-Disposition: inline; filename=sky2-mike1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

netif_stop_queue does not ensure all in-progress transmits are complete,
 so use netif_tx_disable() instead.

Secondly, make sure NAPI polls are disabled before stopping the tx queue,
 otherwise sky2_status_intr might trigger a TX queue wakeup between when
 we stop the queue and NAPI is disabled.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
This is not a regression, so only apply to -next


--- a/drivers/net/sky2.c	2010-05-13 08:57:20.186332415 -0700
+++ b/drivers/net/sky2.c	2010-05-13 08:57:22.526983099 -0700
@@ -2275,8 +2275,8 @@ static int sky2_change_mtu(struct net_de
 	sky2_write32(hw, B0_IMSK, 0);
 
 	dev->trans_start = jiffies;	/* prevent tx timeout */
-	netif_stop_queue(dev);
 	napi_disable(&hw->napi);
+	netif_tx_disable(dev);
 
 	synchronize_irq(hw->pdev->irq);
 


