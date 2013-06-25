From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] net: add a tx_queue attribute rate_queue_limits in
 Mbps
Date: Tue, 25 Jun 2013 20:00:37 +0100
Message-ID: <1372186837.2110.17.camel@bwh-desktop.uk.level5networks.com>
References: <20130624032407.7546.96685.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <therbert@google.com>,
	<ben@decadent.org.uk>, <jesse.brandeburg@intel.com>,
	<jeffrey.t.kirsher@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31887 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab3FYTAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 15:00:42 -0400
In-Reply-To: <20130624032407.7546.96685.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-23 at 20:24 -0700, John Fastabend wrote:
[...]
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
[...]
> +int ixgbe_set_rate_limit(struct net_device *dev, int index, u32 *tx_rate)
> +{
> +	struct ixgbe_adapter *a = netdev_priv(dev);
> +	struct ixgbe_hw *hw = &a->hw;
> +	int linkspeed = ixgbe_link_mbps(a);
> +	u8 reg_idx = a->tx_ring[index]->reg_idx;
> +	u32 bcnrc = ixgbe_bcnrc_from_rate(a, *tx_rate, linkspeed);
> +
> +	/* rate limit cannot be less than 10Mbs or greater than link speed */
> +	if (*tx_rate && ((*tx_rate <= 10) || (*tx_rate > linkspeed)))
> +		return -EINVAL;

What if the link is not up?

What if the link speed is currently higher than tx_rate, but is later
reduced below tx_rate?

[...]
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -574,6 +574,7 @@ struct netdev_queue {
>  #ifdef CONFIG_BQL
>  	struct dql		dql;
>  #endif
> +	unsigned long		rate_limit;

Should be u32, consistent with variables in ndo_set_ratelimit and
set_tx_rate_limit.

>  } ____cacheline_aligned_in_smp;
>  
>  static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
> @@ -932,6 +933,14 @@ struct netdev_fcoe_hbainfo {
>   *	that determine carrier state from physical hardware properties (eg
>   *	network cables) or protocol-dependent mechanisms (eg
>   *	USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
> + *
> + * int (*ndo_set_ratelimit)(struct net_device *dev,
> + *			    int queue_index, u32 *maxrate)
> + *	Called to set the rate limit in Mpbs specified by maxrate of the
> + *	specified queue_index. It is expected that hardware way may quantize
> + *	the rate limits. In these cases the driver should guarentee the
> + *	specfied maxrate is not exceeded and return the set value in maxrate.
> + *	Zero should be returned on sucess otherwise use appropriate error code.
[...]

In general, how does maxrate interact with link speed?

There are also several spelling and grammar errors in this text.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
