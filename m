From: Arun Chandran <achandran@mvista.com>
Subject: Re: [PATCH] net: macb: fix endian code for avr32
Date: Wed, 18 Mar 2015 18:46:39 +0530
Message-ID: <CAFdej002eW+iVa-R6Wada5GsKj+HgheHTB_GOAxd7PhQKw6CfA@mail.gmail.com>
References: <1426676247-14023-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@lists.codethink.co.uk,
	Linux Networking List <netdev@vger.kernel.org>,
	Haavard Skinnemoen <hskinnemoen@gmail.com>,
	Hans-Christian Egtvedt <egtvedt@samfundet.no>,
	Linux Kernel List <linux-kernel@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34739 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755979AbbCRNQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 09:16:40 -0400
Received: by iecsl2 with SMTP id sl2so37541211iec.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 06:16:39 -0700 (PDT)
In-Reply-To: <1426676247-14023-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2015 at 4:27 PM, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
>
> [note this has yet to be compile tested on avr32]
>
> The changes to run the macb driver in 29af05aeb98e ("net: macb:

Yes I mistakenly thought zynq board was the first to run it in
BIG endian mode.

> Add big endian CPU support") to support big endian operation on
> ARM may not work on AVR32 which already is naturally big endian
> architecture (and the driver already works here).
>
> In this case  the readl/writel relaxed will do the opposite of __raw
> accesors which arleady work. Add an indirection of cdneth_ prefixed
> accesors which are changed as necessary. Also do not issue the DMA
> descritpor endian fetch configuration for AVR32.
>
> From discussions with Arnd Bergman, the following fix changes the use
> of readl_relaxed and writel_relaxed with a version that can be put
> back to __raw_readl/__raw_writel for the CONFIG_AVR32 case (and also
> remove the change to the DMA descriptor endian).
>
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> --
> CC: Linux Networking List <netdev@vger.kernel.org>
> CC: Arun Chandran <achandran@mvista.com>
> CC: Haavard Skinnemoen <hskinnemoen@gmail.com>
> CC: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> CC: Linux Kernel List <linux-kernel@vger.kernel.org>
> CC: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 14 +++++++-------
>  drivers/net/ethernet/cadence/macb.h | 20 ++++++++++++++------
>  2 files changed, 21 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index b71e316..1c3f6e7 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
>         WARN_ON((unsigned long)(end - p - 1) != (MACB_TPF - MACB_PFR) / 4);
>
>         for(; p < end; p++, reg++)
> -               *p += readl_relaxed(reg);
> +               *p += cdneth_readl(reg);
>  }
>
>  static int macb_halt_tx(struct macb *bp)
> @@ -1587,7 +1587,7 @@ static void macb_configure_dma(struct macb *bp)
>                 dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
>                 dmacfg &= ~GEM_BIT(ENDIA_PKT);
>                 /* Tell the chip to byteswap descriptors on big-endian hosts */
> -#ifdef __BIG_ENDIAN


With https://kernel.googlesource.com/pub/scm/linux/kernel/git/davem/net-next/+/62f6924cb1543a10d05150d77f9a5e01e12c9ce1
in net-next I think CONFIG_AVR32 check is not required.

--Arun
