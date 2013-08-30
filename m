From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v2 07/11] net: calxedaxgmac: enable interrupts after napi_enable
Date: Thu, 29 Aug 2013 22:13:44 -0500
Message-ID: <1377832428-18117-7-git-send-email-robherring2@gmail.com>
References: <1377832428-18117-1-git-send-email-robherring2@gmail.com>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	bhutchings@solarflare.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:35736 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862Ab3H3DOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:14:06 -0400
Received: by mail-oa0-f42.google.com with SMTP id j10so1335528oah.15
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 20:14:06 -0700 (PDT)
In-Reply-To: <1377832428-18117-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

Fix a race condition where the interrupt handler may have called
napi_schedule before napi_enable is called. This would disable interrupts
and never actually schedule napi to run.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
v2: No change

 drivers/net/ethernet/calxeda/xgmac.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 54be55b..530b594 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -959,9 +959,7 @@ static int xgmac_hw_init(struct net_device *dev)
 		DMA_BUS_MODE_FB | DMA_BUS_MODE_ATDS | DMA_BUS_MODE_AAL;
 	writel(value, ioaddr + XGMAC_DMA_BUS_MODE);
 
-	/* Enable interrupts */
-	writel(DMA_INTR_DEFAULT_MASK, ioaddr + XGMAC_DMA_STATUS);
-	writel(DMA_INTR_DEFAULT_MASK, ioaddr + XGMAC_DMA_INTR_ENA);
+	writel(0, ioaddr + XGMAC_DMA_INTR_ENA);
 
 	/* Mask power mgt interrupt */
 	writel(XGMAC_INT_STAT_PMTIM, ioaddr + XGMAC_INT_STAT);
@@ -1029,6 +1027,10 @@ static int xgmac_open(struct net_device *dev)
 	napi_enable(&priv->napi);
 	netif_start_queue(dev);
 
+	/* Enable interrupts */
+	writel(DMA_INTR_DEFAULT_MASK, ioaddr + XGMAC_DMA_STATUS);
+	writel(DMA_INTR_DEFAULT_MASK, ioaddr + XGMAC_DMA_INTR_ENA);
+
 	return 0;
 }
 
-- 
1.8.1.2
