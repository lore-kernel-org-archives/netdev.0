From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] bnx2: avoid flushing statistics when doing a MTU change
Date: Mon, 30 Nov 2009 11:17:50 -0200
Message-ID: <4B13C5FE.7060403@linux.vnet.ibm.com>
References: <C27F8246C663564A84BB7AB34397724218065B9851@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:57992 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbZK3NRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 08:17:51 -0500
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp02.br.ibm.com (8.14.3/8.13.1) with ESMTP id nAUDe184024652
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 11:40:01 -0200
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAUDJKFa1515550
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 11:19:23 -0200
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAUCPs0W030812
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 10:25:54 -0200
In-Reply-To: <C27F8246C663564A84BB7AB34397724218065B9851@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael, Eric, 

Thanks for the reviews. Now stats_extra is inline in the bnx2 structure,
bnx2_open is cleaning stats_extra and I am doing a DMA to the statistics
structure before saving it.

Michael Chan wrote:
> Eric Dumazet wrote:
>> I wonder if you need to renew this stats before copying them ?
>>  (eg calling bnx2_get_stats())
> 
> Calling bnx2_get_stats() won't refresh the stats counters because
> they are DMA'ed once a second.  There's an I/O to immediately DMA
> the counters:
> 
> REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
>                                 BNX2_HC_COMMAND_STATS_NOW);
> REG_RD(bp, BNX2_HC_COMMAND);
> 
> We then need to add some delay to wait for the DMA to complete.
In the following patch, I just called this I/O as specified above, 
but looking into the code, I saw that the following I/O is just called
when BNX2_FLAG_BROKEN_STATS is set, and I am not sure if my call is correct.

Here is my new patch:

---

[PATCH] bnx2: avoid flushing statistics when doing a MTU change

Actually when bnx2 changes the interface's MTU size, it resets
the chip and consequently flushes the interface statistics.
This patch saves the statistics in a temporary space in order to
maintain the statistics correct after the chip reset.

Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>
---
 drivers/net/bnx2.c |   56 ++++++++++++++++++++++++++++++++++++++-------------
 drivers/net/bnx2.h |    1 +
 2 files changed, 42 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7fa4048..3cefee3 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6221,6 +6221,8 @@ bnx2_open(struct net_device *dev)
 	else if (bp->flags & BNX2_FLAG_USING_MSIX)
 		printk(KERN_INFO PFX "%s: using MSIX\n", dev->name);
 
+	memset(&bp->stats_extra, 0, sizeof(struct net_device_stats));
+
 	netif_tx_start_all_queues(dev);
 
 	return 0;
@@ -6469,46 +6471,58 @@ bnx2_get_stats(struct net_device *dev)
 	net_stats->rx_packets =
 		GET_NET_STATS(stats_blk->stat_IfHCInUcastPkts) +
 		GET_NET_STATS(stats_blk->stat_IfHCInMulticastPkts) +
-		GET_NET_STATS(stats_blk->stat_IfHCInBroadcastPkts);
+		GET_NET_STATS(stats_blk->stat_IfHCInBroadcastPkts) + 
+		bp->stats_extra.rx_packets;
 
 	net_stats->tx_packets =
 		GET_NET_STATS(stats_blk->stat_IfHCOutUcastPkts) +
 		GET_NET_STATS(stats_blk->stat_IfHCOutMulticastPkts) +
-		GET_NET_STATS(stats_blk->stat_IfHCOutBroadcastPkts);
+		GET_NET_STATS(stats_blk->stat_IfHCOutBroadcastPkts) +
+		bp->stats_extra.tx_packets;
 
 	net_stats->rx_bytes =
-		GET_NET_STATS(stats_blk->stat_IfHCInOctets);
+		GET_NET_STATS(stats_blk->stat_IfHCInOctets) +
+		bp->stats_extra.rx_bytes;
 
 	net_stats->tx_bytes =
-		GET_NET_STATS(stats_blk->stat_IfHCOutOctets);
+		GET_NET_STATS(stats_blk->stat_IfHCOutOctets) +
+		bp->stats_extra.tx_bytes;
 
 	net_stats->multicast =
-		GET_NET_STATS(stats_blk->stat_IfHCOutMulticastPkts);
+		GET_NET_STATS(stats_blk->stat_IfHCOutMulticastPkts) +
+		bp->stats_extra.multicast;
 
 	net_stats->collisions =
-		(unsigned long) stats_blk->stat_EtherStatsCollisions;
+		(unsigned long) stats_blk->stat_EtherStatsCollisions +
+		bp->stats_extra.collisions;
 
 	net_stats->rx_length_errors =
 		(unsigned long) (stats_blk->stat_EtherStatsUndersizePkts +
-		stats_blk->stat_EtherStatsOverrsizePkts);
+		stats_blk->stat_EtherStatsOverrsizePkts) +
+		bp->stats_extra.rx_length_errors;
 
 	net_stats->rx_over_errors =
 		(unsigned long) (stats_blk->stat_IfInFTQDiscards +
-		stats_blk->stat_IfInMBUFDiscards);
+		stats_blk->stat_IfInMBUFDiscards) +
+		bp->stats_extra.rx_over_errors;
 
 	net_stats->rx_frame_errors =
-		(unsigned long) stats_blk->stat_Dot3StatsAlignmentErrors;
+		(unsigned long) stats_blk->stat_Dot3StatsAlignmentErrors +
+		bp->stats_extra.rx_frame_errors;
 
 	net_stats->rx_crc_errors =
-		(unsigned long) stats_blk->stat_Dot3StatsFCSErrors;
+		(unsigned long) stats_blk->stat_Dot3StatsFCSErrors +
+		bp->stats_extra.rx_crc_errors;
 
 	net_stats->rx_errors = net_stats->rx_length_errors +
 		net_stats->rx_over_errors + net_stats->rx_frame_errors +
-		net_stats->rx_crc_errors;
+		net_stats->rx_crc_errors +
+		bp->stats_extra.rx_errors;
 
 	net_stats->tx_aborted_errors =
     		(unsigned long) (stats_blk->stat_Dot3StatsExcessiveCollisions +
-		stats_blk->stat_Dot3StatsLateCollisions);
+		stats_blk->stat_Dot3StatsLateCollisions) +
+		bp->stats_extra.tx_aborted_errors;
 
 	if ((CHIP_NUM(bp) == CHIP_NUM_5706) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_A0))
@@ -6516,7 +6530,8 @@ bnx2_get_stats(struct net_device *dev)
 	else {
 		net_stats->tx_carrier_errors =
 			(unsigned long)
-			stats_blk->stat_Dot3StatsCarrierSenseErrors;
+			stats_blk->stat_Dot3StatsCarrierSenseErrors +
+			bp->stats_extra.tx_carrier_errors;
 	}
 
 	net_stats->tx_errors =
@@ -6524,11 +6539,13 @@ bnx2_get_stats(struct net_device *dev)
 		stats_blk->stat_emac_tx_stat_dot3statsinternalmactransmiterrors
 		+
 		net_stats->tx_aborted_errors +
-		net_stats->tx_carrier_errors;
+		net_stats->tx_carrier_errors +
+		bp->stats_extra.tx_errors;
 
 	net_stats->rx_missed_errors =
 		(unsigned long) (stats_blk->stat_IfInFTQDiscards +
-		stats_blk->stat_IfInMBUFDiscards + stats_blk->stat_FwRxDrop);
+		stats_blk->stat_IfInMBUFDiscards + stats_blk->stat_FwRxDrop) +
+		bp->stats_extra.rx_missed_errors;
 
 	return net_stats;
 }
@@ -6989,6 +7006,15 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 {
 	if (netif_running(bp->dev)) {
 		bnx2_netif_stop(bp);
+
+		/* Save statistics that is going to be reseted */
+		REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
+				BNX2_HC_COMMAND_STATS_NOW);
+		REG_RD(bp, BNX2_HC_COMMAND);
+		udelay(5);
+		memcpy(&bp->stats_extra, &bp->dev->stats,
+			sizeof(struct net_device_stats));
+
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
 		bnx2_free_skbs(bp);
 		bnx2_free_mem(bp);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index a4d8340..1063d1a 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6912,6 +6912,7 @@ struct bnx2 {
 
 	const struct firmware	*mips_firmware;
 	const struct firmware	*rv2p_firmware;
+	struct net_device_stats stats_extra;
 };
 
 #define REG_RD(bp, offset)					\
-- 
1.6.0.2

