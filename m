From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH v2 2/2] macb: Enable 1588 support in SAMA5D2 platform.
Date: Sun, 20 Nov 2016 20:54:13 +0100
Message-ID: <20161120195413.GB7874@localhost.localdomain>
References: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
 <1479478912-14067-2-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, davem@davemloft.net,
        nicolas.ferre@atmel.com, harinikatakamlinux@gmail.com,
        harini.katakam@xilinx.com, punnaia@xilinx.com, michals@xilinx.com,
        anirudh@xilinx.com, boris.brezillon@free-electrons.com,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1479478912-14067-2-git-send-email-andrei.pistirica@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 18, 2016 at 03:21:52PM +0100, Andrei Pistirica wrote:
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index d975882..eb66b76 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -697,6 +697,8 @@ static void macb_tx_interrupt(struct macb_queue *queue)
>  
>  			/* First, update TX stats if needed */
>  			if (skb) {
> +				macb_ptp_do_txstamp(bp, skb);

This is in the hot path, and so you should have an inline wrapper that
tests (bp->hwts_tx_en) and THEN calls into macb_ptp.c

In case PTP isn't configured, then the inline wrapper should be empty.

>  				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
>  					    macb_tx_ring_wrap(tail), skb->data);
>  				bp->stats.tx_packets++;
> @@ -853,6 +855,8 @@ static int gem_rx(struct macb *bp, int budget)
>  		    GEM_BFEXT(RX_CSUM, ctrl) & GEM_RX_CSUM_CHECKED_MASK)
>  			skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
> +		macb_ptp_do_rxstamp(bp, skb);

Same here.

>  		bp->stats.rx_packets++;
>  		bp->stats.rx_bytes += skb->len;
>  
> @@ -1946,6 +1950,8 @@ static int macb_open(struct net_device *dev)
>  
>  	netif_tx_start_all_queues(dev);
>  
> +	macb_ptp_init(dev);

This leaks PHC instances starting the second time that the interface goes up!

>  	return 0;
>  }
>  
> @@ -2204,7 +2210,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
>  	.get_regs_len		= macb_get_regs_len,
>  	.get_regs		= macb_get_regs,
>  	.get_link		= ethtool_op_get_link,
> -	.get_ts_info		= ethtool_op_get_ts_info,
> +	.get_ts_info		= macb_get_ts_info,

You enable the time stamping logic unconditionally here ...

>  	.get_ethtool_stats	= gem_get_ethtool_stats,
>  	.get_strings		= gem_get_ethtool_strings,
>  	.get_sset_count		= gem_get_sset_count,
> @@ -2221,7 +2227,14 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  	if (!phydev)
>  		return -ENODEV;
>  
> -	return phy_mii_ioctl(phydev, rq, cmd);
> +	switch (cmd) {
> +	case SIOCSHWTSTAMP:
> +		return macb_hwtst_set(dev, rq, cmd);
> +	case SIOCGHWTSTAMP:
> +		return macb_hwtst_get(dev, rq);

and here.

Is that logic always available on every MACB device?  If so, is the
implementation also identical?

Thanks,
Richard
