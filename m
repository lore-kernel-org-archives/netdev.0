From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 09/10] net/macb: ethtool interface: add register dump
 feature
Date: Thu, 6 Sep 2012 00:36:14 +0100
Message-ID: <1346888174.5325.55.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
	 <fcd1c2443a30f23ffcd8de28328c5a382e2a2459.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<davem@davemloft.net>, <havard@skinnemoen.net>,
	<plagnioj@jcrosoft.com>, <jamie@jamieiles.com>,
	<linux-kernel@vger.kernel.org>, <patrice.vilchez@atmel.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fcd1c2443a30f23ffcd8de28328c5a382e2a2459.1346775479.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-05 at 11:00 +0200, Nicolas Ferre wrote:
> Add macb_get_regs() ethtool function and its helper function:
> macb_get_regs_len().
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
>  drivers/net/ethernet/cadence/macb.c |   40 +++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/cadence/macb.h |    3 +++
>  2 files changed, 43 insertions(+)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index c7c39f1..f31c0a7 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1321,10 +1321,50 @@ static void macb_get_drvinfo(struct net_device *dev,
>  	strcpy(info->bus_info, dev_name(&bp->pdev->dev));
>  }
>  
> +static int macb_get_regs_len(struct net_device *netdev)
> +{
> +	return MACB_GREGS_LEN * sizeof(u32);
> +}
> +
> +static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
> +			  void *p)
> +{
> +	struct macb *bp = netdev_priv(dev);
> +	unsigned int tail, head;
> +	u32 *regs_buff = p;
> +
> +        memset(p, 0, MACB_GREGS_LEN * sizeof(u32));

The ethtool core does that for you.  (Drivers can't be trusted to do
it!)

> +	regs->version = MACB_BFEXT(IDNUM, macb_readl(bp, MID));

Note that the version field is supposed to be the version of the
register dump format.  Is this value sufficient for userland to easily
decide whether macb_is_gem()?  Are there spare bits that you can set if
you change the format later?

> +	tail = macb_tx_ring_wrap(bp->tx_tail);
> +	head = macb_tx_ring_wrap(bp->tx_head);
> +
> +	regs_buff[0]  = macb_readl(bp, NCR);
> +	regs_buff[1]  = macb_or_gem_readl(bp, NCFGR);
> +	regs_buff[2]  = macb_readl(bp, NSR);
> +	regs_buff[3]  = macb_readl(bp, TSR);
> +	regs_buff[4]  = macb_readl(bp, RBQP);
> +	regs_buff[5]  = macb_readl(bp, TBQP);
> +	regs_buff[6]  = macb_readl(bp, RSR);
> +	regs_buff[7]  = macb_readl(bp, IMR);
> +
> +	regs_buff[8]  = tail;
> +	regs_buff[9]  = head;
> +	regs_buff[10] = macb_tx_dma(bp, tail);
> +	regs_buff[11] = macb_tx_dma(bp, head);
> +
> +	if (macb_is_gem(bp)) {
> +		regs_buff[12] = gem_readl(bp, USRIO);
> +		regs_buff[13] = gem_readl(bp, DMACFG);
> +	}
> +}
> +
>  static const struct ethtool_ops macb_ethtool_ops = {
>  	.get_settings		= macb_get_settings,
>  	.set_settings		= macb_set_settings,
>  	.get_drvinfo		= macb_get_drvinfo,
> +	.get_regs_len		= macb_get_regs_len,
> +	.get_regs		= macb_get_regs,
>  	.get_link		= ethtool_op_get_link,
>  	.get_ts_info		= ethtool_op_get_ts_info,
>  };
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 8a4ee2f..d509e88 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -10,6 +10,9 @@
>  #ifndef _MACB_H
>  #define _MACB_H
>  
> +
> +#define MACB_GREGS_LEN 32

Why is this rather larger than the actual number of registers you
return?  Also, the name is not a great idea as 'regs_len' is normally a
number of bytes.

Ben.

>  /* MACB register offsets */
>  #define MACB_NCR				0x0000
>  #define MACB_NCFGR				0x0004

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
