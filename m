From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/5] dpaa_eth: move of_phy_connect() to the eth driver
Date: Sun, 15 Oct 2017 20:33:49 +0200
Message-ID: <20171015183349.GD6374@lunn.ch>
References: <1507906212-10076-1-git-send-email-madalin.bucur@nxp.com>
 <1507906212-10076-3-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, junote@outlook.com,
        linux-kernel@vger.kernel.org
To: Madalin Bucur <madalin.bucur@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507906212-10076-3-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 13, 2017 at 05:50:09PM +0300, Madalin Bucur wrote:
> Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
> ---
>  drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 48 +++++++++++--
>  drivers/net/ethernet/freescale/fman/mac.c      | 97 ++++++--------------------
>  drivers/net/ethernet/freescale/fman/mac.h      |  5 +-
>  3 files changed, 66 insertions(+), 84 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> index 4225806..7cf61d6 100644
> --- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> @@ -2435,6 +2435,48 @@ static void dpaa_eth_napi_disable(struct dpaa_priv *priv)
>  	}
>  }
>  
> +static void dpaa_adjust_link(struct net_device *net_dev)
> +{
> +	struct mac_device *mac_dev;
> +	struct dpaa_priv *priv;
> +
> +	priv = netdev_priv(net_dev);
> +	mac_dev = priv->mac_dev;
> +	mac_dev->adjust_link(mac_dev);
> +}
> +
> +static int dpaa_phy_init(struct net_device *net_dev)
> +{
> +	struct mac_device *mac_dev;
> +	struct phy_device *phy_dev;
> +	struct dpaa_priv *priv;
> +
> +	priv = netdev_priv(net_dev);
> +	mac_dev = priv->mac_dev;
> +
> +	phy_dev = of_phy_connect(net_dev, mac_dev->phy_node,
> +				 &dpaa_adjust_link, 0,
> +				 mac_dev->phy_if);
> +	if (!phy_dev) {
> +		netif_err(priv, ifup, net_dev, "init_phy() failed\n");
> +		return -ENODEV;
> +	}
> +
> +	/* Remove any features not supported by the controller */
> +	phy_dev->supported &= mac_dev->if_support;
> +
> +	/* Enable the symmetric and asymmetric PAUSE frame advertisements,
> +	 * as most of the PHY drivers do not enable them by default.
> +	 */

Hi Madalin

This is just moving code around, so the patch is O.K. However, it
would be nice to have a followup patch. This comment is wrong. The phy
driver should never enable symmetric and asymmetric PAUSE frames. The
MAC needs to, because only the MAC knows if the MAC supports pause
frames.

	Andrew
