From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] net: mv643xx_eth: use {readl|writel}_relaxed instead of readl/writel
Date: Fri, 13 May 2016 14:09:43 +0200
Message-ID: <3966837.tFk2PD8QFb@wuerfel>
References: <1463140760-7128-1-git-send-email-jszhang@marvell.com> <1463140760-7128-2-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jisheng Zhang <jszhang@marvell.com>,
	sebastian.hesselbarth@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463140760-7128-2-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 13 May 2016 19:59:19 Jisheng Zhang wrote:
>  /* port register accessors **************************************************/
>  static inline u32 rdl(struct mv643xx_eth_private *mp, int offset)
>  {
> -	return readl(mp->shared->base + offset);
> +	return readl_relaxed(mp->shared->base + offset);
>  }
>  
>  static inline u32 rdlp(struct mv643xx_eth_private *mp, int offset)
>  {
> -	return readl(mp->base + offset);
> +	return readl_relaxed(mp->base + offset);
>  }

I'd recommend not changing these in general, but introducing new 'rdl_relaxed()'
and 'rdlp_relaxed()' etc variants that you use in the code that actually
is performance sensitive, but use the normal non-relaxed versions by
default.

Then add a comment to each use of the relaxed accessors on how you know
that it's safe for that caller. This usually is just needed for the xmit()
function and for the interrupt handler.
  
> @@ -2642,10 +2642,10 @@ mv643xx_eth_conf_mbus_windows(struct mv643xx_eth_shared_private *msp,
>  	int i;
>  
>  	for (i = 0; i < 6; i++) {
> -		writel(0, base + WINDOW_BASE(i));
> -		writel(0, base + WINDOW_SIZE(i));
> +		writel_relaxed(0, base + WINDOW_BASE(i));
> +		writel_relaxed(0, base + WINDOW_SIZE(i));
>  		if (i < 4)
> -			writel(0, base + WINDOW_REMAP_HIGH(i));
> +			writel_relaxed(0, base + WINDOW_REMAP_HIGH(i));
>  	}
>  
>  	win_enable = 0x3f;

Configuring the mbus for instance is clearly not an operation in which
performance matters at all, so better not touch that.

> @@ -2674,8 +2675,8 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
>  	 * [21:8], or a 16-bit coal limit in bits [25,21:7] of the
>  	 * SDMA config register.
>  	 */
> -	writel(0x02000000, msp->base + 0x0400 + SDMA_CONFIG);
> -	if (readl(msp->base + 0x0400 + SDMA_CONFIG) & 0x02000000)
> +	writel_relaxed(0x02000000, msp->base + 0x0400 + SDMA_CONFIG);
> +	if (readl_relaxed(msp->base + 0x0400 + SDMA_CONFIG) & 0x02000000)
>  		msp->extended_rx_coal_limit = 1;
>  	else
>  		msp->extended_rx_coal_limit = 0;


This also seems to be configuration, rather than in the packet rx/tx hotpath.

	Arnd
