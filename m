From: Vladimir Zapolskiy <vz@mleia.com>
Subject: Re: [PATCH] net: lpc_eth: Check clk_prepare_enable() error
Date: Tue, 23 Aug 2016 10:19:58 +0300
Message-ID: <e477ea4c-864c-4288-72c4-6029eed94140@mleia.com>
References: <1471917678-9130-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mleia.com ([178.79.152.223]:47128 "EHLO mail.mleia.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756561AbcHWH33 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 03:29:29 -0400
In-Reply-To: <1471917678-9130-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fabio,

On 23.08.2016 05:01, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> clk_prepare_enable() may fail, so we should better check its return
> value and propagate it in the case of failure.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
> ---
>  drivers/net/ethernet/nxp/lpc_eth.c | 29 ++++++++++++++++++++++-------
>  1 file changed, 22 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
> index 4d4ecba..7c796f7 100644
> --- a/drivers/net/ethernet/nxp/lpc_eth.c
> +++ b/drivers/net/ethernet/nxp/lpc_eth.c
> @@ -475,12 +475,19 @@ static void __lpc_get_mac(struct netdata_local *pldat, u8 *mac)
>  	mac[5] = tmp >> 8;
>  }
>  
> -static void __lpc_eth_clock_enable(struct netdata_local *pldat, bool enable)
> +static int __lpc_eth_clock_enable(struct netdata_local *pldat, bool enable)
>  {
> -	if (enable)
> -		clk_prepare_enable(pldat->clk);
> -	else
> +	int ret;
> +
> +	if (enable) {
> +		ret = clk_prepare_enable(pldat->clk);
> +		if (ret)
> +			return ret;
> +	} else {
>  		clk_disable_unprepare(pldat->clk);
> +	}
> +
> +	return 0;
>  }

The change is correct, but let me ask you to replace all instances of
__lpc_eth_clock_enable() with plain clk_prepare_enable() or
clk_disable_unprepare(). It should save one redundant error check also.
