From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH 2/2] macb: Enable 1588 support in SAMA5D2 platform.
Date: Tue, 6 Sep 2016 18:37:18 +0200
Message-ID: <20160906163718.GB7012@localhost.localdomain>
References: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com>
 <1472820817-21874-2-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tbultel@pixelsurmer.com, boris.brezillon@free-electrons.com,
 netdev@vger.kernel.org, alexandre.belloni@free-electrons.com,
 nicolas.ferre@atmel.com, linux-kernel@vger.kernel.org,
 harinikatakamlinux@gmail.com, michals@xilinx.com, anirudh@xilinx.com,
 punnaia@xilinx.com, harini.katakam@xilinx.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1472820817-21874-2-git-send-email-andrei.pistirica@microchip.com>
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

On Fri, Sep 02, 2016 at 02:53:37PM +0200, Andrei Pistirica wrote:
> Hardware time stamp on the PTP Ethernet packets are received using the
> SO_TIMESTAMPING API. Timers are obtained from the PTP event/peer
> gem registers.
> 
> Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
> ---
> Integration with SAMA5D2 only. This feature wasn't tested on any
> other platform that might use cadence/gem.

What does that mean?  I didn't see any references to SAMA5D2 anywhere
in your patch.

The driver needs to positively identify the HW that supports this
feature.

> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 8d54e7b..18f0715 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -697,6 +697,11 @@ static void macb_tx_interrupt(struct macb_queue *queue)
>  
>  			/* First, update TX stats if needed */
>  			if (skb) {
> +/* guard the hot-path */
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +				if (bp->hwts_tx_en)
> +					macb_ptp_do_txstamp(bp, skb);
> +#endif

Pull the test into the helper function, and then you can drop the
ifdef and the funny comment.

>  				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
>  					    macb_tx_ring_wrap(tail), skb->data);
>  				bp->stats.tx_packets++;
> @@ -853,6 +858,11 @@ static int gem_rx(struct macb *bp, int budget)
>  		    GEM_BFEXT(RX_CSUM, ctrl) & GEM_RX_CSUM_CHECKED_MASK)
>  			skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
> +/* guard the hot-path */
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +		if (bp->hwts_rx_en)
> +			macb_ptp_do_rxstamp(bp, skb);
> +#endif

Same here.

>  		bp->stats.rx_packets++;
>  		bp->stats.rx_bytes += skb->len;
>  
> @@ -1723,6 +1733,11 @@ static void macb_init_hw(struct macb *bp)
>  
>  	/* Enable TX and RX */
>  	macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE));
> +
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +	bp->hwts_tx_en = 0;
> +	bp->hwts_rx_en = 0;
> +#endif

We don't initialize to zero unless we have to.

>  }
>  
>  /*
> @@ -1885,6 +1900,8 @@ static int macb_open(struct net_device *dev)
>  
>  	netif_tx_start_all_queues(dev);
>  
> +	macb_ptp_init(dev);
> +
>  	return 0;
>  }
>  
> @@ -2143,7 +2160,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
>  	.get_regs_len		= macb_get_regs_len,
>  	.get_regs		= macb_get_regs,
>  	.get_link		= ethtool_op_get_link,
> -	.get_ts_info		= ethtool_op_get_ts_info,
> +	.get_ts_info		= macb_get_ts_info,
>  	.get_ethtool_stats	= gem_get_ethtool_stats,
>  	.get_strings		= gem_get_ethtool_strings,
>  	.get_sset_count		= gem_get_sset_count,
> @@ -2157,6 +2174,12 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  	if (!netif_running(dev))
>  		return -EINVAL;
>  
> +	if (cmd == SIOCSHWTSTAMP)
> +		return macb_hwtst_set(dev, rq, cmd);
> +
> +	if (cmd == SIOCGHWTSTAMP)
> +		return macb_hwtst_get(dev, rq);

switch/case?

> +
>  	if (!phydev)
>  		return -ENODEV;
>  
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 8c3779d..555316a 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -920,8 +920,21 @@ struct macb {
>  
>  #ifdef CONFIG_MACB_USE_HWSTAMP
>  void macb_ptp_init(struct net_device *ndev);
> +void macb_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb);
> +void macb_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb);
> +int macb_ptp_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info);
> +#define macb_get_ts_info macb_ptp_get_ts_info
> +int macb_hwtst_set(struct net_device *netdev, struct ifreq *ifr, int cmd);
> +int macb_hwtst_get(struct net_device *netdev, struct ifreq *ifr);
>  #else
>  void macb_ptp_init(struct net_device *ndev) { }
> +void macb_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb) { }
> +void macb_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb) { }
> +#define macb_get_ts_info ethtool_op_get_ts_info
> +int macb_hwtst_set(struct net_device *netdev, struct ifreq *ifr, int cmd)
> +	{ return -1; }
> +int macb_hwtst_get(struct net_device *netdev, struct ifreq *ifr)
> +	{ return -1; }

Use a proper return code please.

>  #endif
>  
>  static inline bool macb_is_gem(struct macb *bp)
> diff --git a/drivers/net/ethernet/cadence/macb_ptp.c b/drivers/net/ethernet/cadence/macb_ptp.c
> index 6d6a6ec..e3f784a 100644
> --- a/drivers/net/ethernet/cadence/macb_ptp.c
> +++ b/drivers/net/ethernet/cadence/macb_ptp.c
> @@ -5,6 +5,7 @@
>   * Copyright (C) 2016 Microchip Technology
>   *
>   * Authors: Harini Katakam <harinik@xilinx.com>
> + *	    Andrei Pistirica <andrei.pistirica@microchip.com>

We don't add additional authors any more, because git tells us that info.

>   *
>   * This file is licensed under the terms of the GNU General Public
>   * License version 2. This program is licensed "as is" without any
> @@ -222,3 +223,219 @@ void macb_ptp_init(struct net_device *ndev)
>  
>  	dev_info(&bp->pdev->dev, "%s ptp clock registered.\n", GMAC_TIMER_NAME);
>  }
> +
> +/* While the GEM can timestamp PTP packets, it does not mark the RX descriptor
> + * to identify them. This is entirely the wrong place to be parsing UDP
> + * headers, but some minimal effort must be made.

If you must parse, then it isn't the wrong place.

> + *
> + * Note: Inspired from drivers/net/ethernet/ti/cpts.c
> + */
> +static inline int macb_get_ptp_peer(struct sk_buff *skb, int ptp_class)

Leave off inline, let the compiler decide.

> +{
> +	unsigned int offset = 0;
> +	u8 *msgtype, *data = skb->data;
> +
> +	if (ptp_class == PTP_CLASS_NONE)
> +		return -1;
> +
> +	if (ptp_class & PTP_CLASS_VLAN)
> +		offset += VLAN_HLEN;
> +
> +	switch (ptp_class & PTP_CLASS_PMASK) {
> +	case PTP_CLASS_IPV4:
> +		offset += ETH_HLEN + IPV4_HLEN(data + offset) + UDP_HLEN;
> +	break;
> +	case PTP_CLASS_IPV6:
> +		offset += ETH_HLEN + IP6_HLEN + UDP_HLEN;
> +	break;
> +	case PTP_CLASS_L2:
> +		offset += ETH_HLEN;
> +		break;
> +
> +	/* something went wrong! */
> +	default:
> +		return -1;
> +	}
> +
> +	if (skb->len + ETH_HLEN < offset + OFF_PTP_SEQUENCE_ID)
> +		return -1;
> +
> +	if (unlikely(ptp_class & PTP_CLASS_V1))
> +		msgtype = data + offset + OFF_PTP_CONTROL;
> +	else
> +		msgtype = data + offset;
> +
> +	return (*msgtype) & 0x2;
> +}
> +
> +static inline void macb_ptp_tx_hwtstamp(struct macb *bp, struct sk_buff *skb,
> +					int peer_ev)

no 'inline' please

> +{
> +	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> +	struct timespec64 ts;
> +	u64 ns;
> +
> +	/* PTP Peer Event Frame packets */
> +	if (peer_ev) {
> +		ts.tv_sec = gem_readl(bp, PEFTSL);
> +		ts.tv_nsec = gem_readl(bp, PEFTN);
> +
> +	/* PTP Event Frame packets */
> +	} else {
> +		ts.tv_sec = gem_readl(bp, EFTSL);
> +		ts.tv_nsec = gem_readl(bp, EFTN);
> +	}
> +	ns = timespec64_to_ns(&ts);
> +
> +	memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
> +	shhwtstamps->hwtstamp = ns_to_ktime(ns);
> +	skb_tstamp_tx(skb, skb_hwtstamps(skb));
> +}
> +
> +inline void macb_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb)

s/inline/static/

> +{
> +	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) {
> +		int class = ptp_classify_raw(skb);
> +		int peer;
> +
> +		peer = macb_get_ptp_peer(skb, class);
> +		if (peer < 0)
> +			return;
> +
> +		/* Timestamp this packet */
> +		macb_ptp_tx_hwtstamp(bp, skb, peer);
> +	}
> +}
> +
> +static inline void macb_ptp_rx_hwtstamp(struct macb *bp, struct sk_buff *skb,
> +					int peer_ev)
> +{
> +	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> +	struct timespec64 ts;
> +	u64 ns;
> +
> +	if (peer_ev) {
> +		/* PTP Peer Event Frame packets */
> +		ts.tv_sec = gem_readl(bp, PEFRSL);
> +		ts.tv_nsec = gem_readl(bp, PEFRN);
> +	} else {
> +		/* PTP Event Frame packets */
> +		ts.tv_sec = gem_readl(bp, EFRSL);
> +		ts.tv_nsec = gem_readl(bp, EFRN);
> +	}

So you say the HW provides no matching information?  Then it is really
poor.  I surely don't want to let this out into the wild.  I'll get
questions on the linuxptp list, like "PTP on mainline Linux is
mysteriously broken!"

> +	ns = timespec64_to_ns(&ts);
> +
> +	memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
> +	shhwtstamps->hwtstamp = ns_to_ktime(ns);
> +}
> +
> +inline void macb_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb)
> +{
> +	int class;
> +	int peer;
> +
> +	/* ffs !!! */

What is this comment for?

> +	__skb_push(skb, ETH_HLEN);
> +	class = ptp_classify_raw(skb);
> +	__skb_pull(skb, ETH_HLEN);
> +
> +	peer = macb_get_ptp_peer(skb, class);
> +	if (peer < 0)
> +		return;
> +
> +	macb_ptp_rx_hwtstamp(bp, skb, peer);
> +}

Thanks,
Richard
