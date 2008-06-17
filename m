From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] [Rev2] MPC5121 FEC support
Date: Tue, 17 Jun 2008 21:22:37 +0200
Message-ID: <20080617192237.GA12961@uranus.ravnborg.org>
References: <1213729717-26688-1-git-send-email-jrigby@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, netdev@vger.kernel.org
To: John Rigby <jrigby@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:40141 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756419AbYFQTVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 15:21:53 -0400
Content-Disposition: inline
In-Reply-To: <1213729717-26688-1-git-send-email-jrigby@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John - a few nitpicks.

>  
> +config FS_ENET_MPC5121_FEC
> +	bool "Freescale MPC512x FEC driver"
> +	depends on PPC_MPC512x
> +	select FS_ENET
> +	select PPC_CPM_NEW_BINDING
> +	default y

help is missing. I assume you can help the casual reader a bit by being
a bit more verbose. Especially so some random MPC user knows this is not for him.


> +/*
> + * The 5121 FEC doc says transmit buffers must have 4 byte alignment.
> + * We get alignement from the device tree in case this changes on future
> + * platforms.
> + */
> +static struct sk_buff *align_tx_skb(struct net_device *dev, struct sk_buff *skb,
> +			    int align)
> +{
> +	struct sk_buff *skbn;
> +
> +	if ((((unsigned long)skb->data) & (align-1)) == 0)
> +		return skb;
Use one of the available ALIGN macros?
Spaces arounf operators please.

> +
> +	skbn = dev_alloc_skb(ENET_RX_FRSIZE+align);
spaces around operatiors please.

> +	if (!skbn) {
> +		printk(KERN_WARNING DRV_MODULE_NAME
> +			": %s Memory squeeze, dropping tx packet.\n",
> +			dev->name);
> +		dev_kfree_skb_any(skb);
> +		return NULL;

Consider using goto for error handling like we do in many
other places.

> +	data = of_get_property(ofdev->node, "fsl,align-tx-packets", &len);
> +	if (data && len == 4)
> +		fpi->align_tx_packets = *data;
> +
Where did "4" come from. USe a define with a desriptive name.

>  	fpi->rx_ring = 32;
>  	fpi->tx_ring = 32;
Same for "32"
>  	fpi->rx_copybreak = 240;
Same for "240".

> --- a/drivers/net/fs_enet/fs_enet.h
> +++ b/drivers/net/fs_enet/fs_enet.h
> @@ -10,12 +10,17 @@
>  
>  #include <linux/fs_enet_pd.h>
>  #include <asm/fs_pd.h>
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> +#include "fec_mpc5121.h"
> +#endif

Which is this include ifdeffed - looks like some wrong concept.

>  
>  #ifdef CONFIG_CPM1
>  #include <asm/cpm1.h>
> +#endif
>  
> +#if defined(CONFIG_FS_ENET_HAS_FEC)
>  struct fec_info {
> -	fec_t __iomem *fecp;
> +	struct fec __iomem *fecp;
>  	u32 mii_speed;

I we have a conversion from fec_t to struct fec
then this is a separate patch in the normal case.

> diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
> index 8a311d1..a48a550 100644
> --- a/drivers/net/fs_enet/mac-fec.c
> +++ b/drivers/net/fs_enet/mac-fec.c
> @@ -42,6 +42,9 @@
>  #include <asm/mpc8xx.h>
>  #include <asm/cpm1.h>
>  #endif
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> +#include "fec_mpc5121.h"
> +#endif
The ifdeffed include shows up again...

> -static int whack_reset(fec_t __iomem *fecp)
> +static int whack_reset(struct fec __iomem *fecp)
And so does fec_t => struct fec...

>  {
And so does fec_t => struct fec...

>  static void set_promiscuous_mode(struct net_device *dev)
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
> -	fec_t __iomem *fecp = fep->fec.fecp;
> +	struct fec __iomem *fecp = fep->fec.fecp;
Again.. (will drop mention it for now. But this is truly
a unrelated change.

The amount of ifdef introduced looks bad..
And try to run the patch through scripts/checkpatch.pl
And try to split it up a bit.

	Sam
