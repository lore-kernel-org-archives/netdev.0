From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next v2 1/2] net: tc35815: Fix build error due to missed
 API change
Date: Sun, 10 Jan 2016 16:46:44 +0100
Message-ID: <20160110154644.GC22229@lunn.ch>
References: <1452438645-29440-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452438645-29440-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2016 at 07:10:44AM -0800, Guenter Roeck wrote:
> Commit 7f854420fbfe ("phy: Add API for {un}registering an mdio device to
> a bus") introduces an API to access mii_bus structures, but missed to
> update the tc35815 driver. This results in the following error message.
> 
> drivers/net/ethernet/toshiba/tc35815.c: In function 'tc_mii_probe':
> drivers/net/ethernet/toshiba/tc35815.c:617:18: error:
> 	'struct mii_bus' has no member named 'phy_map'
> drivers/net/ethernet/toshiba/tc35815.c:623:24: error:
> 	'struct mii_bus' has no member named 'phy_map'
> 
> Instead of looping over the list of phy addresses to find a phy chip,
> use phy_find_first(). While the intent of the original code was to return
> an error if more than one phy was specified, this code path was never
> executed because the loop aborted after finding the first phy. The
> original code is therefore semantically identical to phy_find_first(),
> thus it is simpler and more straightforward to use phy_find_first()
> directly.
> 
> Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
> v2: Use phy_find_first() instead of open-coding it.
> 
>  drivers/net/ethernet/toshiba/tc35815.c | 17 ++---------------
>  1 file changed, 2 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
> index fed5e3dfbc8f..71efe0092bec 100644
> --- a/drivers/net/ethernet/toshiba/tc35815.c
> +++ b/drivers/net/ethernet/toshiba/tc35815.c
> @@ -608,23 +608,10 @@ static void tc_handle_link_change(struct net_device *dev)
>  static int tc_mii_probe(struct net_device *dev)
>  {
>  	struct tc35815_local *lp = netdev_priv(dev);
> -	struct phy_device *phydev = NULL;
> -	int phy_addr;
> +	struct phy_device *phydev;
>  	u32 dropmask;
>  
> -	/* find the first phy */
> -	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
> -		if (lp->mii_bus->phy_map[phy_addr]) {
> -			if (phydev) {
> -				printk(KERN_ERR "%s: multiple PHYs found\n",
> -				       dev->name);
> -				return -EINVAL;
> -			}
> -			phydev = lp->mii_bus->phy_map[phy_addr];
> -			break;
> -		}
> -	}
> -
> +	phydev = phy_find_first(lp->mii_bus);
>  	if (!phydev) {
>  		printk(KERN_ERR "%s: no PHY found\n", dev->name);
>  		return -ENODEV;
> -- 
> 2.1.4
> 
