From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Wed, 24 Mar 2004 01:41:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040324014140.A16202@electric-eye.fr.zoreil.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com> <405DDDC6.7030007@pobox.com> <8765cvmyaq.fsf@devron.myhome.or.jp> <20040323195119.A14062@electric-eye.fr.zoreil.com> <871xnjgwrs.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Content-Disposition: inline
In-Reply-To: <871xnjgwrs.fsf@devron.myhome.or.jp>; from hirofumi@mail.parknet.co.jp on Wed, Mar 24, 2004 at 04:59:19AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
[...]
> > -> napi irq are disabled and device is removed from poll list. What will
> >    prevent it ?
> 
> __LINK_STATE_RX_SCHED flag is setting until __netif_rx_complete() is called.
> So netif_rx_schedule_prep() returns 0.

Ok, thanks for the explanation. It is possible that the lock stays anyway (see
below).

[...]
> > Afaiu, if some data comes in just before the spin_lock, it may wait for ages.
> 
> Yes, maybe. But, if after spin_lock, it loop may call the twice
> __netif_rx_schedule(). And netif_rx_complete() doesn't call dev_put().
> It will leaks the dev->refcnt, I think.

@$*#!zW

The following patch should avoid the leak as well as the packet rot
(untested, 1:33 AM, apply on top of previous serie).


Multiple invocation of __netif_rx_schedule() in epic_interrupt() while
epic_poll loops over __netif_rx_complete() leads to serious device
refcount leak.


 drivers/net/epic100.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff -puN drivers/net/epic100.c~epic100-napi-30 drivers/net/epic100.c
--- linux-2.6.5-rc2/drivers/net/epic100.c~epic100-napi-30	2004-03-24 01:18:25.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/epic100.c	2004-03-24 01:19:35.000000000 +0100
@@ -337,6 +337,7 @@ struct epic_private {
 	/* Ring pointers. */
 	spinlock_t lock;				/* Group with Tx control cache line. */
 	spinlock_t napi_lock;
+	unsigned int reschedule_in_poll;
 	unsigned int cur_tx, dirty_tx;
 
 	unsigned int cur_rx, dirty_rx;
@@ -472,7 +473,9 @@ static int __devinit epic_init_one (stru
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
 
-	spin_lock_init (&ep->lock);
+	spin_lock_init(&ep->lock);
+	spin_lock_init(&ep->napi_lock);
+	ep->reschedule_in_poll = 0;
 
 	/* Bring the chip out of low-power mode. */
 	outl(0x4200, ioaddr + GENCTL);
@@ -981,8 +984,6 @@ static void epic_init_ring(struct net_de
 	int i;
 
 	ep->tx_full = 0;
-	spin_lock_init(&ep->lock);
-	spin_lock_init(&ep->napi_lock);
 	ep->dirty_tx = ep->cur_tx = 0;
 	ep->cur_rx = ep->dirty_rx = 0;
 	ep->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
@@ -1152,7 +1153,6 @@ static void epic_tx(struct net_device *d
 	}
 }
 
-
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t epic_interrupt(int irq, void *dev_instance, struct pt_regs *regs)
@@ -1177,12 +1177,13 @@ static irqreturn_t epic_interrupt(int ir
 			break;
 		handled = 1;
 
-		if (status & EpicNapiEvent) {
+		if ((status & EpicNapiEvent) && !ep->reschedule_in_poll) {
 			spin_lock(&ep->napi_lock);
 			if (netif_rx_schedule_prep(dev)) {
 				epic_napi_irq_off(dev, ep);
 				__netif_rx_schedule(dev);
-			}
+			} else
+				ep->reschedule_in_poll++;
 			spin_unlock(&ep->napi_lock);
 		}
 
@@ -1355,7 +1356,6 @@ static int epic_poll(struct net_device *
 
 	orig_budget = (*budget > dev->quota) ? dev->quota : *budget;
 
-rx_action:
 	outl(EpicNapiEvent, ioaddr + INTSTAT);
 
 	epic_tx(dev, ep);
@@ -1369,18 +1369,18 @@ rx_action:
 
 	if (netif_running(dev) && (work_done < orig_budget)) {
 		unsigned long flags;
-		int status;
 
-		spin_lock_irqsave(&ep->napi_lock, flags);
 		epic_napi_irq_on(dev, ep);
+
+		spin_lock_irqsave(&ep->napi_lock, flags);
 		__netif_rx_complete(dev);
-		spin_unlock_irqrestore(&ep->napi_lock, flags);
 
-		status = inl(ioaddr + INTSTAT);
-		if (status & EpicNapiEvent) {
+		if (ep->reschedule_in_poll) {
 			epic_napi_irq_off(dev, ep);
-			goto rx_action;
+			__netif_rx_schedule(dev);
+			ep->reschedule_in_poll--;
 		}
+		spin_unlock_irqrestore(&ep->napi_lock, flags);
 	}
 
 	return (work_done >= orig_budget);

_
