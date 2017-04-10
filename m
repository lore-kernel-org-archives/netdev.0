From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: micrel: KSZ9031: fix crash when statistic
 requested
Date: Mon, 10 Apr 2017 16:40:37 -0700
Message-ID: <e821198e-5a61-7912-d120-205f66c02650@gmail.com>
References: <20170410233324.1178-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170410233324.1178-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/10/2017 04:33 PM, Grygorii Strashko wrote:
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

This is a strange way to fix the problem, presumably this PHY supports
fetching statistics, if that is the case it sounds like we would want to
sort of provide two probe function:

- one which is just allocating the PHY device's private structure so we
have enough room for statistics
- another one which is doing all the reference clock fetching and so on

By adding a NULL pointer check here, you'd be better off just removing
all the function pointers pertaining to ethtool statistics.

> 
> Fix it by adding additional checks for !phydev->priv in
> kszphy_get_stats(), kszphy_get_strings() and kszphy_get_sset_count()
> 
> Fixes: 2b2427d06426 ("phy: micrel: Add ethtool statistics counters")
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>  drivers/net/phy/micrel.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 6742070..8dbc1be 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -574,7 +574,6 @@ static int ksz9031_config_init(struct phy_device *phydev)
>  				MII_KSZ9031RN_TX_DATA_PAD_SKEW, 4,
>  				tx_data_skews, 4);
>  	}
> -
>  	return ksz9031_center_flp_timing(phydev);
>  }
>  
> @@ -654,6 +653,9 @@ ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
>  
>  static int kszphy_get_sset_count(struct phy_device *phydev)
>  {
> +	if (!phydev->priv)
> +		return -EOPNOTSUPP;
> +
>  	return ARRAY_SIZE(kszphy_hw_stats);
>  }
>  
> @@ -661,6 +663,9 @@ static void kszphy_get_strings(struct phy_device *phydev, u8 *data)
>  {
>  	int i;
>  
> +	if (!phydev->priv)
> +		return;
> +
>  	for (i = 0; i < ARRAY_SIZE(kszphy_hw_stats); i++) {
>  		memcpy(data + i * ETH_GSTRING_LEN,
>  		       kszphy_hw_stats[i].string, ETH_GSTRING_LEN);
> @@ -694,6 +699,9 @@ static void kszphy_get_stats(struct phy_device *phydev,
>  {
>  	int i;
>  
> +	if (!phydev->priv)
> +		return;
> +
>  	for (i = 0; i < ARRAY_SIZE(kszphy_hw_stats); i++)
>  		data[i] = kszphy_get_stat(phydev, i);
>  }
> 


-- 
Florian
