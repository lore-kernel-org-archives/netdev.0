From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 04/15] drivers: net: cpsw: ethtool: fix accessing to
 suspended device
Date: Wed, 15 Jun 2016 09:14:07 -0700
Message-ID: <57617ECF.2010902@gmail.com>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
 <20160615115603.4897-5-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, devicetree@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615115603.4897-5-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/15/2016 04:55 AM, Grygorii Strashko wrote:
> The CPSW might be suspended by RPM if all ethX interfaces are down,
> but it still could be accesible through ethtool interfce. In this case
> ethtool operations, requiring registers access, will cause L3 errors and
> CPSW crash.
> 
> Hence, fix it by adding RPM get/put calls in ethtool callbcaks which
> can access CPSW registers: .set_coalesce(), .get_ethtool_stats(),
> .set_pauseparam(), .get_regs()

Provided that you implement an ethtool_ops::begin, it will be called
before each ethtool operation runs, so that could allow you to eliminate
some of the duplication here. Conversely ethtool_ops::end terminates
each operation and can be used for that purpose.

> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 36 +++++++++++++++++++++++++++++++++++-
>  1 file changed, 35 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index ba81d4e..1ba0c09 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -931,6 +931,13 @@ static int cpsw_set_coalesce(struct net_device *ndev,
>  	u32 prescale = 0;
>  	u32 addnl_dvdr = 1;
>  	u32 coal_intvl = 0;
> +	int ret;
> +
> +	ret = pm_runtime_get_sync(&priv->pdev->dev);
> +	if (ret < 0) {
> +		pm_runtime_put_noidle(&priv->pdev->dev);
> +		return ret;
> +	}
>  
>  	coal_intvl = coal->rx_coalesce_usecs;
>  
> @@ -985,6 +992,8 @@ update_return:
>  		priv->coal_intvl = coal_intvl;
>  	}
>  
> +	pm_runtime_put(&priv->pdev->dev);
> +
>  	return 0;
>  }
>  
> @@ -1022,7 +1031,13 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
>  	struct cpdma_chan_stats tx_stats;
>  	u32 val;
>  	u8 *p;
> -	int i;
> +	int i, ret;
> +
> +	ret = pm_runtime_get_sync(&priv->pdev->dev);
> +	if (ret < 0) {
> +		pm_runtime_put_noidle(&priv->pdev->dev);
> +		return;
> +	}
>  
>  	/* Collect Davinci CPDMA stats for Rx and Tx Channel */
>  	cpdma_chan_get_stats(priv->rxch, &rx_stats);
> @@ -1049,6 +1064,8 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
>  			break;
>  		}
>  	}
> +
> +	pm_runtime_put(&priv->pdev->dev);
>  }
>  
>  static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
> @@ -1780,11 +1797,20 @@ static void cpsw_get_regs(struct net_device *ndev,
>  {
>  	struct cpsw_priv *priv = netdev_priv(ndev);
>  	u32 *reg = p;
> +	int ret;
> +
> +	ret = pm_runtime_get_sync(&priv->pdev->dev);
> +	if (ret < 0) {
> +		pm_runtime_put_noidle(&priv->pdev->dev);
> +		return;
> +	}
>  
>  	/* update CPSW IP version */
>  	regs->version = priv->version;
>  
>  	cpsw_ale_dump(priv->ale, reg);
> +
> +	pm_runtime_put(&priv->pdev->dev);
>  }
>  
>  static void cpsw_get_drvinfo(struct net_device *ndev,
> @@ -1902,12 +1928,20 @@ static int cpsw_set_pauseparam(struct net_device *ndev,
>  {
>  	struct cpsw_priv *priv = netdev_priv(ndev);
>  	bool link;
> +	int ret;
> +
> +	ret = pm_runtime_get_sync(&priv->pdev->dev);
> +	if (ret < 0) {
> +		pm_runtime_put_noidle(&priv->pdev->dev);
> +		return ret;
> +	}
>  
>  	priv->rx_pause = pause->rx_pause ? true : false;
>  	priv->tx_pause = pause->tx_pause ? true : false;
>  
>  	for_each_slave(priv, _cpsw_adjust_link, priv, &link);
>  
> +	pm_runtime_put(&priv->pdev->dev);
>  	return 0;
>  }
>  
> 


-- 
Florian
