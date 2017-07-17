From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 11/12] net: dsa: mv88e6xxx: add Energy Detect ops
Date: Mon, 17 Jul 2017 21:27:34 +0200
Message-ID: <20170717192734.GD9363@lunn.ch>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
 <20170717170346.19555-12-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170717170346.19555-12-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
> index 436668bd50dc..317ae89cfa68 100644
> --- a/drivers/net/dsa/mv88e6xxx/phy.c
> +++ b/drivers/net/dsa/mv88e6xxx/phy.c
> @@ -246,3 +246,99 @@ int mv88e6xxx_phy_setup(struct mv88e6xxx_chip *chip)
>  {
>  	return mv88e6xxx_phy_ppu_enable(chip);
>  }
> +
> +/* Page 0, Register 16: Copper Specific Control Register 1 */
> +
> +int mv88e6352_phy_energy_detect_read(struct mv88e6xxx_chip *chip, int phy,
> +				     struct ethtool_eee *eee)
> +{
> +	u16 val;
> +	int err;
> +
> +	err = mv88e6xxx_phy_read(chip, phy, MV88E6XXX_PHY_CSCTL1, &val);
> +	if (err)
> +		return err;
> +
> +	val &= MV88E6352_PHY_CSCTL1_ENERGY_DETECT_MASK;
> +
> +	eee->eee_enabled = false;
> +	eee->tx_lpi_enabled = false;
> +
> +	switch (val) {
> +	case MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_NLP:
> +		eee->tx_lpi_enabled = true;
> +		/* fall through... */
> +	case MV88E6352_PHY_CSCTL1_ENERGY_DETECT_SENSE_RCV:
> +		eee->eee_enabled = true;
> +	}
> +
> +	return 0;
> +}

Hi Vivien

I never liked this. I think it is architecturally wrong for the switch
to be poking around in the PHY. It should ask the PHY driver. This is
especially true for external PHYs which might not be a Marvell PHY.

   Andrew
