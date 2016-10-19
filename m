From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH (net.git)] stmmac: fix and review the ptp registration.
Date: Wed, 19 Oct 2016 10:47:42 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610191045130.25105@knanqh.ubzr>
References: <1476860801-28242-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        linux-kernel@vger.kernel.org,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Rayagond Kokatanur <rayagond@vayavyalabs.com>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Richard Cochran <richardcochran@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476860801-28242-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ added Richard to CC ]

On Wed, 19 Oct 2016, Giuseppe Cavallaro wrote:

> The commit commit 7086605a6ab5 ("stmmac: fix error check when init ptp")
> breaks the procedure added by the
> commit efee95f42b5d ("ptp_clock: future-proofing drivers against PTP
> subsystem becoming optional")
> 
> So this patch tries to re-import the logic added by the latest
> commit above: it makes sense to have the stmmac_ptp_register
> as void function and, inside the main, the stmmac_init_ptp can fails
> in case of the capability cannot be supported by the HW.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Alexandre TORGUE <alexandre.torgue@st.com>
> Cc: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Nicolas Pitre <nico@linaro.org>

Acked-by: Nicolas Pitre <nico@linaro.org>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  2 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  6 ++++--
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c  | 15 ++++-----------
>  3 files changed, 9 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index 8dc9056..b15fc55 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -145,7 +145,7 @@ int stmmac_mdio_register(struct net_device *ndev);
>  int stmmac_mdio_reset(struct mii_bus *mii);
>  void stmmac_set_ethtool_ops(struct net_device *netdev);
>  
> -int stmmac_ptp_register(struct stmmac_priv *priv);
> +void stmmac_ptp_register(struct stmmac_priv *priv);
>  void stmmac_ptp_unregister(struct stmmac_priv *priv);
>  int stmmac_resume(struct device *dev);
>  int stmmac_suspend(struct device *dev);
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 6c85b61..48e71fa 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -676,7 +676,9 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
>  	priv->hwts_tx_en = 0;
>  	priv->hwts_rx_en = 0;
>  
> -	return stmmac_ptp_register(priv);
> +	stmmac_ptp_register(priv);
> +
> +	return 0;
>  }
>  
>  static void stmmac_release_ptp(struct stmmac_priv *priv)
> @@ -1710,7 +1712,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
>  	if (init_ptp) {
>  		ret = stmmac_init_ptp(priv);
>  		if (ret)
> -			netdev_warn(priv->dev, "PTP support cannot init.\n");
> +			netdev_warn(priv->dev, "fail to init PTP.\n");
>  	}
>  
>  #ifdef CONFIG_DEBUG_FS
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
> index 5d61fb2..1477471 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
> @@ -177,7 +177,7 @@ static struct ptp_clock_info stmmac_ptp_clock_ops = {
>   * Description: this function will register the ptp clock driver
>   * to kernel. It also does some house keeping work.
>   */
> -int stmmac_ptp_register(struct stmmac_priv *priv)
> +void stmmac_ptp_register(struct stmmac_priv *priv)
>  {
>  	spin_lock_init(&priv->ptp_lock);
>  	priv->ptp_clock_ops = stmmac_ptp_clock_ops;
> @@ -185,17 +185,10 @@ int stmmac_ptp_register(struct stmmac_priv *priv)
>  	priv->ptp_clock = ptp_clock_register(&priv->ptp_clock_ops,
>  					     priv->device);
>  	if (IS_ERR(priv->ptp_clock)) {
> -		int ret = PTR_ERR(priv->ptp_clock);
> -
> +		netdev_err(priv->dev, "ptp_clock_register failed\n");
>  		priv->ptp_clock = NULL;
> -		return ret;
> -	}
> -
> -	spin_lock_init(&priv->ptp_lock);
> -
> -	netdev_dbg(priv->dev, "Added PTP HW clock successfully\n");
> -
> -	return 0;
> +	} else if (priv->ptp_clock)
> +		netdev_info(priv->dev, "registered PTP clock\n");
>  }
>  
>  /**
> -- 
> 2.7.4
> 
> 
