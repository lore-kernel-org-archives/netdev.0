From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Tue, 15 Jul 2008 15:43:39 -0500
Message-ID: <1216154619.3084.148.camel@cheeto.emacinc.com>
References: <20080620060219.GA22784@2ka.mipt.ru>
	 <1213981859.9245.133.camel@localhost.localdomain>
	 <20080620172513.GA16673@2ka.mipt.ru>
	 <1213983664.9245.150.camel@localhost.localdomain>
	 <20080620175440.GA12197@2ka.mipt.ru>
	 <1213985826.9245.169.camel@localhost.localdomain>
	 <20080620182333.GA9342@2ka.mipt.ru>
	 <1213995972.9245.202.camel@localhost.localdomain>
	 <20080621071253.GA17557@2ka.mipt.ru>
	 <1215465030.14023.105.camel@localhost.localdomain>
	 <20080707212531.GA15288@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:33500 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759011AbYGOUnz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 16:43:55 -0400
In-Reply-To: <20080707212531.GA15288@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-08 at 01:25 +0400, Evgeniy Polyakov wrote:
> 
> Can it be missed acknowledge when ->poll() hits the quota limit?

I don't think so. The poll() function explicitly checks if (work_done >=
budget) and if so returns work_done without calling netif_rx_complete().
Also, I added a printk to detect if the budget was ever reached, and it
is not (which makes sense in this case because only two packets are sent
at a time, 127 B followed by 4 B).

> It is quite clear patch, but please provide needed part on top of .25
> tree.

I have pasted my patch against vanilla 2.6.25 below. It displays the
same behavior as 2.6.20. The largest change is in the poll() function
and the added private ioctl().

I was unsure about one thing: in the poll() function, I used a loop to
keep receiving packets until either the budget was exhausted or the
receive status register claimed that no packets were available. This
requires the possibility for multiple calls to macb_rx() which takes the
budget as a parameter. I assumed that the budget passed to macb_rx()
should be decremented by the amount received in the previous call rather
than the original budget, so I used a few extra variables
(pass_work_done - the amount received in this pass of the loop,
orig_budget - the original budget that poll() was called with) to keep
track of this (I couldn't see a better way at the time). Was this a
correct assumption?

Thank you,

Travis

--- linux-2.6.25/drivers/net/macb.c     2008-04-16 21:49:44.000000000 -0500
+++ linux-2.6.25.AT91/drivers/net/macb.c        2008-07-15 14:49:56.000000000 -0500
@@ -455,10 +455,9 @@
        int received = 0;
        unsigned int tail = bp->rx_tail;
        int first_frag = -1;
+       u32 addr, ctrl;

        for (; budget > 0; tail = NEXT_RX(tail)) {
-               u32 addr, ctrl;
-
                rmb();
                addr = bp->rx_ring[tail].addr;
                ctrl = bp->rx_ring[tail].ctrl;
@@ -497,47 +496,48 @@
 {
        struct macb *bp = container_of(napi, struct macb, napi);
        struct net_device *dev = bp->dev;
-       int work_done;
+       int work_done, orig_budget, pass_work_done;
        u32 status;

        status = macb_readl(bp, RSR);
-       macb_writel(bp, RSR, status);

        work_done = 0;
+       pass_work_done = 0;
+       orig_budget = budget;
        if (!status) {
                /*
                 * This may happen if an interrupt was pending before
                 * this function was called last time, and no packets
                 * have been received since.
                 */
-               netif_rx_complete(dev, napi);
-               goto out;
-       }
-
-       dev_dbg(&bp->pdev->dev, "poll: status = %08lx, budget = %d\n",
-               (unsigned long)status, budget);
-
-       if (!(status & MACB_BIT(REC))) {
-               dev_warn(&bp->pdev->dev,
-                        "No RX buffers complete, status = %02lx\n",
-                        (unsigned long)status);
-               netif_rx_complete(dev, napi);
                goto out;
        }
+       do {
+               macb_writel(bp, RSR, status);
+               dev_dbg(&bp->pdev->dev, "poll: status = %08lx, budget = %d\n",
+                       (unsigned long)status, budget);
+
+               if (unlikely(!(status & MACB_BIT(REC)))) {
+                       dev_warn(&bp->pdev->dev,
+                               "No RX buffers complete, status = %02lx\n",
+                               (unsigned long)status);
+                       goto out;
+               }

-       work_done = macb_rx(bp, budget);
-       if (work_done < budget)
-               netif_rx_complete(dev, napi);
-
-       /*
-        * We've done what we can to clean the buffers. Make sure we
-        * get notified when new packets arrive.
-        */
+               pass_work_done = macb_rx(bp, budget);
+               work_done += pass_work_done;
+               budget -= pass_work_done;
+               if (unlikely(work_done >= orig_budget)) {
+                       printk("macb hit quota\n");
+                       goto hitquota;
+               }
+       } while ((status = macb_readl(bp, RSR)));
 out:
+       netif_rx_complete(dev, napi);
        macb_writel(bp, IER, MACB_RX_INT_FLAGS);

        /* TODO: Handle errors */
-
+hitquota:
        return work_done;
 }

@@ -562,7 +562,7 @@
                }

                if (status & MACB_RX_INT_FLAGS) {
-                       if (netif_rx_schedule_prep(dev, &bp->napi)) {
+                       if (likely(netif_rx_schedule_prep(dev, &bp->napi))) {
                                /*
                                 * There's no point taking any more interrupts
                                 * until we have processed the buffers
@@ -582,7 +582,7 @@
                 * add that if/when we get our hands on a full-blown MII PHY.
                 */

-               if (status & MACB_BIT(HRESP)) {
+               if (unlikely(status & MACB_BIT(HRESP))) {
                        /*
                         * TODO: Reset the hardware, and maybe move the printk
                         * to a lower-priority context as well (work queue?)
@@ -1074,6 +1074,7 @@
 {
        struct macb *bp = netdev_priv(dev);
        struct phy_device *phydev = bp->phy_dev;
+       int rc;

        if (!netif_running(dev))
                return -EINVAL;
@@ -1081,7 +1082,32 @@
        if (!phydev)
                return -ENODEV;

-       return phy_mii_ioctl(phydev, if_mii(rq), cmd);
+       rc = phy_mii_ioctl(phydev, if_mii(rq), cmd);
+
+       /* custom private commands */
+       switch(cmd)
+       {
+       /**
+       * SIOCDEVPRIVATE is used to force the driver to examine the RSR and
+       * check for missed data. If an IRQ is missed, calling this ioctl will
+       * force polling to be re-enabled.
+       */
+       case SIOCDEVPRIVATE:
+               if (likely(macb_readl(bp, RSR))) {
+                       spin_lock(&bp->lock);
+                       if (likely(netif_rx_schedule_prep(dev, &bp->napi))) {
+                               /* disable RX interrupts */
+                               macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
+                               dev_dbg(&bp->pdev->dev, "scheduling RX softirq via ioctl\n");
+                               __netif_rx_schedule(dev, &bp->napi);
+                       }
+                       spin_unlock(&bp->lock);
+               }
+               return 0;
+       default:
+               return -EINVAL;
+       }
+       return rc;
 }

 static int __init macb_probe(struct platform_device *pdev)


