From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: [PATCH] bfin_mac: Fix MDIO clock frequency
Date: Wed, 30 Jan 2008 02:01:37 +0800
Message-ID: <1201629697.26902.21.camel@roc-laptop>
References: <Pine.LNX.4.64.0801291421440.7503@pc-213-140-179-32.aina.net>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bryan Wu <bryan.wu@analog.com>
To: Kalle Pokki <kalle.pokki@eke.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:41548 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbYA2SBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 13:01:43 -0500
In-Reply-To: <Pine.LNX.4.64.0801291421440.7503@pc-213-140-179-32.aina.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-01-29 at 20:27 +0800, Kalle Pokki wrote:
> The clock divisor is set to all ones at reset. 
> --- 
>  drivers/net/bfin_mac.c |    2 +- 
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c 
> index eb97175..c199633 100644 
> --- a/drivers/net/bfin_mac.c 
> +++ b/drivers/net/bfin_mac.c 
> @@ -425,7 +425,7 @@ static int mii_probe(struct net_device *dev) 
>   
>         /* MDC  = 2.5 MHz */ 
>         sysctl = bfin_read_EMAC_SYSCTL(); 
> -       sysctl |= SET_MDCDIV(24); 
> +       sysctl = (sysctl & ~MDCDIV) | SET_MDCDIV(24); 

Good catch, I will apply this. 
Actually, another patch will modified this operation, you patch can not
be applied cleanly:

>From e347fc2fdb8d8ecd8fa563929fcfa51759d5ac1c Mon Sep 17 00:00:00 2001
From: Bryan Wu <bryan.wu@analog.com>
Date: Fri, 11 Jan 2008 15:17:03 +0800
Subject: [PATCH] [Blackfin] EMAC driver: define MDC_CLK=2.5MHz and caculate mdc_div according to SCLK.

Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/bfin_mac.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 4006a5d..ee39819 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -412,20 +412,26 @@ static void bf537_adjust_link(struct net_device *dev)
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
+/* MDC  = 2.5 MHz */
+#define MDC_CLK 2500000
+
 static int mii_probe(struct net_device *dev)
 {
 	struct bf537mac_local *lp = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 	unsigned short sysctl;
 	int i;
+	u32 sclk, mdc_div;
 
 	/* Enable PHY output early */
 	if (!(bfin_read_VR_CTL() & PHYCLKOE))
 		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
 
-	/* MDC  = 2.5 MHz */
+	sclk = get_sclk();
+	mdc_div = ((sclk / MDC_CLK) / 2) - 1;
+
 	sysctl = bfin_read_EMAC_SYSCTL();
-	sysctl |= SET_MDCDIV(24);
+	sysctl |= SET_MDCDIV(mdc_div);
 	bfin_write_EMAC_SYSCTL(sysctl);
 
 	/* search for connect PHY device */
@@ -477,8 +483,10 @@ static int mii_probe(struct net_device *dev)
 	lp->phydev = phydev;
 
 	printk(KERN_INFO "%s: attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d)\n",
-	       DRV_NAME, phydev->drv->name, phydev->dev.bus_id, phydev->irq);
+	       "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)"
+	       "@sclk=%dMHz)\n",
+	       DRV_NAME, phydev->drv->name, phydev->dev.bus_id, phydev->irq,
+	       MDC_CLK, mdc_div, sclk/1000000);
 
 	return 0;
 }
-- 
1.5.3.4

Do you mind I modified you patch to against this one and send out as a patch set to upstream?

Regards,
-Bryan
