From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 4/4] bnx2x, cnic: support DRV_INFO upon FW
 request
Date: Mon, 05 Dec 2011 21:56:38 -0800
Message-ID: <1323150998.19483.11.camel@joe2Laptop>
References: <1323150288-28153-1-git-send-email-mchan@broadcom.com>
	 <1323150288-28153-2-git-send-email-mchan@broadcom.com>
	 <1323150288-28153-3-git-send-email-mchan@broadcom.com>
	 <1323150288-28153-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, barak@broadcom.com,
	eilong@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37726 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752174Ab1LFF4j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 00:56:39 -0500
In-Reply-To: <1323150288-28153-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-12-05 at 21:44 -0800, Michael Chan wrote:
> From: Barak Witkowski <barak@broadcom.com>
> Add support to send driver capabilities, settings and statistics to
> management firmware.
[]
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
[]
> @@ -2912,6 +2912,159 @@ static void bnx2x_e1h_enable(struct bnx2x *bp)
>  	 */
>  }
>  
> +#define DRV_INFO_ETH_STAT_NUM_MACS_REQUIRED 3
> +
> +static inline void bnx2x_drv_info_ether_stat(struct bnx2x *bp)

Most likely this should not be inline

> +{
> +	/* leave last char as NULL */
> +	memcpy(bp->slowpath->drv_info_to_mcp.ether_stat.version,
> +		DRV_MODULE_VERSION, ETH_STAT_INFO_VERSION_LEN - 1);

This would read and perform a lot better with temporaries.
Many (all?) gcc versions don't optimize out the repeated indirections.

	whatever_type *dev = bp->dev;
	whatever_type *ether_stats = &bp->slowpath->drv_info_to_mp.etherstat;

> +
> +	bp->fp[0].mac_obj.get_n_elements(bp, &bp->fp[0].mac_obj,
> +					 DRV_INFO_ETH_STAT_NUM_MACS_REQUIRED,
> +			bp->slowpath->drv_info_to_mcp.ether_stat.mac_local);
> +
> +	bp->slowpath->drv_info_to_mcp.ether_stat.mtu_size = bp->dev->mtu;

	ether_stats->mtu_size = dev->mtu;
> +
> +	if (bp->dev->features & NETIF_F_RXCSUM)
> +		bp->slowpath->drv_info_to_mcp.ether_stat.feature_flags |=
> +		FEATURE_ETH_CHKSUM_OFFLOAD_MASK;

	if (dev->features & NETIF_F_RXCSUM)
		ether_stats->feature_flags |= FEATURE_ETH_CHKSUM_OFFLOAD_MASK;

> +	if (bp->dev->features & NETIF_F_TSO)
> +		bp->slowpath->drv_info_to_mcp.ether_stat.feature_flags |=
> +		FEATURE_ETH_LSO_MASK;

	if (dev->features & NETIF_F_TSO)
		ether_stats->feature_flags |= FEATURE_ETH_LSO_MASK;

> +	bp->slowpath->drv_info_to_mcp.ether_stat.feature_flags |=
> +		bp->common.boot_mode;

etc.,

> +static inline void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
> +{
> +	struct bnx2x_dcbx_app_params *app = &bp->dcbx_port_params.app;
> +
> +	memcpy(bp->slowpath->drv_info_to_mcp.fcoe_stat.mac_local,
> +		bp->fip_mac, ETH_ALEN);

Same temporary use.

> +
> +	bp->slowpath->drv_info_to_mcp.fcoe_stat.qos_priority =
> +		app->traffic_type_priority[LLFC_TRAFFIC_TYPE_FCOE];
> +
> +	/* insert FCoE stats from ramrod response */
> +	if (!NO_FCOE(bp)) {
> +		struct tstorm_per_queue_stats *fcoe_q_tstorm_stats =
> +			&bp->fw_stats_data->queue_stats[FCOE_IDX].
> +			tstorm_queue_statistics;
> +
> +		struct xstorm_per_queue_stats *fcoe_q_xstorm_stats =
> +			&bp->fw_stats_data->queue_stats[FCOE_IDX].
> +			xstorm_queue_statistics;
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_bytes_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_bytes_lo,
> +			bp->fw_stats_data->fcoe.rx_stat0.fcoe_rx_byte_cnt);

temporaries for bp->slowpath->drv_info_to_mcp.fcoe_stat
and bp->fw_stats_data->fcoe.rx_stat0 too.

> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_bytes_hi,
> +			fcoe_q_tstorm_stats->rcv_ucast_bytes.hi,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_bytes_lo,
> +			fcoe_q_tstorm_stats->rcv_ucast_bytes.lo);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_bytes_hi,
> +			fcoe_q_tstorm_stats->rcv_bcast_bytes.hi,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_bytes_lo,
> +			fcoe_q_tstorm_stats->rcv_bcast_bytes.lo);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_bytes_hi,
> +			fcoe_q_tstorm_stats->rcv_mcast_bytes.hi,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_bytes_lo,
> +			fcoe_q_tstorm_stats->rcv_mcast_bytes.lo);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_frames_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_frames_lo,
> +			bp->fw_stats_data->fcoe.rx_stat0.fcoe_rx_pkt_cnt);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_frames_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_frames_lo,
> +			fcoe_q_tstorm_stats->rcv_ucast_pkts);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_frames_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_frames_lo,
> +			fcoe_q_tstorm_stats->rcv_bcast_pkts);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_frames_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.rx_frames_lo,
> +			fcoe_q_tstorm_stats->rcv_ucast_pkts);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_bytes_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_bytes_lo,
> +			bp->fw_stats_data->fcoe.tx_stat.fcoe_tx_byte_cnt);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_bytes_hi,
> +			fcoe_q_xstorm_stats->ucast_bytes_sent.hi,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_bytes_lo,
> +			fcoe_q_xstorm_stats->ucast_bytes_sent.lo);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_bytes_hi,
> +			fcoe_q_xstorm_stats->bcast_bytes_sent.hi,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_bytes_lo,
> +			fcoe_q_xstorm_stats->bcast_bytes_sent.lo);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_bytes_hi,
> +			fcoe_q_xstorm_stats->mcast_bytes_sent.hi,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_bytes_lo,
> +			fcoe_q_xstorm_stats->mcast_bytes_sent.lo);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_frames_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_frames_lo,
> +			bp->fw_stats_data->fcoe.tx_stat.fcoe_tx_pkt_cnt);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_frames_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_frames_lo,
> +			fcoe_q_xstorm_stats->ucast_pkts_sent);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_frames_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_frames_lo,
> +			fcoe_q_xstorm_stats->bcast_pkts_sent);
> +
> +		ADD_64(bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_frames_hi,
> +			0,
> +			bp->slowpath->drv_info_to_mcp.fcoe_stat.tx_frames_lo,
> +			fcoe_q_xstorm_stats->mcast_pkts_sent);
> +	}
> +

cheers, Joe
