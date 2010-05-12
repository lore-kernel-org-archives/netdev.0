From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 1/5] sky2: Avoid race in sky2_change_mtu
Date: Thu, 13 May 2010 08:16:31 +0900
Message-ID: <4BEB36CF.70001@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:39536 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755771Ab0ELXZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 19:25:33 -0400
Received: by pxi5 with SMTP id 5so334180pxi.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 16:25:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_stop_queue does not ensure all in-progress transmits are complete,
 so use netif_tx_disable() instead.

Secondly, make sure NAPI polls are disabled before stopping the tx queue,
 otherwise sky2_status_intr might trigger a TX queue wakeup between when
 we stop the queue and NAPI is disabled.

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


