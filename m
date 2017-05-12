From: Quentin Schulz <quentin.schulz@free-electrons.com>
Subject: Re: [PATCH v4 1/4] can: m_can: move Message RAM initialization to
 function
Date: Fri, 12 May 2017 08:37:07 +0200
Message-ID: <90788d6d-24f3-64ba-43f3-16301b777536@free-electrons.com>
References: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: wg@grandegger.com, mkl@pengutronix.de, mario.huettel@gmx.net,
        socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

On 05/05/2017 15:50, Quentin Schulz wrote:
> To avoid possible ECC/parity checksum errors when reading an
> uninitialized buffer, the entire Message RAM is initialized when probing
> the driver. This initialization is done in the same function reading the
> Device Tree properties.
> 
> This patch moves the RAM initialization to a separate function so it can
> be called separately from device initialization from Device Tree.
> 
> Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>

It's been a week since I sent this patch series. Any comments?

Thanks,
Quentin

> ---
> 
> v4:
>   - remove unused variables from m_can_of_parse_mram,
> 
>  drivers/net/can/m_can/m_can.c | 26 +++++++++++++++-----------
>  1 file changed, 15 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
> index bf8fdaeb955e..5da1bdb202a3 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -1489,11 +1489,23 @@ static int register_m_can_dev(struct net_device *dev)
>  	return register_candev(dev);
>  }
>  
> +static void m_can_init_ram(struct m_can_priv *priv)
> +{
> +	int end, i, start;
> +
> +	/* initialize the entire Message RAM in use to avoid possible
> +	 * ECC/parity checksum errors when reading an uninitialized buffer
> +	 */
> +	start = priv->mcfg[MRAM_SIDF].off;
> +	end = priv->mcfg[MRAM_TXB].off +
> +		priv->mcfg[MRAM_TXB].num * TXB_ELEMENT_SIZE;
> +	for (i = start; i < end; i += 4)
> +		writel(0x0, priv->mram_base + i);
> +}
> +
>  static void m_can_of_parse_mram(struct m_can_priv *priv,
>  				const u32 *mram_config_vals)
>  {
> -	int i, start, end;
> -
>  	priv->mcfg[MRAM_SIDF].off = mram_config_vals[0];
>  	priv->mcfg[MRAM_SIDF].num = mram_config_vals[1];
>  	priv->mcfg[MRAM_XIDF].off = priv->mcfg[MRAM_SIDF].off +
> @@ -1529,15 +1541,7 @@ static void m_can_of_parse_mram(struct m_can_priv *priv,
>  		priv->mcfg[MRAM_TXE].off, priv->mcfg[MRAM_TXE].num,
>  		priv->mcfg[MRAM_TXB].off, priv->mcfg[MRAM_TXB].num);
>  
> -	/* initialize the entire Message RAM in use to avoid possible
> -	 * ECC/parity checksum errors when reading an uninitialized buffer
> -	 */
> -	start = priv->mcfg[MRAM_SIDF].off;
> -	end = priv->mcfg[MRAM_TXB].off +
> -		priv->mcfg[MRAM_TXB].num * TXB_ELEMENT_SIZE;
> -	for (i = start; i < end; i += 4)
> -		writel(0x0, priv->mram_base + i);
> -
> +	m_can_init_ram(priv);
>  }
>  
>  static int m_can_plat_probe(struct platform_device *pdev)
> 

-- 
Quentin Schulz, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
