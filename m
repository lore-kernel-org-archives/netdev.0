From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 12/14] net: ethernet: ti: cpsw: fix int dbg message
Date: Sat, 06 Aug 2016 13:24:41 -0700
Message-ID: <1470515081.28648.20.camel@perches.com>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
	 <1470480524-6851-13-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-13-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-08-06 at 13:48 +0300, Ivan Khoronzhuk wrote:
> While poll handlers there is no possibility to figure out
> which network device is handling packets, as cpdma channels
> are common for both network devices in dual_emac mode. Currently,
> the messages are printed only for one device, in fact, there is two.
> So, better to print integrated num_tx value for both devices if
> any of them is allowed to.
[]
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
[]
> @@ -378,6 +378,7 @@ struct cpsw_common {
>  	bool				rx_irq_disabled;
>  	bool				tx_irq_disabled;
>  	u32 irqs_table[IRQ_NUM];
> +	int				intr_dbg_msg;

Looks like this should be bool and should
be placed after tx_irq_disabled

[]

> @@ -1848,8 +1853,35 @@ static u32 cpsw_get_msglevel(struct net_device *ndev)
>  
>  static void cpsw_set_msglevel(struct net_device *ndev, u32 value)
>  {
> +	int i;
> +	struct cpsw_priv *sl_priv;
>  	struct cpsw_priv *priv = netdev_priv(ndev);
> +	struct cpsw_common *cpsw = priv->cpsw;
> +
>  	priv->msg_enable = value;
> +
> +	/* There is no possibility to at napi poll level
> +	 * to know which netdev is handled, so enable
> +	 * common dbg msg print if any interface is enabled to

to? too?

> +	 */
> +	cpsw->intr_dbg_msg = 0;
> +	if (!cpsw->data.dual_emac) {
> +		if (netif_msg_intr(priv))
> +			cpsw->intr_dbg_msg = 1;
> +		return;
> +	}
> +
> +	for (i = 0; i < cpsw->data.slaves; i++) {
> +		ndev = netdev_priv(cpsw->slaves[i].ndev);
> +		if (!ndev)
> +			continue;
> +
> +		sl_priv = netdev_priv(ndev);
> +		if (netif_msg_intr(sl_priv)) {
> +			cpsw->intr_dbg_msg = 1;
> +			break;
> +		}
> +	}
>  }
>  
>  static int cpsw_get_ts_info(struct net_device *ndev,
