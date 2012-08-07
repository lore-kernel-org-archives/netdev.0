From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/6] hash: Introduce ptr_hash_mix routine
Date: Tue, 07 Aug 2012 13:11:41 +0400
Message-ID: <5020DBCD.7040806@parallels.com>
References: <501FD0F2.4040609@parallels.com>	<501FD11B.6000006@parallels.com> <20120806.134459.954167716448843820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "ebiederm@xmission.com" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42789 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945Ab2HGJLu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 05:11:50 -0400
In-Reply-To: <20120806.134459.954167716448843820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2012 12:44 AM, David Miller wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Mon, 06 Aug 2012 18:13:47 +0400
> 
>> @@ -67,4 +68,13 @@ static inline unsigned long hash_ptr(const void *ptr, unsigned int bits)
>>  {
>>  	return hash_long((unsigned long)ptr, bits);
>>  }
>> +
>> +static inline u32 ptr_hash_mix(const void *ptr)
>> +{
>> +#if BITS_PER_LONG == 32
>> +	return (u32)(unsigned long)ptr;
>> +#else
>> +	return (u32)((unsigned long)ptr >> L1_CACHE_SHIFT);
>> +#endif
>> +}
>>  #endif /* _LINUX_HASH_H */
> 
> This doesn't make much sense to me.
> 
> If the whole 32-bits of the pointer is useful for entropy on 32-bit
> why isn't the whole 64-bits useful on 64-bit?
> 
> I would, instead, expect something like:
> 
> 	ptr ^ (ptr >> 32)
> 
> for the 64-bit case.
> 
> Also, that L1_CACHE_SHIFT is something callers can decide to do.
> 
> Only they know the size of their structure, the alignment used to
> allocate such objects, and thus what bits are "less relevant" and
> therefore profitable to elide from the bottom of the value.
> .

Maybe it would be better to change the way neigh_table->hash work more
significantly then? Currently it is used like

	hash = tbl->hash(key, dev, tbl->rnd);
	hash >>= (32 - tbl->hash_shift);

i.e. the caller asks for u32 hash value and then trims some lower bits.
It can be changed like

	hash = tbl->hash(key, dev, tbl->rnd, tbl->hash_shift);

making the hash fn trim the bits itself. This will allow us to use the
existing (declared to be proven to be effective) hash_ptr() routine for
the net_device pointer hashing (it requires the number of bits to use).

E.g. the arp hash might look like

static u32 arp_hashfn(u32 key, struct net_device *dev, u32 hash_rnd,
		unsigned int bits)
{
	return hash_ptr(dev, bits) ^ hash_32(key * hash_rnd, bits);
}

and the ndisc one like

static u32 ndisc_hashfn(u32 *pkey, struct net_device *dev, u32 *hash_rnd,
		unsigned int bits)
{
	return hash_ptr(dev, bits) ^
		hash_32(key[0] * hash_rnd[0], bits) ^
		hash_32(key[1] * hash_rnd[1], bits) ^
		hash_32(key[2] * hash_rnd[2], bits) ^
		hash_32(key[3] * hash_rnd[3], bits);
}

What do you think?

Thanks,
Pavel
