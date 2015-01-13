From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access
 in user space
Date: Tue, 13 Jan 2015 07:58:51 -0800
Message-ID: <54B540BB.2090507@gmail.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32> <54B535E2.7040600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, john.ronciak@intel.com,
	hannes@stressinduktion.org, brouer@redhat.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:54237 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbbAMP7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 10:59:17 -0500
Received: by mail-ob0-f172.google.com with SMTP id va8so3203495obc.3
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 07:59:16 -0800 (PST)
In-Reply-To: <54B535E2.7040600@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 07:12 AM, Daniel Borkmann wrote:
> On 01/13/2015 05:35 AM, John Fastabend wrote:
> ...
>>   struct net_device_ops {
>>       int            (*ndo_init)(struct net_device *dev);
>> @@ -1190,6 +1240,35 @@ struct net_device_ops {
>>       int            (*ndo_switch_port_stp_update)(struct net_device
>> *dev,
>>                                     u8 state);
>>   #endif
>> +    int            (*ndo_split_queue_pairs)(struct net_device *dev,
>> +                     unsigned int qpairs_start_from,
>> +                     unsigned int qpairs_num,
>> +                     struct sock *sk);
> ...
>> +    int            (*ndo_get_dma_region_info)
>> +                    (struct net_device *dev,
>> +                     struct tpacket_dma_mem_region *region,
>> +                     struct sock *sk);
>>   };
>
> Any slight chance these 8 ndo ops could be further reduced? ;)
>

Its possible we could collapse a few of these calls. I'll see if
we can get it a bit smaller. Another option would be to put a
a pointer to the set of ops in the net_device struct. Something
like,

	struct net_device {
		...
		const struct af_packet_hw *afp_ops;
		...
	}

	struct af_packet_hw {
		int (*ndo_split_queue_pairs)(struct net_device *dev,
					     unsigned int qpairs_start_from,
					     unsigned int qpairs_num,
					     struct sock *sk);
		...
	}
		

>>   /**
>> diff --git a/include/uapi/linux/if_packet.h
>> b/include/uapi/linux/if_packet.h
>> index da2d668..eb7a727 100644
>> --- a/include/uapi/linux/if_packet.h
>> +++ b/include/uapi/linux/if_packet.h
> ...
>> +struct tpacket_dev_qpair_map_region_info {
>> +    unsigned int tp_dev_bar_sz;        /* size of BAR */
>> +    unsigned int tp_dev_sysm_sz;        /* size of systerm memory */
>> +    /* number of contiguous memory on BAR mapping to user space */
>> +    unsigned int tp_num_map_regions;
>> +    /* number of contiguous memory on system mapping to user apce */
>> +    unsigned int tp_num_sysm_map_regions;
>> +    struct map_page_region {
>> +        unsigned page_offset;    /* offset to start of region */
>> +        unsigned page_sz;    /* size of page */
>> +        unsigned page_cnt;    /* number of pages */
>
> Please use unsigned int et al, or preferably __u* variants consistently
> in the uapi structs.

I'll turn this all into __u* variants.

[...]

> ...
>> +static int
>>   packet_setsockopt(struct socket *sock, int level, int optname, char
>> __user *optval, unsigned int optlen)
>>   {
>>       struct sock *sk = sock->sk;
>> @@ -3428,6 +3525,167 @@ packet_setsockopt(struct socket *sock, int
>> level, int optname, char __user *optv
>>           po->xmit = val ? packet_direct_xmit : dev_queue_xmit;
>>           return 0;
>>       }
>> +    case PACKET_RXTX_QPAIRS_SPLIT:
>> +    {
> ...
>> +        /* This call only works after a bind call which calls a dev_hold
>> +         * operation so we do not need to increment dev ref counter
>> +         */
>> +        dev = __dev_get_by_index(sock_net(sk), po->ifindex);
>> +        if (!dev)
>> +            return -EINVAL;
>> +        ops = dev->netdev_ops;
>> +        if (!ops->ndo_split_queue_pairs)
>> +            return -EOPNOTSUPP;
>> +
>> +        err =  ops->ndo_split_queue_pairs(dev,
>> +                          qpairs.tp_qpairs_start_from,
>> +                          qpairs.tp_qpairs_num, sk);
>> +        if (!err)
>> +            po->tp_owns_queue_pairs = true;
>
> When this is being set here, above test in packet_release() and the chunk
> quoted below in packet_mmap() are not guaranteed to work since we don't
> test if some ndos are actually implemented by the driver. Seems a bit
> fragile, I'm wondering if we should test this capability as a _whole_,
> iow if all necessary functions to make this work are being provided by the
> driver, e.g. flag the netdev as such and test for that instead.

Sounds good to me, better than scattering ndo checks throughout. Also
with a feature flag administrators could disable it easily.

>
>> +        return err;
>> +    }
>> +    case PACKET_RXTX_QPAIRS_RETURN:
>> +    {
> ...
>> +        dev = __dev_get_by_index(sock_net(sk), po->ifindex);
>> +        if (!dev)
>> +            return -EINVAL;
>> +        ops = dev->netdev_ops;
>> +        if (!ops->ndo_split_queue_pairs)
>> +            return -EOPNOTSUPP;
>
> Should test for ndo_return_queue_pairs.

yep but I like the feature flag idea above.

>
>> +        err =  dev->netdev_ops->ndo_return_queue_pairs(dev, sk);
>> +        if (!err)
>> +            po->tp_owns_queue_pairs = false;
>> +
> ...
>> +    case PACKET_RXTX_QPAIRS_SPLIT:
>> +    {
> ...
>> +        /* This call only work after a bind call which calls a dev_hold
>> +         * operation so we do not need to increment dev ref counter
>> +         */
>> +        dev = __dev_get_by_index(sock_net(sk), po->ifindex);
>> +        if (!dev)
>> +            return -EINVAL;
>> +        if (!dev->netdev_ops->ndo_split_queue_pairs)
>> +            return -EOPNOTSUPP;
>
> Copy-paste (although not quite, since here's no extra ops var). :)
> Should be ndo_get_split_queue_pairs.

yep.

[...]

Thanks for reviewing!

-- 
John Fastabend         Intel Corporation
