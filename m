From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH RFC] lib/rhashtable: allow users to set the minimum shifts
 of shrinking
Date: Thu, 28 Aug 2014 09:04:17 +0800
Message-ID: <53FE8011.4060100@windriver.com>
References: <1409129851-11630-1-git-send-email-ying.xue@windriver.com> <20140827103412.GC13116@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60070 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592AbaH1BE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 21:04:58 -0400
In-Reply-To: <20140827103412.GC13116@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2014 06:34 PM, Thomas Graf wrote:
> On 08/27/14 at 04:57pm, Ying Xue wrote:
>> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
>> index a2c7881..1466e2d 100644
>> --- a/lib/rhashtable.c
>> +++ b/lib/rhashtable.c
>> @@ -293,12 +293,15 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
>>  int rhashtable_shrink(struct rhashtable *ht, gfp_t flags)
>>  {
>>  	struct bucket_table *ntbl, *tbl = rht_dereference(ht->tbl, ht);
>> +	size_t min_shift = ilog2(HASH_MIN_SIZE);
>>  	struct rhash_head __rcu **pprev;
>>  	unsigned int i;
>>  
>>  	ASSERT_RHT_MUTEX(ht);
>>  
>> -	if (tbl->size <= HASH_MIN_SIZE)
>> +	if (ht->p.min_shift)
>> +		min_shift = max(ht->p.min_shift, min_shift);
>> +	if (ht->shift <= min_shift)
>>  		return 0;
> 
> I like it. Can you translate HASH_MIN_SIZE to .minshift in
> rhashtable_init()? That way we only have to deal with .min_shift in
> rhashtable_shrink().
> 

Good suggestion! I will change it in next version.

> Note that shrinking can also be disabled by not providing a
> .shrink_decision function in rhashtable_params if the shrinking is
> too expensive for your case.
> 

Yes, I know the rule. But in some case we hope that rhashtable doesn't
take such expensive actions like expanding and shrinking when its size
is small; meanwhile, when its size is rather big, shrinking is able to
de done as usual.

In fact, we already published the max_shift to users, allowing them to
limit the biggest size of rhashtable. So, exporting min_shift should be
reasonable, having users have a chance to specify the smallest size of
rhashtable.

>> -static size_t rounded_hashtable_size(unsigned int nelem)
>> +static size_t rounded_hashtable_size(struct rhashtable_params *params)
>>  {
>> -	return max(roundup_pow_of_two(nelem * 4 / 3), HASH_MIN_SIZE);
>> +	size_t size = HASH_MIN_SIZE;
>> +
>> +	if (params->min_shift)
>> +		size = max((1UL << params->min_shift), HASH_MIN_SIZE);
>> +
>> +	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3), size);
>>  }
> 
> Same here. If you merge the provided .min_shift with HASH_MIN_SIZE
> in rhashtable_init() before calculating the size, the above logic
> can be simplified a lot.
> 

Thanks for your suggestion.

Regards,
Ying

> 
