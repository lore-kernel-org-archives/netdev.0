From: "Gerard Kam" <gerardk5@verizon.net>
Subject: RE: [PATCH 2/2] macb: process the RX ring regardless of interrupt status
Date: Thu, 16 Apr 2009 11:41:57 -0700
Message-ID: <4C1740923F034ABB8BFCC03E69B8E3AC@hobbes>
References: <1239874331-9431-2-git-send-email-haavard.skinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'Nicolas Ferre'" <nicolas.ferre@atmel.com>,
	"'Erik Waling'" <erik.waling@konftel.com>
To: "'Haavard Skinnemoen'" <haavard.skinnemoen@atmel.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.vzn.mail.mud.yahoo.com ([68.142.199.252]:21347 "HELO
	smtp104.vzn.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756609AbZDPSsn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 14:48:43 -0400
In-reply-to: <1239874331-9431-2-git-send-email-haavard.skinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> Sent: Thursday, April 16, 2009 2:32 AM

> Fix this by scanning the ring no matter what flags are set in the
> interrupt status register.

I've been using a similar patch to macb, however, it's to fix an issue with
rotting packets.  I'm using kernel 2.6.25, and haven't updated this patch to
a more recent kernel version.  Patch was developed with input from Travis
Stratman, tstratman@emacinc.com.


Fix for RX rotting packets.

diff -pruN a/drivers/net/macb.c b/drivers/net/macb.c
--- a/drivers/net/macb.c	2008-05-18 22:21:53.000000000 -0700
+++ b/drivers/net/macb.c	2008-08-28 11:36:42.000000000 -0700
@@ -508,40 +508,29 @@ static int macb_poll(struct napi_struct 
 	u32 status;
 
 	status = macb_readl(bp, RSR);
-	macb_writel(bp, RSR, status);
-
-	work_done = 0;
-	if (!status) {
-		/*
-		 * This may happen if an interrupt was pending before
-		 * this function was called last time, and no packets
-		 * have been received since.
-		 */
-		netif_rx_complete(dev, napi);
-		goto out;
-	}
+	macb_writel(bp, RSR, status);	/* not atomic read-clear! */
 
 	dev_dbg(&bp->pdev->dev, "poll: status = %08lx, budget = %d\n",
 		(unsigned long)status, budget);
 
-	if (!(status & MACB_BIT(REC))) {
-		dev_warn(&bp->pdev->dev,
-			 "No RX buffers complete, status = %02lx\n",
-			 (unsigned long)status);
-		netif_rx_complete(dev, napi);
-		goto out;
-	}
-
 	work_done = macb_rx(bp, budget);
-	if (work_done < budget)
+	if ((work_done < budget) && !macb_readl(bp, RSR)) {
+		/*
+		 * We've done what we can to clean the buffers.
+		 * Make sure there's no new RX activity during transition
+		 * from poll mode back to interrupt mode.
+		 */
 		netif_rx_complete(dev, napi);
-
-	/*
-	 * We've done what we can to clean the buffers. Make sure we
-	 * get notified when new packets arrive.
-	 */
-out:
-	macb_writel(bp, IER, MACB_RX_INT_FLAGS);
+		macb_writel(bp, IER, MACB_RX_INT_FLAGS);
+		status = macb_readl(bp, RSR);
+		if (status) {
+			/* new RX, undo the polling-done operations */
+			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
+			netif_rx_reschedule(dev, napi);
+			dev_dbg(&bp->pdev->dev, "poll: undo status =
%08lx\n",
+				(unsigned long)status);
+		}
+	}
 
 	/* TODO: Handle errors */
 
@@ -554,7 +543,7 @@ static irqreturn_t macb_interrupt(int ir
 	struct macb *bp = netdev_priv(dev);
 	u32 status;
 
-	status = macb_readl(bp, ISR);
+	status = macb_readl(bp, ISR) & ~macb_readl(bp, IMR);
 
 	if (unlikely(!status))
 		return IRQ_NONE;
@@ -578,7 +567,9 @@ static irqreturn_t macb_interrupt(int ir
 				dev_dbg(&bp->pdev->dev,
 					"scheduling RX softirq\n");
 				__netif_rx_schedule(dev, &bp->napi);
-			}
+			} else
+				printk(KERN_ERR "%s: sched RX poll
failed\n",
+					dev->name);
 		}
 
 		if (status & (MACB_BIT(TCOMP) | MACB_BIT(ISR_TUND)))
@@ -598,7 +589,7 @@ static irqreturn_t macb_interrupt(int ir
 			       dev->name);
 		}
 
-		status = macb_readl(bp, ISR);
+		status = macb_readl(bp, ISR) & ~macb_readl(bp, IMR);
 	}
 
 	spin_unlock(&bp->lock);
--



 

