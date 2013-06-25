From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH] net: add a tx_queue attribute rate_queue_limits in
 Mbps
Date: Tue, 25 Jun 2013 14:08:26 -0700
Message-ID: <51CA06CA.2010305@gmail.com>
References: <20130624032407.7546.96685.stgit@nitbit.x32> <1372186837.2110.17.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:61784 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab3FYVIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 17:08:51 -0400
Received: by mail-oa0-f53.google.com with SMTP id k14so14116945oag.12
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 14:08:50 -0700 (PDT)
In-Reply-To: <1372186837.2110.17.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2013 12:00 PM, Ben Hutchings wrote:
> On Sun, 2013-06-23 at 20:24 -0700, John Fastabend wrote:
> [...]
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> [...]
>> +int ixgbe_set_rate_limit(struct net_device *dev, int index, u32 *tx_rate)
>> +{
>> +	struct ixgbe_adapter *a = netdev_priv(dev);
>> +	struct ixgbe_hw *hw = &a->hw;
>> +	int linkspeed = ixgbe_link_mbps(a);
>> +	u8 reg_idx = a->tx_ring[index]->reg_idx;
>> +	u32 bcnrc = ixgbe_bcnrc_from_rate(a, *tx_rate, linkspeed);
>> +
>> +	/* rate limit cannot be less than 10Mbs or greater than link speed */
>> +	if (*tx_rate && ((*tx_rate <= 10) || (*tx_rate > linkspeed)))
>> +		return -EINVAL;
>
> What if the link is not up?
>

As its written this would always be an error because link_speed is 0.
Not likely what we want.

> What if the link speed is currently higher than tx_rate, but is later
> reduced below tx_rate?

As its written you just end up with a tx_rate limit that is broken and
because the hw calculation depends on link speed the value won't be
correct any more.

Both of these cases are probably broken as is.

>
> [...]
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -574,6 +574,7 @@ struct netdev_queue {
>>   #ifdef CONFIG_BQL
>>   	struct dql		dql;
>>   #endif
>> +	unsigned long		rate_limit;
>
> Should be u32, consistent with variables in ndo_set_ratelimit and
> set_tx_rate_limit.
>
>>   } ____cacheline_aligned_in_smp;
>>
>>   static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
>> @@ -932,6 +933,14 @@ struct netdev_fcoe_hbainfo {
>>    *	that determine carrier state from physical hardware properties (eg
>>    *	network cables) or protocol-dependent mechanisms (eg
>>    *	USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
>> + *
>> + * int (*ndo_set_ratelimit)(struct net_device *dev,
>> + *			    int queue_index, u32 *maxrate)
>> + *	Called to set the rate limit in Mpbs specified by maxrate of the
>> + *	specified queue_index. It is expected that hardware way may quantize
>> + *	the rate limits. In these cases the driver should guarentee the
>> + *	specfied maxrate is not exceeded and return the set value in maxrate.
>> + *	Zero should be returned on sucess otherwise use appropriate error code.
> [...]
>
> In general, how does maxrate interact with link speed?

I think the best approach is to allow a max_rate that is greater than
the link speed. This seems more straight forward than arbitrarily
resetting the value or doing something else.

ixgbe and maybe other drivers will need to reconfigure their internal
hardware limiters if they are derived from link speed.

>
> There are also several spelling and grammar errors in this text.
>

Yeah, must have been late, not enough coffee. Thanks for looking at it
Ben.

Also I was thinking about pushing it over to netlink as Stephen
preferred.

-- 
John Fastabend         Intel Corporation
