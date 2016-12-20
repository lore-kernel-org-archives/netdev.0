From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [RFC PATCH net-next v4 2/2] macb: Enable 1588 support in SAMA5Dx
 platforms.
Date: Tue, 20 Dec 2016 16:38:45 +0000
Message-ID: <BN3PR07MB2516E276164A4C2B5F92DDFDC9900@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
 <1481720175-12703-2-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "punnaia@xilinx.com" <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        "anirudh@xilinx.com" <anirudh@xilinx.com>,
        "boris.brezillon@free-electrons.com"
        <boris.brezillon@free-electrons.com>,
        "alexandre.belloni@free-electrons.com"
        <alexandre.belloni@free-electrons.com>,
        "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>
To: Andrei Pistirica <andrei.pistirica@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "harinikatakamlinux@gmail.com" <harinikatakamlinux@gmail.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481720175-12703-2-git-send-email-andrei.pistirica@microchip.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrei Pistirica [mailto:andrei.pistirica@microchip.com]=20
Sent: 14 grudnia 2016 13:56

> This patch does the following:                                           =
                                         =20
> - Enable HW time stamp for the following platforms: SAMA5D2, SAMA5D3 and =
                                         =20
>   SAMA5D4.                                                               =
                                         =20
> - HW time stamp capabilities are advertised via ethtool and macb ioctl is=
                                         =20
>   updated accordingly.                                                   =
                                         =20
> - HW time stamp on the PTP Ethernet packets are received using the       =
                                         =20
>   SO_TIMESTAMPING API. Where timers are obtained from the PTP event/peer =
                                         =20
>   registers.                                                             =
                                         =20
>                                                                          =
                                         =20
> Note: Patch on net-next, on December 7th.                                =
                                         =20
>                                                                          =
                                         =20
> Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>         =
                                         =20
> ---                                                                      =
                                         =20
> Patch history:                                                           =
                                         =20
>                                                                          =
                                         =20
> Version 1:                                                               =
                                         =20
> Integration with SAMA5D2 only. This feature wasn't tested on any other pl=
atform that might use cadence/gem.       =20
>                                                                          =
                                         =20
> Patch is not completely ported to the very latest version of net-next, an=
d it will be after review.               =20
>                                                                          =
                                         =20
> Version 2 modifications:                                                 =
                                         =20
> - add PTP caps for SAMA5D2/3/4 platforms                                 =
                                         =20
> - and cosmetic changes                                                   =
                                         =20
>                                                                          =
                                         =20
> Version 3 modifications:                                                 =
                                         =20
> - add support for sama5D2/3/4 platforms using GEM-PTP interface.         =
                                         =20
>                                                                          =
                                         =20
> Version 4 modifications:                                                 =
                                         =20
> - time stamp only PTP_V2 events                                          =
                                         =20
> - maximum adjustment value is set based on Richard's input               =
                                         =20
>                                                                          =
                                         =20
> Note: Patch on net-next, on December 14th.                               =
                                         =20
>                                                                          =
                                         =20
>  drivers/net/ethernet/cadence/macb.c | 168 ++++++++++++++++++++++++++++++=
++++--                                   =20
>  1 file changed, 163 insertions(+), 5 deletions(-)                       =
                                         =20
>                                                                          =
                                         =20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/c=
adence/macb.c                            =20
> index 538544a..8d5c976 100644                                            =
                                         =20
> --- a/drivers/net/ethernet/cadence/macb.c                                =
                                         =20
> +++ b/drivers/net/ethernet/cadence/macb.c                                =
                                         =20
> @@ -714,6 +714,8 @@ static void macb_tx_interrupt(struct macb_queue *queu=
e)                                       =20
>                                                                          =
                                         =20
>                       /* First, update TX stats if needed */             =
                                         =20
>                       if (skb) {                                         =
                                         =20
> +                             gem_ptp_do_txstamp(bp, skb);               =
                                         =20
> +                                                                        =
                 =20
I think, you can not do it in that way.=20
It will hold two locks. If you enable appropriate option in kernel (as far =
as I=20
remember CONFIG_DEBUG_SPINLOCK) you will get a warning here.

Please look at following call-stack:

1. macb_interrupt()   // spin_lock(&bp->lock) is taken
2. macb_tx_interrupt()
3. macb_handle_txtstamp()
4. skb_tstamp_tx()
5. __skb_tstamp_tx()
6. skb_may_tx_timestamp()
7. read_lock_bh() // second lock is taken

I know that those are different locks and different types. But this could l=
ead=20
to deadlocks. This is the reason of warning I could see.
And this is the reason why I get timestamp in interrupt routine but pass it=
 to=20
skb outside interrupt (using circular buffer).

Please, refer to this:
https://lkml.org/lkml/2016/11/18/168

1. macb_tx_interrupt()
2. macb_tx_timestamp_add() and schedule_work(&queue->tx_timestamp_task)

Then, outside interrupt (without holding a lock) :
1. macb_tx_timestamp_flush()
2. macb_tstamp_tx()
3. skb_tstamp_tx()

>                               netdev_vdbg(bp->dev, "skb %u (data %p) TX c=
omplete\n",                              =20
>                                           macb_tx_ring_wrap(bp, tail),   =
                                         =20
>                                           skb->data);                    =
                                         =20
> @@ -878,6 +880,8 @@ static int gem_rx(struct macb *bp, int budget)       =
                                         =20
>                   GEM_BFEXT(RX_CSUM, ctrl) & GEM_RX_CSUM_CHECKED_MASK)   =
                                         =20
>                       skb->ip_summed =3D CHECKSUM_UNNECESSARY;           =
                                           =20
>                                                                          =
                                         =20
> +             gem_ptp_do_rxstamp(bp, skb);                               =
                                         =20
> +                                                                        =
                                         =20
>               bp->stats.rx_packets++;                                    =
                                         =20
>               bp->stats.rx_bytes +=3D skb->len;                          =
                                           =20
>                                                                          =
                                         =20
> @@ -2080,6 +2084,9 @@ static int macb_open(struct net_device *dev)       =
                                         =20
>                                                                          =
                                         =20
>       netif_tx_start_all_queues(dev);                                    =
                                         =20
>                                                                          =
                                         =20
> +     if (bp->ptp_info)                                                  =
                                         =20
> +             bp->ptp_info->ptp_init(dev);                               =
                                         =20
> +                                                                        =
                                         =20
>       return 0;                                                          =
                                         =20
>  }                                                                       =
                                         =20
>                                                                          =
                                         =20
> @@ -2101,6 +2108,9 @@ static int macb_close(struct net_device *dev)      =
                                         =20
>                                                                          =
                                         =20
>       macb_free_consistent(bp);                                          =
                                         =20
>                                                                          =
                                         =20
> +     if (bp->ptp_info)                                                  =
                                         =20
> +             bp->ptp_info->ptp_remove(dev);                             =
                                         =20
> +                                                                        =
                                         =20
>       return 0;                                                          =
                                         =20
>  }                                                                       =
                                         =20
>                                                                          =
                                         =20
> @@ -2374,6 +2384,133 @@ static int macb_set_ringparam(struct net_device *=
netdev,                                  =20
>       return 0;                                                          =
                                         =20
>  }                                                                       =
                                         =20
>                                                                          =
                                         =20
> +#ifdef CONFIG_MACB_USE_HWSTAMP                                          =
                                         =20
> +static unsigned int gem_get_tsu_rate(struct macb *bp) {                 =
                                         =20
> +     /* Note: TSU rate is hardwired to PCLK. */                         =
                                         =20
> +     return clk_get_rate(bp->pclk);                                     =
                                         =20
> +}    =20
Not exactly. There could be separate TSU clock.=20
In my solution I check tsu_clk in DT before I decide to take pclk.
But it could be change in macb_ptp_info.

> +                                                                        =
                                         =20
> +static s32 gem_get_ptp_max_adj(void)                                    =
                                         =20
> +{                                                                       =
                                         =20
> +     return 3921508;                                                    =
                                         =20
> +}                                                                       =
                                         =20
> +                                                                        =
                                         =20
> +static int gem_get_ts_info(struct net_device *dev,                      =
                                         =20
> +                        struct ethtool_ts_info *info)                   =
                                         =20
> +{                                                                       =
                                         =20
> +     struct macb *bp =3D netdev_priv(dev);                              =
                                           =20
> +                                                                        =
                                         =20
> +     ethtool_op_get_ts_info(dev, info);                                 =
                                         =20
> +     info->so_timestamping =3D                                          =
                                           =20
> +             SOF_TIMESTAMPING_TX_SOFTWARE |                             =
                                         =20
> +             SOF_TIMESTAMPING_RX_SOFTWARE |                             =
                                         =20
> +             SOF_TIMESTAMPING_SOFTWARE |                                =
                                         =20
> +             SOF_TIMESTAMPING_TX_HARDWARE |                             =
                                         =20
> +             SOF_TIMESTAMPING_RX_HARDWARE |                             =
                                         =20
> +             SOF_TIMESTAMPING_RAW_HARDWARE;                             =
                                         =20
> +     info->phc_index =3D -1;                                            =
                                           =20
> +                                                                        =
                                         =20
> +     if (bp->ptp_clock)                                                 =
                                         =20
> +             info->phc_index =3D ptp_clock_index(bp->ptp_clock);        =
                                           =20
> +                                                                        =
                                         =20
> +     return 0;                                                          =
                                         =20
> +}                                                                       =
                                         =20
> +                                                                        =
                                         =20
> +static int gem_set_hwtst(struct net_device *netdev,                     =
                                         =20
> +                      struct ifreq *ifr, int cmd)                       =
                                         =20
> +{                                                                       =
                                         =20
> +     struct hwtstamp_config config;                                     =
                                         =20
> +     struct macb *priv =3D netdev_priv(netdev);                         =
                                           =20
> +     u32 regval;                                                        =
                                         =20
> +                                                                        =
                                         =20
> +     netdev_vdbg(netdev, "macb_hwtstamp_ioctl\n");                      =
                                         =20
> +                                                                        =
                                         =20
> +     if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))        =
                                         =20
> +             return -EFAULT;                                            =
                                         =20
> +                                                                        =
                                         =20
> +     /* reserved for future extensions */                               =
                                         =20
> +     if (config.flags)                                                  =
                                         =20
> +             return -EINVAL;                                            =
                                         =20
> +                                                                        =
                                         =20
> +     switch (config.tx_type) {                                          =
                                         =20
> +     case HWTSTAMP_TX_OFF:                                              =
                                         =20
> +             priv->hwts_tx_en =3D false;                                =
                                           =20
> +             break;                                                     =
                                         =20
> +     case HWTSTAMP_TX_ON:                                               =
                                         =20
> +             priv->hwts_tx_en =3D true;                                 =
                                           =20
> +             break;                                                     =
                                         =20
> +     default:                                                           =
                                         =20
> +             return -ERANGE;                                            =
                                         =20
> +     }                                                                  =
                                         =20
> +                                                                        =
                                         =20
> +     switch (config.rx_filter) {                                        =
                                         =20
> +     case HWTSTAMP_FILTER_NONE:                                         =
                                         =20
> +             if (priv->hwts_rx_en)                                      =
                                         =20
> +                     priv->hwts_rx_en =3D false;                        =
                                           =20
> +             break;                                                     =
                                         =20
> +     case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:                              =
                                         =20
> +     case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:                              =
                                         =20
> +     case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:                               =
                                         =20
> +     case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:                               =
                                         =20
> +     case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:                          =
                                         =20
> +     case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:                          =
                                         =20
> +     case HWTSTAMP_FILTER_PTP_V2_EVENT:                                 =
                                         =20
> +     case HWTSTAMP_FILTER_PTP_V2_SYNC:                                  =
                                         =20
> +     case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:                             =
                                         =20
> +             config.rx_filter =3D HWTSTAMP_FILTER_PTP_V2_EVENT;         =
                                           =20
> +             regval =3D macb_readl(priv, NCR);                          =
                                           =20
> +             macb_writel(priv, NCR, (regval | MACB_BIT(SRTSM)));        =
                                         =20
> +                                                                        =
                                         =20
> +             if (!priv->hwts_rx_en)                                     =
                                         =20
> +                     priv->hwts_rx_en =3D true;                         =
                                           =20
> +             break;                                                     =
                                         =20
> +     default:                                                           =
                                         =20
> +             config.rx_filter =3D HWTSTAMP_FILTER_NONE;                 =
                                           =20
> +             return -ERANGE;                                            =
                                         =20
> +     }                                                                  =
                                         =20
> +                                                                        =
                                         =20
> +     return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?      =
                                         =20
> +             -EFAULT : 0;                                               =
                                         =20
> +}                                                                       =
                                         =20
> +                                                                        =
                                         =20
> +static int gem_get_hwtst(struct net_device *netdev,                     =
                                         =20
> +                      struct ifreq *ifr)                                =
                                         =20
> +{                                                                       =
                                         =20
> +     struct hwtstamp_config config;                                     =
                                         =20
> +     struct macb *priv =3D netdev_priv(netdev);                         =
                                           =20
> +                                                                        =
                                         =20
> +     config.flags =3D 0;                                                =
                                           =20
> +     config.tx_type =3D priv->hwts_tx_en ? HWTSTAMP_TX_ON : HWTSTAMP_TX_=
OFF;                                       =20
> +     config.rx_filter =3D (priv->hwts_rx_en ?                           =
                                           =20
> +                         HWTSTAMP_FILTER_ALL : HWTSTAMP_FILTER_NONE);   =
                                         =20
> +                                                                        =
                                         =20
> +     return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?      =
                                         =20
> +             -EFAULT : 0;                                               =
                                         =20
> +}                                                                       =
                                         =20
> +                                                                        =
                                         =20
> +static struct macb_ptp_info gem_ptp_info =3D {                          =
                                           =20
> +     .ptp_init        =3D gem_ptp_init,                                 =
                                           =20
> +     .ptp_remove      =3D gem_ptp_remove,                               =
                                           =20
> +     .get_ptp_max_adj =3D gem_get_ptp_max_adj,                          =
                                           =20
> +     .get_tsu_rate    =3D gem_get_tsu_rate,                             =
                                           =20
> +     .get_ts_info     =3D gem_get_ts_info,                              =
                                           =20
> +     .get_hwtst       =3D gem_get_hwtst,                                =
                                           =20
> +     .set_hwtst       =3D gem_set_hwtst,                                =
                                           =20
> +};                                                                      =
                                         =20
> +#endif                                                                  =
                                         =20
> +                                                                        =
                                         =20
> +static int macb_get_ts_info(struct net_device *netdev,                  =
                                         =20
> +                         struct ethtool_ts_info *info)                  =
                                         =20
> +{                                                                       =
                                         =20
> +     struct macb *bp =3D netdev_priv(netdev);                           =
                                           =20
> +                                                                        =
                                         =20
> +     if (bp->ptp_info)                                                  =
                                         =20
> +             return bp->ptp_info->get_ts_info(netdev, info);            =
                                         =20
> +                                                                        =
                                         =20
> +     return ethtool_op_get_ts_info(netdev, info); }                     =
                                         =20
> +                                                                        =
                                         =20
>  static const struct ethtool_ops macb_ethtool_ops =3D {                  =
                                           =20
>       .get_regs_len           =3D macb_get_regs_len,                     =
                                           =20
>       .get_regs               =3D macb_get_regs,                         =
                                           =20
> @@ -2391,7 +2528,7 @@ static const struct ethtool_ops gem_ethtool_ops =3D=
 {                                         =20
>       .get_regs_len           =3D macb_get_regs_len,                     =
                                           =20
>       .get_regs               =3D macb_get_regs,                         =
                                           =20
>       .get_link               =3D ethtool_op_get_link,                   =
                                           =20
> -     .get_ts_info            =3D ethtool_op_get_ts_info,                =
                                           =20
> +     .get_ts_info            =3D macb_get_ts_info,                      =
                                           =20
>       .get_ethtool_stats      =3D gem_get_ethtool_stats,                 =
                                           =20
>       .get_strings            =3D gem_get_ethtool_strings,               =
                                           =20
>       .get_sset_count         =3D gem_get_sset_count,                    =
                                           =20
> @@ -2404,6 +2541,7 @@ static const struct ethtool_ops gem_ethtool_ops =3D=
 {  static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd=
)  {                                                                       =
          =20
>       struct phy_device *phydev =3D dev->phydev;                         =
                                           =20
> +     struct macb *bp =3D netdev_priv(dev);                              =
                                           =20
>                                                                          =
                                         =20
>       if (!netif_running(dev))                                           =
                                         =20
>               return -EINVAL;                                            =
                                         =20
> @@ -2411,7 +2549,20 @@ static int macb_ioctl(struct net_device *dev, stru=
ct ifreq *rq, int cmd)                   =20
>       if (!phydev)                                                       =
                                         =20
>               return -ENODEV;
>
> -     return phy_mii_ioctl(phydev, rq, cmd);
> +     switch (cmd) {
> +     case SIOCSHWTSTAMP:
> +             if (bp->ptp_info)
> +                     return bp->ptp_info->set_hwtst(dev, rq, cmd);
> +
> +             return -EOPNOTSUPP;
> +     case SIOCGHWTSTAMP:
> +             if (bp->ptp_info)
> +                     return bp->ptp_info->get_hwtst(dev, rq);
> +
> +             return -EOPNOTSUPP;
> +     default:
> +             return phy_mii_ioctl(phydev, rq, cmd);
> +     }
>  }
>
>  static int macb_set_features(struct net_device *netdev, @@ -2485,6 +2636=
,12 @@ static void macb_configure_caps(struct macb *bp,
>               dcfg =3D gem_readl(bp, DCFG2);
>               if ((dcfg & (GEM_BIT(RX_PKT_BUFF) | GEM_BIT(TX_PKT_BUFF))) =
=3D=3D 0)
>                       bp->caps |=3D MACB_CAPS_FIFO_MODE;
> +
> +             /* iff HWSTAMP is configure and gem has the capability */ #=
ifdef
> +CONFIG_MACB_USE_HWSTAMP
> +             if (gem_has_ptp(bp))
> +                     bp->ptp_info =3D &gem_ptp_info;
> +#endif
>       }
>
>       dev_dbg(&bp->pdev->dev, "Cadence caps 0x%08x\n", bp->caps); @@ -304=
1,7 +3198,7 @@ static const struct macb_config pc302gem_config =3D {  };
>
>  static const struct macb_config sama5d2_config =3D {
> -     .caps =3D MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
> +     .caps =3D MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII | MACB_CAPS_GEM_HAS_P=
TP,
There are many IP cores with many configuration. If it is possible, capabil=
ities should be read from IP directly.
And it is possible in that case:
Design Configuration Register 5 (0x290)
bit 8: tsu
There is now PTP hardware support without that bit.

>       .dma_burst_length =3D 16,
>       .clk_init =3D macb_clk_init,
>       .init =3D macb_init,
> @@ -3049,14 +3206,15 @@ static const struct macb_config sama5d2_config =
=3D {
>
>  static const struct macb_config sama5d3_config =3D {
>       .caps =3D MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE
> -           | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
> +           | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII
> +           | MACB_CAPS_GEM_HAS_PTP,
>       .dma_burst_length =3D 16,
>       .clk_init =3D macb_clk_init,
>       .init =3D macb_init,
>  };
>
>  static const struct macb_config sama5d4_config =3D {
> -     .caps =3D MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
> +     .caps =3D MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII | MACB_CAPS_GEM_HAS_P=
TP,
>       .dma_burst_length =3D 4,
>       .clk_init =3D macb_clk_init,
>       .init =3D macb_init,
> --
> 2.7.4

In macb_start_xmit() there is also invoked skb_tx_timestamp() for software =
timestamping.
I think, it should be disabled if you do hardware timestamping.

Best regards,=20
Rafal Ozieblo   |   Firmware System Engineer,=20
www.cadence.com
