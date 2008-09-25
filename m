From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 11/21] fs-enet: remove code associated with !CONFIG_PPC_MERGE
Date: Wed, 24 Sep 2008 22:15:20 -0400
Message-ID: <48DAF438.3080001@garzik.org>
References: <200809222152.m8MLqIAI031969@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, galak@kernel.crashing.org,
	benh@kernel.crashing.org, paulus@samba.org, scottwood@freescale.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55409 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbYIYCP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 22:15:27 -0400
In-Reply-To: <200809222152.m8MLqIAI031969@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Kumar Gala <galak@kernel.crashing.org>
> 
> Now that arch/ppc is gone we don't need CONFIG_PPC_MERGE anymore remove
> the dead code associated with !CONFIG_PPC_MERGE.
> 
> With this change the pre_request_irq() and post_free_irq() calls became
> nops so they have been removed.  Also removed fs_request_irq() and
> fs_free_irq() and just called request_irq() and free_irq().
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Scott Wood <scottwood@freescale.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/fs_enet/fs_enet-main.c |   22 ++-----------------
>  drivers/net/fs_enet/fs_enet.h      |    2 -
>  drivers/net/fs_enet/mac-fcc.c      |   12 ----------
>  drivers/net/fs_enet/mac-fec.c      |   30 ---------------------------
>  drivers/net/fs_enet/mac-scc.c      |   26 -----------------------
>  5 files changed, 3 insertions(+), 89 deletions(-)
> 
> diff -puN drivers/net/fs_enet/fs_enet-main.c~fs-enet-remove-code-associated-with-config_ppc_merge drivers/net/fs_enet/fs_enet-main.c
> --- a/drivers/net/fs_enet/fs_enet-main.c~fs-enet-remove-code-associated-with-config_ppc_merge
> +++ a/drivers/net/fs_enet/fs_enet-main.c
> @@ -664,23 +664,6 @@ static int fs_enet_start_xmit(struct sk_
>  	return NETDEV_TX_OK;
>  }
>  
> -static int fs_request_irq(struct net_device *dev, int irq, const char *name,
> -		irq_handler_t irqf)
> -{
> -	struct fs_enet_private *fep = netdev_priv(dev);
> -
> -	(*fep->ops->pre_request_irq)(dev, irq);
> -	return request_irq(irq, irqf, IRQF_SHARED, name, dev);
> -}
> -
> -static void fs_free_irq(struct net_device *dev, int irq)
> -{
> -	struct fs_enet_private *fep = netdev_priv(dev);
> -
> -	free_irq(irq, dev);
> -	(*fep->ops->post_free_irq)(dev, irq);
> -}
> -
>  static void fs_timeout(struct net_device *dev)
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
> @@ -800,7 +783,8 @@ static int fs_enet_open(struct net_devic
>  		napi_enable(&fep->napi);
>  
>  	/* Install our interrupt handler. */
> -	r = fs_request_irq(dev, fep->interrupt, "fs_enet-mac", fs_enet_interrupt);
> +	r = request_irq(fep->interrupt, fs_enet_interrupt, IRQF_SHARED,
> +			"fs_enet-mac", dev);
>  	if (r != 0) {
>  		printk(KERN_ERR DRV_MODULE_NAME
>  		       ": %s Could not allocate FS_ENET IRQ!", dev->name);
> @@ -842,7 +826,7 @@ static int fs_enet_close(struct net_devi
>  	/* release any irqs */
>  	phy_disconnect(fep->phydev);
>  	fep->phydev = NULL;
> -	fs_free_irq(dev, fep->interrupt);
> +	free_irq(fep->interrupt, dev);
>  
>  	return 0;
>  }
> diff -puN drivers/net/fs_enet/fs_enet.h~fs-enet-remove-code-associated-with-config_ppc_merge drivers/net/fs_enet/fs_enet.h
> --- a/drivers/net/fs_enet/fs_enet.h~fs-enet-remove-code-associated-with-config_ppc_merge
> +++ a/drivers/net/fs_enet/fs_enet.h
> @@ -34,8 +34,6 @@ struct fs_ops {
>  	void (*adjust_link)(struct net_device *dev);
>  	void (*restart)(struct net_device *dev);
>  	void (*stop)(struct net_device *dev);
> -	void (*pre_request_irq)(struct net_device *dev, int irq);
> -	void (*post_free_irq)(struct net_device *dev, int irq);
>  	void (*napi_clear_rx_event)(struct net_device *dev);
>  	void (*napi_enable_rx)(struct net_device *dev);
>  	void (*napi_disable_rx)(struct net_device *dev);
> diff -puN drivers/net/fs_enet/mac-fcc.c~fs-enet-remove-code-associated-with-config_ppc_merge drivers/net/fs_enet/mac-fcc.c
> --- a/drivers/net/fs_enet/mac-fcc.c~fs-enet-remove-code-associated-with-config_ppc_merge
> +++ a/drivers/net/fs_enet/mac-fcc.c
> @@ -421,16 +421,6 @@ static void stop(struct net_device *dev)
>  	fs_cleanup_bds(dev);
>  }
>  
> -static void pre_request_irq(struct net_device *dev, int irq)
> -{
> -	/* nothing */
> -}
> -
> -static void post_free_irq(struct net_device *dev, int irq)
> -{
> -	/* nothing */
> -}
> -
>  static void napi_clear_rx_event(struct net_device *dev)
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
> @@ -540,8 +530,6 @@ const struct fs_ops fs_fcc_ops = {
>  	.set_multicast_list	= set_multicast_list,
>  	.restart		= restart,
>  	.stop			= stop,
> -	.pre_request_irq	= pre_request_irq,
> -	.post_free_irq		= post_free_irq,
>  	.napi_clear_rx_event	= napi_clear_rx_event,
>  	.napi_enable_rx		= napi_enable_rx,
>  	.napi_disable_rx	= napi_disable_rx,
> diff -puN drivers/net/fs_enet/mac-fec.c~fs-enet-remove-code-associated-with-config_ppc_merge drivers/net/fs_enet/mac-fec.c
> --- a/drivers/net/fs_enet/mac-fec.c~fs-enet-remove-code-associated-with-config_ppc_merge
> +++ a/drivers/net/fs_enet/mac-fec.c
> @@ -313,11 +313,7 @@ static void restart(struct net_device *d
>  	 * Clear any outstanding interrupt.
>  	 */
>  	FW(fecp, ievent, 0xffc0);
> -#ifndef CONFIG_PPC_MERGE
> -	FW(fecp, ivec, (fep->interrupt / 2) << 29);
> -#else
>  	FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
> -#endif
>  
>  	/*
>  	 * adjust to speed (only for DUET & RMII)
> @@ -413,30 +409,6 @@ static void stop(struct net_device *dev)
>  	}
>  }
>  
> -static void pre_request_irq(struct net_device *dev, int irq)
> -{
> -#ifndef CONFIG_PPC_MERGE
> -	immap_t *immap = fs_enet_immap;
> -	u32 siel;
> -
> -	/* SIU interrupt */
> -	if (irq >= SIU_IRQ0 && irq < SIU_LEVEL7) {
> -
> -		siel = in_be32(&immap->im_siu_conf.sc_siel);
> -		if ((irq & 1) == 0)
> -			siel |= (0x80000000 >> irq);
> -		else
> -			siel &= ~(0x80000000 >> (irq & ~1));
> -		out_be32(&immap->im_siu_conf.sc_siel, siel);
> -	}
> -#endif
> -}
> -
> -static void post_free_irq(struct net_device *dev, int irq)
> -{
> -	/* nothing */
> -}
> -
>  static void napi_clear_rx_event(struct net_device *dev)
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
> @@ -529,8 +501,6 @@ const struct fs_ops fs_fec_ops = {
>  	.set_multicast_list	= set_multicast_list,
>  	.restart		= restart,
>  	.stop			= stop,
> -	.pre_request_irq	= pre_request_irq,
> -	.post_free_irq		= post_free_irq,
>  	.napi_clear_rx_event	= napi_clear_rx_event,
>  	.napi_enable_rx		= napi_enable_rx,
>  	.napi_disable_rx	= napi_disable_rx,
> diff -puN drivers/net/fs_enet/mac-scc.c~fs-enet-remove-code-associated-with-config_ppc_merge drivers/net/fs_enet/mac-scc.c
> --- a/drivers/net/fs_enet/mac-scc.c~fs-enet-remove-code-associated-with-config_ppc_merge
> +++ a/drivers/net/fs_enet/mac-scc.c
> @@ -377,30 +377,6 @@ static void stop(struct net_device *dev)
>  	fs_cleanup_bds(dev);
>  }
>  
> -static void pre_request_irq(struct net_device *dev, int irq)
> -{
> -#ifndef CONFIG_PPC_MERGE
> -	immap_t *immap = fs_enet_immap;
> -	u32 siel;
> -
> -	/* SIU interrupt */
> -	if (irq >= SIU_IRQ0 && irq < SIU_LEVEL7) {
> -
> -		siel = in_be32(&immap->im_siu_conf.sc_siel);
> -		if ((irq & 1) == 0)
> -			siel |= (0x80000000 >> irq);
> -		else
> -			siel &= ~(0x80000000 >> (irq & ~1));
> -		out_be32(&immap->im_siu_conf.sc_siel, siel);
> -	}
> -#endif
> -}
> -
> -static void post_free_irq(struct net_device *dev, int irq)
> -{
> -	/* nothing */
> -}
> -
>  static void napi_clear_rx_event(struct net_device *dev)
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
> @@ -494,8 +470,6 @@ const struct fs_ops fs_scc_ops = {
>  	.set_multicast_list	= set_multicast_list,
>  	.restart		= restart,
>  	.stop			= stop,
> -	.pre_request_irq	= pre_request_irq,
> -	.post_free_irq		= post_free_irq,
>  	.napi_clear_rx_event	= napi_clear_rx_event,
>  	.napi_enable_rx		= napi_enable_rx,

applied


