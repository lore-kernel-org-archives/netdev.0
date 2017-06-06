From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 4/4] net: macb: Add hardware PTP support
Date: Tue, 6 Jun 2017 20:33:58 +0200
Message-ID: <20170606183358.GA25220@localhost.localdomain>
References: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
 <1496413690-22826-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nicolas.ferre@atmel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        harini.katakam@xilinx.com, andrei.pistirica@microchip.com
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1496413690-22826-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2017 at 03:28:10PM +0100, Rafal Ozieblo wrote:
> +static s32 gem_get_ptp_max_adj(void)
> +{
> +	return 64E6;
> +}

This is a floating point constant.  Please use integer instead.

> +
> +static int gem_get_ts_info(struct net_device *dev,
> +			   struct ethtool_ts_info *info)
> +{
> +	struct macb *bp = netdev_priv(dev);
> +
> +	ethtool_op_get_ts_info(dev, info);

This default is misguided.

> +	if ((bp->hw_dma_cap & HW_DMA_CAP_PTP) == 0)
> +		return 0;

Try this: 

	if ((bp->hw_dma_cap & HW_DMA_CAP_PTP) == 0) {
		ethtool_op_get_ts_info(dev, info);
		return 0;
	}

> +	info->so_timestamping =
> +		SOF_TIMESTAMPING_TX_SOFTWARE |
> +		SOF_TIMESTAMPING_RX_SOFTWARE |
> +		SOF_TIMESTAMPING_SOFTWARE |
> +		SOF_TIMESTAMPING_TX_HARDWARE |
> +		SOF_TIMESTAMPING_RX_HARDWARE |
> +		SOF_TIMESTAMPING_RAW_HARDWARE;
> +	info->tx_types =
> +		(1 << HWTSTAMP_TX_ONESTEP_SYNC) |
> +		(1 << HWTSTAMP_TX_OFF) |
> +		(1 << HWTSTAMP_TX_ON);
> +	info->rx_filters =
> +		(1 << HWTSTAMP_FILTER_NONE) |
> +		(1 << HWTSTAMP_FILTER_ALL);
> +	info->phc_index = -1;
> +
> +	if (bp->ptp_clock)
> +		info->phc_index = ptp_clock_index(bp->ptp_clock);

Like this please:

	info->phc_index = bp->ptp_clock ? ptp_clock_index(bp->ptp_clock) : -1;

> +
> +	return 0;
> +}
> +
> +static struct macb_ptp_info gem_ptp_info = {
> +	.ptp_init	 = gem_ptp_init,
> +	.ptp_remove	 = gem_ptp_remove,
> +	.get_ptp_max_adj = gem_get_ptp_max_adj,
> +	.get_tsu_rate	 = gem_get_tsu_rate,
> +	.get_ts_info	 = gem_get_ts_info,
> +	.get_hwtst	 = gem_get_hwtst,
> +	.set_hwtst	 = gem_set_hwtst,
> +};
> +#endif
> +
>  static int macb_get_ts_info(struct net_device *netdev,
>  			    struct ethtool_ts_info *info)
>  {
> @@ -2636,12 +2707,16 @@ static void macb_configure_caps(struct macb *bp,
>  		dcfg = gem_readl(bp, DCFG2);
>  		if ((dcfg & (GEM_BIT(RX_PKT_BUFF) | GEM_BIT(TX_PKT_BUFF))) == 0)
>  			bp->caps |= MACB_CAPS_FIFO_MODE;
> -		if (IS_ENABLED(CONFIG_MACB_USE_HWSTAMP) && gem_has_ptp(bp)) {
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +		if (gem_has_ptp(bp)) {
>  			if (!GEM_BFEXT(TSU, gem_readl(bp, DCFG5)))
>  				pr_err("GEM doesn't support hardware ptp.\n");
> -			else
> +			else {
>  				bp->hw_dma_cap |= HW_DMA_CAP_PTP;
> +				bp->ptp_info = &gem_ptp_info;
> +			}
>  		}
> +#endif
>  	}
>  
>  	dev_dbg(&bp->pdev->dev, "Cadence caps 0x%08x\n", bp->caps);
> @@ -3247,7 +3322,9 @@ static const struct macb_config np4_config = {
>  };
>  
>  static const struct macb_config zynqmp_config = {
> -	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
> +	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE |
> +			MACB_CAPS_JUMBO |
> +			MACB_CAPS_GEM_HAS_PTP,
>  	.dma_burst_length = 16,
>  	.clk_init = macb_clk_init,
>  	.init = macb_init,
> @@ -3281,7 +3358,9 @@ MODULE_DEVICE_TABLE(of, macb_dt_ids);
>  #endif /* CONFIG_OF */
>  
>  static const struct macb_config default_gem_config = {
> -	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
> +	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE |
> +			MACB_CAPS_JUMBO |
> +			MACB_CAPS_GEM_HAS_PTP,
>  	.dma_burst_length = 16,
>  	.clk_init = macb_clk_init,
>  	.init = macb_init,

> diff --git a/drivers/net/ethernet/cadence/macb_ptp.c b/drivers/net/ethernet/cadence/macb_ptp.c
> new file mode 100755
> index 0000000..d536970
> --- /dev/null
> +++ b/drivers/net/ethernet/cadence/macb_ptp.c
> @@ -0,0 +1,512 @@
> +/**
> + * 1588 PTP support for Cadence GEM device.
> + *
> + * Copyright (C) 2017 Cadence Design Systems - http://www.cadence.com
> + *
> + * Authors: Rafal Ozieblo <rafalo@cadence.com>
> + *          Bartosz Folta <bfolta@cadence.com>
> + *
> + * This program is free software: you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2  of
> + * the License as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
> + */
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/clk.h>
> +#include <linux/device.h>
> +#include <linux/etherdevice.h>
> +#include <linux/platform_device.h>
> +#include <linux/time64.h>
> +#include <linux/ptp_classify.h>
> +#include <linux/if_ether.h>
> +#include <linux/if_vlan.h>
> +#include <linux/net_tstamp.h>
> +#include <linux/circ_buf.h>
> +#include <linux/spinlock.h>
> +
> +#include "macb.h"
> +
> +#define  GEM_PTP_TIMER_NAME "gem-ptp-timer"
> +
> +static struct macb_dma_desc_ptp *macb_ptp_desc(struct macb *bp,
> +					       struct macb_dma_desc *desc)
> +{
> +	if (bp->hw_dma_cap == HW_DMA_CAP_PTP)
> +		return (struct macb_dma_desc_ptp *)
> +				((u8 *)desc + sizeof(struct macb_dma_desc));
> +	if (bp->hw_dma_cap == HW_DMA_CAP_64B_PTP)
> +		return (struct macb_dma_desc_ptp *)
> +				((u8 *)desc + sizeof(struct macb_dma_desc)
> +				+ sizeof(struct macb_dma_desc_64));
> +	return NULL;
> +}
> +
> +static int gem_tsu_get_time(struct ptp_clock_info *ptp, struct timespec64 *ts)
> +{
> +	long first, second;
> +	u32 secl, sech;
> +	unsigned long flags;
> +	struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);

Please list locals in "upside down Christmas tree" style:

	struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);
	unsigned long flags;
	long first, second;
	u32 secl, sech;

> +	spin_lock_irqsave(&bp->tsu_clk_lock, flags);
> +	first = gem_readl(bp, TN);
> +	secl = gem_readl(bp, TSL);
> +	sech = gem_readl(bp, TSH);
> +	second = gem_readl(bp, TN);
> +
> +	/* test for nsec rollover */
> +	if (first > second) {
> +		/* if so, use later read & re-read seconds
> +		 * (assume all done within 1s)
> +		 */
> +		ts->tv_nsec = gem_readl(bp, TN);
> +		secl = gem_readl(bp, TSL);
> +		sech = gem_readl(bp, TSH);
> +	} else {
> +		ts->tv_nsec = first;
> +	}
> +
> +	spin_unlock_irqrestore(&bp->tsu_clk_lock, flags);
> +	ts->tv_sec = (((u64)sech << GEM_TSL_SIZE) | secl)
> +			& TSU_SEC_MAX_VAL;
> +	return 0;
> +}
> +
> +static int gem_tsu_set_time(struct ptp_clock_info *ptp,
> +			    const struct timespec64 *ts)
> +{
> +	u32 ns, sech, secl;
> +	unsigned long flags;
> +	struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);

here too ...

> +	secl = (u32)ts->tv_sec;
> +	sech = (ts->tv_sec >> GEM_TSL_SIZE) & ((1 << GEM_TSH_SIZE) - 1);
> +	ns = ts->tv_nsec;
> +
> +	spin_lock_irqsave(&bp->tsu_clk_lock, flags);
> +
> +	/* TSH doesn't latch the time and no atomicity! */
> +	gem_writel(bp, TN, 0); /* clear to avoid overflow */
> +	gem_writel(bp, TSH, sech);
> +	/* write lower bits 2nd, for synchronized secs update */
> +	gem_writel(bp, TSL, secl);
> +	gem_writel(bp, TN, ns);
> +
> +	spin_unlock_irqrestore(&bp->tsu_clk_lock, flags);
> +
> +	return 0;
> +}
> +
> +static int gem_tsu_incr_set(struct macb *bp, struct tsu_incr *incr_spec)
> +{
> +	unsigned long flags;
> +
> +	/* tsu_timer_incr register must be written after
> +	 * the tsu_timer_incr_sub_ns register and the write operation
> +	 * will cause the value written to the tsu_timer_incr_sub_ns register
> +	 * to take effect.
> +	 */
> +	spin_lock_irqsave(&bp->tsu_clk_lock, flags);
> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, incr_spec->sub_ns));
> +	gem_writel(bp, TI, GEM_BF(NSINCR, incr_spec->ns));
> +	spin_unlock_irqrestore(&bp->tsu_clk_lock, flags);
> +
> +	return 0;
> +}
> +
> +static int gem_ptp_adjfine(struct ptp_clock_info *ptp, long scaled_ppm)
> +{
> +	struct tsu_incr incr_spec;
> +	struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);
> +	u64 adj;
> +	u32 word;
> +	bool neg_adj = false;

and here ...

> +
> +	if (scaled_ppm < 0) {
> +		neg_adj = true;
> +		scaled_ppm = -scaled_ppm;
> +	}
> +
> +	/* Adjustment is relative to base frequency */
> +	incr_spec.sub_ns = bp->tsu_incr.sub_ns;
> +	incr_spec.ns = bp->tsu_incr.ns;
> +
> +	/* scaling: unused(8bit) | ns(8bit) | fractions(16bit) */
> +	word = ((u64)incr_spec.ns << GEM_SUBNSINCR_SIZE) + incr_spec.sub_ns;
> +	adj = (u64)scaled_ppm * word;
> +	/* Divide with rounding, equivalent to floating dividing:
> +	 * (temp / USEC_PER_SEC) + 0.5
> +	 */
> +	adj += (USEC_PER_SEC >> 1);
> +	adj >>= GEM_SUBNSINCR_SIZE; /* remove fractions */
> +	adj = div_u64(adj, USEC_PER_SEC);
> +	adj = neg_adj ? (word - adj) : (word + adj);
> +
> +	incr_spec.ns = (adj >> GEM_SUBNSINCR_SIZE)
> +			& ((1 << GEM_NSINCR_SIZE) - 1);
> +	incr_spec.sub_ns = adj & ((1 << GEM_SUBNSINCR_SIZE) - 1);
> +	gem_tsu_incr_set(bp, &incr_spec);
> +	return 0;
> +}
> +
> +static int gem_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
> +{
> +	struct timespec64 now, then = ns_to_timespec64(delta);
> +	struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);
> +	u32 adj, sign = 0;

and here too.  Please check the other functions...

> +	if (delta < 0) {
> +		sign = 1;
> +		delta = -delta;
> +	}
> +
> +	if (delta > TSU_NSEC_MAX_VAL) {
> +		gem_tsu_get_time(&bp->ptp_clock_info, &now);
> +		if (sign)
> +			now = timespec64_sub(now, then);
> +		else
> +			now = timespec64_add(now, then);
> +
> +		gem_tsu_set_time(&bp->ptp_clock_info,
> +				 (const struct timespec64 *)&now);
> +	} else {
> +		adj = (sign << GEM_ADDSUB_OFFSET) | delta;
> +
> +		gem_writel(bp, TA, adj);
> +	}
> +
> +	return 0;
> +}
> +
> +static int gem_ptp_enable(struct ptp_clock_info *ptp,
> +			  struct ptp_clock_request *rq, int on)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
> +static struct ptp_clock_info gem_ptp_caps_template = {
> +	.owner		= THIS_MODULE,
> +	.name		= GEM_PTP_TIMER_NAME,
> +	.max_adj	= 0,
> +	.n_alarm	= 0,
> +	.n_ext_ts	= 0,
> +	.n_per_out	= 0,
> +	.n_pins		= 0,
> +	.pps		= 1,
> +	.adjfine	= gem_ptp_adjfine,
> +	.adjtime	= gem_ptp_adjtime,
> +	.gettime64	= gem_tsu_get_time,
> +	.settime64	= gem_tsu_set_time,
> +	.enable		= gem_ptp_enable,
> +};
> +
> +static void gem_ptp_init_timer(struct macb *bp)
> +{
> +	u32 rem = 0;
> +
> +	bp->tsu_incr.ns = div_u64_rem(NSEC_PER_SEC, bp->tsu_rate, &rem);
> +	if (rem) {
> +		u64 adj = rem;

This variable belongs above, not in the if-block.

> +		adj <<= GEM_SUBNSINCR_SIZE;
> +		bp->tsu_incr.sub_ns = div_u64(adj, bp->tsu_rate);
> +	} else {
> +		bp->tsu_incr.sub_ns = 0;
> +	}
> +}
> +
> +static void gem_ptp_init_tsu(struct macb *bp)
> +{
> +	struct timespec64 ts;
> +
> +	/* 1. get current system time */
> +	ts = ns_to_timespec64(ktime_to_ns(ktime_get_real()));
> +
> +	/* 2. set ptp timer */
> +	gem_tsu_set_time(&bp->ptp_clock_info, &ts);
> +
> +	/* 3. set PTP timer increment value to BASE_INCREMENT */
> +	gem_tsu_incr_set(bp, &bp->tsu_incr);
> +
> +	gem_writel(bp, TA, 0);
> +}
> +
> +static void gem_ptp_clear_timer(struct macb *bp)
> +{
> +	bp->tsu_incr.ns = 0;
> +	bp->tsu_incr.sub_ns = 0;

What is the point of this function?

> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, 0));
> +	gem_writel(bp, TI, GEM_BF(NSINCR, 0));
> +	gem_writel(bp, TA, 0);
> +}
> +
> +static int gem_hw_timestamp(struct macb *bp, u32 dma_desc_ts_1,
> +			    u32 dma_desc_ts_2, struct timespec64 *ts)
> +{
> +	struct timespec64 tsu;
> +
> +	ts->tv_sec = (GEM_BFEXT(DMA_SECH, dma_desc_ts_2) << GEM_DMA_SECL_SIZE) |
> +			GEM_BFEXT(DMA_SECL, dma_desc_ts_1);
> +	ts->tv_nsec = GEM_BFEXT(DMA_NSEC, dma_desc_ts_1);
> +
> +	/* TSU overlapping workaround
> +	 * The timestamp only contains lower few bits of seconds,
> +	 * so add value from 1588 timer
> +	 */
> +	gem_tsu_get_time(&bp->ptp_clock_info, &tsu);
> +
> +	/* If the top bit is set in the timestamp,
> +	 * but not in 1588 timer, it has rolled over,
> +	 * so subtract max size
> +	 */
> +	if ((ts->tv_sec & (GEM_DMA_SEC_TOP >> 1)) &&
> +	    !(tsu.tv_sec & (GEM_DMA_SEC_TOP >> 1)))
> +		ts->tv_sec -= GEM_DMA_SEC_TOP;
> +
> +	ts->tv_sec += ((~GEM_DMA_SEC_MASK) & tsu.tv_sec);
> +
> +	return 0;
> +}
> +
> +void gem_ptp_rxstamp(struct macb *bp, struct sk_buff *skb,
> +		     struct macb_dma_desc *desc)
> +{
> +	struct timespec64 ts;
> +	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> +	struct macb_dma_desc_ptp *desc_ptp;
> +
> +	if (GEM_BFEXT(DMA_RXVALID, desc->addr)) {
> +		desc_ptp = macb_ptp_desc(bp, desc);
> +		gem_hw_timestamp(bp, desc_ptp->ts_1, desc_ptp->ts_2, &ts);
> +		memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
> +		shhwtstamps->hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
> +	}
> +}
> +
> +static void gem_tstamp_tx(struct macb *bp, struct sk_buff *skb,
> +			  struct macb_dma_desc_ptp *desc_ptp)
> +{
> +	struct skb_shared_hwtstamps shhwtstamps;
> +	struct timespec64 ts;
> +
> +	gem_hw_timestamp(bp, desc_ptp->ts_1, desc_ptp->ts_2, &ts);
> +	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
> +	shhwtstamps.hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
> +	skb_tstamp_tx(skb, &shhwtstamps);
> +}
> +
> +int gem_ptp_txstamp(struct macb_queue *queue, struct sk_buff *skb,
> +		    struct macb_dma_desc *desc)
> +{
> +	struct gem_tx_ts *tx_timestamp;
> +	struct macb_dma_desc_ptp *desc_ptp;
> +	unsigned long head = queue->tx_ts_head;
> +	unsigned long tail = READ_ONCE(queue->tx_ts_tail);
> +
> +	if (!GEM_BFEXT(DMA_TXVALID, desc->ctrl))
> +		return -EINVAL;
> +
> +	if (CIRC_SPACE(head, tail, PTP_TS_BUFFER_SIZE) == 0)
> +		return -ENOMEM;
> +
> +	skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
> +	desc_ptp = macb_ptp_desc(queue->bp, desc);
> +	tx_timestamp = &queue->tx_timestamps[head];
> +	tx_timestamp->skb = skb;
> +	tx_timestamp->desc_ptp.ts_1 = desc_ptp->ts_1;
> +	tx_timestamp->desc_ptp.ts_2 = desc_ptp->ts_2;
> +	/* move head */
> +	smp_store_release(&queue->tx_ts_head,
> +			  (head + 1) & (PTP_TS_BUFFER_SIZE - 1));
> +
> +	schedule_work(&queue->tx_ts_task);

Since the time stamp is in the buffer descriptor, why delay the
delivery via the work item?

> +	return 0;
> +}
> +
> +static void gem_tx_timestamp_flush(struct work_struct *work)
> +{
> +	struct macb_queue *queue =
> +			container_of(work, struct macb_queue, tx_ts_task);
> +	struct gem_tx_ts *tx_ts;
> +	unsigned long head, tail;
> +
> +	/* take current head */
> +	head = smp_load_acquire(&queue->tx_ts_head);
> +	tail = queue->tx_ts_tail;
> +
> +	while (CIRC_CNT(head, tail, PTP_TS_BUFFER_SIZE)) {
> +		tx_ts = &queue->tx_timestamps[tail];
> +		gem_tstamp_tx(queue->bp, tx_ts->skb, &tx_ts->desc_ptp);
> +		/* cleanup */
> +		dev_kfree_skb_any(tx_ts->skb);
> +		/* remove old tail */
> +		smp_store_release(&queue->tx_ts_tail,
> +				  (tail + 1) & (PTP_TS_BUFFER_SIZE - 1));
> +		tail = queue->tx_ts_tail;
> +	}
> +}
> +
> +void gem_ptp_init(struct net_device *dev)
> +{
> +	struct macb *bp = netdev_priv(dev);
> +	unsigned int q;
> +	struct macb_queue *queue;
> +
> +	bp->ptp_clock_info = gem_ptp_caps_template;
> +
> +	/* nominal frequency and maximum adjustment in ppb */
> +	bp->tsu_rate = bp->ptp_info->get_tsu_rate(bp);
> +	bp->ptp_clock_info.max_adj = bp->ptp_info->get_ptp_max_adj();
> +	gem_ptp_init_timer(bp);
> +	bp->ptp_clock = ptp_clock_register(&bp->ptp_clock_info, &dev->dev);
> +	if (IS_ERR(&bp->ptp_clock)) {
> +		bp->ptp_clock = NULL;
> +		pr_err("ptp clock register failed\n");
> +		return;
> +	}

ptp_clock_register() can also return NULL, and so you can avoid the
following code in that case, right?

> +
> +	spin_lock_init(&bp->tsu_clk_lock);
> +	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
> +		queue->tx_ts_head = 0;
> +		queue->tx_ts_tail = 0;
> +		INIT_WORK(&queue->tx_ts_task, gem_tx_timestamp_flush);
> +	}
> +
> +	gem_ptp_init_tsu(bp);
> +
> +	dev_info(&bp->pdev->dev, "%s ptp clock registered.\n",
> +		 GEM_PTP_TIMER_NAME);
> +}
> +
> +void gem_ptp_remove(struct net_device *ndev)
> +{
> +	struct macb *bp = netdev_priv(ndev);
> +
> +	if (bp->ptp_clock)
> +		ptp_clock_unregister(bp->ptp_clock);
> +
> +	gem_ptp_clear_timer(bp);

Why is this 'clear' needed?

> +	dev_info(&bp->pdev->dev, "%s ptp clock unregistered.\n",
> +		 GEM_PTP_TIMER_NAME);
> +}

Thanks,
Richard
