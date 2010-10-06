From: Oskar Schirmer <oskar@linutronix.de>
Subject: [PATCH] net/fec: fix link/queue interaction, wake queue iff link is up
Date: Wed,  6 Oct 2010 13:31:58 +0200
Message-ID: <1286364718-20070-1-git-send-email-oskar@linutronix.de>
Cc: Dan Malek <dan@embeddedalley.com>,
	Sebastian Siewior <bigeasy@linutronix.de>,
	"Hans J. Koch" <hjk@linutronix.de>,
	Oskar Schirmer <oskar@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:39141 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753072Ab0JFLbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 07:31:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

with hardware slow in negotiation, the system did freeze
while trying to mount root on nfs at boot time.

while the driver did report being busy when the link is down
or no transmission buffers are available, it did not stop the
queue, causing instant retries. furthermore, transmission being
triggered with link down was caused by unconditional queue
wakes, especially on timeouts.

now, wake queue only iff link is up and transmission
buffers are available, and dont forget to wake queue
when link has been adjusted. next, add stop queue notification
upon driver induced transmission problems, so network stack has
a chance to handle the situation.

Signed-off-by: Oskar Schirmer <oskar@linutronix.de>
---
 drivers/net/fec.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 768b840..c2da006 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -222,12 +222,14 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned short	status;
 	unsigned long flags;
 
+	spin_lock_irqsave(&fep->hw_lock, flags);
 	if (!fep->link) {
 		/* Link is down or autonegotiation is in progress. */
+		netif_stop_queue(dev);
+		spin_unlock_irqrestore(&fep->hw_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
-	spin_lock_irqsave(&fep->hw_lock, flags);
 	/* Fill in a Tx ring entry */
 	bdp = fep->cur_tx;
 
@@ -238,6 +240,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * This should not happen, since dev->tbusy should be set.
 		 */
 		printk("%s: tx queue full!.\n", dev->name);
+		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&fep->hw_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
@@ -309,7 +312,8 @@ fec_timeout(struct net_device *dev)
 	dev->stats.tx_errors++;
 
 	fec_restart(dev, fep->full_duplex);
-	netif_wake_queue(dev);
+	if (fep->link && !fep->tx_full)
+		netif_wake_queue(dev);
 }
 
 static irqreturn_t
@@ -602,9 +606,11 @@ static void fec_enet_adjust_link(struct net_device *dev)
 	/* Link on or off change */
 	if (phy_dev->link != fep->link) {
 		fep->link = phy_dev->link;
-		if (phy_dev->link)
+		if (phy_dev->link) {
 			fec_restart(dev, phy_dev->duplex);
-		else
+			if (!fep->tx_full)
+				netif_wake_queue(dev);
+		} else
 			fec_stop(dev);
 		status_change = 1;
 	}
-- 
1.7.0.4

