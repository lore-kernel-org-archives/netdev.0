From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v9 5/7] ixgbe: Add GET_RSS_KEY command to VF-PF
 channel commands set
Date: Sun, 29 Mar 2015 15:04:55 -0700
Message-ID: <55187707.2070609@gmail.com>
References: <1427645497-8339-1-git-send-email-vladz@cloudius-systems.com> <1427645497-8339-6-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34166 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbbC2WE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 18:04:57 -0400
Received: by pacwe9 with SMTP id we9so148301699pac.1
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 15:04:56 -0700 (PDT)
In-Reply-To: <1427645497-8339-6-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2015 09:11 AM, Vlad Zolotarov wrote:
> For 82599 and x540 VFs and PF share the same RSS Key. Therefore we will return
> the same RSS key for all VFs.
> 
> Support for other devices will be added later.
> 
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v9:
>    - Reduce the support to 82599 and x540 devices only.
>    - Get rid of registers access in GET_VF_RSS_KEY flow:
>       - Get the RSS HASH Key value from the PF's adapter->rss_key[].
> 
> New in v5:
>    - Use a newly added netdev op to allow/prevent the RSS Hash Key querying on a per-VF
>      basis.
> 
> New in v3:
>    - Added a support for x550 devices.
> 
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single option case
>      (in ixgbe_get_vf_rss_key()).
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 25 +++++++++++++++++++++++++
>  2 files changed, 26 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> index 3522f53..b1e4703 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
> @@ -100,6 +100,7 @@ enum ixgbe_pfvf_api_rev {
>  
>  /* mailbox API, version 1.2 VF requests */
>  #define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
> +#define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS key */
>  
>  /* length of permanent address message returned from PF */
>  #define IXGBE_VF_PERMADDR_MSG_LEN 4
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> index 8424e7f..4d87458 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -996,6 +996,28 @@ static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
>  	return 0;
>  }
>  
> +static int ixgbe_get_vf_rss_key(struct ixgbe_adapter *adapter,
> +				u32 *msgbuf, u32 vf)
> +{
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	u32 *rss_key = &msgbuf[1];
> +
> +	/* verify the PF is supporting the correct API */
> +	if (!adapter->vfinfo[vf].rss_query_enabled ||
> +	    (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12))
> +		return -EPERM;
> +
> +	/* Read the RSS KEY.
> +	 * We only support 82599 and x540 devices at the moment.
> +	 */
> +	if (hw->mac.type >= ixgbe_mac_X550)
> +		return -1;
> +

The return should be not supported, not -1 since that is too ambiguous.

> +	memcpy(rss_key, adapter->rss_key, sizeof(adapter->rss_key));
> +
> +	return 0;
> +}
> +
>  static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
>  {
>  	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
> @@ -1055,6 +1077,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
>  	case IXGBE_VF_GET_RETA:
>  		retval = ixgbe_get_vf_reta(adapter, msgbuf, vf);
>  		break;
> +	case IXGBE_VF_GET_RSS_KEY:
> +		retval = ixgbe_get_vf_rss_key(adapter, msgbuf, vf);
> +		break;
>  	default:
>  		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
>  		retval = IXGBE_ERR_MBX;
> 
