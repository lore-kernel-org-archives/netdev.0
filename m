From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 2.6.5-rc2 - more epic100 napi
Date: Thu, 25 Mar 2004 01:27:52 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040325012752.B30067@electric-eye.fr.zoreil.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com> <405DDDC6.7030007@pobox.com> <8765cvmyaq.fsf@devron.myhome.or.jp> <20040323195119.A14062@electric-eye.fr.zoreil.com> <871xnjgwrs.fsf@devron.myhome.or.jp> <20040324014140.A16202@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040324014140.A16202@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Wed, Mar 24, 2004 at 01:41:40AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> diff -puN drivers/net/epic100.c~epic100-napi-30 drivers/net/epic100.c
> --- linux-2.6.5-rc2/drivers/net/epic100.c~epic100-napi-30	2004-03-24 01:18:25.000000000 +0100
> +++ linux-2.6.5-rc2-fr/drivers/net/epic100.c	2004-03-24 01:19:35.000000000 +0100
> @@ -1355,7 +1356,6 @@ static int epic_poll(struct net_device *
>  
>  	orig_budget = (*budget > dev->quota) ? dev->quota : *budget;
>  
> -rx_action:
>  	outl(EpicNapiEvent, ioaddr + INTSTAT);
>  
>  	epic_tx(dev, ep);
> @@ -1369,18 +1369,18 @@ rx_action:
>  
>  	if (netif_running(dev) && (work_done < orig_budget)) {
>  		unsigned long flags;
> -		int status;
>  
> -		spin_lock_irqsave(&ep->napi_lock, flags);
>  		epic_napi_irq_on(dev, ep);
> +
> +		spin_lock_irqsave(&ep->napi_lock, flags);
>  		__netif_rx_complete(dev);
> -		spin_unlock_irqrestore(&ep->napi_lock, flags);
>  
> -		status = inl(ioaddr + INTSTAT);
> -		if (status & EpicNapiEvent) {
> +		if (ep->reschedule_in_poll) {
>  			epic_napi_irq_off(dev, ep);
> -			goto rx_action;
> +			__netif_rx_schedule(dev);
                        ^^^^^^^^^^^^^^^^^^^^^^^^^

While in poll() handler, brilliant :o(

Please apply (tested) patch below on top of the acked patches (i.e 1/4...4/4):
- issuing commands via the serial console under an incoming stream of 40k
  short sized pps sucks but it is possible;
- does not leak refcount (it rmmods fine).

Next step: identify the best performer amongst the previously discussed changes.


Multiple invocation of __netif_rx_schedule() in epic_interrupt() while
epic_poll loops over __netif_rx_complete() leads to serious device
refcount leak.


 drivers/net/epic100.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff -puN drivers/net/epic100.c~epic100-napi-30 drivers/net/epic100.c
--- linux-2.6.5-rc2/drivers/net/epic100.c~epic100-napi-30	2004-03-24 01:18:25.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/epic100.c	2004-03-25 00:51:30.000000000 +0100
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
@@ -1177,14 +1177,16 @@ static irqreturn_t epic_interrupt(int ir
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
+		status &= ~EpicNapiEvent;
 
 		/* Check uncommon events all at once. */
 		if (status &
@@ -1211,7 +1213,7 @@ static irqreturn_t epic_interrupt(int ir
 			/* Clear all error sources. */
 			outl(status & 0x7f18, ioaddr + INTSTAT);
 		}
-		if (status & EpicNormalEvent)
+		if (!(status & EpicNormalEvent))
 			break;
 		if (--boguscnt < 0) {
 			printk(KERN_ERR "%s: Too much work at interrupt, "
@@ -1356,7 +1358,6 @@ static int epic_poll(struct net_device *
 	orig_budget = (*budget > dev->quota) ? dev->quota : *budget;
 
 rx_action:
-	outl(EpicNapiEvent, ioaddr + INTSTAT);
 
 	epic_tx(dev, ep);
 
@@ -1369,18 +1370,20 @@ rx_action:
 
 	if (netif_running(dev) && (work_done < orig_budget)) {
 		unsigned long flags;
-		int status;
 
 		spin_lock_irqsave(&ep->napi_lock, flags);
-		epic_napi_irq_on(dev, ep);
-		__netif_rx_complete(dev);
-		spin_unlock_irqrestore(&ep->napi_lock, flags);
 
-		status = inl(ioaddr + INTSTAT);
-		if (status & EpicNapiEvent) {
-			epic_napi_irq_off(dev, ep);
+		if (ep->reschedule_in_poll) {
+			ep->reschedule_in_poll--;
+			spin_unlock_irqrestore(&ep->napi_lock, flags);
 			goto rx_action;
 		}
+
+		outl(EpicNapiEvent, ioaddr + INTSTAT);
+		epic_napi_irq_on(dev, ep);
+		__netif_rx_complete(dev);
+
+		spin_unlock_irqrestore(&ep->napi_lock, flags);
 	}
 
 	return (work_done >= orig_budget);

_
