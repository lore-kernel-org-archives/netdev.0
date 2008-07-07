From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Mon, 07 Jul 2008 16:10:30 -0500
Message-ID: <1215465030.14023.105.camel@localhost.localdomain>
References: <20080618062857.GA3598@2ka.mipt.ru>
	 <1213917029.9245.86.camel@localhost.localdomain>
	 <20080620060219.GA22784@2ka.mipt.ru>
	 <1213981859.9245.133.camel@localhost.localdomain>
	 <20080620172513.GA16673@2ka.mipt.ru>
	 <1213983664.9245.150.camel@localhost.localdomain>
	 <20080620175440.GA12197@2ka.mipt.ru>
	 <1213985826.9245.169.camel@localhost.localdomain>
	 <20080620182333.GA9342@2ka.mipt.ru>
	 <1213995972.9245.202.camel@localhost.localdomain>
	 <20080621071253.GA17557@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:55513 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756549AbYGGVLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 17:11:24 -0400
In-Reply-To: <20080621071253.GA17557@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-06-21 at 11:12 +0400, Evgeniy Polyakov wrote:
> 
> It may or may not be the driver issue, but the way it works with NAPI.
> Or driver just looses interrupt (or if it has weird interrupt
> coalescing/mitigation feature) under the load. What about adding a
> counter into interrupt handler and napi polling callback with ability to
> clear/read it via driver ioctl (or just clear it when first small packet
> is recived and dump when module is unloaded), so can determine via
> tcpdump how many packets were actually received and what counter is.
> It can be trivial issue with work_done < or <= than budget, which was a
> frequent error in drivers for a while, and with your protocol it can be
> fatal until next received packet.

I have not been able to work on this recently but I have some time to
look at it again now. Before I stopped working on it, I implemented a
workaround using a private ioctl() that was able to correct the issue
after a hangup and (I believe) illustrates that a missed interrupt is
causing the problem.

I added a private ioctl call to the macb driver that does the following:
1. read rx status register
2. if rx status is true, schedule poll (same block of code as in
interrupt handler)
3. return

Then, in my userspace code, I called poll() with a timeout and called
the ioctl() if poll timed out with no data. What I found was that the rx
status register always reported a packet present but not acknowledged
when poll timed out (on the board that missed the packet). Scheduling a
poll in the driver forced it to read this new packet and the userspace
code was able to continue from there.

If the macb poll is executed, the receive status register will be
cleared, so somewhere along the way an interrupt is being missed (or
like you suggested some type of coalescing is happening).

Below is a patch of the changes that I have made to the driver including
my rewrite of the poll() function and additional private ioctl()
workaround. This patch is against 2.6.20 with some of the patches from
http://maxim.org.za/sam9.html , most of which have been added to the
vanilla kernel in the more current versions that I have tested (i.e.
2.6.25). This shows the changes that I have made more easily, but I can
provide the full patch from vanilla if it would be more helpful (i.e.
this one will not apply cleanly to a vanilla kernel). I wasn't sure
which would be the best to post.

Thanks,

Travis

Index: linux-2.6.20.AT91/drivers/net/macb.c
===================================================================
--- linux-2.6.20.AT91/drivers/net/macb.c        (revision 646)
+++ linux-2.6.20.AT91/drivers/net/macb.c        (working copy)
@@ -8,6 +8,9 @@
  * published by the Free Software Foundation.
  */

+//#define DEBUG 1
+#undef DEBUG
+
 #include <linux/clk.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -429,10 +432,9 @@
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
@@ -470,55 +472,55 @@
 static int macb_poll(struct net_device *dev, int *budget)
 {
        struct macb *bp = netdev_priv(dev);
-       int orig_budget, work_done, retval = 0;
+       int orig_budget, work_done;
        u32 status;

        status = macb_readl(bp, RSR);
-       macb_writel(bp, RSR, status);
-
        if (!status) {
                /*
                 * This may happen if an interrupt was pending before
                 * this function was called last time, and no packets
                 * have been received since.
                 */
-               netif_rx_complete(dev);
-               goto out;
+               goto done; /* close polling, reset interrupts, return 0 */
        }
+       do {
+               macb_writel(bp, RSR, status);
+               dev_dbg(&bp->pdev->dev, "poll: status = %08lx, budget = %d\n",
+                       (unsigned long)status, *budget);
+               if (!(status & MACB_BIT(REC))) {
+                       dev_warn(&bp->pdev->dev,
+                                "No RX buffers complete, status = %02lx\n",
+                                (unsigned long)status);
+                       goto done; /* re-enable ints and return 0 */
+               }

-       dev_dbg(&bp->pdev->dev, "poll: status = %08lx, budget = %d\n",
-               (unsigned long)status, *budget);
+               orig_budget = *budget;
+               if (orig_budget > dev->quota)
+                       orig_budget = dev->quota;
+               work_done = macb_rx(bp, orig_budget);
+
+               *budget -= work_done;
+               dev->quota -= work_done;
+
+               if (work_done >= orig_budget) {
+                       goto hitquota; /* DONT touch interrupt enable register */
+               }
+       } while ((status = macb_readl(bp, RSR)));

-       if (!(status & MACB_BIT(REC))) {
-               dev_warn(&bp->pdev->dev,
-                        "No RX buffers complete, status = %02lx\n",
-                        (unsigned long)status);
-               netif_rx_complete(dev);
-               goto out;
-       }
+done:
+       /* close polling */
+       netif_rx_complete(dev);
+       /* enable interrupts */
+       macb_writel(bp, IER, MACB_RX_INT_FLAGS);

-       orig_budget = *budget;
-       if (orig_budget > dev->quota)
-               orig_budget = dev->quota;
+       return 0;

-       work_done = macb_rx(bp, orig_budget);
-       if (work_done < orig_budget) {
-               netif_rx_complete(dev);
-               retval = 0;
-       } else {
-               retval = 1;
-       }
-
-       /*
-        * We've done what we can to clean the buffers. Make sure we
-        * get notified when new packets arrive.
-        */
-out:
-       macb_writel(bp, IER, MACB_RX_INT_FLAGS);
-
        /* TODO: Handle errors */

-       return retval;
+hitquota:
+       printk(KERN_ERR "hit quota!!\n");
+       return 1;
 }

 static irqreturn_t macb_interrupt(int irq, void *dev_id)
@@ -545,7 +547,7 @@
                }

                if (status & MACB_RX_INT_FLAGS) {
-                       if (netif_rx_schedule_prep(dev)) {
+                       if (likely(netif_rx_schedule_prep(dev))) {
                                /*
                                 * There's no point taking any more interrupts
                                 * until we have processed the buffers
@@ -553,7 +555,12 @@
                                macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
                                dev_dbg(&bp->pdev->dev, "scheduling RX softirq\n");
                                __netif_rx_schedule(dev);
-                       }
+                       }
+                       //else {
+                       //      printk(KERN_ERR "%s: Driver bug: interrupt while in polling mode\n", dev->name);
+                               /* disable interrupts */
+                               //macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
+                       //}
                }

                if (status & (MACB_BIT(TCOMP) | MACB_BIT(ISR_TUND)))
@@ -564,7 +571,7 @@
                 * add that if/when we get our hands on a full-blown MII PHY.
                 */

-               if (status & MACB_BIT(HRESP)) {
+               if (unlikely(status & MACB_BIT(HRESP))) {
                        /*
                         * TODO: Reset the hardware, and maybe move the printk
                         * to a lower-priority context as well (work queue?)
@@ -572,7 +579,6 @@
                        printk(KERN_ERR "%s: DMA bus error: HRESP not OK\n",
                               dev->name);
                }
-
                status = macb_readl(bp, ISR);
        }

@@ -987,11 +993,34 @@
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
        struct macb *bp = netdev_priv(dev);
+       int rc;

        if (!netif_running(dev))
                return -EINVAL;
-
-       return generic_mii_ioctl(&bp->mii, if_mii(rq), cmd, NULL);
+
+       rc = generic_mii_ioctl(&bp->mii, if_mii(rq), cmd, NULL);
+       /* custom private commands */
+       switch(cmd)
+       {
+       /**
+        * SIOCDEVPRIVATE is used to force the driver to examine the RSR and
+        * check for missed data. If an IRQ is missed, calling this ioctl will
+        * force polling to be re-enabled.
+        */
+       case SIOCDEVPRIVATE:
+               if (macb_readl(bp, RSR)) {
+                       if (likely(netif_rx_schedule_prep(dev))) {
+                               /* disable RX interrupts */
+                               macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
+                               dev_dbg(&bp->pdev->dev, "scheduling RX softirq\n");
+                               __netif_rx_schedule(dev);
+                       }
+               }
+               return 0;
+       default:
+               return -EINVAL;
+       }
+       return rc;
 }

 static ssize_t macb_mii_show(const struct class_device *cd, char *buf,
@@ -1283,3 +1312,4 @@
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Atmel MACB Ethernet driver");
 MODULE_AUTHOR("Haavard Skinnemoen <hskinnemoen@atmel.com>");
+


