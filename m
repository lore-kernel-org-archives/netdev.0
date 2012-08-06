From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/5] net: Don't use ifindices in hash fns
Date: Mon, 06 Aug 2012 15:01:14 +0400
Message-ID: <501FA3FA.9010107@parallels.com>
References: <501F9CAF.3030605@parallels.com>  <501F9CDA.6040403@parallels.com> <1344249789.26674.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:22943 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755773Ab2HFLBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 07:01:20 -0400
In-Reply-To: <1344249789.26674.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2012 02:43 PM, Eric Dumazet wrote:
> On Mon, 2012-08-06 at 14:30 +0400, Pavel Emelyanov wrote:
>> Eric noticed, that when there will be devices with equal indices, some
>> hash functions that use them will become less effective as they could.
>>
>> Fix this in advance by taking the net_device address into calculations
>> instead of the device index. Since the net_device is always aligned in
>> memory, shift the pointer to eliminate always zero bits (like we do it
>> in net_hash_mix).
>>
>> This is true for arp and ndisc hash fns. The netlabel, can and llc ones
>> are also ifindex-based, but that three are init_net-only, thus will not
>> be affected.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>
>> ---
>>  include/linux/netdevice.h |    6 ++++++
>>  include/net/arp.h         |    2 +-
>>  include/net/ndisc.h       |    2 +-
>>  3 files changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index a9db4f3..6010b37 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1330,6 +1330,12 @@ struct net_device {
>>  
>>  #define	NETDEV_ALIGN		32
>>  
>> +static inline unsigned int netdev_hash_mix(const struct net_device *dev)
>> +{
>> +	return (unsigned int)(((unsigned long)dev) >>
>> +			max(L1_CACHE_BYTES, NETDEV_ALIGN));
>> +}
>> +
> 
> I guess you didnt test this patch very well ...

Damn :( You're right.

> This returns 0 as is

Well, on 64-bit no, but what it does is also not what it was supposed to.

> I would define a generic pointer hash mix instead of a 'net_device
> thing'
> 
> static inline u32 ptr_hash_mix(void *ptr)
> {
> #if BITS_PER_LONG==32
> 	return (u32)(unsigned long)ptr;
> #else
> 	return (u32)((unsigned long)ptr >> L1_CACHE_SHIFT);
> #endif
> }

OK. It will also obsolete the net_hash_mix then. Any suggestions where to put
the new one?

Thanks,
Pavel
