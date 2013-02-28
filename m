From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH 2/3] ixgbe: Use default fdb handlers when not in VF
 mode.
Date: Wed, 27 Feb 2013 20:26:31 -0800
Message-ID: <512EDC77.5090802@intel.com>
References: <1361987164-15280-1-git-send-email-vyasevic@redhat.com> <1361987164-15280-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:49615 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854Ab3B1E1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 23:27:40 -0500
In-Reply-To: <1361987164-15280-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/27/2013 9:46 AM, Vlad Yasevich wrote:
> Allow the use of ndo_dflt_fdb_<add|del|dump> when the
> adapter does not have VF configured.  This allows for
> IFF_UNICAST_FLT support and allows VF handling to potentially
> do something different.
>
> CC: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   26 ++++++++++--------------
>   1 files changed, 11 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 68478d6..0ae2525 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -7007,7 +7007,7 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],

With the first patch we can just remove this routine altogether and
let the dflt handler do its work.

CC'd Greg in case I miss something.

>   	int err;
>
>   	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
> -		return -EOPNOTSUPP;
> +		return ndo_dflt_fdb_add(ndm, tb, dev, addr, flags);
>
>   	/* Hardware does not support aging addresses so if a
>   	 * ndm_state is given only allow permanent addresses
> @@ -7045,20 +7045,21 @@ static int ixgbe_ndo_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],

same here just remove it and use the dflt handler.

>   	struct ixgbe_adapter *adapter = netdev_priv(dev);
>   	int err = -EOPNOTSUPP;
>
> +	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
> +		return ndo_dflt_fdb_del(ndm, tb, dev, addr);
> +
>   	if (ndm->ndm_state & NUD_PERMANENT) {
>   		pr_info("%s: FDB only supports static addresses\n",
>   			ixgbe_driver_name);
>   		return -EINVAL;
>   	}
>
> -	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
> -		if (is_unicast_ether_addr(addr))
> -			err = dev_uc_del(dev, addr);
> -		else if (is_multicast_ether_addr(addr))
> -			err = dev_mc_del(dev, addr);
> -		else
> -			err = -EINVAL;
> -	}
> +	if (is_unicast_ether_addr(addr))
> +		err = dev_uc_del(dev, addr);
> +	else if (is_multicast_ether_addr(addr))
> +		err = dev_mc_del(dev, addr);
> +	else
> +		err = -EINVAL;
>
>   	return err;
>   }
> @@ -7068,12 +7069,7 @@ static int ixgbe_ndo_fdb_dump(struct sk_buff *skb,
>   			      struct net_device *dev,
>   			      int idx)
>   {

This is the same as not defining the op at all right? Just
remove it.

> -	struct ixgbe_adapter *adapter = netdev_priv(dev);
> -
> -	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
> -		idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
> -
> -	return idx;
> +	return ndo_dflt_fdb_dump(skb, cb, dev, idx);
>   }
>
>   static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
>

Then we get a patch with all '-' which is sort of nice.
