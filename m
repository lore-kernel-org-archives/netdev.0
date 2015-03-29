From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v9 4/7] ixgbevf: Add a RETA query code
Date: Sun, 29 Mar 2015 15:51:42 -0700
Message-ID: <551881FE.7000600@gmail.com>
References: <1427645497-8339-1-git-send-email-vladz@cloudius-systems.com> <1427645497-8339-5-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35282 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbbC2Wvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 18:51:47 -0400
Received: by pacwz10 with SMTP id wz10so97948495pac.2
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 15:51:47 -0700 (PDT)
In-Reply-To: <1427645497-8339-5-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2015 09:11 AM, Vlad Zolotarov wrote:
> We will currently support only 82599 and x540 deviced. Support for other devices
> will be added later.
> 
>    - Added a new API version support.
>    - Added the query implementation in the ixgbevf.
> 
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v9:
>    - Reduce the support to 82599 and x540 devices only.
>    - Improvements in RETA query code:
>       - Implement a "compression" of VF's RETA contents: pass only 2 bits
>         per-entry.
>       - RETA querying is done in a single mailbox operation thanks to compression.
> 
> New in v8:
>    - Protect mailbox with a spinlock.
> 
> New in v7:
>    - Add ixgbe_mbox_api_12 case in ixgbevf_set_num_queues().
>    - Properly expand HW RETA into the ethtool buffer.
> 
> New in v6:
>    - Add a proper return code when an operation is blocked by PF.
> 
> New in v3:
>    - Adjusted to the new interface IXGBE_VF_GET_RETA command.
>    - Added a proper support for x550 devices.
> 
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single option case
>      (in ixgbevf_get_reta()).
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  5 +-
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  4 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 76 +++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |  2 +
>  4 files changed, 86 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 4ee15ad..a16d267 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -2030,7 +2030,8 @@ static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
>  static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
>  {
>  	struct ixgbe_hw *hw = &adapter->hw;
> -	int api[] = { ixgbe_mbox_api_11,
> +	int api[] = { ixgbe_mbox_api_12,
> +		      ixgbe_mbox_api_11,
>  		      ixgbe_mbox_api_10,
>  		      ixgbe_mbox_api_unknown };
>  	int err = 0, idx = 0;
> @@ -2332,6 +2333,7 @@ static void ixgbevf_set_num_queues(struct ixgbevf_adapter *adapter)
>  
>  		switch (hw->api_version) {
>  		case ixgbe_mbox_api_11:
> +		case ixgbe_mbox_api_12:
>  			adapter->num_rx_queues = rss;
>  			adapter->num_tx_queues = rss;
>  		default:
> @@ -3712,6 +3714,7 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
>  
>  	switch (adapter->hw.api_version) {
>  	case ixgbe_mbox_api_11:
> +	case ixgbe_mbox_api_12:
>  		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
>  		break;
>  	default:
> diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
> index 6253e93..66e138b 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
> @@ -83,6 +83,7 @@ enum ixgbe_pfvf_api_rev {
>  	ixgbe_mbox_api_10,	/* API version 1.0, linux/freebsd VF driver */
>  	ixgbe_mbox_api_20,	/* API version 2.0, solaris Phase1 VF driver */
>  	ixgbe_mbox_api_11,	/* API version 1.1, linux/freebsd VF driver */
> +	ixgbe_mbox_api_12,	/* API version 1.2, linux/freebsd VF driver */
>  	/* This value should always be last */
>  	ixgbe_mbox_api_unknown,	/* indicates that API version is not known */
>  };
> @@ -107,6 +108,9 @@ enum ixgbe_pfvf_api_rev {
>  #define IXGBE_VF_TRANS_VLAN	3 /* Indication of port VLAN */
>  #define IXGBE_VF_DEF_QUEUE	4 /* Default queue offset */
>  
> +/* mailbox API, version 1.2 VF requests */
> +#define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
> +
>  /* length of permanent address message returned from PF */
>  #define IXGBE_VF_PERMADDR_MSG_LEN	4
>  /* word in permanent address message with the current multicast type */
> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
> index 2614fd3..2676c0b 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/vf.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
> @@ -256,6 +256,81 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
>  	return ret_val;
>  }
>  
> +static inline int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *msgbuf,
> +					  u32 *reta)
> +{
> +	int err, i, j;
> +	u32 *hw_reta = &msgbuf[1];
> +
> +	/* We have to use a mailbox for 82599 and x540 devices only.
> +	 * For these devices RETA has 128 entries.
> +	 * Also these VFs support up to 4 RSS queues. Therefore PF will compress
> +	 * 16 RETA entries in each DWORD giving 2 bits to each entry.
> +	 */
> +	int dwords = 128 / 16;
> +
> +	msgbuf[0] = IXGBE_VF_GET_RETA;
> +
> +	err = hw->mbx.ops.write_posted(hw, msgbuf, 1);
> +
> +	if (err)
> +		return err;
> +
> +	err = hw->mbx.ops.read_posted(hw, msgbuf, dwords + 1);
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
> +	if (msgbuf[0] != (IXGBE_VF_GET_RETA | IXGBE_VT_MSGTYPE_ACK))
> +		return IXGBE_ERR_MBX;
> +
> +	for (i = 0; i < dwords; i++)
> +		for (j = 0; j < 16; j++)
> +			reta[i * 16 + j] = (hw_reta[i] >> (2 * j)) & 0x3;
> +
> +	return 0;
> +}
> +
> +/**
> + * ixgbevf_get_reta - get the RSS redirection table (RETA) contents.
> + * @adapter: pointer to the port handle
> + * @reta: buffer to fill with RETA contents.
> + *
> + * The "reta" buffer should be big enough to contain 32 registers.
> + *
> + * Returns: 0 on success.
> + *          if API doesn't support this operation - (-EPERM).
> + */
> +int ixgbevf_get_reta(struct ixgbevf_adapter *adapter, u32 *reta)
> +{
> +	int err;
> +	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
> +
> +	/* We support the RSS querying for 82599 and x540 devices only.
> +	 * Thus return an error if API doesn't support RETA querying or querying
> +	 * is not supported for this device type.
> +	 */
> +	if (adapter->hw.api_version != ixgbe_mbox_api_12 ||
> +	    adapter->hw.mac.type >= ixgbe_mac_X550_vf)
> +		return -EPERM;
> +
> +	spin_lock_bh(&adapter->mbx_lock);
> +	err = ixgbevf_get_reta_locked(&adapter->hw, msgbuf, reta);
> +	spin_unlock_bh(&adapter->mbx_lock);
> +
> +	return err;
> +}
> +

You really shouldn't be pushing the lock down to this level.  The caller
should be one to hold the mailbox lock.  Also the functions at this
level are normally only passed the hardware struct, not the adapter
struct as most of this code is meant to be usable in other OSes such as
FreeBSD and the Linux spin_lock calls are not generic across OSes.

>  /**
>   *  ixgbevf_set_rar_vf - set device MAC address
>   *  @hw: pointer to hardware structure
> @@ -545,6 +620,7 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
>  	/* do nothing if API doesn't support ixgbevf_get_queues */
>  	switch (hw->api_version) {
>  	case ixgbe_mbox_api_11:
> +	case ixgbe_mbox_api_12:
>  		break;
>  	default:
>  		return 0;
> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
> index 6688250..7944962 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/vf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
> @@ -38,6 +38,7 @@
>  #include "mbx.h"
>  
>  struct ixgbe_hw;
> +struct ixgbevf_adapter;
>  
>  /* iterator type for walking multicast address lists */
>  typedef u8* (*ixgbe_mc_addr_itr) (struct ixgbe_hw *hw, u8 **mc_addr_ptr,
> @@ -210,4 +211,5 @@ void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size);
>  int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
>  int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
>  		       unsigned int *default_tc);
> +int ixgbevf_get_reta(struct ixgbevf_adapter *adapter, u32 *reta);
>  #endif /* __IXGBE_VF_H__ */
> 
