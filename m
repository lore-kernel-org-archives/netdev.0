From: Vladimir Zapolskiy <vz@mleia.com>
Subject: Re: [PATCH v2] net: lpc_eth: Check clk_prepare_enable() error
Date: Tue, 23 Aug 2016 14:55:54 +0300
Message-ID: <026272b3-c839-6e67-c758-61145ea2bab1@mleia.com>
References: <1471948683-29129-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mleia.com ([178.79.152.223]:48223 "EHLO mail.mleia.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751621AbcHWL4w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 07:56:52 -0400
In-Reply-To: <1471948683-29129-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fabio,

On 23.08.2016 13:38, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> clk_prepare_enable() may fail, so we should better check its return
> value and propagate it in the case of failure
> 
> While at it, replace __lpc_eth_clock_enable() with a plain
> clk_prepare_enable/clk_disable_unprepare() call in order to
> simplify the code.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
> ---
> Changes since v1:
> - Replace __lpc_eth_clock_enable() with a plain
> clk_prepare_enable/clk_disable_unprepare() call (Vladimir)
> 
>  drivers/net/ethernet/nxp/lpc_eth.c | 19 ++++++++-----------
>  1 file changed, 8 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
> index 4d4ecba..cda87ba 100644
> --- a/drivers/net/ethernet/nxp/lpc_eth.c
> +++ b/drivers/net/ethernet/nxp/lpc_eth.c
> @@ -475,14 +475,6 @@ static void __lpc_get_mac(struct netdata_local *pldat, u8 *mac)
>  	mac[5] = tmp >> 8;
>  }
>  
> -static void __lpc_eth_clock_enable(struct netdata_local *pldat, bool enable)
> -{
> -	if (enable)
> -		clk_prepare_enable(pldat->clk);
> -	else
> -		clk_disable_unprepare(pldat->clk);
> -}
> -
>  static void __lpc_params_setup(struct netdata_local *pldat)
>  {
>  	u32 tmp;
> @@ -1056,7 +1048,7 @@ static int lpc_eth_close(struct net_device *ndev)
>  	writel(0, LPC_ENET_MAC2(pldat->net_base));
>  	spin_unlock_irqrestore(&pldat->lock, flags);
>  
> -	__lpc_eth_clock_enable(pldat, false);
> +	clk_disable_unprepare(pldat->clk);
>  
>  	return 0;
>  }
> @@ -1197,11 +1189,14 @@ static int lpc_eth_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
>  static int lpc_eth_open(struct net_device *ndev)
>  {
>  	struct netdata_local *pldat = netdev_priv(ndev);
> +	int ret;
>  
>  	if (netif_msg_ifup(pldat))
>  		dev_dbg(&pldat->pdev->dev, "enabling %s\n", ndev->name);
>  
> -	__lpc_eth_clock_enable(pldat, true);
> +	ret = clk_prepare_enable(pldat->clk);
> +	if (ret)
> +		return ret;
>  
>  	/* Suspended PHY makes LPC ethernet core block, so resume now */
>  	phy_resume(ndev->phydev);
> @@ -1320,7 +1315,9 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
>  	}
>  
>  	/* Enable network clock */
> -	__lpc_eth_clock_enable(pldat, true);
> +	ret = clk_prepare_enable(pldat->clk);
> +	if (ret)
> +		goto err_out_free_dev;
>  
>  	/* Map IO space */
>  	pldat->net_base = ioremap(res->start, resource_size(res));
> 

sorry for nitpicking, would you mind to send v3 with a clk_put(pldat->clk)
resource release call on newly added error path?

In advance if it is done, please feel free to add my

Acked-by: Vladimir Zapolskiy <vz@mleia.com>

Thank you for the fix!
