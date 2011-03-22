From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Tue, 22 Mar 2011 17:55:23 +0000
Message-ID: <20110322175523.GE10058@pulham.picochip.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <20110316.131734.242138246.davem@davemloft.net>
 <4D86F25A.7060405@atmel.com>
 <20110321111838.GC2610@pulham.picochip.com>
 <20110322161811.GF6466@game.jcrosoft.org>
 <20110322163917.GD10058@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Andrew Victor <linux@maxim.org.za>,
	Peter Korsgaard <jacmet@sunsite.dk>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55508 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474Ab1CVRzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 13:55:41 -0400
Received: by wwa36 with SMTP id 36so9131529wwa.1
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 10:55:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110322163917.GD10058@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jean-Christophe,

On Tue, Mar 22, 2011 at 04:39:17PM +0000, Jamie Iles wrote:
> Hi Jean-Christophe,
> 
> On Tue, Mar 22, 2011 at 05:18:11PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > On 11:18 Mon 21 Mar     , Jamie Iles wrote:
> > > I have an existing tree for this at
> > > 
> > > 	git://github.com/jamieiles/linux-2.6-ji.git macb-gem
> > > 
> > > based off of 2.6.38 (with your ACK's now added) and I'd be happy with 
> > > either route.
> > but we must detect the gem via the version register and ditto for macb for
> > avr32 and at91
> > 
> > so please rebase it over my patch
> > 
> > and you get my sob too
> 
> Would you mind respinning your patch without the changes to the clk 
> stuff?  Otherwise we're changing it from compile time to version based, 
> only to completely remove it in subsequent patches.

Actually, this patch doesn't work anyway as the version register is 
being read before the clks are enabled so the device isn't accessible 
(and the registers haven't yet been ioremap()'d).

> Also, can you confirm that the module ID's that you are using to 
> differentiate between AT91 and AVR32 won't clash with MACB uses in 
> other, non-at91/avr32 chips, or that it doesn't matter?

If this does work, then it would be nice if we made the else path of the 
RMII AT91 tests also test for avr32 too so we aren't driving the USRIO 
pins on platforms that aren't at91 but also aren't avr32.  So something 
the patch below instead.

Jamie

8<---

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 79ccb54..55b81f5 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -22,7 +22,6 @@
 #include <linux/phy.h>
 
 #include <mach/board.h>
-#include <mach/cpu.h>
 
 #include "macb.h"
 
@@ -1169,6 +1168,7 @@ static int __init macb_probe(struct platform_device *pdev)
 		err = -ENOMEM;
 		goto err_out_disable_clocks;
 	}
+	bp->version = macb_readl(bp, VERSION);
 
 	dev->irq = platform_get_irq(pdev, 0);
 	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
@@ -1201,18 +1201,18 @@ static int __init macb_probe(struct platform_device *pdev)
 	macb_get_hwaddr(bp);
 	pdata = pdev->dev.platform_data;
 
-	if (pdata && pdata->is_rmii)
-#if defined(CONFIG_ARCH_AT91)
-		macb_writel(bp, USRIO, (MACB_BIT(RMII) | MACB_BIT(CLKEN)) );
-#else
-		macb_writel(bp, USRIO, 0);
-#endif
-	else
-#if defined(CONFIG_ARCH_AT91)
-		macb_writel(bp, USRIO, MACB_BIT(CLKEN));
-#else
-		macb_writel(bp, USRIO, MACB_BIT(MII));
-#endif
+	if (pdata && pdata->is_rmii) {
+		if (macb_is_at91(bp))
+			macb_writel(bp, USRIO,
+				    (MACB_BIT(RMII) | MACB_BIT(CLKEN)));
+		else if (macb_is_avr32(bp))
+			macb_writel(bp, USRIO, 0);
+	} else {
+		if (macb_is_at91(bp))
+			macb_writel(bp, USRIO, MACB_BIT(CLKEN));
+		else if (macb_is_avr32(bp))
+			macb_writel(bp, USRIO, MACB_BIT(MII));
+	}
 
 	bp->tx_pending = DEF_TX_RING_PENDING;
 
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index d3212f6..56a4fcb 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -59,6 +59,7 @@
 #define MACB_TPQ				0x00bc
 #define MACB_USRIO				0x00c0
 #define MACB_WOL				0x00c4
+#define MACB_VERSION				0x00fc
 
 /* Bitfields in NCR */
 #define MACB_LB_OFFSET				0
@@ -389,6 +390,14 @@ struct macb {
 	unsigned int 		link;
 	unsigned int 		speed;
 	unsigned int 		duplex;
+
+	uint32_t		version;
 };
 
+#define MACB_VERSION_MASK	0xffff0000
+#define macb_is_at91(bp)	\
+	(((bp)->version & MACB_VERSION_MASK) == 0x06010000)
+#define macb_is_avr32(bp)	\
+	(((bp)->version & MACB_VERSION_MASK) == 0x00010000)
+
 #endif /* _MACB_H */
