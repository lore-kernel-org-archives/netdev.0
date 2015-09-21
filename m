From: Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 2/3] net: macb: Add support for 1588 for Zynq
 Ultrascale+ MPSoC
Date: Mon, 21 Sep 2015 23:19:32 +0530
Message-ID: <CAFcVECLfXL-=efbUhNeKhiFQgtfv6Z1+JJckg+js7DM-LfFeSw@mail.gmail.com>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
	<1441958258-35441-3-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org" <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org
To: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441958258-35441-3-git-send-email-harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 1:27 PM, Harini Katakam
<harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org> wrote:
> Cadence GEM in Zynq Ultrascale+ MPSoC supports 1588 and provides a
> 102 bit time counter with 48 bits for seconds, 30 bits for nsecs and
> 24 bits for sub-nsecs. The timestamp is made available to the SW through
> registers as well as (more precisely) through upper two words in
> an extended BD.
>
> This patch does the following:
> - Adds MACB_CAPS_TSU in zynqmp_config.
> - Registers to ptp clock framework (after checking for timestamp support in
>   IP and capability in config).
> - TX BD and RX BD control registers are written to populate timestamp in
>   extended BD words.
> - Timer initialization is done by writing time of day to the timer counter.
> - ns increment register is programmed as NS_PER_SEC/TSU_CLK.
>   For a 24 bit subns precision, the subns increment equals
>   remainder of (NS_PER_SEC/TSU_CLK) * (2^24).
>   TSU (Time stamp unit) clock is obtained by the  driver from devicetree.
> - HW time stamp capabilities are advertised via ethtool and macb ioctl is
>   updated accordingly.
> - For all PTP event frames, nanoseconds and the lower 5 bits of seconds are
>   obtained from the BD. This offers a precise timestamp. The upper bits
>   (which dont vary between consecutive packets) are obtained from the
>   TX/RX PTP event/PEER registers. The timestamp obtained thus is updated
>   in skb for upper layers to access.
> - The drivers register functions with ptp to perform time and frequency
>   adjustment.
> - Time adjustment is done by writing to the 1558_ADJUST register.
>   The controller will read the delta in this register and update the timer
>   counter register. Alternatively, for large time offset adjustments,
>   the driver reads the secs and nsecs counter values, adds/subtracts the
>   delta and updates the timer counter. In order to be as precise as possible,
>   nsecs counter is read again if secs has incremented during the counter read.
> - Frequency adjustment is not directly supported by this IP.
>   addend is the initial value ns increment and similarly addendesub.
>   The ppb (parts per billion) provided is used as
>   ns_incr = addend +/- (ppb/rate).
>   Similarly the remainder of the above is used to populate subns increment.
>   In case the ppb requested is negative AND subns adjustment greater than
>   the addendsub, ns_incr is reduced by 1 and subns_incr is adjusted in
>   positive accordingly.
>
> Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>:
> ---
>  drivers/net/ethernet/cadence/macb.c |  372 ++++++++++++++++++++++++++++++++++-
>  drivers/net/ethernet/cadence/macb.h |   64 ++++++
>  2 files changed, 428 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index bb2932c..b531008 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -30,6 +30,8 @@
>  #include <linux/of_device.h>
>  #include <linux/of_mdio.h>
>  #include <linux/of_net.h>
> +#include <linux/net_tstamp.h>
> +#include <linux/ptp_clock_kernel.h>
>
>  #include "macb.h"
>
> @@ -56,6 +58,9 @@
>
>  #define GEM_MTU_MIN_SIZE       68
>
> +#define GEM_TX_PTPHDR_OFFSET   42
> +#define GEM_RX_PTPHDR_OFFSET   28
> +
>  /*
>   * Graceful stop timeouts in us. We should allow up to
>   * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
> @@ -165,6 +170,9 @@ static void macb_set_hwaddr(struct macb *bp)
>         top = cpu_to_le16(*((u16 *)(bp->dev->dev_addr + 4)));
>         macb_or_gem_writel(bp, SA1T, top);
>
> +       gem_writel(bp, RXPTPUNI, bottom);
> +       gem_writel(bp, TXPTPUNI, bottom);
> +
>         /* Clear unused address register sets */
>         macb_or_gem_writel(bp, SA2B, 0);
>         macb_or_gem_writel(bp, SA2T, 0);
> @@ -653,6 +661,40 @@ static void macb_tx_error_task(struct work_struct *work)
>         spin_unlock_irqrestore(&bp->lock, flags);
>  }
>
> +static inline void macb_handle_txtstamp(struct macb *bp, struct sk_buff *skb,
> +                                       struct macb_dma_desc *desc)
> +{
> +       u32 ts_s, ts_ns;
> +       u8 msg_type;
> +
> +       skb_copy_from_linear_data_offset(skb, GEM_TX_PTPHDR_OFFSET,
> +                                        &msg_type, 1);
> +
> +       /* Bit[32:6] of TS secs from register
> +        * Bit[5:0] of TS secs from BD
> +        * TS nano secs is available in BD
> +        */
> +       if (msg_type & 0x2) {
> +               /* PTP Peer Event Frame packets */
> +               ts_s = (gem_readl(bp, 1588PEERTXSEC) & GEM_SEC_MASK) |
> +                      ((desc->tsl >> GEM_TSL_SEC_RS) |
> +                      (desc->tsh << GEM_TSH_SEC_LS));
> +               ts_ns = desc->tsl & GEM_TSL_NSEC_MASK;
> +       } else {
> +               /* PTP Event Frame packets */
> +               ts_s = (gem_readl(bp, 1588TXSEC) & GEM_SEC_MASK) |
> +                      ((desc->tsl >> GEM_TSL_SEC_RS) |
> +                      (desc->tsh << GEM_TSH_SEC_LS));
> +               ts_ns = desc->tsl & GEM_TSL_NSEC_MASK;
> +       }
> +
> +       struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> +
> +       memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
> +       shhwtstamps->hwtstamp = ns_to_ktime((ts_s * NS_PER_SEC) + ts_ns);
> +       skb_tstamp_tx(skb, skb_hwtstamps(skb));
> +}
> +
>  static void macb_tx_interrupt(struct macb_queue *queue)
>  {
>         unsigned int tail;
> @@ -703,6 +745,10 @@ static void macb_tx_interrupt(struct macb_queue *queue)
>                                 bp->stats.tx_bytes += skb->len;
>                         }
>
> +#ifdef CONFIG_MACB_EXT_BD
> +                       if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)
> +                               macb_handle_txtstamp(bp, skb, desc);
> +#endif
>                         /* Now we can safely release resources */
>                         macb_tx_unmap(bp, tx_skb);
>
> @@ -796,6 +842,39 @@ static void discard_partial_frame(struct macb *bp, unsigned int begin,
>          */
>  }
>
> +static inline void macb_handle_rxtstamp(struct macb *bp, struct sk_buff *skb,
> +                                       struct macb_dma_desc *desc)
> +{
> +       u8 msg_type;
> +       u32 ts_ns, ts_s;
> +
> +       skb_copy_from_linear_data_offset(skb, GEM_RX_PTPHDR_OFFSET,
> +                                        &msg_type, 1);
> +
> +       /* Bit[32:6] of TS secs from register
> +        * Bit[5:0] of TS secs from BD
> +        * TS nano secs is available in BD
> +        */
> +       if (msg_type & 0x2) {
> +               /* PTP Peer Event Frame packets */
> +               ts_s = (gem_readl(bp, 1588PEERRXSEC) & GEM_SEC_MASK) |
> +                       ((desc->tsl >> GEM_TSL_SEC_RS) |
> +                       (desc->tsh << GEM_TSH_SEC_LS));
> +               ts_ns = desc->tsl & GEM_TSL_NSEC_MASK;
> +       } else {
> +               /* PTP Event Frame packets */
> +               ts_s = (gem_readl(bp, 1588RXSEC) & GEM_SEC_MASK) |
> +                       ((desc->tsl >> GEM_TSL_SEC_RS) |
> +                       (desc->tsh << GEM_TSH_SEC_LS));
> +               ts_ns = desc->tsl & GEM_TSL_NSEC_MASK;
> +       }
> +
> +       struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> +
> +       memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
> +       shhwtstamps->hwtstamp = ns_to_ktime((ts_s * NS_PER_SEC) + ts_ns);
> +}
> +
>  static int gem_rx(struct macb *bp, int budget)
>  {
>         unsigned int            len;
> @@ -847,6 +926,12 @@ static int gem_rx(struct macb *bp, int budget)
>                                  bp->rx_buffer_size, DMA_FROM_DEVICE);
>
>                 skb->protocol = eth_type_trans(skb, bp->dev);
> +
> +#ifdef CONFIG_MACB_EXT_BD
> +               if (addr & GEM_RX_TS_MASK)
> +                       macb_handle_rxtstamp(bp, skb, desc);
> +#endif
> +
>                 skb_checksum_none_assert(skb);
>                 if (bp->dev->features & NETIF_F_RXCSUM &&
>                     !(bp->dev->flags & IFF_PROMISC) &&
> @@ -1636,6 +1721,193 @@ static u32 macb_dbw(struct macb *bp)
>         }
>  }
>
> +static inline void macb_ptp_read(struct macb *bp, struct timespec *ts)
> +{
> +       ts->tv_sec = gem_readl(bp, 1588S);
> +       ts->tv_nsec = gem_readl(bp, 1588NS);
> +
> +       if (ts->tv_sec < gem_readl(bp, 1588S))
> +               ts->tv_nsec = gem_readl(bp, 1588NS);
> +}
> +
> +static inline void macb_ptp_write(struct macb *bp, const struct timespec *ts)
> +{
> +       gem_writel(bp, 1588S, ts->tv_sec);
> +       gem_writel(bp, 1588NS, ts->tv_nsec);
> +}
> +
> +static int macb_ptp_enable(struct ptp_clock_info *ptp,
> +                          struct ptp_clock_request *rq, int on)
> +{
> +       return -EOPNOTSUPP;
> +}
> +
> +static void macb_ptp_close(struct macb *bp)
> +{
> +       /* Clear the time counters */
> +       gem_writel(bp, 1588NS, 0);
> +       gem_writel(bp, 1588S, 0);
> +       gem_writel(bp, 1588ADJ, 0);
> +       gem_writel(bp, 1588INCR, 0);
> +
> +       ptp_clock_unregister(bp->ptp_clock);
> +}
> +
> +static int macb_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
> +{
> +       struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +
> +       macb_ptp_read(bp, ts);
> +
> +       return 0;
> +}
> +
> +static int macb_ptp_settime(struct ptp_clock_info *ptp,
> +                           const struct timespec *ts)
> +{
> +       struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +
> +       macb_ptp_write(bp, ts);
> +
> +       return 0;
> +}
> +
> +static int macb_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
> +{
> +       struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +       struct timespec now, then = ns_to_timespec(delta);
> +       u32 adj, sign = 0;
> +
> +       if (delta < 0) {
> +               delta = -delta;
> +               sign = 1;
> +       }
> +
> +       if (delta > 0x3FFFFFFF) {
> +               macb_ptp_read(bp, &now);
> +
> +               if (sign)
> +                       now = timespec_sub(now, then);
> +               else
> +                       now = timespec_add(now, then);
> +
> +               macb_ptp_write(bp, (const struct timespec *)&now);
> +       } else {
> +               adj = delta;
> +               if (sign)
> +                       adj |= GEM_BIT(ADDSUB);
> +
> +               gem_writel(bp, 1588ADJ, adj);
> +       }
> +
> +       return 0;
> +}
> +
> +static int macb_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
> +{
> +       struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +       unsigned long rate = bp->tsu_clk;
> +       u64 adjsub;
> +       u32 addend, diff;
> +       u32 diffsub, addendsub;
> +       bool neg_adj = false;
> +       u32 subnsreg, rem;
> +
> +       if (ppb < 0) {
> +               neg_adj = true;
> +               ppb = -ppb;
> +       }
> +
> +       addend = bp->ns_incr;
> +       addendsub = bp->subns_incr;
> +
> +       diff = div_u64_rem(ppb, rate, &rem);
> +       addend = neg_adj ? addend - diff : addend + diff;
> +
> +       if (rem) {
> +               adjsub = rem;
> +               /* Multiple by 2^24 as subns field is 24 bits */
> +               adjsub = adjsub << 24;
> +
> +               diffsub = div_u64(adjsub, rate);
> +       } else {
> +               diffsub = 0;
> +       }
> +
> +       if (neg_adj && (diffsub > addendsub)) {
> +               addend -= 1;
> +               rem = (NS_PER_SEC - rem);
> +               neg_adj = false;
> +
> +               adjsub = rem;
> +               adjsub = adjsub << 24;
> +               diffsub = div_u64(adjsub, rate);
> +       }
> +
> +       addendsub = neg_adj ? addendsub - diffsub : addendsub + diffsub;
> +       /* RegBit[15:0] = Subns[23:8]; RegBit[31:24] = Subns[7:0] */
> +       subnsreg = ((addendsub & GEM_SUBNSINCL_MASK) << GEM_SUBNSINCL_SHFT) |
> +                  ((addendsub & GEM_SUBNSINCH_MASK) >> GEM_SUBNSINCH_SHFT);
> +
> +       gem_writel(bp, 1588INCRSUBNS, subnsreg);
> +       gem_writel(bp, 1588INCR, GEM_BF(NSINCR, addend));
> +
> +       return 0;
> +}
> +
> +static void macb_ptp_init(struct macb *bp)
> +{
> +       struct timespec now;
> +       unsigned long rate;
> +       u32 subnsreg, rem = 0;
> +       u64 adj;
> +
> +       bp->ptp_caps.owner = THIS_MODULE;
> +       bp->ptp_caps.max_adj = 250000000;
> +       bp->ptp_caps.n_alarm = 0;
> +       bp->ptp_caps.n_ext_ts = 0;
> +       bp->ptp_caps.n_per_out = 0;
> +       bp->ptp_caps.pps = 0;
> +       bp->ptp_caps.adjtime = macb_ptp_adjtime;
> +       bp->ptp_caps.gettime = macb_ptp_gettime;
> +       bp->ptp_caps.settime = macb_ptp_settime;
> +       bp->ptp_caps.enable = macb_ptp_enable;
> +       bp->ptp_caps.adjfreq = macb_ptp_adjfreq;
> +
> +       rate = bp->tsu_clk;
> +
> +       getnstimeofday(&now);
> +       gem_writel(bp, 1588SMSB, 0);
> +       macb_ptp_write(bp, (const struct timespec *)&now);
> +
> +       bp->ns_incr = div_u64_rem(NS_PER_SEC, rate, &rem);
> +       if (rem) {
> +               adj = rem;
> +               /* Multiply by 2^24 as subns register is 24 bits */
> +               adj = adj << 24;
> +
> +               bp->subns_incr = div_u64(adj, rate);
> +       } else {
> +               bp->subns_incr = 0;
> +       }
> +
> +       /* RegBit[15:0] = Subns[23:8]; RegBit[31:24] = Subns[7:0] */
> +       subnsreg = ((bp->subns_incr & GEM_SUBNSINCL_MASK)
> +                   << GEM_SUBNSINCL_SHFT) |
> +                  ((bp->subns_incr & GEM_SUBNSINCH_MASK)
> +                   >> GEM_SUBNSINCH_SHFT);
> +       gem_writel(bp, 1588INCRSUBNS, subnsreg);
> +       gem_writel(bp, 1588INCR, bp->ns_incr);
> +       gem_writel(bp, 1588ADJ, 0);
> +
> +       bp->ptp_clock = ptp_clock_register(&bp->ptp_caps, &bp->pdev->dev);
> +       if (IS_ERR(bp->ptp_clock)) {
> +               bp->ptp_clock = NULL;
> +               netdev_err(bp->dev, "ptp_clock_register failed\n");
> +       }
> +       bp->phc_index = ptp_clock_index(bp->ptp_clock);
> +}
> +
>  /*
>   * Configure the receive DMA engine
>   * - use the correct receive buffer size
> @@ -1686,6 +1958,7 @@ static void macb_init_hw(struct macb *bp)
>         macb_set_hwaddr(bp);
>
>         config = macb_mdc_clk_div(bp);
> +       config |= macb_readl(bp, NCFGR) & (3 << 21);
>         config |= MACB_BF(RBOF, NET_IP_ALIGN);  /* Make eth data aligned */
>         config |= MACB_BIT(PAE);                /* PAuse Enable */
>         config |= MACB_BIT(DRFCS);              /* Discard Rx FCS */
> @@ -1709,6 +1982,18 @@ static void macb_init_hw(struct macb *bp)
>         if (bp->caps & MACB_CAPS_JUMBO)
>                 bp->rx_frm_len_mask = MACB_RX_JFRMLEN_MASK;
>
> +       gem_writel(bp, TXBDCNTRL,
> +                  (gem_readl(bp, TXBDCNTRL) & ~(GEM_TXBDCNTRL_MODE_ALL)) |
> +                  GEM_TXBDCNTRL_MODE_PTP_EVNT);
> +       gem_writel(bp, RXBDCNTRL,
> +                  (gem_readl(bp, RXBDCNTRL) & ~(GEM_RXBDCNTRL_MODE_ALL)) |
> +                  GEM_RXBDCNTRL_MODE_PTP_EVNT);
> +
> +       if ((gem_readl(bp, DCFG5) & GEM_BIT(TSU)) &&
> +           (bp->caps & MACB_CAPS_TSU)) {
> +               macb_ptp_init(bp);
> +       }
> +
>         macb_configure_dma(bp);
>
>         /* Initialize TX and RX buffers */
> @@ -1724,7 +2009,8 @@ static void macb_init_hw(struct macb *bp)
>         }
>
>         /* Enable TX and RX */
> -       macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE));
> +       macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE) |
> +                   MACB_BIT(PTPUNI));
>  }
>
>  /*
> @@ -1903,6 +2189,7 @@ static int macb_close(struct net_device *dev)
>
>         spin_lock_irqsave(&bp->lock, flags);
>         macb_reset_hw(bp);
> +       macb_ptp_close(bp);
>         netif_carrier_off(dev);
>         spin_unlock_irqrestore(&bp->lock, flags);
>
> @@ -2130,6 +2417,23 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
>         }
>  }
>
> +static int macb_get_ts_info(struct net_device *dev,
> +                           struct ethtool_ts_info *info)
> +{
> +       struct macb *bp = netdev_priv(dev);
> +
> +       info->so_timestamping = SOF_TIMESTAMPING_TX_HARDWARE |
> +                               SOF_TIMESTAMPING_RX_HARDWARE |
> +                               SOF_TIMESTAMPING_RAW_HARDWARE;
> +       info->phc_index = bp->phc_index;
> +       info->tx_types = (1 << HWTSTAMP_TX_OFF) |
> +                        (1 << HWTSTAMP_TX_ON);
> +       info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
> +                          (1 << HWTSTAMP_FILTER_ALL);
> +
> +       return 0;
> +}
> +
>  static const struct ethtool_ops macb_ethtool_ops = {
>         .get_settings           = macb_get_settings,
>         .set_settings           = macb_set_settings,
> @@ -2145,24 +2449,74 @@ static const struct ethtool_ops gem_ethtool_ops = {
>         .get_regs_len           = macb_get_regs_len,
>         .get_regs               = macb_get_regs,
>         .get_link               = ethtool_op_get_link,
> -       .get_ts_info            = ethtool_op_get_ts_info,
> +       .get_ts_info            = macb_get_ts_info,
>         .get_ethtool_stats      = gem_get_ethtool_stats,
>         .get_strings            = gem_get_ethtool_strings,
>         .get_sset_count         = gem_get_sset_count,
>  };
>
> +static int macb_hwtstamp_ioctl(struct net_device *dev,
> +                              struct ifreq *ifr, int cmd)
> +{
> +       struct hwtstamp_config config;
> +
> +       if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
> +               return -EFAULT;
> +
> +       /* reserved for future extensions */
> +       if (config.flags)
> +               return -EINVAL;
> +
> +       if ((config.tx_type != HWTSTAMP_TX_OFF) &&
> +           (config.tx_type != HWTSTAMP_TX_ON))
> +               return -ERANGE;
> +
> +       switch (config.rx_filter) {
> +       case HWTSTAMP_FILTER_NONE:
> +               break;
> +       case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
> +       case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
> +       case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
> +       case HWTSTAMP_FILTER_ALL:
> +       case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
> +       case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
> +       case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
> +       case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
> +       case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
> +       case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
> +       case HWTSTAMP_FILTER_PTP_V2_EVENT:
> +       case HWTSTAMP_FILTER_PTP_V2_SYNC:
> +       case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
> +               config.rx_filter = HWTSTAMP_FILTER_ALL;
> +               break;
> +       default:
> +               return -ERANGE;
> +       }
> +
> +       config.tx_type = HWTSTAMP_TX_ON;
> +
> +       return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
> +               -EFAULT : 0;
> +}
> +
>  static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  {
>         struct macb *bp = netdev_priv(dev);
>         struct phy_device *phydev = bp->phy_dev;
>
> -       if (!netif_running(dev))
> -               return -EINVAL;
> +       switch (cmd) {
> +       case SIOCSHWTSTAMP:
> +                       return macb_hwtstamp_ioctl(dev, rq, cmd);
>
> -       if (!phydev)
> -               return -ENODEV;
> +       default:
> +               if (!netif_running(dev))
> +                       return -EINVAL;
> +
> +               if (!phydev)
> +                       return -ENODEV;
>
> -       return phy_mii_ioctl(phydev, rq, cmd);
> +               return phy_mii_ioctl(phydev, rq, cmd);
> +       }
>  }
>
>  static int macb_set_features(struct net_device *netdev,
> @@ -2778,7 +3132,7 @@ static const struct macb_config emac_config = {
>
>
>  static const struct macb_config zynqmp_config = {
> -       .caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
> +       .caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO | MACB_CAPS_TSU,
>         .dma_burst_length = 16,
>         .clk_init = macb_clk_init,
>         .init = macb_init,
> @@ -2885,6 +3239,8 @@ static int macb_probe(struct platform_device *pdev)
>         if (macb_config)
>                 bp->jumbo_max_len = macb_config->jumbo_max_len;
>
> +       of_property_read_u32(pdev->dev.of_node, "tsu-clk", &bp->tsu_clk);
> +
>         spin_lock_init(&bp->lock);
>
>         /* setup capabilities */
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 58c9870..16edad4 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -82,6 +82,8 @@
>  #define GEM_SA3T               0x009C /* Specific3 Top */
>  #define GEM_SA4B               0x00A0 /* Specific4 Bottom */
>  #define GEM_SA4T               0x00A4 /* Specific4 Top */
> +#define GEM_RXPTPUNI           0x00D4 /* PTP RX Unicast address */
> +#define GEM_TXPTPUNI           0x00D8 /* PTP TX Unicast address */
>  #define GEM_OTX                        0x0100 /* Octets transmitted */
>  #define GEM_OCTTXL             0x0100 /* Octets transmitted [31:0] */
>  #define GEM_OCTTXH             0x0104 /* Octets transmitted [47:32] */
> @@ -129,6 +131,20 @@
>  #define GEM_RXIPCCNT           0x01a8 /* IP header Checksum Error Counter */
>  #define GEM_RXTCPCCNT          0x01ac /* TCP Checksum Error Counter */
>  #define GEM_RXUDPCCNT          0x01b0 /* UDP Checksum Error Counter */
> +#define GEM_1588INCRSUBNS      0x01BC /* 1588 timer sub nsec increment */
> +#define GEM_1588SMSB           0x01C0 /* 1588 timer seconds register[47:32] */
> +#define GEM_1588S              0x01D0 /* 1588 timer seconds register[31:0] */
> +#define GEM_1588NS             0x01D4 /* 1588 timer nano seconds register */
> +#define GEM_1588ADJ            0x01D8 /* 1588 timer adjust register */
> +#define GEM_1588INCR           0x01DC /* 1588 timer increment register */
> +#define GEM_1588TXSEC          0x01E0 /* PTP event TX timestamp secs */
> +#define GEM_1588TXNSEC         0x01E4 /* PTP event TX timestamp nsecs */
> +#define GEM_1588RXSEC          0x01E8 /* PTP event RX timestamp secs */
> +#define GEM_1588RXNSEC         0x01EC /* PTP event RX timestamp nsecs */
> +#define GEM_1588PEERTXSEC      0x01F0 /* PTP peer event TX timestamp secs */
> +#define GEM_1588PEERTXNSEC     0x01F4 /* PTP peer event TX timestamp nsecs */
> +#define GEM_1588PEERRXSEC      0x01F8 /* PTP peer event RX timestamp secs */
> +#define GEM_1588PEERRXNSEC     0x01FC /* PTP peer event RX timestamp nsecs */
>  #define GEM_DCFG1              0x0280 /* Design Config 1 */
>  #define GEM_DCFG2              0x0284 /* Design Config 2 */
>  #define GEM_DCFG3              0x0288 /* Design Config 3 */
> @@ -136,6 +152,8 @@
>  #define GEM_DCFG5              0x0290 /* Design Config 5 */
>  #define GEM_DCFG6              0x0294 /* Design Config 6 */
>  #define GEM_DCFG7              0x0298 /* Design Config 7 */
> +#define GEM_TXBDCNTRL          0x04CC /* TX descriptor control */
> +#define GEM_RXBDCNTRL          0x04D0 /* RX descriptor control */
>
>  #define GEM_ISR(hw_q)          (0x0400 + ((hw_q) << 2))
>  #define GEM_TBQP(hw_q)         (0x0440 + ((hw_q) << 2))
> @@ -171,6 +189,8 @@
>  #define MACB_NCR_TPF_SIZE      1
>  #define MACB_TZQ_OFFSET                12 /* Transmit zero quantum pause frame */
>  #define MACB_TZQ_SIZE          1
> +#define MACB_PTPUNI_OFFSET                     20
> +#define MACB_PTPUNI_SIZE                       1
>
>  /* Bitfields in NCFGR */
>  #define MACB_SPD_OFFSET                0 /* Speed */
> @@ -374,6 +394,34 @@
>  #define GEM_TX_PKT_BUFF_OFFSET                 21
>  #define GEM_TX_PKT_BUFF_SIZE                   1
>
> +/* Bitfields in DCFG5. */
> +#define GEM_TSU_OFFSET                         8
> +#define GEM_TSU_SIZE                           1
> +
> +/* Bitfields in 1588INCRSUBNS */
> +#define GEM_SUBNSINCL_SHFT                     24
> +#define GEM_SUBNSINCL_MASK                     0xFF
> +#define GEM_SUBNSINCH_SHFT                     8
> +#define GEM_SUBNSINCH_MASK                     0xFFFF00
> +
> +/* Bitfields in 1588INCRNS */
> +#define GEM_NSINCR_OFFSET                      0
> +#define GEM_NSINCR_SIZE                                8
> +
> +/* Bitfields in 1588ADJ */
> +#define GEM_ADDSUB_OFFSET                      31
> +#define GEM_ADDSUB_SIZE                                1
> +
> +/* Bitfields in TXBDCNTRL */
> +#define GEM_TXBDCNTRL_MODE_ALL                 0x00000030
> +#define GEM_TXBDCNTRL_MODE_PTP_EVNT            0x00000010
> +#define GEM_TXBDCNTRL_MODE_PTP_ALL             0x00000020
> +
> +/* Bitfields in RXBDCNTRL */
> +#define GEM_RXBDCNTRL_MODE_ALL                 0x00000030
> +#define GEM_RXBDCNTRL_MODE_PTP_EVNT            0x00000010
> +#define GEM_RXBDCNTRL_MODE_PTP_ALL             0x00000020
> +
>  /* Constants for CLK */
>  #define MACB_CLK_DIV8                          0
>  #define MACB_CLK_DIV16                         1
> @@ -404,6 +452,8 @@
>  #define MACB_CAPS_SG_DISABLED                  0x40000000
>  #define MACB_CAPS_MACB_IS_GEM                  0x80000000
>  #define MACB_CAPS_JUMBO                                0x00000010
> +#define MACB_CAPS_TSU                          0x00000020
> +#define NS_PER_SEC                             1000000000ULL
>
>  /* Bit manipulation macros */
>  #define MACB_BIT(name)                                 \
> @@ -550,6 +600,11 @@ struct macb_dma_desc {
>  #define GEM_TX_FRMLEN_OFFSET                   0
>  #define GEM_TX_FRMLEN_SIZE                     14
>
> +#define GEM_SEC_MASK           0xFFFFFFC0
> +#define GEM_TSL_SEC_RS         30
> +#define GEM_TSH_SEC_LS         2
> +#define GEM_TSL_NSEC_MASK      0x3FFFFFFF
> +
>  /* Buffer descriptor constants */
>  #define GEM_RX_CSUM_NONE                       0
>  #define GEM_RX_CSUM_IP_ONLY                    1
> @@ -559,6 +614,8 @@ struct macb_dma_desc {
>  /* limit RX checksum offload to TCP and UDP packets */
>  #define GEM_RX_CSUM_CHECKED_MASK               2
>
> +#define GEM_RX_TS_MASK                         0x4
> +
>  /* struct macb_tx_skb - data about an skb which is being transmitted
>   * @skb: skb currently being transmitted, only set for the last buffer
>   *       of the frame
> @@ -843,6 +900,13 @@ struct macb {
>
>         unsigned int            rx_frm_len_mask;
>         unsigned int            jumbo_max_len;
> +       unsigned int            tsu_clk;
> +       struct ptp_clock        *ptp_clock;
> +       struct ptp_clock_info   ptp_caps;
> +       int                     rx_hwtstamp_filter;
> +       int                     phc_index;
> +       unsigned int            ns_incr;
> +       unsigned int            subns_incr;
>  };
>
>  static inline bool macb_is_gem(struct macb *bp)
> --
> 1.7.9.5
>

Ping

Thanks.

Regards,
Hairni
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
