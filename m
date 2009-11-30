From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: avoid flushing statistics when doing a MTU
 change
Date: Mon, 30 Nov 2009 01:20:11 -0800
Message-ID: <C27F8246C663564A84BB7AB34397724218065B984C@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1259341163-12775-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "'leitao@linux.vnet.ibm.com'" <leitao@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1170 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501AbZK3JUN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 04:20:13 -0500
In-Reply-To: <1259341163-12775-1-git-send-email-leitao@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

leitao@linux.vnet.ibm.com wrote:

> Actually when bnx2 changes the interface's MTU size, it resets
> the chip and consequently flushes the interface statistics.
> This patch saves the statistics in a temporary space in order to
> maintain the statistics correct after the chip reset.

Thanks Breno.  This looks ok, but I think we need to zero the
stats_extra during bnx2_open().

>
> Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>
> ---
>  drivers/net/bnx2.c |   52
> +++++++++++++++++++++++++++++++++++++---------------
>  drivers/net/bnx2.h |    1 +
>  2 files changed, 38 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 7fa4048..f99e688 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -6469,46 +6469,58 @@ bnx2_get_stats(struct net_device *dev)
>       net_stats->rx_packets =
>               GET_NET_STATS(stats_blk->stat_IfHCInUcastPkts) +
>               GET_NET_STATS(stats_blk->stat_IfHCInMulticastPkts) +
> -             GET_NET_STATS(stats_blk->stat_IfHCInBroadcastPkts);
> +             GET_NET_STATS(stats_blk->stat_IfHCInBroadcastPkts) +
> +             bp->stats_extra->rx_packets;
>
>       net_stats->tx_packets =
>               GET_NET_STATS(stats_blk->stat_IfHCOutUcastPkts) +
>               GET_NET_STATS(stats_blk->stat_IfHCOutMulticastPkts) +
> -             GET_NET_STATS(stats_blk->stat_IfHCOutBroadcastPkts);
> +             GET_NET_STATS(stats_blk->stat_IfHCOutBroadcastPkts) +
> +             bp->stats_extra->tx_packets;
>
>       net_stats->rx_bytes =
> -             GET_NET_STATS(stats_blk->stat_IfHCInOctets);
> +             GET_NET_STATS(stats_blk->stat_IfHCInOctets) +
> +             bp->stats_extra->rx_bytes;
>
>       net_stats->tx_bytes =
> -             GET_NET_STATS(stats_blk->stat_IfHCOutOctets);
> +             GET_NET_STATS(stats_blk->stat_IfHCOutOctets) +
> +             bp->stats_extra->tx_bytes;
>
>       net_stats->multicast =
> -             GET_NET_STATS(stats_blk->stat_IfHCOutMulticastPkts);
> +             GET_NET_STATS(stats_blk->stat_IfHCOutMulticastPkts) +
> +             bp->stats_extra->multicast;
>
>       net_stats->collisions =
> -             (unsigned long) stats_blk->stat_EtherStatsCollisions;
> +             (unsigned long) stats_blk->stat_EtherStatsCollisions +
> +             bp->stats_extra->collisions;
>
>       net_stats->rx_length_errors =
>               (unsigned long)
> (stats_blk->stat_EtherStatsUndersizePkts +
> -             stats_blk->stat_EtherStatsOverrsizePkts);
> +             stats_blk->stat_EtherStatsOverrsizePkts) +
> +             bp->stats_extra->rx_length_errors;
>
>       net_stats->rx_over_errors =
>               (unsigned long) (stats_blk->stat_IfInFTQDiscards +
> -             stats_blk->stat_IfInMBUFDiscards);
> +             stats_blk->stat_IfInMBUFDiscards) +
> +             bp->stats_extra->rx_over_errors;
>
>       net_stats->rx_frame_errors =
> -             (unsigned long)
> stats_blk->stat_Dot3StatsAlignmentErrors;
> +             (unsigned long)
> stats_blk->stat_Dot3StatsAlignmentErrors +
> +             bp->stats_extra->rx_frame_errors;
>
>       net_stats->rx_crc_errors =
> -             (unsigned long) stats_blk->stat_Dot3StatsFCSErrors;
> +             (unsigned long) stats_blk->stat_Dot3StatsFCSErrors +
> +             bp->stats_extra->rx_crc_errors;
>
>       net_stats->rx_errors = net_stats->rx_length_errors +
>               net_stats->rx_over_errors + net_stats->rx_frame_errors +
> -             net_stats->rx_crc_errors;
> +             net_stats->rx_crc_errors +
> +             bp->stats_extra->rx_errors;
>
>       net_stats->tx_aborted_errors =
>               (unsigned long)
> (stats_blk->stat_Dot3StatsExcessiveCollisions +
> -             stats_blk->stat_Dot3StatsLateCollisions);
> +             stats_blk->stat_Dot3StatsLateCollisions) +
> +             bp->stats_extra->tx_aborted_errors;
>
>       if ((CHIP_NUM(bp) == CHIP_NUM_5706) ||
>           (CHIP_ID(bp) == CHIP_ID_5708_A0))
> @@ -6516,7 +6528,8 @@ bnx2_get_stats(struct net_device *dev)
>       else {
>               net_stats->tx_carrier_errors =
>                       (unsigned long)
> -                     stats_blk->stat_Dot3StatsCarrierSenseErrors;
> +                     stats_blk->stat_Dot3StatsCarrierSenseErrors +
> +                     bp->stats_extra->tx_carrier_errors;
>       }
>
>       net_stats->tx_errors =
> @@ -6524,11 +6537,13 @@ bnx2_get_stats(struct net_device *dev)
>
> stats_blk->stat_emac_tx_stat_dot3statsinternalmactransmiterrors
>               +
>               net_stats->tx_aborted_errors +
> -             net_stats->tx_carrier_errors;
> +             net_stats->tx_carrier_errors +
> +             bp->stats_extra->tx_errors;
>
>       net_stats->rx_missed_errors =
>               (unsigned long) (stats_blk->stat_IfInFTQDiscards +
> -             stats_blk->stat_IfInMBUFDiscards +
> stats_blk->stat_FwRxDrop);
> +             stats_blk->stat_IfInMBUFDiscards +
> stats_blk->stat_FwRxDrop) +
> +             bp->stats_extra->rx_missed_errors;
>
>       return net_stats;
>  }
> @@ -6989,6 +7004,11 @@ bnx2_change_ring_size(struct bnx2 *bp,
> u32 rx, u32 tx)
>  {
>       if (netif_running(bp->dev)) {
>               bnx2_netif_stop(bp);
> +
> +             /* Save statistics that is going to be reseted */
> +             memcpy(bp->stats_extra, &bp->dev->stats,
> +                     sizeof(struct net_device_stats));
> +
>               bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
>               bnx2_free_skbs(bp);
>               bnx2_free_mem(bp);
> @@ -7649,6 +7669,7 @@ bnx2_init_board(struct pci_dev *pdev,
> struct net_device *dev)
>
>       bp->flags = 0;
>       bp->phy_flags = 0;
> +     bp->stats_extra = kzalloc(sizeof(struct
> net_device_stats), GFP_KERNEL);
>
>       /* enable device (incl. PCI PM wakeup), and bus-mastering */
>       rc = pci_enable_device(pdev);
> @@ -8162,6 +8183,7 @@ bnx2_remove_one(struct pci_dev *pdev)
>       if (bp->regview)
>               iounmap(bp->regview);
>
> +     kfree(bp->stats_extra);
>       free_netdev(dev);
>       pci_release_regions(pdev);
>       pci_disable_device(pdev);
> diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
> index a4d8340..b29b0d5 100644
> --- a/drivers/net/bnx2.h
> +++ b/drivers/net/bnx2.h
> @@ -6912,6 +6912,7 @@ struct bnx2 {
>
>       const struct firmware   *mips_firmware;
>       const struct firmware   *rv2p_firmware;
> +     struct net_device_stats *stats_extra;
>  };
>
>  #define REG_RD(bp, offset)                                   \
> --
> 1.6.0.2
>
>
>

