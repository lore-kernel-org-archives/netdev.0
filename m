From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 7/7] gianfar: add support for wake-on-packet
Date: Fri, 4 Nov 2011 16:11:49 -0500
Message-ID: <4EB45515.6060405@freescale.com>
References: <1320410403-14639-1-git-send-email-chenhui.zhao@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<afleming@freescale.com>
To: Zhao Chenhui <chenhui.zhao@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:39370
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751016Ab1KDVLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 17:11:54 -0400
In-Reply-To: <1320410403-14639-1-git-send-email-chenhui.zhao@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2011 07:40 AM, Zhao Chenhui wrote:
> diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
> index 2c6be03..543e36c 100644
> --- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
> +++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
> @@ -56,6 +56,9 @@ Properties:
>      hardware.
>    - fsl,magic-packet : If present, indicates that the hardware supports
>      waking up via magic packet.
> +  - fsl,wake-on-filer : If present, indicates that the hardware supports
> +    waking up via arp request to local ip address or unicast packet to
> +    local mac address.

Is there any way to determine this at runtime via the device's registers?

I think TSEC_ID2[TSEC_CFG] can be used.  The manual describes it
awkwardly, but it looks like 0x20 is the bit for the filer.

> @@ -751,7 +764,6 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
>  			FSL_GIANFAR_DEV_HAS_PADDING |
>  			FSL_GIANFAR_DEV_HAS_CSUM |
>  			FSL_GIANFAR_DEV_HAS_VLAN |
> -			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
>  			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
>  			FSL_GIANFAR_DEV_HAS_TIMER;

This is an unrelated change.  Are there any eTSECs that don't support
magic packet?

> +static int gfar_get_ip(struct net_device *dev)
> +{
> +	struct gfar_private *priv = netdev_priv(dev);
> +	struct in_device *in_dev = (struct in_device *)dev->ip_ptr;
> +	struct in_ifaddr *ifa;
> +
> +	if (in_dev != NULL) {
> +		ifa = (struct in_ifaddr *)in_dev->ifa_list;
> +		if (ifa != NULL) {
> +			memcpy(priv->ip_addr, &ifa->ifa_address, 4);
> +			return 0;
> +		}
> +	}
> +	return -ENOENT;
> +}

Unnecessary cast, ifa_list is already struct in_ifaddr *.

Better, use for_primary_ifa(), and document that you won't wake on ARP
packets for secondary IP addresses.

>  static int gfar_suspend(struct device *dev)
>  {
> @@ -1268,9 +1443,17 @@ static int gfar_suspend(struct device *dev)
>  	struct gfar __iomem *regs = priv->gfargrp[0].regs;
>  	unsigned long flags;
>  	u32 tempval;
> -
>  	int magic_packet = priv->wol_en &&
> -		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
> +		(priv->wol_opts & GIANFAR_WOL_MAGIC);
> +	int arp_packet = priv->wol_en &&
> +		(priv->wol_opts & GIANFAR_WOL_ARP);
> +
> +	if (arp_packet) {
> +		pmc_enable_wake(priv->ofdev, PM_SUSPEND_MEM, 1);
> +		pmc_enable_lossless(1);
> +		gfar_arp_suspend(ndev);
> +		return 0;
> +	}

How do we know this isn't standby?

> @@ -577,11 +578,18 @@ static void gfar_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
>  {
>  	struct gfar_private *priv = netdev_priv(dev);
>  
> +	wol->supported = 0;
> +	wol->wolopts = 0;
> +
>  	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) {
> -		wol->supported = WAKE_MAGIC;
> -		wol->wolopts = priv->wol_en ? WAKE_MAGIC : 0;
> -	} else {
> -		wol->supported = wol->wolopts = 0;
> +		wol->supported |= WAKE_MAGIC;
> +		wol->wolopts |= (priv->wol_opts & GIANFAR_WOL_MAGIC) ?
> +							WAKE_MAGIC : 0;
> +	}
> +	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_ARP_PACKET) {
> +		wol->supported |= WAKE_ARP;
> +		wol->wolopts |= (priv->wol_opts & GIANFAR_WOL_ARP) ?
> +							WAKE_ARP : 0;
>  	}
>  }

Shouldn't we just make sure we don't set a bit in priv->wol_opts if we
don't support it?  Maybe create the "supported" mask at init time, so we
can use logical bit ops rather than a bunch of if statements?

> @@ -591,16 +599,21 @@ static int gfar_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
>  	unsigned long flags;
>  
>  	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
> -	    wol->wolopts != 0)
> -		return -EINVAL;
> -
> -	if (wol->wolopts & ~WAKE_MAGIC)
> +	    !(priv->device_flags & FSL_GIANFAR_DEV_HAS_ARP_PACKET))
>  		return -EINVAL;
>  
> -	device_set_wakeup_enable(&dev->dev, wol->wolopts & WAKE_MAGIC);
> -
>  	spin_lock_irqsave(&priv->bflock, flags);
> -	priv->wol_en =  !!device_may_wakeup(&dev->dev);
> +	if (wol->wolopts & WAKE_MAGIC) {
> +		priv->wol_en = 1;
> +		priv->wol_opts = GIANFAR_WOL_MAGIC;
> +	} else if (wol->wolopts & WAKE_ARP) {
> +		priv->wol_en = 1;
> +		priv->wol_opts = GIANFAR_WOL_ARP;

What if both WAKE_MAGIC and WAKE_ARP are set?

And shouldn't you make sure we actually support the one being requested,
rather than just making sure that we support one of the wake modes?

-Scott
