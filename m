From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/1] ethtool : added
 get_phy_stats,get_strings,get_sset_count
Date: Mon, 27 Mar 2017 09:44:37 -0700
Message-ID: <5153db09-092f-55b1-a8fc-aa23433c52a0@gmail.com>
References: <1490609570-3571-1-git-send-email-thomasscariah@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: nsekhar@ti.com, grygorii.strashko@ti.com, davem@davemloft.net,
        drivshin@allworx.com, mugunthanvnm@ti.com,
        ivan.khoronzhuk@linaro.org, thomas.scariah@harman.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Thomas Scariah <thomasscariah@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35359 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751124AbdC0Qp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 12:45:57 -0400
In-Reply-To: <1490609570-3571-1-git-send-email-thomasscariah@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 03/27/2017 03:12 AM, Thomas Scariah wrote:
> From: "Scariah, Thomas" <thomas.scariah@harman.com>
> 
>  Added functions to support ethtool to print the phy statistics and error
>  information along with other ethtool statistics. This will help ethtool
>  information to know the error is from physical layer or MAC layer.
>  This is an enahancement for ethtool to accommodate phy statistics

It sounds like your patch should actually be 3 different patches:

- add helper function to the core PHY library
- add statistics support to the Micrel PHY driver
- hook the proper ndo operations in cpsw to allow querying the PHY
driver's statistics

> 
> Signed-off-by: Thomas Scariah <thomasscariah@gmail.com>
> ---
>  drivers/net/ethernet/ti/cpsw.c |   16 ++++++++++++-
>  drivers/net/phy/micrel.c       |   50 ++++++++++++++++++++++++++++++++++++++++
>  drivers/net/phy/phy.c          |   23 ++++++++++++++++++
>  include/linux/phy.h            |   14 +++++++++++
>  4 files changed, 102 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 3f48bb9..26d2dc5 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1001,9 +1001,16 @@ update_return:
>  
>  static int cpsw_get_sset_count(struct net_device *ndev, int sset)
>  {
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	int slave_no = cpsw_slave_index(priv);
> +	int count;
> +
>  	switch (sset) {
>  	case ETH_SS_STATS:
> -		return CPSW_STATS_LEN;
> +		count = CPSW_STATS_LEN;
> +		count += phy_ethtool_get_sset_count(priv->slaves[slave_no].phy,
> +						    sset);
> +		return count;
>  	default:
>  		return -EOPNOTSUPP;
>  	}

We already have a way to obtain PHY specific statistics through the
ETH_SS_PHY_STATS string set, cannot we use that here too? It certainly
makes it easier to overlay cpsw statistics with PHY device statistics,
but when Andrew added support for that, AFAIR this was made
intentionally separate.

> @@ -1011,6 +1018,8 @@ static int cpsw_get_sset_count(struct net_device *ndev, int sset)
>  
>  static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
>  {
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	int slave_no = cpsw_slave_index(priv);
>  	u8 *p = data;
>  	int i;
>  
> @@ -1021,6 +1030,8 @@ static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
>  			       ETH_GSTRING_LEN);
>  			p += ETH_GSTRING_LEN;
>  		}
> +		phy_ethtool_get_strings(priv->slaves[slave_no].phy,
> +					stringset, p);

Same here.

>  		break;
>  	}
>  }
> @@ -1031,6 +1042,7 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
>  	struct cpsw_priv *priv = netdev_priv(ndev);
>  	struct cpdma_chan_stats rx_stats;
>  	struct cpdma_chan_stats tx_stats;
> +	int slave_no = cpsw_slave_index(priv);
>  	u32 val;
>  	u8 *p;
>  	int i, ret;
> @@ -1067,6 +1079,8 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
>  		}
>  	}
>  
> +	phy_ethtool_get_stats(priv->slaves[slave_no].phy, stats,
> +			      &data[CPSW_STATS_LEN]);

And here.

>  	pm_runtime_put(&priv->pdev->dev);
>  }
>  


-- 
Florian
