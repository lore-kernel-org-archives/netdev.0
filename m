From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 7/8] lock validator: fix ns83820.c irq-flags bug
Date: Sun, 11 Jun 2006 13:01:46 -0400
Message-ID: <448C4C7A.7020301@garzik.org>
References: <200606090519.k595JmDG032032@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080303030004060200000503"
Cc: netdev@vger.kernel.org, mingo@elte.hu, arjan@linux.intel.com,
	bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52704 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750780AbWFKRBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 13:01:48 -0400
To: akpm@osdl.org
In-Reply-To: <200606090519.k595JmDG032032@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080303030004060200000503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

akpm@osdl.org wrote:
> diff -puN drivers/net/ns83820.c~lock-validator-fix-ns83820c-irq-flags-bug drivers/net/ns83820.c
> --- devel/drivers/net/ns83820.c~lock-validator-fix-ns83820c-irq-flags-bug	2006-06-08 22:18:34.000000000 -0700
> +++ devel-akpm/drivers/net/ns83820.c	2006-06-08 22:18:48.000000000 -0700
> @@ -804,7 +804,7 @@ static int ns83820_setup_rx(struct net_d
>  
>  		writel(dev->IMR_cache, dev->base + IMR);
>  		writel(1, dev->base + IER);
> -		spin_unlock_irq(&dev->misc_lock);
> +		spin_unlock(&dev->misc_lock);
>  
>  		kick_rx(ndev);
>  

The above code snippet removes the nested unlock-irq, but now the code 
is unbalanced, so IMO this patch _adds_ confusion.

I think the conservative patch for 2.6.17 is the one I have attached. 
Unless there are objections, that is what I will forward...

	Jeff



--------------080303030004060200000503
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 706aed7..cee0e74 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -776,9 +776,11 @@ static int ns83820_setup_rx(struct net_d
 
 	ret = rx_refill(ndev, GFP_KERNEL);
 	if (!ret) {
+		unsigned long flags;
+
 		dprintk("starting receiver\n");
 		/* prevent the interrupt handler from stomping on us */
-		spin_lock_irq(&dev->rx_info.lock);
+		spin_lock_irqsave(&dev->rx_info.lock, flags);
 
 		writel(0x0001, dev->base + CCSR);
 		writel(0, dev->base + RFCR);
@@ -790,7 +792,7 @@ static int ns83820_setup_rx(struct net_d
 		phy_intr(ndev);
 
 		/* Okay, let it rip */
-		spin_lock_irq(&dev->misc_lock);
+		spin_lock(&dev->misc_lock);
 		dev->IMR_cache |= ISR_PHY;
 		dev->IMR_cache |= ISR_RXRCMP;
 		//dev->IMR_cache |= ISR_RXERR;
@@ -804,11 +806,11 @@ static int ns83820_setup_rx(struct net_d
 
 		writel(dev->IMR_cache, dev->base + IMR);
 		writel(1, dev->base + IER);
-		spin_unlock_irq(&dev->misc_lock);
+		spin_unlock(&dev->misc_lock);
 
 		kick_rx(ndev);
 
-		spin_unlock_irq(&dev->rx_info.lock);
+		spin_unlock_irqrestore(&dev->rx_info.lock, flags);
 	}
 	return ret;
 }

--------------080303030004060200000503--
