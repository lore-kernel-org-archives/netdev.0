From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] net: phy: Don't use drv when it is NULL in
 phy_attached_print
Date: Mon, 21 Aug 2017 15:16:04 +0200
Message-ID: <20170821131604.GA1703@lunn.ch>
References: <20170821075235.28473-1-romain.perier@collabora.com>
 <20170821075235.28473-3-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Romain Perier <romain.perier@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170821075235.28473-3-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 09:52:35AM +0200, Romain Perier wrote:
> Currently, if this logging function is used prior the phy driver is
> binded to the phy device (that is usually done from .ndo_open),
> 'phydev->drv' might be NULL, resulting in a kernel crash. That is
> typically the case in the stmmac driver, info about the phy is displayed
> during the registration of the MDIO bus, and then genphy driver is binded
> to this phydev when .ndo_open is called.
> 
> This commit fixes the issue by using the right genphy driver, when
> phydev->drv is NULL.
> 
> Fixes: commit fbca164776e4 ("net: stmmac: Use the right logging functi")
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
>  drivers/net/phy/phy_device.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 9493fb369682..b38926bc275f 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -877,15 +877,24 @@ EXPORT_SYMBOL(phy_attached_info);
>  #define ATTACHED_FMT "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)"
>  void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
>  {
> +	struct phy_driver *drv = phydev->drv;
> +
> +	if (!drv) {
> +		if (phydev->is_c45)
> +			drv = &genphy_10g_driver;
> +		else
> +			drv = &genphy_driver;
> +	}

Hi Romain

I don't like this. You end up with the same code twice. c45 does not
imply 10g, so i would not be surprised if sometime in the future this
changes. And then we have two places we need to make the same change.

I also wonder what happens if you load the PHY driver later, but
before it is bound. Will it then use the correct driver?


> +
>  	if (!fmt) {
>  		dev_info(&phydev->mdio.dev, ATTACHED_FMT "\n",
> -			 phydev->drv->name, phydev_name(phydev),
> +			 drv->name, phydev_name(phydev),

I would prefer (phydev->drv ? phydev->drv->name, "unknown")

  Andrew
