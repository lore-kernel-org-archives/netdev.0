From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC net-next (v2) 12/14] ixgbe: set maximal number of default
 RSS queues
Date: Tue, 26 Jun 2012 08:55:52 -0700
Message-ID: <4FE9DB88.5070208@intel.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com> <1340624745-8650-13-git-send-email-yuvalmin@broadcom.com> <4FE88770.7070007@intel.com> <1340646818.2486.27.camel@lb-tlvb-eilong.il.broadcom.com> <4FE8B019.4030807@intel.com> <4FE9983C.2060006@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50955 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756880Ab2FZP4O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 11:56:14 -0400
In-Reply-To: <4FE9983C.2060006@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26/2012 04:08 AM, Yuval Mintz wrote:
>>> How about this:
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
>>> index af1a531..23a8609 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
>>> @@ -277,6 +277,8 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
>>>  	bool ret = false;
>>>  	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_RSS];
>>>  
>>> +	f->indices = min_t(int, netif_get_num_default_rss_queues(), f->indices);
>>> +
>>>  	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
>>>  		f->mask = 0xF;
>>>  		adapter->num_rx_queues = f->indices;
>>> @@ -302,7 +304,9 @@ static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
>>>  	bool ret = false;
>>>  	struct ixgbe_ring_feature *f_fdir = &adapter->ring_feature[RING_F_FDIR];
>>>  
>>> -	f_fdir->indices = min_t(int, num_online_cpus(), f_fdir->indices);
>>> +	f_fdir->indices = min_t(int, netif_get_num_default_rss_queues(),
>>> +				f_fdir->indices);
>>> +
>>>  	f_fdir->mask = 0;
>>>  
>>>  	/*
>>> @@ -339,8 +343,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
>>>  	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
>>>  		return false;
>>>  
>>> -	f->indices = min_t(int, num_online_cpus(), f->indices);
>>> -
>>> +	f->indices = min_t(int, f->indices, netif_get_num_default_rss_queues());
>>>  	adapter->num_rx_queues = 1;
>>>  	adapter->num_tx_queues = 1;
>>>
>> This makes much more sense, but still needs a few minor changes.
>
>
> Well, what about this one:
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> index af1a531..0dd1e51 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> @@ -277,6 +277,7 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
>  	bool ret = false;
>  	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_RSS];
>
> +	f->indices = min_t(int, netif_get_num_default_rss_queues(), f->indices);
>  	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
>  		f->mask = 0xF;
>  		adapter->num_rx_queues = f->indices;
> @@ -376,7 +377,7 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
>
>  	/* Map queue offset and counts onto allocated tx queues */
>  	per_tc_q = min_t(unsigned int, dev->num_tx_queues / tcs, DCB_QUEUE_CAP);
> -	q = min_t(int, num_online_cpus(), per_tc_q);
> +	q = min_t(int, netif_get_num_default_rss_queues(), per_tc_q);
>
>  	for (i = 0; i < tcs; i++) {
>  		netdev_set_tc_queue(dev, i, q, offset);
>
Add back in the bit for ixgbe_set_fcoe_queues and you should just about
have it in terms of limiting the number of RSS queues.  That bit is
valid since the FCoE queues are based directly off of the RSS configuration.

One thing that just occurred to me though is that this is going to lock
the upper limit for us and we won't be able to override it if we
implement the set channels code.  I believe the same thing goes for the
igb driver as well.

Is there any chance you could just bypass the ixgbe and igb drivers for
now and give us time to come up with a more complete solution that would
allow us to add the set_channels calls.  One issue is I have a number of
ixgbe patches that are going to be completely rewriting this code anyway
so I could probably just add set_channels support and support for your
function once it is included in net-next.

Thanks,

Alex
