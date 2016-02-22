From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: net: netcp: regarding commit 899077: netcp: try to reduce type confusion in descriptors
Date: Mon, 22 Feb 2016 23:13:25 +0100
Message-ID: <2817046.Cys9vdONqu@wuerfel>
References: <56CB821E.7040809@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:49281 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755934AbcBVWNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 17:13:30 -0500
In-Reply-To: <56CB821E.7040809@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 22 February 2016 16:48:14 Murali Karicheri wrote:
> Arnd,
> 
> As promised, here is what I found wrong with the commit 899077 that introduced a 
> regression. With these changes, I am able to boot kernel without issues on K2 platforms.

Thanks so much for looking into this!

> From the commit description, it appears that you are trying to make the driver do the right
> thing if compiled for a 64 bit systems. Is it mandatory for all kernel drivers to be
> 64bit compliant? Similar question on supporting mixed endian in all kernel drivers.

I would generally expect all device driver code to be written as architecture-independent
as possible, for multiple reasons:

* hardware gets reused all the time, we have plenty of drivers that started out on
  big-endian powerpc32 or mips32 and are now used on 64-bit little-endian arm, so
  you should not make any assumptions

* code gets copied into other drivers, so whatever you write should be able to serve
  as an example to other developers

> Keystone can have SoC configured to be in big endian mode for peripherals and DSP.

I'm not entirely sure what this means

> so that is
> something we need to support if there is customer interest. Wondering why do one run BE kernel
> binary on these platforms? Any reason? I saw some reference to that in past discussion on this
> regression issue.

The only real reason to run a big-endian ARM kernel is for compatibility with user space
that has either is known to not be portable to little-endian, or that has only ever been
used on big-endian machines and that might have unknown problems.

This is typically the case for proprietary user space network stacks of the kind you
find in commercial network infrastructure hardware, but there are a couple of other
uses in enterprise systems that have source code ported from mainframes.

> diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
> index c61d66d..ac35161 100644
> --- a/drivers/net/ethernet/ti/netcp_core.c
> +++ b/drivers/net/ethernet/ti/netcp_core.c
> @@ -167,7 +167,7 @@ static void set_pad_info(u32 pad0, u32 pad1, u32 pad2, struct knav_dma_desc *des
>  {
>         desc->pad[0] = cpu_to_le32(pad0);
>         desc->pad[1] = cpu_to_le32(pad1);
> -       desc->pad[2] = cpu_to_le32(pad1);
> +       desc->pad[2] = cpu_to_le32(pad2);
>  }

I had found this hunk earlier.

>  static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
> @@ -870,8 +870,8 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>                 }
>                 buf_len = PAGE_SIZE;
>                 dma = dma_map_page(netcp->dev, page, 0, buf_len, DMA_TO_DEVICE);
> -               pad[0] = lower_32_bits(dma);
> -               pad[1] = upper_32_bits(dma);
> +               pad[0] = lower_32_bits((uintptr_t)page);
> +               pad[1] = upper_32_bits((uintptr_t)page);
>                 pad[2] = 0;
>         }

And this is my stupid mistake that I failed to see.

> @@ -1194,9 +1194,9 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
>         }
>  
>         set_words(&tmp, 1, &desc->packet_info);
> -       tmp = lower_32_bits((uintptr_t)&skb);
> +       tmp = lower_32_bits((uintptr_t)skb);
>         set_words(&tmp, 1, &desc->pad[0]);
> -       tmp = upper_32_bits((uintptr_t)&skb);
> +       tmp = upper_32_bits((uintptr_t)skb);
>         set_words(&tmp, 1, &desc->pad[1]);
>  
>         if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {

And this is another one of the same sort.

Not my best patch ever obviously, but at least I understand where I went
wrong now, and see that it was only me being sloppy in the conversion rather
than a more fundamental misdesign.

Thanks,

	Arnd
