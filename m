From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v1 4/4] stmmac: pci: split out common_default_data()
 helper
Date: Mon, 8 May 2017 15:19:19 +0100
Message-ID: <ba9d7154-f767-664c-2d2c-593e32c4ba71@synopsys.com>
References: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
 <20170508141422.39612-5-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Jan Kiszka <jan.kiszka@siemens.com>,
        netdev <netdev@vger.kernel.org>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:39187 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754652AbdEHOTX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 10:19:23 -0400
In-Reply-To: <20170508141422.39612-5-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:14 PM de 5/8/2017, Andy Shevchenko escreveu:
> New helper is added in order to prevent misconfiguration happened
> for one of the platforms when configuration data is expanded.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 52 ++++++++----------------
>  1 file changed, 18 insertions(+), 34 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index 2456e0a945ef..22f910795be4 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -70,11 +70,8 @@ static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
>  	return -ENODEV;
>  }
>  
> -static void stmmac_default_data(struct plat_stmmacenet_data *plat)
> +static void common_default_data(struct plat_stmmacenet_data *plat)
>  {
> -	plat->bus_id = 1;
> -	plat->phy_addr = 0;
> -	plat->interface = PHY_INTERFACE_MODE_GMII;
>  	plat->clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
>  	plat->has_gmac = 1;
>  	plat->force_sf_dma_mode = 1;
> @@ -82,10 +79,6 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
>  	plat->mdio_bus_data->phy_reset = NULL;
>  	plat->mdio_bus_data->phy_mask = 0;
>  
> -	plat->dma_cfg->pbl = 32;
> -	plat->dma_cfg->pblx8 = true;
> -	/* TODO: AXI */
> -
>  	/* Set default value for multicast hash bins */
>  	plat->multicast_filter_bins = HASH_TABLE_SIZE;
>  
> @@ -107,12 +100,29 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
>  	plat->rx_queues_cfg[0].pkt_route = 0x0;
>  }
>  
> +static void stmmac_default_data(struct plat_stmmacenet_data *plat)
> +{
> +	/* Set common default data first */
> +	common_default_data(plat);
> +
> +	plat->bus_id = 1;
> +	plat->phy_addr = 0;
> +	plat->interface = PHY_INTERFACE_MODE_GMII;
> +
> +	plat->dma_cfg->pbl = 32;
> +	plat->dma_cfg->pblx8 = true;
> +	/* TODO: AXI */
> +}
> +
>  static int quark_default_data(struct plat_stmmacenet_data *plat,
>  			      struct stmmac_pci_info *info)
>  {
>  	struct pci_dev *pdev = info->pdev;
>  	int ret;
>  
> +	/* Set common default data first */
> +	common_default_data(plat);
> +
>  	/*
>  	 * Refuse to load the driver and register net device if MAC controller
>  	 * does not connect to any PHY interface.
> @@ -124,38 +134,12 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
>  	plat->bus_id = PCI_DEVID(pdev->bus->number, pdev->devfn);
>  	plat->phy_addr = ret;
>  	plat->interface = PHY_INTERFACE_MODE_RMII;
> -	plat->clk_csr = 2;
> -	plat->has_gmac = 1;
> -	plat->force_sf_dma_mode = 1;
> -
> -	plat->mdio_bus_data->phy_reset = NULL;
> -	plat->mdio_bus_data->phy_mask = 0;
>  
>  	plat->dma_cfg->pbl = 16;
>  	plat->dma_cfg->pblx8 = true;
>  	plat->dma_cfg->fixed_burst = 1;
>  	/* AXI (TODO) */
>  
> -	/* Set default value for multicast hash bins */
> -	plat->multicast_filter_bins = HASH_TABLE_SIZE;
> -
> -	/* Set default value for unicast filter entries */
> -	plat->unicast_filter_entries = 1;
> -
> -	/* Set the maxmtu to a default of JUMBO_LEN */
> -	plat->maxmtu = JUMBO_LEN;
> -
> -	/* Set default number of RX and TX queues to use */
> -	plat->tx_queues_to_use = 1;
> -	plat->rx_queues_to_use = 1;
> -
> -	/* Disable Priority config by default */
> -	plat->tx_queues_cfg[0].use_prio = false;
> -	plat->rx_queues_cfg[0].use_prio = false;
> -
> -	/* Disable RX queues routing by default */
> -	plat->rx_queues_cfg[0].pkt_route = 0x0;
> -
>  	return 0;
>  }
>  
> 

Makes sense!

Acked-by: Joao Pinto <jpinto@synopsys.com>
