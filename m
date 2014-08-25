From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH] net: stmmac: add dcrs parameter
Date: Mon, 25 Aug 2014 20:34:29 +0800
Message-ID: <CAGb2v65fi=D_TQBSospft4T5OrBCj5TwQfgtkX=11M8TWFftYg@mail.gmail.com>
References: <1408967442-2724-1-git-send-email-lftan@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, lftan.linux@gmail.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Vince Bridgers <vbridger@altera.com>
To: Ley Foon Tan <lftan@altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:39874 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbaHYMet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 08:34:49 -0400
In-Reply-To: <1408967442-2724-1-git-send-email-lftan@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Aug 25, 2014 at 7:50 PM, Ley Foon Tan <lftan@altera.com> wrote:
> This patch add the option to enable DCRS bit in GMAC control register.
> Default is disabled if snps,dcrs is not defined.
>
> For MII, Carrier Sense (CRS) must be asserted during transmission
> whereas in RGMII, CRS is not. RGMII does not provide a way to signal
> loss of carrier during a transmission.
>
> When DCRS bit set high in control register, the MAC transmitter
> ignore the (G)MII Carrier Sense signal during frame transmission
> in the half-duplex mode. This request results in no errors generated
> because of Loss of Carrier or No Carrier during such transmission.
>
> Signed-off-by: Ley Foon Tan <lftan@altera.com>
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt      | 4 ++++
>  drivers/net/ethernet/stmicro/stmmac/common.h          | 3 ++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c  | 4 +++-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 3 ++-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 ++
>  include/linux/stmmac.h                                | 1 +
>  6 files changed, 14 insertions(+), 3 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index 9b03c57..a68e720 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -39,6 +39,10 @@ Optional properties:
>    further clocks may be specified in derived bindings.
>  - clock-names: One name for each entry in the clocks property, the
>    first one should be "stmmaceth".
> +- snps,dcrs: Enable DCRS bit in GMAC control register. This DCRS bit makes the
> +       MAC transmitter ignore the (G)MII CRS signal during frame transmission
> +       in the half-duplex mode. This request results in no errors generated

Since you know this is only required under (G)MII, could you not re-use
the "phy-mode" property, instead of adding another one?

Better yet, use the "interface" field in the platform data. This way you'll
fix non-DT devices as well. You could then avoid touching the platform driver,
and just modify the driver core.


Cheers
ChenYu

> +       because of Loss of Carrier or No Carrier during such transmission.
>
>  Examples:
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index de507c3..9abe221 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -445,10 +445,11 @@ struct mac_device_info {
>         int multicast_filter_bins;
>         int unicast_filter_entries;
>         int mcast_bits_log2;
> +       int dcrs;
>  };
>
>  struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
> -                                       int perfect_uc_entries);
> +                                       int perfect_uc_entries, int dcrs);
>  struct mac_device_info *dwmac100_setup(void __iomem *ioaddr);
>
>  void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> index d8ef187..924d450 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> @@ -37,6 +37,7 @@ static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
>         void __iomem *ioaddr = hw->pcsr;
>         u32 value = readl(ioaddr + GMAC_CONTROL);
>         value |= GMAC_CORE_INIT;
> +       value |= hw->dcrs;
>         if (mtu > 1500)
>                 value |= GMAC_CONTROL_2K;
>         if (mtu > 2000)
> @@ -409,7 +410,7 @@ static const struct stmmac_ops dwmac1000_ops = {
>  };
>
>  struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
> -                                       int perfect_uc_entries)
> +                                       int perfect_uc_entries, int dcrs)
>  {
>         struct mac_device_info *mac;
>         u32 hwid = readl(ioaddr + GMAC_VERSION);
> @@ -422,6 +423,7 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
>         mac->multicast_filter_bins = mcbins;
>         mac->unicast_filter_entries = perfect_uc_entries;
>         mac->mcast_bits_log2 = 0;
> +       mac->dcrs = dcrs;
>
>         if (mac->multicast_filter_bins)
>                 mac->mcast_bits_log2 = ilog2(mac->multicast_filter_bins);
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 08addd6..bf35b19 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2600,7 +2600,8 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
>                 priv->dev->priv_flags |= IFF_UNICAST_FLT;
>                 mac = dwmac1000_setup(priv->ioaddr,
>                                       priv->plat->multicast_filter_bins,
> -                                     priv->plat->unicast_filter_entries);
> +                                     priv->plat->unicast_filter_entries,
> +                                     priv->plat->dcrs);
>         } else {
>                 mac = dwmac100_setup(priv->ioaddr);
>         }
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index bb524a9..07f895f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -227,6 +227,8 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>                 pr_warn("force_sf_dma_mode is ignored if force_thresh_dma_mode is set.");
>         }
>
> +       plat->dcrs = of_property_read_bool(np, "snps,dcrs");
> +
>         return 0;
>  }
>  #else
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index cd63851..6367f42 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -114,6 +114,7 @@ struct plat_stmmacenet_data {
>         int maxmtu;
>         int multicast_filter_bins;
>         int unicast_filter_entries;
> +       int dcrs;
>         void (*fix_mac_speed)(void *priv, unsigned int speed);
>         void (*bus_setup)(void __iomem *ioaddr);
>         void *(*setup)(struct platform_device *pdev);
> --
> 1.8.2.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
