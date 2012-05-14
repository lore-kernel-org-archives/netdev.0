From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] CS89x0 : Use ioread16/iowrite16 on all platforms
Date: Mon, 14 May 2012 07:42:23 +0000
Message-ID: <201205140742.23478.arnd@arndb.de>
References: <1336947279-10769-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, gfm@funxed.com, davem@davemloft.net,
	festevam@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:49602 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664Ab2ENHnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:43:50 -0400
In-Reply-To: <1336947279-10769-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 13 May 2012, Jaccon Bastiaansen wrote:
> The use of the inw/outw functions by the cs89x0 platform driver
> results in NULL pointer references.
> 
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>

Hi Jaccon,

Thanks for taking on this patch. I think it needs some more work, but you are on
the right track.

First of all, the description about should be more specific. I would recommend
adding at least the specific platform on which you saw it, and something like
[results in NULL pointer references] on platforms that do not provide ISA-style
programmed I/O accessors, and accesses the wrong address space on platforms
that have a PCI I/O space that is not identity-mapped into the physical address
space.

I would also recommend building the driver with "make C=1" after installing "sparse",
so you can detect any location where you potentially use the wrong pointer.

> diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
> index b9406cb..5a1e5d7 100644
> --- a/drivers/net/ethernet/cirrus/cs89x0.c
> +++ b/drivers/net/ethernet/cirrus/cs89x0.c
> @@ -222,6 +222,7 @@ struct net_local {
>  	int send_underrun;	/* keep track of how many underruns in a row we get */
>  	int force;		/* force various values; see FORCE* above. */
>  	spinlock_t lock;
> +	unsigned long phys_addr;/* CS89x0 I/O port or physical address. */
>  #if ALLOW_DMA
>  	int use_dma;		/* Flag: we're using dma */
>  	int dma;		/* DMA channel */
> @@ -231,8 +232,6 @@ struct net_local {
>  	unsigned char *rx_dma_ptr;	/* points to the next packet  */
>  #endif
>  #ifdef CONFIG_CS89x0_PLATFORM
> -	void __iomem *virt_addr;/* Virtual address for accessing the CS89x0. */
> -	unsigned long phys_addr;/* Physical address for accessing the CS89x0. */
>  	unsigned long size;	/* Length of CS89x0 memory region. */
>  #endif
>  };

I think it makes sense to remove the #ifdef here and just leave the "size" member
next to "phys_addr".

More importantly, I would rename the "base_addr" member to "virt_addr" and change
the type to void __iomem *. This will let you remove a lot of type casts and
catch potentially broken accesses where the __iomem token still gets passed into
inw/outw.

> @@ -279,6 +278,47 @@ static int __init dma_fn(char *str)
>  __setup("cs89x0_dma=", dma_fn);
>  #endif	/* !defined(MODULE) && (ALLOW_DMA != 0) */
>  
> +#ifndef CONFIG_CS89x0_PLATFORM
> +/*
> + * This function converts the I/O port addres used by the cs89x0_probe() and
> + * init_module() functions to the I/O memory address used by the
> + * cs89x0_probe1() function.
> + */
> +static int __init
> +cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
> +{
> +	struct net_local *lp = netdev_priv(dev);
> +	int ret = 0;
> +	void __iomem *io_mem;
> +
> +	if (!lp)
> +		return -ENOMEM;
> +
> +	lp->phys_addr = ioport;
> +
> +	if (!request_region(ioport, NETCARD_IO_EXTENT, DRV_NAME)) {
> +		ret = -EBUSY;
> +		goto out;
> +	}
> +
> +	io_mem = ioport_map(ioport, NETCARD_IO_EXTENT);
> +	if (!io_mem) {
> +		ret = -ENOMEM;
> +		goto release;
> +	}
> +
> +	ret = cs89x0_probe1(dev, ret, modular);
> +	if (!ret)
> +		goto out;
> +
> +	ioport_unmap(io_mem);
> +release:
> +	release_region(ioport, NETCARD_IO_EXTENT);
> +out:
> +	return ret;
> +}
> +#endif

You don't seem to actually assign the io_mem pointer to base_addr here, so the
accesses will go to the wrong address in the ISA case. It's generally better
not to initially "ret" to zero in cases like this, so the compiler can catch
this kind of bug.

> @@ -373,13 +412,13 @@ writeword(unsigned long base_addr, int portno, u16 value)
>  static u16
>  readword(unsigned long base_addr, int portno)
>  {
> -	return inw(base_addr + portno);
> +	return ioread16((void __iomem *)base_addr + portno);
>  }
>  
>  static void
>  writeword(unsigned long base_addr, int portno, u16 value)
>  {
> -	outw(value, base_addr + portno);
> +	iowrite16(value, (void __iomem *)(base_addr + portno));
>  }
>  #endif

These functions (and others) should just get changed to take a "void __iomem *"
pointer instead. In fact, you can remove them now and just call iowrite16 directly,
since the ixp2000 case in the #ifdef is now obsolete as the platform is getting
removed and everything just uses ioread/iowrite.

	Arnd
