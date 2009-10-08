From: Kevin Hilman <khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH] TI DaVinci EMAC: Clear statistics register properly.
Date: Thu, 8 Oct 2009 12:11:33 -0700
Message-ID: <877hv57lay.fsf@deeprootsystems.com>
References: <1254919470-20595-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
To: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1254919470-20595-1-git-send-email-srk-l0cyMroinI0@public.gmane.org> (Sriramakrishnan's
	message of "Wed\, 7 Oct 2009 18\:14\:30 +0530")
List-Unsubscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.omap.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org> writes:

> The mechanism to clear the statistics register is dependent
> on the status of GMIIEN bit in MAC control register. If the
> GMIIEN bit is set, the stats registers are write to decrement.
> If the GMIIEN bit is cleared, the stats registers are plain
> read/write registers. The stats register clearing operation
> must take into account the current state of GMIIEN as it
> can be cleared when the interface is brought down.
>
> With existing implementation logic, querying for interface stats
> when the interface is down, can corrupt the statistics counters.
> This patch examines the GMIIEN bit status in MAC_CONTROL
> register before choosing an appropriate mask for clearing stats
> registers.
>
> Signed-off-by: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
> Acked-by: Chaithrika U S <chaithrika-l0cyMroinI0@public.gmane.org>
> ---
> This patch is generated against the tip of net-next-2.6.

OK, will also add to linux-davinci while waiting for it reach
mainline.

Kevin

>  drivers/net/davinci_emac.c |   36 ++++++++++++++++++++++++------------
>  1 files changed, 24 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index a421ec0..a876dce 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -330,6 +330,9 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
>  #define EMAC_DM646X_MAC_EOI_C0_RXEN	(0x01)
>  #define EMAC_DM646X_MAC_EOI_C0_TXEN	(0x02)
>  
> +/* EMAC Stats Clear Mask */
> +#define EMAC_STATS_CLR_MASK    (0xFFFFFFFF)
> +
>  /** net_buf_obj: EMAC network bufferdata structure
>   *
>   * EMAC network buffer data structure
> @@ -2544,40 +2547,49 @@ static int emac_dev_stop(struct net_device *ndev)
>  static struct net_device_stats *emac_dev_getnetstats(struct net_device *ndev)
>  {
>  	struct emac_priv *priv = netdev_priv(ndev);
> +	u32 mac_control;
> +	u32 stats_clear_mask;
>  
>  	/* update emac hardware stats and reset the registers*/
>  
> +	mac_control = emac_read(EMAC_MACCONTROL);
> +
> +	if (mac_control & EMAC_MACCONTROL_GMIIEN)
> +		stats_clear_mask = EMAC_STATS_CLR_MASK;
> +	else
> +		stats_clear_mask = 0;
> +
>  	priv->net_dev_stats.multicast += emac_read(EMAC_RXMCASTFRAMES);
> -	emac_write(EMAC_RXMCASTFRAMES, EMAC_ALL_MULTI_REG_VALUE);
> +	emac_write(EMAC_RXMCASTFRAMES, stats_clear_mask);
>  
>  	priv->net_dev_stats.collisions += (emac_read(EMAC_TXCOLLISION) +
>  					   emac_read(EMAC_TXSINGLECOLL) +
>  					   emac_read(EMAC_TXMULTICOLL));
> -	emac_write(EMAC_TXCOLLISION, EMAC_ALL_MULTI_REG_VALUE);
> -	emac_write(EMAC_TXSINGLECOLL, EMAC_ALL_MULTI_REG_VALUE);
> -	emac_write(EMAC_TXMULTICOLL, EMAC_ALL_MULTI_REG_VALUE);
> +	emac_write(EMAC_TXCOLLISION, stats_clear_mask);
> +	emac_write(EMAC_TXSINGLECOLL, stats_clear_mask);
> +	emac_write(EMAC_TXMULTICOLL, stats_clear_mask);
>  
>  	priv->net_dev_stats.rx_length_errors += (emac_read(EMAC_RXOVERSIZED) +
>  						emac_read(EMAC_RXJABBER) +
>  						emac_read(EMAC_RXUNDERSIZED));
> -	emac_write(EMAC_RXOVERSIZED, EMAC_ALL_MULTI_REG_VALUE);
> -	emac_write(EMAC_RXJABBER, EMAC_ALL_MULTI_REG_VALUE);
> -	emac_write(EMAC_RXUNDERSIZED, EMAC_ALL_MULTI_REG_VALUE);
> +	emac_write(EMAC_RXOVERSIZED, stats_clear_mask);
> +	emac_write(EMAC_RXJABBER, stats_clear_mask);
> +	emac_write(EMAC_RXUNDERSIZED, stats_clear_mask);
>  
>  	priv->net_dev_stats.rx_over_errors += (emac_read(EMAC_RXSOFOVERRUNS) +
>  					       emac_read(EMAC_RXMOFOVERRUNS));
> -	emac_write(EMAC_RXSOFOVERRUNS, EMAC_ALL_MULTI_REG_VALUE);
> -	emac_write(EMAC_RXMOFOVERRUNS, EMAC_ALL_MULTI_REG_VALUE);
> +	emac_write(EMAC_RXSOFOVERRUNS, stats_clear_mask);
> +	emac_write(EMAC_RXMOFOVERRUNS, stats_clear_mask);
>  
>  	priv->net_dev_stats.rx_fifo_errors += emac_read(EMAC_RXDMAOVERRUNS);
> -	emac_write(EMAC_RXDMAOVERRUNS, EMAC_ALL_MULTI_REG_VALUE);
> +	emac_write(EMAC_RXDMAOVERRUNS, stats_clear_mask);
>  
>  	priv->net_dev_stats.tx_carrier_errors +=
>  		emac_read(EMAC_TXCARRIERSENSE);
> -	emac_write(EMAC_TXCARRIERSENSE, EMAC_ALL_MULTI_REG_VALUE);
> +	emac_write(EMAC_TXCARRIERSENSE, stats_clear_mask);
>  
>  	priv->net_dev_stats.tx_fifo_errors = emac_read(EMAC_TXUNDERRUN);
> -	emac_write(EMAC_TXUNDERRUN, EMAC_ALL_MULTI_REG_VALUE);
> +	emac_write(EMAC_TXUNDERRUN, stats_clear_mask);
>  
>  	return &priv->net_dev_stats;
>  }
> -- 
> 1.6.2.4
>
> _______________________________________________
> Davinci-linux-open-source mailing list
> Davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
> http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
