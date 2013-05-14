From: Hein Tibosch <hein_tibosch@yahoo.es>
Subject: Re: [PATCH v2] net/macb: fix ISR clear-on-write behavior only for
 some SoC
Date: Tue, 14 May 2013 21:43:16 +0800
Message-ID: <51923F74.8010803@yahoo.es>
References: <1368461105-23128-1-git-send-email-nicolas.ferre@atmel.com> <1368536416-18364-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	michal.simek@xilinx.com,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	s.trumtrar@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368536416-18364-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicolas,

On 5/14/2013 9:00 PM, Nicolas Ferre wrote:
> Commit 749a2b6 (net/macb: clear tx/rx completion flags in ISR)
> introduces clear-on-write on ISR register. This behavior is not always
> implemented when using Cadence MACB/GEM and is breaking other platforms.
> We are using the Design Configuration Register 1 information and a capability
> property to actually activate this clear-on-write behavior on ISR.
>
> Reported-by: Hein Tibosch <hein_tibosch@yahoo.es>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
> v2: - use DCFG1 bit 23 integration information instead of device tree
>       compatibility string to retreive information about c-o-r vs. c-o-w ISR.
>     - move configuration in macb_init_hw() function instead of probe() - at
>       "open" time.
>
> As I have changed the most of this patch, I will collect your Ack and feedback
> just like a new patch. Thanks for your help...
>
> Bye,
>
>  drivers/net/ethernet/cadence/macb.c | 18 ++++++++++++++++--
>  drivers/net/ethernet/cadence/macb.h |  7 +++++++
>  2 files changed, 23 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 6be513d..c89aa41 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -485,7 +485,8 @@ static void macb_tx_interrupt(struct macb *bp)
>  	status = macb_readl(bp, TSR);
>  	macb_writel(bp, TSR, status);
>  
> -	macb_writel(bp, ISR, MACB_BIT(TCOMP));
> +	if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +		macb_writel(bp, ISR, MACB_BIT(TCOMP));
>  
>  	netdev_vdbg(bp->dev, "macb_tx_interrupt status = 0x%03lx\n",
>  		(unsigned long)status);
> @@ -738,7 +739,8 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
>  			 * now.
>  			 */
>  			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
> -			macb_writel(bp, ISR, MACB_BIT(RCOMP));
> +			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +				macb_writel(bp, ISR, MACB_BIT(RCOMP));
>  
>  			if (napi_schedule_prep(&bp->napi)) {
>  				netdev_vdbg(bp->dev, "scheduling RX softirq\n");
> @@ -1062,6 +1064,17 @@ static void macb_configure_dma(struct macb *bp)
>  	}
>  }
>  
> +/*
> + * Configure peripheral capacities according to integration options used
> + */
> +static void macb_configure_caps(struct macb *bp)
> +{
> +	if (macb_is_gem(bp)) {
> +		if (GEM_BF(IRQCOR, gem_readl(bp, DCFG1)) == 0)
> +			bp->caps |= MACB_CAPS_ISR_CLEAR_ON_WRITE;
> +	}
> +}

As you'll know on avr32 (AP7), macb_is_gem() returns false and thus the cap
won't be set, which is correct.

> +
>  static void macb_init_hw(struct macb *bp)
>  {
>  	u32 config;
> @@ -1084,6 +1097,7 @@ static void macb_init_hw(struct macb *bp)
>  	bp->duplex = DUPLEX_HALF;
>  
>  	macb_configure_dma(bp);
> +	macb_configure_caps(bp);
>  
>  	/* Initialize TX and RX buffers */
>  	macb_writel(bp, RBQP, bp->rx_ring_dma);
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 993d703..548c0ec 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -300,6 +300,8 @@
>  #define MACB_REV_SIZE				16
>  
>  /* Bitfields in DCFG1. */
> +#define GEM_IRQCOR_OFFSET			23
> +#define GEM_IRQCOR_SIZE				1
>  #define GEM_DBWDEF_OFFSET			25
>  #define GEM_DBWDEF_SIZE				3
>  
> @@ -323,6 +325,9 @@
>  #define MACB_MAN_READ				2
>  #define MACB_MAN_CODE				2
>  
> +/* Capability mask bits */
> +#define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x1
> +
>  /* Bit manipulation macros */
>  #define MACB_BIT(name)					\
>  	(1 << MACB_##name##_OFFSET)
> @@ -574,6 +579,8 @@ struct macb {
>  	unsigned int 		speed;
>  	unsigned int 		duplex;
>  
> +	u32			caps;
> +
>  	phy_interface_t		phy_interface;
>  
>  	/* AT91RM9200 transmit */
Just re-tested with the above patch and it works like before,
also iperf results are unaffected (57/100 Mbit).

Tested-by: Hein Tibosch <hein_tibosch@yahoo.es>

Thanks a lot,
Hein
