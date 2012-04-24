From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH V2 6/9] net/stmmac: Remove conditional compilation of
 clk code
Date: Tue, 24 Apr 2012 08:16:49 +0200
Message-ID: <4F964551.4050507@st.com>
References: <cover.1335246730.git.viresh.kumar@st.com> <4336df4e231467d253e25bbd41dbce6d189ed1e8.1335246730.git.viresh.kumar@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, mturquette@linaro.org,
	sshtylyov@mvista.com, jgarzik@redhat.com, linux@arm.linux.org.uk,
	spear-devel@list.st.com, viresh.linux@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>
To: Viresh KUMAR <viresh.kumar@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4336df4e231467d253e25bbd41dbce6d189ed1e8.1335246730.git.viresh.kumar@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/24/2012 7:56 AM, Viresh KUMAR wrote:
> With addition of dummy clk_*() calls for non CONFIG_HAVE_CLK cases in clk.h,
> there is no need to have clk code enclosed in #ifdef CONFIG_HAVE_CLK, #endif
> macros.

Hello Viresh

patch only applies fine against the net-next repository so on top of the
diver version: March_2012 and it builds fine on arch w/ w/o HAVE_CLK
(just tested).

Thanks a lot.

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> Signed-off-by: Viresh Kumar <viresh.kumar@st.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   41 ---------------------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   31 ++++++++++------
>  2 files changed, 19 insertions(+), 53 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> index db2de9a..7f85895 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
> @@ -81,9 +81,7 @@ struct stmmac_priv {
>  	struct stmmac_counters mmc;
>  	struct dma_features dma_cap;
>  	int hw_cap_support;
> -#ifdef CONFIG_HAVE_CLK
>  	struct clk *stmmac_clk;
> -#endif
>  	int clk_csr;
>  };
>  
> @@ -103,42 +101,3 @@ int stmmac_dvr_remove(struct net_device *ndev);
>  struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>  				     struct plat_stmmacenet_data *plat_dat,
>  				     void __iomem *addr);
> -
> -#ifdef CONFIG_HAVE_CLK
> -static inline int stmmac_clk_enable(struct stmmac_priv *priv)
> -{
> -	if (!IS_ERR(priv->stmmac_clk))
> -		return clk_enable(priv->stmmac_clk);
> -
> -	return 0;
> -}
> -
> -static inline void stmmac_clk_disable(struct stmmac_priv *priv)
> -{
> -	if (IS_ERR(priv->stmmac_clk))
> -		return;
> -
> -	clk_disable(priv->stmmac_clk);
> -}
> -static inline int stmmac_clk_get(struct stmmac_priv *priv)
> -{
> -	priv->stmmac_clk = clk_get(priv->device, NULL);
> -
> -	if (IS_ERR(priv->stmmac_clk))
> -		return PTR_ERR(priv->stmmac_clk);
> -
> -	return 0;
> -}
> -#else
> -static inline int stmmac_clk_enable(struct stmmac_priv *priv)
> -{
> -	return 0;
> -}
> -static inline void stmmac_clk_disable(struct stmmac_priv *priv)
> -{
> -}
> -static inline int stmmac_clk_get(struct stmmac_priv *priv)
> -{
> -	return 0;
> -}
> -#endif /* CONFIG_HAVE_CLK */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 1a4cf81..18ce287 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -28,6 +28,7 @@
>  	https://bugzilla.stlinux.com/
>  *******************************************************************************/
>  
> +#include <linux/clk.h>
>  #include <linux/kernel.h>
>  #include <linux/interrupt.h>
>  #include <linux/ip.h>
> @@ -165,7 +166,6 @@ static void stmmac_verify_args(void)
>  
>  static void stmmac_clk_csr_set(struct stmmac_priv *priv)
>  {
> -#ifdef CONFIG_HAVE_CLK
>  	u32 clk_rate;
>  
>  	if (IS_ERR(priv->stmmac_clk))
> @@ -192,7 +192,6 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
>  	   * we can not estimate the proper divider as it is not known
>  	   * the frequency of clk_csr_i. So we do not change the default
>  	   * divider. */
> -#endif
>  }
>  
>  #if defined(STMMAC_XMIT_DEBUG) || defined(STMMAC_RX_DEBUG)
> @@ -971,7 +970,8 @@ static int stmmac_open(struct net_device *dev)
>  	} else
>  		priv->tm->enable = 1;
>  #endif
> -	stmmac_clk_enable(priv);
> +	if (!IS_ERR(priv->stmmac_clk))
> +		clk_enable(priv->stmmac_clk);
>  
>  	stmmac_check_ether_addr(priv);
>  
> @@ -1075,7 +1075,8 @@ open_error:
>  	if (priv->phydev)
>  		phy_disconnect(priv->phydev);
>  
> -	stmmac_clk_disable(priv);
> +	if (!IS_ERR(priv->stmmac_clk))
> +		clk_disable(priv->stmmac_clk);
>  
>  	return ret;
>  }
> @@ -1128,7 +1129,9 @@ static int stmmac_release(struct net_device *dev)
>  #ifdef CONFIG_STMMAC_DEBUG_FS
>  	stmmac_exit_fs();
>  #endif
> -	stmmac_clk_disable(priv);
> +
> +	if (!IS_ERR(priv->stmmac_clk))
> +		clk_disable(priv->stmmac_clk);
>  
>  	return 0;
>  }
> @@ -1925,7 +1928,8 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>  		goto error;
>  	}
>  
> -	if (stmmac_clk_get(priv))
> +	priv->stmmac_clk = clk_get(priv->device, NULL);
> +	if (IS_ERR(priv->stmmac_clk))
>  		pr_warning("%s: warning: cannot get CSR clock\n", __func__);
>  
>  	/* If a specific clk_csr value is passed from the platform
> @@ -1934,10 +1938,12 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>  	 * set the MDC clock dynamically according to the csr actual
>  	 * clock input.
>  	 */
> -	if (!priv->plat->clk_csr)
> -		stmmac_clk_csr_set(priv);
> -	else
> +	if (!priv->plat->clk_csr) {
> +		if (!IS_ERR(priv->stmmac_clk))
> +			stmmac_clk_csr_set(priv);
> +	} else {
>  		priv->clk_csr = priv->plat->clk_csr;
> +	}
>  
>  	/* MDIO bus Registration */
>  	ret = stmmac_mdio_register(ndev);
> @@ -2020,7 +2026,8 @@ int stmmac_suspend(struct net_device *ndev)
>  	else {
>  		stmmac_set_mac(priv->ioaddr, false);
>  		/* Disable clock in case of PWM is off */
> -		stmmac_clk_disable(priv);
> +		if (!IS_ERR(priv->stmmac_clk))
> +			clk_disable(priv->stmmac_clk);
>  	}
>  	spin_unlock(&priv->lock);
>  	return 0;
> @@ -2042,9 +2049,9 @@ int stmmac_resume(struct net_device *ndev)
>  	 * from another devices (e.g. serial console). */
>  	if (device_may_wakeup(priv->device))
>  		priv->hw->mac->pmt(priv->ioaddr, 0);
> -	else
> +	else if (!IS_ERR(priv->stmmac_clk))
>  		/* enable the clk prevously disabled */
> -		stmmac_clk_enable(priv);
> +			clk_enable(priv->stmmac_clk);
>  
>  	netif_device_attach(ndev);
>  
