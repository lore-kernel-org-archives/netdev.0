From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/7] skge: deadlock on tx timeout
Date: Fri, 16 Mar 2007 14:01:26 -0700
Message-ID: <20070316210155.813001089@linux-foundation.org>
References: <20070316210125.324052637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36165 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965934AbXCPVGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 17:06:33 -0400
Content-Disposition: inline; filename=skge-tx-timeout-deadlock.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The skge driver will deadlock if gets a transmit timeout
because the netif_tx_lock() is already held.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- skge-dev.orig/drivers/net/skge.c
+++ skge-dev/drivers/net/skge.c
@@ -2576,7 +2576,11 @@ static int skge_down(struct net_device *
 	skge_led(skge, LED_MODE_OFF);
 
 	netif_poll_disable(dev);
+
+	netif_tx_lock_bh(dev);
 	skge_tx_clean(dev);
+	netif_tx_unlock_bh(dev);
+
 	skge_rx_clean(skge);
 
 	kfree(skge->rx_ring.start);
@@ -2721,7 +2725,6 @@ static void skge_tx_clean(struct net_dev
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_element *e;
 
-	netif_tx_lock_bh(dev);
 	for (e = skge->tx_ring.to_clean; e != skge->tx_ring.to_use; e = e->next) {
 		struct skge_tx_desc *td = e->desc;
 		skge_tx_free(skge, e, td->control);
@@ -2730,7 +2733,6 @@ static void skge_tx_clean(struct net_dev
 
 	skge->tx_ring.to_clean = e;
 	netif_wake_queue(dev);
-	netif_tx_unlock_bh(dev);
 }
 
 static void skge_tx_timeout(struct net_device *dev)

-- 

