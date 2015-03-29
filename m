From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v9 6/7] ixgbevf: Add RSS Key query code
Date: Sun, 29 Mar 2015 15:04:10 -0700
Message-ID: <551876DA.1000607@gmail.com>
References: <1427645497-8339-1-git-send-email-vladz@cloudius-systems.com> <1427645497-8339-7-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35654 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbbC2WEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 18:04:13 -0400
Received: by pddn5 with SMTP id n5so39187553pdd.2
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 15:04:12 -0700 (PDT)
In-Reply-To: <1427645497-8339-7-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2015 09:11 AM, Vlad Zolotarov wrote:
> Add the ixgbevf_get_rss_key() function that queries the PF for an RSS Random Key
> using a new VF-PF channel IXGBE_VF_GET_RSS_KEY command.
> 
> This patch adds the support for 82599 and x540 devices only. Support for other
> devices will be added later.
> 
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v9:
>    - Reduce the support to 82599 and x540 devices only.
>    - Added IXGBEVF_RSS_HASH_KEY_SIZE macro.
> 
> New in v8:
>    - Protect a mailbox access.
> 
> New in v6:
>    - Return a proper return code when an operation is blocked by PF.
> 
> New in v2:
>    - Added a more detailed patch description.
> 
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single option case
>      (in ixgbevf_get_rss_key()).
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h |  1 +
>  drivers/net/ethernet/intel/ixgbevf/mbx.h     |  1 +
>  drivers/net/ethernet/intel/ixgbevf/vf.c      | 66 ++++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h      |  1 +
>  4 files changed, 69 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> index bc939a1..6771ae3 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> @@ -145,6 +145,7 @@ struct ixgbevf_ring {
>  #define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
>  #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
>  #define IXGBEVF_MAX_RSS_QUEUES	2
> +#define IXGBEVF_RSS_HASH_KEY_SIZE	40
>  
>  #define IXGBEVF_DEFAULT_TXD	1024
>  #define IXGBEVF_DEFAULT_RXD	512
> diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
> index 66e138b..82f44e0 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
> @@ -110,6 +110,7 @@ enum ixgbe_pfvf_api_rev {
>  
>  /* mailbox API, version 1.2 VF requests */
>  #define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
> +#define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS hash key */
>  
>  /* length of permanent address message returned from PF */
>  #define IXGBE_VF_PERMADDR_MSG_LEN	4
> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
> index 2676c0b..ec68145 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/vf.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
> @@ -301,6 +301,72 @@ static inline int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *msgbuf,
>  	return 0;
>  }
>  
> +static inline int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, u8 *rss_key)
> +{
> +	int err;
> +	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
> +
> +	/* We currently support the RSS Random Key retrieval for 82599 and x540
> +	 * devices only.
> +	 *
> +	 * Thus return an error if API doesn't support RSS Random Key retrieval
> +	 * or if the operation is not supported for this device type.
> +	 */
> +	if (hw->api_version != ixgbe_mbox_api_12 ||
> +	    hw->mac.type >= ixgbe_mac_X550_vf)
> +		return -EPERM;
> +

The return type here should be not supported, or IXGBE_NOT_IMPLEMENTED,
not no permissions.

> +	msgbuf[0] = IXGBE_VF_GET_RSS_KEY;
> +	err = hw->mbx.ops.write_posted(hw, msgbuf, 1);
> +
> +	if (err)
> +		return err;
> +
> +	err = hw->mbx.ops.read_posted(hw, msgbuf, 11);
> +
> +	if (err)
> +		return err;
> +
> +	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
> +
> +	/* If the operation has been refused by a PF return -EPERM */
> +	if (msgbuf[0] == (IXGBE_VF_GET_RETA | IXGBE_VT_MSGTYPE_NACK))
> +		return -EPERM;
> +
> +	/* If we didn't get an ACK there must have been
> +	 * some sort of mailbox error so we should treat it
> +	 * as such.
> +	 */
> +	if (msgbuf[0] != (IXGBE_VF_GET_RSS_KEY | IXGBE_VT_MSGTYPE_ACK))
> +		return IXGBE_ERR_MBX;
> +
> +	memcpy(rss_key, msgbuf + 1, IXGBEVF_RSS_HASH_KEY_SIZE);
> +
> +	return 0;
> +}
> +
> +/**
> + * ixgbevf_get_rss_key - get the RSS Random Key
> + * @hw: pointer to the HW structure
> + * @reta: buffer to fill with RETA contents.
> + *
> + * The "rss_key" buffer should be big enough to contain 10 registers.
> + * Ensures the atomicy of a mailbox access using the adapter.mbx_lock spinlock.
> + *
> + * Returns: 0 on success.
> + *          if API doesn't support this operation - (-EPERM).
> + */
> +int ixgbevf_get_rss_key(struct ixgbevf_adapter *a, u8 *rss_key)
> +{
> +	int rc;
> +
> +	spin_lock_bh(&a->mbx_lock);
> +	rc = ixgbevf_get_rss_key_locked(&a->hw, rss_key);
> +	spin_unlock_bh(&a->mbx_lock);
> +
> +	return rc;
> +}
> +

Since there is currently no cases where you would be getting the rss_key
without the RETA you might just want to combine this function with
ixgbevf_get_reta so you only take the lock once and process both
messages in one pass instead of having to bounce the spinlock.

>  /**
>   * ixgbevf_get_reta - get the RSS redirection table (RETA) contents.
>   * @adapter: pointer to the port handle
> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
> index 7944962..a054716 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/vf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
> @@ -212,4 +212,5 @@ int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
>  int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
>  		       unsigned int *default_tc);
>  int ixgbevf_get_reta(struct ixgbevf_adapter *adapter, u32 *reta);
> +int ixgbevf_get_rss_key(struct ixgbevf_adapter *adapter, u8 *rss_key);
>  #endif /* __IXGBE_VF_H__ */
> 
