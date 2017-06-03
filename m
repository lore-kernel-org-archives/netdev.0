From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 2/7] net: pch_gbe: Pull PHY GPIO handling out of
 Minnow code
Date: Sat, 3 Jun 2017 19:52:00 +0200
Message-ID: <20170603175200.GC17099@lunn.ch>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
 <20170602234042.22782-3-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>,
        "David S . Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>, linux-mips@linux-mips.org,
        Eric Dumazet <edumazet@google.com>
To: Paul Burton <paul.burton@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35436 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750991AbdFCRwG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Jun 2017 13:52:06 -0400
Content-Disposition: inline
In-Reply-To: <20170602234042.22782-3-paul.burton@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 02, 2017 at 04:40:37PM -0700, Paul Burton wrote:
> The MIPS Boston development board uses the Intel EG20T Platform
> Controller Hub, including its gigabit ethernet controller, and requires
> that its RTL8211E PHY be reset much like the Minnow platform. Pull the
> PHY reset GPIO handling out of Minnow-specific code such that it can be
> shared by later patches.
> 
> Signed-off-by: Paul Burton <paul.burton@imgtec.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jarod Wilson <jarod@redhat.com>
> Cc: Tobias Klauser <tklauser@distanz.ch>
> Cc: linux-mips@linux-mips.org
> Cc: netdev@vger.kernel.org
> ---
> 
> Changes in v3:
> - Use adapter->pdata as arg to platform_init, to fix bisectability.
> 
> Changes in v2: None
> 
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |  4 ++-
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 33 +++++++++++++++-------
>  2 files changed, 26 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> index 8d710a3b4db0..de1dd08050f4 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> @@ -580,15 +580,17 @@ struct pch_gbe_hw_stats {
>  
>  /**
>   * struct pch_gbe_privdata - PCI Device ID driver data
> + * @phy_reset_gpio:		PHY reset GPIO descriptor.
>   * @phy_tx_clk_delay:		Bool, configure the PHY TX delay in software
>   * @phy_disable_hibernate:	Bool, disable PHY hibernation
>   * @platform_init:		Platform initialization callback, called from
>   *				probe, prior to PHY initialization.
>   */
>  struct pch_gbe_privdata {
> +	struct gpio_desc *phy_reset_gpio;
>  	bool phy_tx_clk_delay;
>  	bool phy_disable_hibernate;
> -	int (*platform_init)(struct pci_dev *pdev);
> +	int (*platform_init)(struct pci_dev *, struct pch_gbe_privdata *);
>  };
>  
>  /**
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index d38198718005..cb9b904786e4 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -360,6 +360,16 @@ static void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
>  	pch_gbe_wait_clr_bit(&hw->reg->ADDR_MASK, PCH_GBE_BUSY);
>  }
>  
> +static void pch_gbe_phy_set_reset(struct pch_gbe_hw *hw, int value)
> +{
> +	struct pch_gbe_adapter *adapter = pch_gbe_hw_to_adapter(hw);
> +
> +	if (!adapter->pdata || !adapter->pdata->phy_reset_gpio)
> +		return;
> +
> +	gpiod_set_value(adapter->pdata->phy_reset_gpio, value);

Hi Paul

Since you are using the gpiod_ API, the core will take notice of the
active low/active high flag when performing this set.

> +}
> +
>  /**
>   * pch_gbe_mac_reset_hw - Reset hardware
>   * @hw:	Pointer to the HW structure
>  
>  	ret = devm_gpio_request_one(&pdev->dev, gpio, flags,
>  				    "minnow_phy_reset");
> -	if (ret) {
> +	if (!ret)
> +		pdata->phy_reset_gpio = gpio_to_desc(gpio);

Here however, you are using the gpio_ API, which ignores the active
high/low flag in device tree. And in your binding patch, you give the
example:

+               phy-reset-gpios = <&eg20t_gpio 6
+                                  GPIO_ACTIVE_LOW>;

This active low is totally ignored.

I personally would say this is all messed up, and going to result in
problems for somebody with a board which actually needs an
GPIO_ACTIVE_HIGH.

Please use the gpiod_ API through out and respect the flags in the
device tree binding.

       Andrew
