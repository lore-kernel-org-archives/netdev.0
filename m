From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 01/10] net: stmmac: Enable stmmac main clock when probing
 hardware
Date: Mon, 9 Dec 2013 08:14:45 +0100
Message-ID: <52A56DE5.5010206@st.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-2-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org,
 Srinivas Kandagatla <srinivas.kandagatla@st.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Rob Herring <rob.herring@calxeda.com>,
 linux-sunxi@googlegroups.com, Maxime Ripard <maxime.ripard@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1386350983-13281-2-git-send-email-wens@csie.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello Chen-Yu

On 12/6/2013 6:29 PM, Chen-Yu Tsai wrote:
> Signed-off-by: Chen-Yu Tsai <wens@csie.org>
> ---
>
> Guiseppe previously stated that the "stmmaceth" clock is the
> main clock that drives the IP. The stmmac driver does not
> enable this clock during the probe phase. When the driver is
> built in to the kernel, this is fine because the clock maybe
> on by default, or the boot loader had enabled it.
>
> If stmmac is built as a module, when the module is loaded,
> the clock may be found unused and disabled by the kernel.

the clk_prepare_enable is then called in the open.
Is it not working for you?
Do you mean that the stmmac_hw_init fails if you do not move
the clk_get and clk_prepare_enable on top of the stmmac_dvr_probe?

Peppe

>
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 24 +++++++++++++----------
>   1 file changed, 14 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 8d4ccd3..7da71ed 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2688,10 +2688,17 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>   	if ((phyaddr >= 0) && (phyaddr <= 31))
>   		priv->plat->phy_addr = phyaddr;
>
> +	priv->stmmac_clk = clk_get(priv->device, STMMAC_RESOURCE_NAME);
> +	if (IS_ERR(priv->stmmac_clk)) {
> +		pr_warn("%s: warning: cannot get CSR clock\n", __func__);
> +		goto error_clk_get;
> +	}
> +	clk_prepare_enable(priv->stmmac_clk);
> +
>   	/* Init MAC and get the capabilities */
>   	ret = stmmac_hw_init(priv);
>   	if (ret)
> -		goto error_free_netdev;
> +		goto error_hw_init;
>
>   	ndev->netdev_ops = &stmmac_netdev_ops;
>
> @@ -2729,12 +2736,6 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>   		goto error_netdev_register;
>   	}
>
> -	priv->stmmac_clk = clk_get(priv->device, STMMAC_RESOURCE_NAME);
> -	if (IS_ERR(priv->stmmac_clk)) {
> -		pr_warn("%s: warning: cannot get CSR clock\n", __func__);
> -		goto error_clk_get;
> -	}
> -
>   	/* If a specific clk_csr value is passed from the platform
>   	 * this means that the CSR Clock Range selection cannot be
>   	 * changed at run-time and it is fixed. Viceversa the driver'll try to
> @@ -2759,15 +2760,18 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>   		}
>   	}
>
> +	clk_disable_unprepare(priv->stmmac_clk);
> +
>   	return priv;
>
>   error_mdio_register:
> -	clk_put(priv->stmmac_clk);
> -error_clk_get:
>   	unregister_netdev(ndev);
>   error_netdev_register:
>   	netif_napi_del(&priv->napi);
> -error_free_netdev:
> +error_hw_init:
> +	clk_disable_unprepare(priv->stmmac_clk);
> +	clk_put(priv->stmmac_clk);
> +error_clk_get:
>   	free_netdev(ndev);
>
>   	return NULL;
>
