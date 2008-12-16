From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 14/14] gianfar: Continue polling until both tx and rx are empty
Date: Tue, 16 Dec 2008 17:21:07 -0600
Message-ID: <1229469667-25002-15-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
 <1229469667-25002-4-git-send-email-afleming@freescale.com>
 <1229469667-25002-5-git-send-email-afleming@freescale.com>
 <1229469667-25002-6-git-send-email-afleming@freescale.com>
 <1229469667-25002-7-git-send-email-afleming@freescale.com>
 <1229469667-25002-8-git-send-email-afleming@freescale.com>
 <1229469667-25002-9-git-send-email-afleming@freescale.com>
 <1229469667-25002-10-git-send-email-afleming@freescale.com>
 <1229469667-25002-11-git-send-email-afleming@freescale.com>
 <1229469667-25002-12-git-send-email-afleming@freescale.com>
 <1229469667-25002-13-git-send-email-afleming@freescale.com>
 <1229469667-25002-14-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39685 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbYLPXVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:21 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNL918013540
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:10 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNL9Up021002
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:09 -0600 (CST)
In-Reply-To: <1229469667-25002-14-git-send-email-afleming@freescale.com>
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
index b96aa52..6a087f6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1846,7 +1846,8 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 {
 	struct gfar_private *priv = container_of(napi, struct gfar_private, napi);
 	struct net_device *dev = priv->dev;
-	int howmany;
+	int tx_cleaned = 0;
+	int rx_cleaned = 0;
 	unsigned long flags;
 
 	/* Clear IEVENT, so interrupts aren't called again
@@ -1855,13 +1856,16 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
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
@@ -1881,7 +1885,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 		}
 	}
 
-	return howmany;
+	return rx_cleaned;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.5.4.GIT

