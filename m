From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v3 1/5] ixgbe: Ensure MAC filter was added before
 setting MACVLAN
Date: Wed, 19 Jul 2017 03:54:55 -0700
Message-ID: <1500461695.25934.35.camel@perches.com>
References: <20170719012305.76795-1-jeffrey.t.kirsher@intel.com>
         <20170719012305.76795-2-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0072.hostedemail.com ([216.40.44.72]:53710 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752269AbdGSKy7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 06:54:59 -0400
In-Reply-To: <20170719012305.76795-2-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-07-18 at 18:23 -0700, Jeff Kirsher wrote:
> This patch adds a check to ensure that adding the MAC filter was
> successful before setting the MACVLAN.  If it was unsuccessful, propagate
> the error.
[]
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
[]
> @@ -681,6 +681,7 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
>  {
>  	struct list_head *pos;
>  	struct vf_macvlans *entry;
> +	s32 retval = 0;

This function returns int, why use s32 here?
 
>  	if (index <= 1) {
>  		list_for_each(pos, &adapter->vf_mvs.l) {
> @@ -721,14 +722,15 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
>  	if (!entry || !entry->free)
>  		return -ENOSPC;
>  
> -	entry->free = false;
> -	entry->is_macvlan = true;
> -	entry->vf = vf;
> -	memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);
> -
> -	ixgbe_add_mac_filter(adapter, mac_addr, vf);
> +	retval = ixgbe_add_mac_filter(adapter, mac_addr, vf);
> +	if (retval >= 0) {
> +		entry->free = false;
> +		entry->is_macvlan = true;
> +		entry->vf = vf;
> +		memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);
> +	}
>  
> -	return 0;
> +	return retval;

This is also backwards logic from typical style
and unnecessarily indents code.

	retval = ixgbe_add_mac_filter(adapter, mac_addr, vf);
	if (retval < 0)
		return retval;

	entry->free = false;
	entry->is_macvlan = true;
	entry->vf = vf;
	memcpy(entry->vf_macvlan, mac_addr, ETH_ALEN);> 

	return 0;
}

This patch also sets the return value to a
possible positive value.

Is that really desired?

The only code that seems to use a possible
positive value also limits its return to 0

static int ixgbe_uc_sync(struct net_device *netdev, const unsigned char *addr)
{
	struct ixgbe_adapter *adapter = netdev_priv(netdev);
	int ret;

	ret = ixgbe_add_mac_filter(adapter, addr, VMDQ_P(0));

	return min_t(int, ret, 0);
}
