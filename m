From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v1 1/2] net: implement mechanism for HW based QOS
Date: Thu, 18 Nov 2010 09:27:59 -0800
Message-ID: <4CE5621F.8040503@intel.com>
References: <20101117051544.19800.97654.stgit@jf-dev1-dcblab> <1289976990.2732.226.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54189 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932656Ab0KRR17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 12:27:59 -0500
In-Reply-To: <1289976990.2732.226.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2010 10:56 PM, Eric Dumazet wrote:
> Le mardi 16 novembre 2010 =C3=A0 21:15 -0800, John Fastabend a =C3=A9=
crit :
>> This patch provides a mechanism for lower layer devices to
>> steer traffic using skb->priority to tx queues. This allows
>> for hardware based QOS schemes to use the default qdisc without
>> incurring the penalties related to global state and the qdisc
>> lock. While reliably receiving skbs on the correct tx ring
>> to avoid head of line blocking resulting from shuffling in
>> the LLD. Finally, all the goodness from txq caching and xps/rps
>> can still be leveraged.
>>
>> Many drivers and hardware exist with the ability to implement
>> QOS schemes in the hardware but currently these drivers tend
>> to rely on firmware to reroute specific traffic, a driver
>> specific select_queue or the queue_mapping action in the
>> qdisc.
>>
>> None of these solutions are ideal or generic so we end up
>> with driver specific solutions that one-off traffic types
>> for example FCoE traffic is steered in ixgbe with the
>> queue_select routine. By using select_queue for this drivers
>> need to be updated for each and every traffic type and we
>> loose the goodness of much of the upstream work. For example
>> txq caching.
>>
>> Firmware solutions are inherently inflexible. And finally if
>> admins are expected to build a qdisc and filter rules to steer
>> traffic this requires knowledge of how the hardware is currently
>> configured. The number of tx queues and the queue offsets may
>> change depending on resources. Also this approach incurs all the
>> overhead of a qdisc with filters.
>>
>> With this mechanism users can set skb priority using expected
>> methods either socket options or the stack can set this directly.
>> Then the skb will be steered to the correct tx queues aligned
>> with hardware QOS traffic classes. In the normal case with a
>> single traffic class and all queues in this class every thing
>> works as is until the LLD enables multiple tcs.
>>
>> To steer the skb we mask out the lower 8 bits of the priority
>> and allow the hardware to configure upto 15 distinct classes
>> of traffic. This is expected to be sufficient for most applications
>> at any rate it is more then the 8021Q spec designates and is
>> equal to the number of prio bands currently implemented in
>> the default qdisc.
>>
>> This in conjunction with a userspace application such as
>> lldpad can be used to implement 8021Q transmission selection
>> algorithms one of these algorithms being the extended transmission
>> selection algorithm currently being used for DCB.
>>
>> If this approach seems reasonable I'll go ahead and finish
>> this up. The priority to tc mapping should probably be exposed
>> to userspace either through sysfs or rtnetlink. Any thoughts?
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>
>>  include/linux/netdevice.h |   47 ++++++++++++++++++++++++++++++++++=
+++++++++++
>>  net/core/dev.c            |   43 ++++++++++++++++++++++++++++++++++=
++++++-
>>  2 files changed, 89 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index b45c1b8..8a2adeb 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1092,6 +1092,12 @@ struct net_device {
>>  	/* Data Center Bridging netlink ops */
>>  	const struct dcbnl_rtnl_ops *dcbnl_ops;
>>  #endif
>> +	u8 max_tcs;
>> +	u8 num_tcs;
>> +	unsigned int *_tc_txqcount;
>> +	unsigned int *_tc_txqoffset;
>=20
> This seems wrong to use two different pointers, this is a waste of ca=
che
> memory. Also, I am not sure we need 32 bits, I believe we have a 16bi=
t
> limit for queue numbers.
>=20

Thanks for the feedback!

num_tx_queues is an unsigned int in net_device and I can't see any plac=
e that would limit it to 16bits. So I think we need 32 bits here. Other=
wise I will make these changes and fix the fallout. This is much cleane=
r.


> Use a struct {
> 	u16 count;
> 	u16 offset;
> };
>=20
>> +	u64 prio_tc_map;
>=20
> Seems wrong too on 32bit arches
>=20
> 	Please use : (even if using 16 bytes instead of 8)
>=20
> 	u8 prio_tc_map[16];
>=20
>> +
>> =20
>>  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
>>  	/* max exchange id for FCoE LRO by ddp */
>> @@ -1108,6 +1114,44 @@ struct net_device {
>>  #define	NETDEV_ALIGN		32
>> =20
>>  static inline
>> +int netdev_get_prio_tc_map(const struct net_device *dev, u32 prio)
>> +{
>> +	return (dev->prio_tc_map >> (4 * (prio & 0xF))) & 0xF;
>=20
> 	return dev->prio_tc_map[prio & 15];
>=20
>> +}


