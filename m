From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: possible use after free in dst_release
Date: Wed, 06 Jan 2016 15:00:53 -0500 (EST)
Message-ID: <20160106.150053.1977206705679836394.davem@davemloft.net>
References: <20160106081848.4532F6340189@us105.sjc.aristanetworks.com>
	<1452088644.8255.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fruggeri@aristanetworks.com, fruggeri@arista.com,
	edumazet@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbcAFUAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:00:55 -0500
In-Reply-To: <1452088644.8255.165.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jan 2016 05:57:24 -0800

> On Wed, 2016-01-06 at 00:18 -0800, Francesco Ruggeri wrote:
>> dst_release should not access dst->flags after decrementing
>> __refcnt to 0. The dst_entry may be in dst_busy_list and
>> dst_gc_task may dst_destroy it before dst_release gets a chance
>> to access dst->flags.
>> 
>> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
>> ---
>>  net/core/dst.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/core/dst.c b/net/core/dst.c
>> index e6dc772..a1656e3 100644
>> --- a/net/core/dst.c
>> +++ b/net/core/dst.c
>> @@ -301,12 +301,13 @@ void dst_release(struct dst_entry *dst)
>>  {
>>  	if (dst) {
>>  		int newrefcnt;
>> +		unsigned short nocache = dst->flags & DST_NOCACHE;
>>  
>>  		newrefcnt = atomic_dec_return(&dst->__refcnt);
>>  		if (unlikely(newrefcnt < 0))
>>  			net_warn_ratelimited("%s: dst:%p refcnt:%d\n",
>>  					     __func__, dst, newrefcnt);
>> -		if (!newrefcnt && unlikely(dst->flags & DST_NOCACHE))
>> +		if (!newrefcnt && unlikely(nocache))
>>  			call_rcu(&dst->rcu_head, dst_destroy_rcu);
>>  	}
>>  }
> 
> You're right.
> 
> My previous fix (commit d69bbf88c8d0) was okay only for DST_NOCACHE dst.
> 
> Fixes: d69bbf88c8d0 ("net: fix a race in dst_release()")
> Fixes: 27b75c95f10d ("net: avoid RCU for NOCACHE dst")
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks everyone!
