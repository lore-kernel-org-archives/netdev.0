From: Michael Buesch <mb@bu3sch.de>
Subject: Re: PATCH] net: b44.c fix sleeping-with-spinlock-helt during resume
Date: Sun, 1 Jun 2008 12:03:40 +0200
Message-ID: <200806011203.40437.mb@bu3sch.de>
References: <20080531201130.0244dc29@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:38132 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213AbYFAKGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 06:06:09 -0400
In-Reply-To: <20080531201130.0244dc29@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 01 June 2008 05:11:30 Arjan van de Ven wrote:
> From: Arjan van de Ven <arjan@linux.intel.com>
> Subject: [PATCH] net: b44.c fix sleeping-with-spinlock-helt during resume
> CC: Michael Buesch <mb@bu3sch.de>
> 
> The b44.c driver calls b44_chip_reset() from the resume path,
> with the device spinlock held.
> Unfortunately, b44_chip_reset() calls ssb_pcicore_dev_irqvecs_enable()
> which is a sleeping function (and calls might_sleep), if and only if
> the device hasn't been enabled yet.
> 
> Not having this hardware, the safest solution seems to be to enable
> the irqvec before taking the spinlock...
> 
> http://www.kerneloops.org/search.php?search=ssb_pcicore_dev_irqvecs_enable
> 
> Reported-by: www.kerneloops.org
> Signed-off-by: Arjan van de Ven
> ---
>  drivers/net/b44.c |   12 ++++++++++--
>  1 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index 59dce6a..6028129 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -1278,6 +1278,7 @@ static void b44_chip_reset(struct b44 *bp, int reset_kind)
>  		bw32(bp, B44_DMARX_CTRL, 0);
>  		bp->rx_prod = bp->rx_cons = 0;
>  	} else
> +		/* this function sleeps! */
>  		ssb_pcicore_dev_irqvecs_enable(&sdev->bus->pcicore, sdev);
>  
>  	ssb_device_enable(bp->sdev, 0);
> @@ -1374,7 +1375,7 @@ static int b44_set_mac_addr(struct net_device *dev, void *p)
>  }
>  
>  /* Called at device open time to get the chip ready for
> - * packet processing.  Invoked with bp->lock held.
> + * packet processing.  Sometimes invoked with bp->lock held.
>   */
>  static void __b44_set_rx_mode(struct net_device *);
>  static void b44_init_hw(struct b44 *bp, int reset_kind)
> @@ -2288,6 +2289,13 @@ static int b44_resume(struct ssb_device *sdev)
>  		return rc;
>  	}
>  
> +	/*
> +	 * If the device isn't enabled yet, we need to do so before taking
> +	 * the spinlock, since the enablinging function sleeps.
> +	 */
> +	if (!ssb_device_is_enabled(bp->sdev))
> +		ssb_pcicore_dev_irqvecs_enable(&sdev->bus->pcicore, sdev);
> +
>  	spin_lock_irq(&bp->lock);
>  
>  	b44_init_rings(bp);

I'm not sure how this is supposed to fix the bug.
I think you will call ssb_pcicore_dev_irqvecs_enable() twice this way.
The call in b44_chip_reset() will still trigger.

Besides that, this only is a theoretical issue, as the function does
only sleep on a PCI-E device. But as b44 PCI-E devices don't exist,
it will never sleep. So I'd rather replace the might_sleep() with a
might_sleep_if() call.
Something like the following:

Index: wireless-testing/drivers/ssb/driver_pcicore.c
===================================================================
--- wireless-testing.orig/drivers/ssb/driver_pcicore.c	2008-04-23 16:06:56.000000000 +0200
+++ wireless-testing/drivers/ssb/driver_pcicore.c	2008-06-01 12:02:33.000000000 +0200
@@ -537,12 +537,12 @@ int ssb_pcicore_dev_irqvecs_enable(struc
 	int err = 0;
 	u32 tmp;
 
-	might_sleep();
-
 	if (!pdev)
 		goto out;
 	bus = pdev->bus;
 
+	might_sleep_if(pdev->id.coreid != SSB_DEV_PCI);
+
 	/* Enable interrupts for this device. */
 	if (bus->host_pci &&
 	    ((pdev->id.revision >= 6) || (pdev->id.coreid == SSB_DEV_PCIE))) {



-- 
Greetings Michael.
