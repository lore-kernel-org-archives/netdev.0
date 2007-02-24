From: Patrick McHardy <kaber@trash.net>
Subject: [SKGE]: Fix deadlock in skge_tx_timeout
Date: Sat, 24 Feb 2007 20:08:23 +0100
Message-ID: <45E08D27.4030509@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010402080104080400040104"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57921 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932809AbXBXTIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 14:08:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010402080104080400040104
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit



--------------010402080104080400040104
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[SKGE]: Fix deadlock in skge_tx_timeout

dev_watchdog() already holds the device lock, don't take it again in
skge_tx_clean().

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0b1cfafa6f6b8a168d5811d1f65cf540942c52b1
tree 4d3f252d6618adfe812e9da95cd496bb798e7c7b
parent 1ca949299260aa49eeba34ff912e2321c8b1f647
author Patrick McHardy <kaber@trash.net> Sat, 24 Feb 2007 20:05:39 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 24 Feb 2007 20:05:39 +0100

 drivers/net/skge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index e482e7f..4a948c2 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2575,7 +2575,9 @@ static int skge_down(struct net_device *
 	skge_led(skge, LED_MODE_OFF);
 
 	netif_poll_disable(dev);
+	netif_tx_lock_bh(dev);
 	skge_tx_clean(dev);
+	netif_tx_unlock_bh(dev);
 	skge_rx_clean(skge);
 
 	kfree(skge->rx_ring.start);
@@ -2720,7 +2722,6 @@ static void skge_tx_clean(struct net_dev
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_element *e;
 
-	netif_tx_lock_bh(dev);
 	for (e = skge->tx_ring.to_clean; e != skge->tx_ring.to_use; e = e->next) {
 		struct skge_tx_desc *td = e->desc;
 		skge_tx_free(skge, e, td->control);
@@ -2729,7 +2730,6 @@ static void skge_tx_clean(struct net_dev
 
 	skge->tx_ring.to_clean = e;
 	netif_wake_queue(dev);
-	netif_tx_unlock_bh(dev);
 }
 
 static void skge_tx_timeout(struct net_device *dev)


--------------010402080104080400040104--
