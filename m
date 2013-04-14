From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 5/9] qlcnic: Enable Interrupt Coalescing for
 83xx adapter
Date: Sun, 14 Apr 2013 12:55:43 +0200
Message-ID: <20130414105543.GD30385@electric-eye.fr.zoreil.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
 <1365874114-6759-6-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44082 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab3DNKzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 06:55:49 -0400
Content-Disposition: inline
In-Reply-To: <1365874114-6759-6-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shahed Shaikh <shahed.shaikh@qlogic.com> :
[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> index 602d3e4..7551b18 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
(...]
> @@ -359,6 +365,8 @@ struct qlcnic_nic_intr_coalesce {
>  	u8	sts_ring_mask;
>  	u16	rx_packets;
>  	u16	rx_time_us;
> +	u16	tx_packets;
> +	u16	tx_time_us;

(ok)

[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
> index c9c342e..fdd1fe7 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
[...]
> @@ -1878,10 +1878,18 @@ void qlcnic_83xx_config_intr_coal(struct qlcnic_adapter *adapter)
>  		return;
>  
>  	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_CONFIG_INTR_COAL);
> -	cmd.req.arg[1] = 1 | (adapter->recv_ctx->context_id << 16);
> +	if (coal->type == QLCNIC_INTR_COAL_TYPE_RX) {
> +		temp = adapter->recv_ctx->context_id;
> +		cmd.req.arg[1] = (QLCNIC_INTR_COAL_TYPE_RX | (temp << 16));
> +		temp = coal->rx_time_us;
> +		cmd.req.arg[2] = (coal->rx_packets | (temp << 16));
> +	} else if (coal->type == QLCNIC_INTR_COAL_TYPE_TX) {
> +		temp = adapter->tx_ring->ctx_id;
> +		cmd.req.arg[1] = (QLCNIC_INTR_COAL_TYPE_TX | (temp << 16));
> +		temp = coal->rx_time_us;
                             ^^ -> tx ?
> +		cmd.req.arg[2] = (coal->rx_packets | (temp << 16));
                                        ^^ -> tx ?

[...]
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -1586,6 +1586,8 @@ out:
>  static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
>  {
>  	int err = 0;
> +	struct qlcnic_hardware_context *ahw = adapter->ahw;
> +

Nit: long lines ought to appear first.

-- 
Ueimor
