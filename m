From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Mon, 05 Dec 2011 16:37:02 +0800
Message-ID: <4EDC82AE.40806@linux.vnet.ibm.com>
References: <1323073241-21144-1-git-send-email-jeffrey.t.kirsher@intel.com> <1323073241-21144-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Flavio Leitner <fbl@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:52352 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab1LEIhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 03:37:16 -0500
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Mon, 5 Dec 2011 14:07:11 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB58b5aW2490572
	for <netdev@vger.kernel.org>; Mon, 5 Dec 2011 14:07:06 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB58b45B008305
	for <netdev@vger.kernel.org>; Mon, 5 Dec 2011 19:37:05 +1100
In-Reply-To: <1323073241-21144-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jeff

Please reserve "From: Michael Wang <wangyun@linux.vnet.ibm.com>" in content.
And because Flavio not respond these days, I add his name for him.

Thanks,
Michael Wang

On 12/05/2011 04:20 PM, Jeff Kirsher wrote:

> Based on the original patch submitted my Michael Wang
> <wangyun@linux.vnet.ibm.com>.

From: Michael Wang <wangyun@linux.vnet.ibm.com>

> Descriptors may not be write-back while checking TX hang with flag
> FLAG2_DMA_BURST on.
> So when we detect hang, we just flush the descriptor and detect
> again for once.
> 
> -v2 change 1 to true and 0 to false and remove extra ()
> 
> CC: Michael Wang <wangyun@linux.vnet.ibm.com>
> CC: Flavio Leitner <fbl@redhat.com>

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
Signed-off-by: Flavio Leitner <fbl@redhat.com>

> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>

> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000e/e1000.h  |    1 +
>  drivers/net/ethernet/intel/e1000e/netdev.c |   23 ++++++++++++++++++++---
>  2 files changed, 21 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
> index 9fe18d1..f478a22 100644
> --- a/drivers/net/ethernet/intel/e1000e/e1000.h
> +++ b/drivers/net/ethernet/intel/e1000e/e1000.h
> @@ -309,6 +309,7 @@ struct e1000_adapter {
>  	u32 txd_cmd;
> 
>  	bool detect_tx_hung;
> +	bool tx_hang_recheck;
>  	u8 tx_timeout_factor;
> 
>  	u32 tx_int_delay;
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index c6e9763..c12df69 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -1014,6 +1014,7 @@ static void e1000_print_hw_hang(struct work_struct *work)
>  	struct e1000_adapter *adapter = container_of(work,
>  	                                             struct e1000_adapter,
>  	                                             print_hang_task);
> +	struct net_device *netdev = adapter->netdev;
>  	struct e1000_ring *tx_ring = adapter->tx_ring;
>  	unsigned int i = tx_ring->next_to_clean;
>  	unsigned int eop = tx_ring->buffer_info[i].next_to_watch;
> @@ -1025,6 +1026,21 @@ static void e1000_print_hw_hang(struct work_struct *work)
>  	if (test_bit(__E1000_DOWN, &adapter->state))
>  		return;
> 
> +	if (!adapter->tx_hang_recheck &&
> +	    (adapter->flags2 & FLAG2_DMA_BURST)) {
> +		/* May be block on write-back, flush and detect again
> +		 * flush pending descriptor writebacks to memory
> +		 */
> +		ew32(TIDV, adapter->tx_int_delay | E1000_TIDV_FPD);
> +		/* execute the writes immediately */
> +		e1e_flush();
> +		adapter->tx_hang_recheck = true;
> +		return;
> +	}
> +	/* Real hang detected */
> +	adapter->tx_hang_recheck = false;
> +	netif_stop_queue(netdev);
> +
>  	e1e_rphy(hw, PHY_STATUS, &phy_status);
>  	e1e_rphy(hw, PHY_1000T_STATUS, &phy_1000t_status);
>  	e1e_rphy(hw, PHY_EXT_STATUS, &phy_ext_status);
> @@ -1145,10 +1161,10 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
>  		if (tx_ring->buffer_info[i].time_stamp &&
>  		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp
>  			       + (adapter->tx_timeout_factor * HZ)) &&
> -		    !(er32(STATUS) & E1000_STATUS_TXOFF)) {
> +		    !(er32(STATUS) & E1000_STATUS_TXOFF))
>  			schedule_work(&adapter->print_hang_task);
> -			netif_stop_queue(netdev);
> -		}
> +		else
> +			adapter->tx_hang_recheck = false;
>  	}
>  	adapter->total_tx_bytes += total_tx_bytes;
>  	adapter->total_tx_packets += total_tx_packets;
> @@ -3838,6 +3854,7 @@ static int e1000_open(struct net_device *netdev)
> 
>  	e1000_irq_enable(adapter);
> 
> +	adapter->tx_hang_recheck = false;
>  	netif_start_queue(netdev);
> 
>  	adapter->idle_check = true;
