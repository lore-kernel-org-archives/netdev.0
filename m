From: Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 1/3] net: macb: Add support for extended BD with a
 config option
Date: Mon, 21 Sep 2015 23:18:06 +0530
Message-ID: <CAFcVEC+K-jX4rU20Qa1BEi-KCLKCFb=3Q3OKgknTgP-Zhn10Fg@mail.gmail.com>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
	<1441958258-35441-2-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org" <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org
To: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441958258-35441-2-git-send-email-harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 1:27 PM, Harini Katakam
<harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org> wrote:
> Cadence GEM supports extended buffer descriptors.
> This patch adds a config option to enable use of extended BD.
> This adds two extra words to the TX BD and RX BD by configuring the
> necessary registers. Corresponding variables are added to the
> macb_dma_desc structure.
>
> Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/cadence/Kconfig |    8 ++++++++
>  drivers/net/ethernet/cadence/macb.c  |    4 ++++
>  drivers/net/ethernet/cadence/macb.h  |    8 ++++++++
>  3 files changed, 20 insertions(+)
>
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
> index f0bcb15..33e4198 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -31,4 +31,12 @@ config MACB
>           To compile this driver as a module, choose M here: the module
>           will be called macb.
>
> +config MACB_EXT_BD
> +       tristate "Cadence MACB/GEM extended buffer descriptor"
> +       depends on HAS_DMA && MACB
> +       ---help---
> +         The Cadence MACB host supports use of extended buffer descriptor.
> +         This option enables additon of two extra words to TX BD and RX BD.
> +         These two extra words are currently used to obtain PTP timestamp.
> +
>  endif # NET_CADENCE
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 88c1e1a..bb2932c 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1665,6 +1665,10 @@ static void macb_configure_dma(struct macb *bp)
>                         dmacfg |= GEM_BIT(TXCOEN);
>                 else
>                         dmacfg &= ~GEM_BIT(TXCOEN);
> +#ifdef CONFIG_MACB_EXT_BD
> +               dmacfg |= GEM_BIT(RXBDEXT);
> +               dmacfg |= GEM_BIT(TXBDEXT);
> +#endif
>                 netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n",
>                            dmacfg);
>                 gem_writel(bp, DMACFG, dmacfg);
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 6e1faea..58c9870 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -244,6 +244,10 @@
>  #define GEM_RXBS_SIZE          8
>  #define GEM_DDRP_OFFSET                24 /* disc_when_no_ahb */
>  #define GEM_DDRP_SIZE          1
> +#define GEM_RXBDEXT_OFFSET     28 /* Extended RX BD */
> +#define GEM_RXBDEXT_SIZE       1
> +#define GEM_TXBDEXT_OFFSET     29 /* Extended TX BD */
> +#define GEM_TXBDEXT_SIZE       1
>
>
>  /* Bitfields in NSR */
> @@ -466,6 +470,10 @@
>  struct macb_dma_desc {
>         u32     addr;
>         u32     ctrl;
> +#ifdef CONFIG_MACB_EXT_BD
> +       u32     tsl;
> +       u32     tsh;
> +#endif
>  };
>
>  /* DMA descriptor bitfields */
> --
> 1.7.9.5
>

Any comment on this?

Regards,
Harini
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
