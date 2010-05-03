From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Avoid race in sky2_change_mtu
Date: Mon, 03 May 2010 23:18:56 +0900
Message-ID: <4BDEDB50.7000707@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40819 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759033Ab0ECO1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 10:27:48 -0400
Received: by fxm10 with SMTP id 10so2152477fxm.19
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 07:27:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_stop_queue does not ensure all in-progress transmits are complete,
 so use netif_tx_disable() instead.

Make sure NAPI polls are disabled, otherwise NAPI might trigger a TX
 restart between when we stop the queue and NAPI is disabled.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 088c797..b839bae 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2236,8 +2236,8 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	sky2_write32(hw, B0_IMSK, 0);
 
 	dev->trans_start = jiffies;	/* prevent tx timeout */
-	netif_stop_queue(dev);
 	napi_disable(&hw->napi);
+	netif_tx_disable(dev);
 
 	synchronize_irq(hw->pdev->irq);
 
-- 
1.5.6.5

