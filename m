From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 07/11] net: calxedaxgmac: enable interrupts after napi_enable
Date: Fri, 30 Aug 2013 16:49:25 -0500
Message-ID: <1377899369-23252-7-git-send-email-robherring2@gmail.com>
References: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:40341 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709Ab3H3VuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:50:05 -0400
Received: by mail-oa0-f51.google.com with SMTP id h1so2913822oag.24
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 14:50:04 -0700 (PDT)
In-Reply-To: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

Fix a race condition where the interrupt handler may have called
napi_schedule before napi_enable is called. This would disable interrupts
and never actually schedule napi to run.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 5d0b61a..73d3f83 100644
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
