From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 v2 5/5] gianfar: Continue polling until both tx and rx are empty
Date: Wed, 17 Dec 2008 12:53:01 -0600
Message-ID: <1229539981-14041-6-git-send-email-afleming@freescale.com>
References: <1229539981-14041-1-git-send-email-afleming@freescale.com>
 <1229539981-14041-2-git-send-email-afleming@freescale.com>
 <1229539981-14041-3-git-send-email-afleming@freescale.com>
 <1229539981-14041-4-git-send-email-afleming@freescale.com>
 <1229539981-14041-5-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:58736 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbYLQSxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 13:53:18 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBHIr3mT011189
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 11:53:14 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id mBHIr28s024696
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 12:53:03 -0600 (CST)
In-Reply-To: <1229539981-14041-5-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gfar_poll would declare polling done once the rx queue was empty,
but the tx queue could still have packets left.

Stolen mostly from the e1000 driver.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 939e38c..144f941 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1843,7 +1843,8 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 {
 	struct gfar_private *priv = container_of(napi, struct gfar_private, napi);
 	struct net_device *dev = priv->dev;
-	int howmany;
+	int tx_cleaned = 0;
+	int rx_cleaned = 0;
 	unsigned long flags;
 
 	/* Clear IEVENT, so interrupts aren't called again
@@ -1852,13 +1853,16 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
 	/* If we fail to get the lock, don't bother with the TX BDs */
 	if (spin_trylock_irqsave(&priv->txlock, flags)) {
-		gfar_clean_tx_ring(dev);
+		tx_cleaned = gfar_clean_tx_ring(dev);
 		spin_unlock_irqrestore(&priv->txlock, flags);
 	}
 
-	howmany = gfar_clean_rx_ring(dev, budget);
+	rx_cleaned = gfar_clean_rx_ring(dev, budget);
 
-	if (howmany < budget) {
+	if (tx_cleaned)
+		return budget;
+
+	if (rx_cleaned < budget) {
 		netif_rx_complete(dev, napi);
 
 		/* Clear the halt bit in RSTAT */
@@ -1878,7 +1882,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 		}
 	}
 
-	return howmany;
+	return rx_cleaned;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.5.4.GIT

