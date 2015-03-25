From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [net-next 05/16] ixgbevf: enable multiple queue support
Date: Wed, 25 Mar 2015 10:44:49 +0200
Message-ID: <55127581.2080205@cloudius-systems.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com> <1423128950-12388-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:34469 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbbCYIow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 04:44:52 -0400
Received: by wgs2 with SMTP id 2so18843587wgs.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 01:44:51 -0700 (PDT)
In-Reply-To: <1423128950-12388-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/05/15 11:35, Jeff Kirsher wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>
>
> This patch enables multiple queues and RSS support for the VF.
> Maximum of 2 queues are supported due to available vectors.
>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 22 +++++++++++++++++++---
>   2 files changed, 20 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> index 8c44ab2..65cda34 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> @@ -124,6 +124,7 @@ struct ixgbevf_ring {
>   
>   #define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
>   #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
> +#define IXGBEVF_MAX_RSS_QUEUES 2

According to the MRQE register description in 82599 and x540 specs 2 
(the value of IXGBEVF_MAX_RSS_QUEUES) is the minimal allowed number of 
queues in a single pool thus it's a minimal number of VF queues - not 
the maximal (see more comments on this below).

>   
>   #define IXGBEVF_DEFAULT_TXD   1024
>   #define IXGBEVF_DEFAULT_RXD   512
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index c9b49bf..815808f 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -1794,7 +1794,8 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
>   	struct ixgbe_hw *hw = &adapter->hw;
>   	unsigned int def_q = 0;
>   	unsigned int num_tcs = 0;
> -	unsigned int num_rx_queues = 1;
> +	unsigned int num_rx_queues = adapter->num_rx_queues;
> +	unsigned int num_tx_queues = adapter->num_tx_queues;
>   	int err;
>   
>   	spin_lock_bh(&adapter->mbx_lock);
> @@ -1808,6 +1809,9 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
>   		return err;
>   
>   	if (num_tcs > 1) {
> +		/* we need only one Tx queue */
> +		num_tx_queues = 1;
> +
>   		/* update default Tx ring register index */
>   		adapter->tx_ring[0]->reg_idx = def_q;
>   
> @@ -1816,7 +1820,8 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
>   	}
>   
>   	/* if we have a bad config abort request queue reset */
> -	if (adapter->num_rx_queues != num_rx_queues) {
> +	if ((adapter->num_rx_queues != num_rx_queues) ||
> +	    (adapter->num_tx_queues != num_tx_queues)) {
>   		/* force mailbox timeout to prevent further messages */
>   		hw->mbx.timeout = 0;
>   
> @@ -2181,8 +2186,19 @@ static void ixgbevf_set_num_queues(struct ixgbevf_adapter *adapter)
>   		return;
>   
>   	/* we need as many queues as traffic classes */
> -	if (num_tcs > 1)
> +	if (num_tcs > 1) {
>   		adapter->num_rx_queues = num_tcs;
> +	} else {
> +		u16 rss = min_t(u16, num_online_cpus(), IXGBEVF_MAX_RSS_QUEUES);

Emil,
Here u ignore the IXGBE_VF_RX_QUEUES value returned the PF (stored in 
the hw->mac.max_rx_queues). This will accidentally work if PF is driven 
by a current ixgbe Linux driver but what would happen if HV is not a 
Linux box? What if HV decides to configure the PSRTYPE[x].RQPL to 0 and 
decide that VF should be configured with a single queue? I maybe miss 
something here but the above line seems bogus. Please, comment.

thanks,
vlad

> +
> +		switch (hw->api_version) {
> +		case ixgbe_mbox_api_11:
> +			adapter->num_rx_queues = rss;
> +			adapter->num_tx_queues = rss;
> +		default:
> +			break;
> +		}
> +	}
>   }
>   
>   /**
