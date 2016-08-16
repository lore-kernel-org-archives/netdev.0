From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/6] net: dsa: mv88e6xxx: describe PHY page and
 SerDes
Date: Tue, 16 Aug 2016 03:16:18 +0200
Message-ID: <20160816011618.GL24664@lunn.ch>
References: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
 <20160815211902.2236-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160815211902.2236-6-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 15, 2016 at 05:19:01PM -0400, Vivien Didelot wrote:
> Add mv88e6xxx_phy_page_{read,write} routines and use them to access the
> SerDes PHY device registers.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c      | 95 +++++++++++++++++++++++++++++------
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 27 ++++++++--
>  2 files changed, 105 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 3b0bc88..faa0751 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -238,6 +238,74 @@ static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
>  	return chip->phy_ops->write(chip, addr, reg, val);
>  }
>  
> +static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
> +{
> +	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_PHY_PAGE))
> +		return -EOPNOTSUPP;
> +
> +	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
> +}
> +
> +static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
> +{
> +	int err;
> +
> +	/* Restore PHY page Copper 0x0 for access via the registered MDIO bus */
> +	err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, PHY_PAGE_COPPER);
> +	if (unlikely(err)) {
> +		dev_err(chip->dev, "failed to restore PHY %d page Copper (%d)\n",
> +			phy, err);
> +	}
> +}
> +
> +static int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
> +				   u8 page, int reg, u16 *val)
> +{
> +	int err;
> +
> +	/* There is no paging for registers 22 */
> +	if (reg == PHY_PAGE)
> +		return -EINVAL;

Hi Vivien

This whole paging scheme only works for internal PHYs, or external
PHYs which happen to be Marvell PHYs. We need to be a little bit
careful here and ensure these functions don't get used for external
PHYs when we don't know who manufactured them. 

At the moment the code is O.K, we only access SERDES or temperature
sensors for a given port. But i wounder if adding a comment would be
wise?

	Andrew
