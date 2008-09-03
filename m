From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 12/17] mv643xx_eth: get rid of netif_{stop,wake}_queue() calls on link down/up
Date: Wed,  3 Sep 2008 14:29:39 +0200
Message-ID: <1220444984-20150-13-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52902 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752269AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to call netif_{stop,wake}_queue() when the link goes
down/up, as the networking already takes care of this internally.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   27 ++++++++-------------------
 1 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b4850cf..bd3ca47 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -631,11 +631,9 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 		for (i = 0; i < mp->txq_count; i++)
 			txq_reclaim(mp->txq + i, 0);
 
-		if (netif_carrier_ok(mp->dev)) {
-			spin_lock_irq(&mp->lock);
-			__txq_maybe_wake(mp->txq);
-			spin_unlock_irq(&mp->lock);
-		}
+		spin_lock_irq(&mp->lock);
+		__txq_maybe_wake(mp->txq);
+		spin_unlock_irq(&mp->lock);
 	}
 #endif
 
@@ -1765,7 +1763,6 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 			printk(KERN_INFO "%s: link down\n", dev->name);
 
 			netif_carrier_off(dev);
-			netif_stop_queue(dev);
 
 			for (i = 0; i < mp->txq_count; i++) {
 				struct tx_queue *txq = mp->txq + i;
@@ -1799,10 +1796,8 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 			 speed, duplex ? "full" : "half",
 			 fc ? "en" : "dis");
 
-	if (!netif_carrier_ok(dev)) {
+	if (!netif_carrier_ok(dev))
 		netif_carrier_on(dev);
-		netif_wake_queue(dev);
-	}
 }
 
 static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
@@ -1851,11 +1846,9 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		 * Enough space again in the primary TX queue for a
 		 * full packet?
 		 */
-		if (netif_carrier_ok(dev)) {
-			spin_lock(&mp->lock);
-			__txq_maybe_wake(mp->txq);
-			spin_unlock(&mp->lock);
-		}
+		spin_lock(&mp->lock);
+		__txq_maybe_wake(mp->txq);
+		spin_unlock(&mp->lock);
 	}
 
 	/*
@@ -2060,7 +2053,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 	}
 
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	port_start(mp);
 
@@ -2123,7 +2115,6 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	del_timer_sync(&mp->rx_oom);
 
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	free_irq(dev->irq, dev);
 
@@ -2184,11 +2175,9 @@ static void tx_timeout_task(struct work_struct *ugly)
 	mp = container_of(ugly, struct mv643xx_eth_private, tx_timeout_task);
 	if (netif_running(mp->dev)) {
 		netif_stop_queue(mp->dev);
-
 		port_reset(mp);
 		port_start(mp);
-
-		__txq_maybe_wake(mp->txq);
+		netif_wake_queue(mp->dev);
 	}
 }
 
-- 
1.5.6.4

