From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: phy: micrel: fix crash when statistic requested
 for KSZ9031 phy
Date: Thu, 13 Apr 2017 20:51:41 +0200
Message-ID: <20170413185141.GA26229@lunn.ch>
References: <20170412225510.16885-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170412225510.16885-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 05:55:10PM -0500, Grygorii Strashko wrote:
> Now the command:
> 	ethtool --phy-statistics eth0
> will cause system crash with meassage "Unable to handle kernel NULL pointer
> dereference at virtual address 00000010" from:
> 
>  (kszphy_get_stats) from [<c069f1d8>] (ethtool_get_phy_stats+0xd8/0x210)
>  (ethtool_get_phy_stats) from [<c06a0738>] (dev_ethtool+0x5b8/0x228c)
>  (dev_ethtool) from [<c06b5484>] (dev_ioctl+0x3fc/0x964)
>  (dev_ioctl) from [<c0679f7c>] (sock_ioctl+0x170/0x2c0)
>  (sock_ioctl) from [<c02419d4>] (do_vfs_ioctl+0xa8/0x95c)
>  (do_vfs_ioctl) from [<c02422c4>] (SyS_ioctl+0x3c/0x64)
>  (SyS_ioctl) from [<c0107d60>] (ret_fast_syscall+0x0/0x44)
> 
> The reason: phy_driver structure for KSZ9031 phy has no .probe() callback
> defined. As result, struct phy_device *phydev->priv pointer will not be
> initializes (null).
> This issue will affect also following phys:
>  KSZ8795, KSZ886X, KSZ8873MLL, KSZ9031, KSZ9021, KSZ8061, KS8737
> 
> Fix it by:
> - adding .probe() = kszphy_probe() callback to KSZ9031, KSZ9021
> phys. The kszphy_probe() can be re-used as it doesn't do any phy specific
> settings.
> - removing statistic callbacks from other phys (KSZ8795, KSZ886X,
> KSZ8873MLL, KSZ8061, KS8737) as they doesn't have corresponding
> statistic counters.
> 
> Fixes: 2b2427d06426 ("phy: micrel: Add ethtool statistics counters")
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
> changes in v2:
>  - probe callback added to KSZ9031, KSZ9021
>  - statistic callback removed from KSZ8795, KSZ886X, KSZ8873MLL, KSZ8061, KS8737
> 
> Link on v1:
>  https://lkml.org/lkml/2017/4/10/1183
> 
>  drivers/net/phy/micrel.c | 18 ++----------------
>  1 file changed, 2 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 6742070..6f207e6 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -574,7 +574,6 @@ static int ksz9031_config_init(struct phy_device *phydev)
>  				MII_KSZ9031RN_TX_DATA_PAD_SKEW, 4,
>  				tx_data_skews, 4);
>  	}
> -
>  	return ksz9031_center_flp_timing(phydev);
>  }

Hi Grygorii

Whitespace changed like this should be in a separate patch, or not
made at all.

Otherwise, thanks for looking at the datasheets and fixing this up.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
