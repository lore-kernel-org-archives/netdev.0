From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 1/2] 2.6.6-rc1-mm1 - spin_unlock_irqrestore avoidance in epic100
Date: Mon, 19 Apr 2004 23:50:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040419235014.A20504@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch avoids to duplicate a spin_unlock:
- it is mostly an artifact due to wild goto;
- it makes the generated code smaller.

diff -puN drivers/net/epic100.c~epic100-napi-40 drivers/net/epic100.c
--- linux-2.6.6-rc1/drivers/net/epic100.c~epic100-napi-40	2004-04-20 00:37:05.000000000 +0200
+++ linux-2.6.6-rc1-fr/drivers/net/epic100.c	2004-04-20 00:37:05.000000000 +0200
@@ -632,7 +632,8 @@ static inline void __epic_pci_commit(lon
 #endif
 }
 
-static void epic_napi_irq_off(struct net_device *dev, struct epic_private *ep)
+static inline void epic_napi_irq_off(struct net_device *dev,
+				     struct epic_private *ep)
 {
 	long ioaddr = dev->base_addr;
 
@@ -640,7 +641,8 @@ static void epic_napi_irq_off(struct net
 	__epic_pci_commit(ioaddr);
 }
 
-static void epic_napi_irq_on(struct net_device *dev, struct epic_private *ep)
+static inline void epic_napi_irq_on(struct net_device *dev,
+				    struct epic_private *ep)
 {
 	long ioaddr = dev->base_addr;
 
@@ -1370,20 +1372,24 @@ rx_action:
 
 	if (netif_running(dev) && (work_done < orig_budget)) {
 		unsigned long flags;
+		int more;
+
+		/* A bit baroque but it avoids a (space hungry) spin_unlock */
 
 		spin_lock_irqsave(&ep->napi_lock, flags);
 
-		if (ep->reschedule_in_poll) {
+		more = ep->reschedule_in_poll;
+		if (!more) {
+			__netif_rx_complete(dev);
+			outl(EpicNapiEvent, ioaddr + INTSTAT);
+			epic_napi_irq_on(dev, ep);
+		} else
 			ep->reschedule_in_poll--;
-			spin_unlock_irqrestore(&ep->napi_lock, flags);
-			goto rx_action;
-		}
-
-		outl(EpicNapiEvent, ioaddr + INTSTAT);
-		epic_napi_irq_on(dev, ep);
-		__netif_rx_complete(dev);
 
 		spin_unlock_irqrestore(&ep->napi_lock, flags);
+
+		if (more)
+			goto rx_action;
 	}
 
 	return (work_done >= orig_budget);

_
