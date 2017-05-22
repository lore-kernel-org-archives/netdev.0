From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/4] net-next: stmmac: rework the speed selection
Date: Mon, 22 May 2017 14:49:44 -0400 (EDT)
Message-ID: <20170522.144944.1978795354564077830.davem@davemloft.net>
References: <20170522123347.5295-1-clabbe.montjoie@gmail.com>
        <20170522123347.5295-5-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522123347.5295-5-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Mon, 22 May 2017 14:33:47 +0200

> The current stmmac_adjust_link() part which handle speed have
> some if (has_platform) code and my dwmac-sun8i will add more of them.
> 
> So we need to handle better speed selection.
> Moreover the struct link member speed and port are hard to guess their
> purpose. And their unique usage are to be combined for writing speed.
> 
> So this patch replace speed/port by simpler
> speed10/speed100/speed1000/speed_mask variables.
> 
> In dwmac4_core_init and dwmac1000_core_init, port/speed value was used
> directly without using the struct link. This patch convert also their
> usage to speedxxx.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/common.h       |  8 ++++---
>  .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 26 +++++++++++++---------
>  .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |  6 +++--
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 26 +++++++++++++---------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 21 ++++-------------
>  5 files changed, 43 insertions(+), 44 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index b7ce3fbb5375..e82b4b70b7be 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -549,9 +549,11 @@ extern const struct stmmac_hwtimestamp stmmac_ptp;
>  extern const struct stmmac_mode_ops dwmac4_ring_mode_ops;
>  
>  struct mac_link {
> -	int port;
> -	int duplex;
> -	int speed;
> +	u32 speed_mask;
> +	u32 speed10;
> +	u32 speed100;
> +	u32 speed1000;
> +	u32 duplex;
>  };
>  
>  struct mii_regs {
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> index f3d9305e5f70..b8848a9d70c5 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> @@ -45,15 +45,17 @@ static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
>  	if (hw->ps) {
>  		value |= GMAC_CONTROL_TE;
>  
> -		if (hw->ps == SPEED_1000) {
> -			value &= ~GMAC_CONTROL_PS;
> -		} else {
> -			value |= GMAC_CONTROL_PS;
> -
> -			if (hw->ps == SPEED_10)
> -				value &= ~GMAC_CONTROL_FES;
> -			else
> -				value |= GMAC_CONTROL_FES;
> +		value &= ~hw->link.speed_mask;
> +		switch (hw->ps) {
> +		case SPEED_1000:
> +			value |= hw->link.speed1000;
> +			break;
> +		case SPEED_100:
> +			value |= hw->link.speed100;
> +			break;
> +		case SPEED_10:
> +			value |= hw->link.speed10;
> +			break;
>  		}
>  	}
>  
> @@ -531,9 +533,11 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
>  	mac->mac = &dwmac1000_ops;
>  	mac->dma = &dwmac1000_dma_ops;
>  
> -	mac->link.port = GMAC_CONTROL_PS;
>  	mac->link.duplex = GMAC_CONTROL_DM;
> -	mac->link.speed = GMAC_CONTROL_FES;
> +	mac->link.speed10 = GMAC_CONTROL_PS;
> +	mac->link.speed100 = GMAC_CONTROL_PS | GMAC_CONTROL_FES;
> +	mac->link.speed1000 = 0;
> +	mac->link.speed_mask = GENMASK(15, 14);

Neither GMAC_CONTROL_PS nor GMAC_CONTROL_FES are defined with
the GENMASK() macro.  So it is very confusing to see constant
bit specifications here in C code.

There are two ways to do this properly:

1) Use "(GMAC_CONTROL_PS | GMAC_CONTROL_FES)"

2) Define a new GMAC_CONTROL_SPDMASK to "GMAC_CONTROL_PS | GMAC_CONTROL_FES"
   and use that here.

> @@ -747,9 +749,11 @@ struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
>  	if (mac->multicast_filter_bins)
>  		mac->mcast_bits_log2 = ilog2(mac->multicast_filter_bins);
>  
> -	mac->link.port = GMAC_CONFIG_PS;
>  	mac->link.duplex = GMAC_CONFIG_DM;
> -	mac->link.speed = GMAC_CONFIG_FES;
> +	mac->link.speed10 = GMAC_CONFIG_PS;
> +	mac->link.speed100 = GMAC_CONFIG_FES | GMAC_CONFIG_PS;
> +	mac->link.speed1000 = 0;
> +	mac->link.speed_mask = GENMASK(15, 14);
>  	mac->mii.addr = GMAC_MDIO_ADDR;
>  	mac->mii.data = GMAC_MDIO_DATA;
>  	mac->mii.addr_shift = 21;

Likewise.
