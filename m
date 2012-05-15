From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH V2] CS89x0 : Use ioread16/iowrite16 on all platforms
Date: Wed, 16 May 2012 00:37:11 +0200
Message-ID: <20120515223711.GA12674@electric-eye.fr.zoreil.com>
References: <1337112906-31033-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd@arndb.de, s.hauer@pengutronix.de, gfm@funxed.com,
	davem@davemloft.net, festevam@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48187 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S966377Ab2EOWoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 18:44:34 -0400
Content-Disposition: inline
In-Reply-To: <1337112906-31033-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
> index b9406cb..8081ad5 100644
> --- a/drivers/net/ethernet/cirrus/cs89x0.c
> +++ b/drivers/net/ethernet/cirrus/cs89x0.c
[...]
> -static int cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular);
> +static int cs89x0_probe1(struct net_device *dev,
> +			 void __iomem *ioaddr,
> +			 int modular);
> +static int cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr,
> +			 int modular);

s/int/bool/ maybe.

You may skip the name of the parameters.

[...]
> +static int __init
> +cs89x0_ioport_probe(struct net_device *dev, unsigned long ioport, int modular)
> +{
> +	struct net_local *lp = netdev_priv(dev);
> +	int ret;
> +	void __iomem *io_mem;
> +
> +	if (!lp)
> +		return -ENOMEM;
> +
> +	dev->base_addr = ioport;

(your changes should reduce the use of netdev.base_addr, nice)

[...]
> +	if (ioport & 1) {
> +		if (net_debug > 1)
> +			printk(KERN_INFO "%s: odd ioaddr 0x%lx\n",
> +			       dev->name,
> +			       ioport);
> +		if ((ioport & 2) != 2)
		if ((ioport & 2) != 2) {

> +			if ((ioread16(io_mem + ADD_PORT) & ADD_MASK) !=
> +			    ADD_SIG) {
> +				printk(KERN_ERR "%s: bad signature 0x%x\n",
> +					dev->name,
> +					ioread16(io_mem + ADD_PORT));

			u16 blah = ioread16(io_mem + ADD_PORT);

			if ((blah & ADD_MASK) != ADD_SIG) {
				printk(KERN_ERR "%s: bad signature 0x%x\n",
					dev->name, blah);

[...]
>  static void
> -readwords(unsigned long base_addr, int portno, void *buf, int length)
> +readwords(void __iomem *base_addr, int portno, void *buf, int length)

You may try the shorter and (arguably) type safer :

static void readwords(struct net_local *lp, int portno, void *buf, int length)

> -writewords(unsigned long base_addr, int portno, void *buf, int length)
> +writewords(void __iomem *base_addr, int portno, void *buf, int length)

Same thing.

[...]
> -	/* Grab the region so we can find another board if autoIRQ fails. */
> -	/* WTF is going on here? */
> -	if (!request_region(ioaddr & ~3, NETCARD_IO_EXTENT, DRV_NAME)) {
> -		printk(KERN_ERR "%s: request_region(0x%lx, 0x%x) failed\n",
> -				DRV_NAME, ioaddr, NETCARD_IO_EXTENT);
> -		retval = -EBUSY;
> -		goto out1;
> -	}
> +	printk(KERN_DEBUG "PP_addr at %p[%x]: 0x%x\n",
> +			ioaddr, ADD_PORT, ioread16(ioaddr + ADD_PORT));

Please use spaces after tabs so that ioaddr lines up nicely with KERN_DEBUG.

[...]
> @@ -1114,7 +1137,10 @@ send_test_pkt(struct net_device *dev)
>  		return 0;	/* this shouldn't happen */
>  
>  	/* Write the contents of the packet */
> -	writewords(dev->base_addr, TX_FRAME_PORT,test_packet,(ETH_ZLEN+1) >>1);
> +	writewords(lp->virt_addr,
> +		   TX_FRAME_PORT,
> +		   test_packet,
> +		   (ETH_ZLEN+1) >> 1);

	writewords(lp, TX_FRAME_PORT, test_packet, (ETH_ZLEN + 1) >> 1);

[...]
> @@ -1631,9 +1656,12 @@ net_rx(struct net_device *dev)
>  	}
>  	skb_reserve(skb, 2);	/* longword align L3 header */
>  
> -	readwords(ioaddr, RX_FRAME_PORT, skb_put(skb, length), length >> 1);
> +	readwords(lp->virt_addr,
> +		  RX_FRAME_PORT,
> +		  skb_put(skb, length),
> +		  length >> 1);

	readwords(lp, RX_FRAME_PORT, skb_put(skb, length), length >> 1);

[...]
> @@ -1928,22 +1960,22 @@ static int __init cs89x0_platform_probe(struct platform_device *pdev)
>  		goto free;
>  	}
>  
> -	lp->phys_addr = mem_res->start;
> +	dev->base_addr = mem_res->start;

You may work directly with mem_res->start in this function at the price
of an extra platform_get_resource() in cs89x0_platform_remove().

-- 
Ueimor
