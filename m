From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [03/22] Cyclades PC300 driver: Fix usage of types
Date: Tue, 31 Jan 2012 19:58:29 +0100
Message-ID: <m3hazb3dii.fsf@intrepid.localdomain>
References: <20120130024605.GD10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, mmarek@suse.cz, jkosina@suse.cz,
	joe@perches.com, justinmattock@gmail.com, gregkh@suse.de,
	alan@linux.intel.com, jdmason@kudzu.us
To: Andrea Shepard <andrea@persephoneslair.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:42153 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227Ab2AaS7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jan 2012 13:59:38 -0500
In-Reply-To: <20120130024605.GD10262@cronus.persephoneslair.org> (Andrea
	Shepard's message of "Sun, 29 Jan 2012 18:46:05 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Andrea Shepard <andrea@persephoneslair.org> writes:

> +++ b/drivers/net/wan/hd64572.h
> @@ -172,11 +172,11 @@
>  
>  /* Block Descriptor Structure */
>  typedef struct {
> -	unsigned long	next;		/* pointer to next block descriptor */
> -	unsigned long	ptbuf;		/* buffer pointer */
> -	unsigned short	len;		/* data length */
> -	unsigned char	status;		/* status */
> -	unsigned char	filler[5];	/* alignment filler (16 bytes) */ 
> +	u32	next;		/* pointer to next block descriptor */
> +	u32	ptbuf;		/* buffer pointer */
> +	u16	len;		/* data length */
> +	u8	status;		/* status */
> +	u8	filler[5];	/* alignment filler (16 bytes) */
>  } pcsca_bd_t;

Perhaps you could just use the following struct which is already in the
file:

/* Block Descriptor Structure */
typedef struct {
        u32 cp;                 /* pointer to next block descriptor */
        u32 bp;                 /* buffer pointer */
        u16 len;                /* data length */
        u8 stat;                /* status */
        u8 unused;              /* pads to 4-byte boundary */
}pkt_desc;

The difference is a different alignment (4 bytes vs 16 bytes) but
I think it's been verified (both docs and real hw) that 32-bit alignment
is ok with these chips.

> +#define cpc_writeb(port, val)	{writeb((u8)(val), \
> +				(void __iomem *)(port)); mb(); }
> +#define cpc_writew(port, val)	{writew((u16)(val), \
> +				(void __iomem *)(port)); mb(); }
> +#define cpc_writel(port, val)	{writel((u32)(val), \
> +				(void __iomem *)(port)); mb(); }

Are these mb() needed? I think write[bwl] and read[bwl] are already
memory barriers.
PCI write posting is a different thing of course and you may need e.g.
a PCI read in some timing-critical parts of the code.

>  #else /* __KERNEL__ */
> -#define cpc_writeb(port,val)	(*(volatile ucchar *)(port) = (ucchar)(val))
> -#define cpc_writew(port,val)	(*(volatile ucshort *)(port) = (ucshort)(val))
> -#define cpc_writel(port,val)	(*(volatile uclong *)(port) = (uclong)(val))
> +#define cpc_writeb(port, val)	(*(u8 *)(port) = (u8)(val))
> +#define cpc_writew(port, val)	(*(u16 *)(port) = (u16)(val))
> +#define cpc_writel(port, val)	(*(u32 *)(port) = (u32)(val))
>  
> -#define cpc_readb(port)		(*(volatile ucchar *)(port))
> -#define cpc_readw(port)		(*(volatile ucshort *)(port))
> -#define cpc_readl(port)		(*(volatile uclong *)(port))
> +#define cpc_readb(port)		(*(u8 *)(port))
> +#define cpc_readw(port)		(*(u16 *)(port))
> +#define cpc_readl(port)		(*(u32 *)(port))

I'm not sure the kernel headers are a good place for such things.

>  void tx_dma_stop(pc300_t * card, int ch)
>  {
> -	uclong scabase = card->hw.scabase;
> -	ucchar drr_ena_bit = 1 << (5 + 2 * ch);
> -	ucchar drr_rst_bit = 1 << (1 + 2 * ch);
> +	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
> +	u8 drr_ena_bit = 1 << (5 + 2 * ch);
> +	u8 drr_rst_bit = 1 << (1 + 2 * ch);

uintptr_t? Is it simply an unsigned int *?
-- 
Krzysztof Halasa
