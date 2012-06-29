From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 5/6] qlge: Categorize receive frame errors from firmware.
Date: Fri, 29 Jun 2012 23:38:00 +0200
Message-ID: <20120629213800.GD19152@electric-eye.fr.zoreil.com>
References: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com> <1340994290-28832-6-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, Ron@linux-zupk.site,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40316 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab2F2VtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 17:49:00 -0400
Content-Disposition: inline
In-Reply-To: <1340994290-28832-6-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jitendra Kalsaria <jitendra.kalsaria@qlogic.com> :
> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> ---
>  drivers/net/ethernet/qlogic/qlge/qlge.h         |    8 ++++
>  drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |   14 +++++++
>  drivers/net/ethernet/qlogic/qlge/qlge_main.c    |   46 ++++++++++++++++++----
>  3 files changed, 59 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
> index 5a639df..e81bbb7 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge.h
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
> @@ -1535,6 +1535,14 @@ struct nic_stats {
>  	u64 rx_1024_to_1518_pkts;
>  	u64 rx_1519_to_max_pkts;
>  	u64 rx_len_err_pkts;
> +	/* Receive Mac Err stats */
> +	u64 rx_code_err;
> +	u64 rx_oversize_err;
> +	u64 rx_undersize_err;
> +	u64 rx_preamble_err;
> +	u64 rx_frame_len_err;
> +	u64 rx_crc_err;
> +	u64 rx_err_count;
>  	/*
>  	 * These stats come from offset 500h to 5C8h
>  	 * in the XGMAC register.
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
> index 966bd96..bbc4136 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
> @@ -226,6 +226,13 @@ static char ql_stats_str_arr[][ETH_GSTRING_LEN] = {
>  	{"rx_1024_to_1518_pkts"},
>  	{"rx_1519_to_max_pkts"},
>  	{"rx_len_err_pkts"},
> +	{"rx_code_err"},
> +	{"rx_oversize_err"},
> +	{"rx_undersize_err"},
> +	{"rx_preamble_err"},
> +	{"rx_frame_len_err"},
> +	{"rx_crc_err"},
> +	{"rx_err_count"},
>  	{"tx_cbfc_pause_frames0"},
>  	{"tx_cbfc_pause_frames1"},
>  	{"tx_cbfc_pause_frames2"},
> @@ -320,6 +327,13 @@ ql_get_ethtool_stats(struct net_device *ndev,
>  	*data++ = s->rx_1024_to_1518_pkts;
>  	*data++ = s->rx_1519_to_max_pkts;
>  	*data++ = s->rx_len_err_pkts;
> +	*data++ = s->rx_code_err;
> +	*data++ = s->rx_oversize_err;
> +	*data++ = s->rx_undersize_err;
> +	*data++ = s->rx_preamble_err;
> +	*data++ = s->rx_frame_len_err;
> +	*data++ = s->rx_crc_err;
> +	*data++ = s->rx_err_count;
>  	*data++ = s->tx_cbfc_pause_frames0;
>  	*data++ = s->tx_cbfc_pause_frames1;
>  	*data++ = s->tx_cbfc_pause_frames2;

The stats seem to be 64 bits integers only. Couldn't you use a plain loop
with ARRAY_SIZE(ql_stats_str_arr) ?

> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> index aa514c5..0f56148 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> @@ -1433,6 +1433,34 @@ map_error:
>  	return NETDEV_TX_BUSY;
>  }
>  
> +/* Categorizing receive firmware frame errors */
> +static void ql_categorize_rx_err(struct ql_adapter *qdev, u8 rx_err)
> +{
> +	qdev->nic_stats.rx_err_count++;

Use a local variable for &qdev->nic_stats ?

> +
> +	switch (rx_err & IB_MAC_IOCB_RSP_ERR_MASK) {
> +	case IB_MAC_IOCB_RSP_ERR_CODE_ERR:
> +		qdev->nic_stats.rx_code_err++;
> +		break;
> +	case IB_MAC_IOCB_RSP_ERR_OVERSIZE:
> +		qdev->nic_stats.rx_oversize_err++;
> +		break;
> +	case IB_MAC_IOCB_RSP_ERR_UNDERSIZE:
> +		qdev->nic_stats.rx_undersize_err++;
> +		break;
> +	case IB_MAC_IOCB_RSP_ERR_PREAMBLE:
> +		qdev->nic_stats.rx_preamble_err++;
> +		break;
> +	case IB_MAC_IOCB_RSP_ERR_FRAME_LEN:
> +		qdev->nic_stats.rx_frame_len_err++;
> +		break;
> +	case IB_MAC_IOCB_RSP_ERR_CRC:
> +		qdev->nic_stats.rx_crc_err++;
> +	default:
> +		break;
> +	}
> +}
> +
>  /* Process an inbound completion from an rx ring. */
>  static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
>  					struct rx_ring *rx_ring,
> @@ -1446,6 +1474,12 @@ static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
>  
>  	napi->dev = qdev->ndev;
>  
> +	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
> +		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2);
> +		put_page(lbq_desc->p.pg_chunk.page);
> +		return;
> +	}

I did not expect a put_page here from the commit description.

-- 
Ueimor
