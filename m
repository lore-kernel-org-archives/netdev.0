From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Sat, 20 Jun 2009 18:39:25 +0200
Message-ID: <4A3D10BD.3050301@gmail.com>
References: <20090619171814.GE18237@hmsreliant.think-freely.org> <4A3CD7EC.2040904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mbizon@freebox.fr, dada1@cosmosbay.com,
	kuznet@ms2.inr.ac.ru, davem@davemloft.net, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:62064 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbZFTQjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 12:39:51 -0400
Received: by fg-out-1718.google.com with SMTP id 16so764396fgg.17
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2009 09:39:52 -0700 (PDT)
In-Reply-To: <4A3CD7EC.2040904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 06/20/2009 02:37 PM:

> Neil Horman wrote, On 06/19/2009 07:18 PM:
> 
>> Don't drop route if we're not caching	

...

>>  route.c |   14 ++++++++++++--
>>  1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index cd76b3c..65b3a8b 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -1085,8 +1085,16 @@ restart:
>>  	now = jiffies;
>>  
>>  	if (!rt_caching(dev_net(rt->u.dst.dev))) {
>> -		rt_drop(rt);


One more question: if this rt is assigned to an skb, there is only
skb_dst_drop() in kfree_skb(), but it seems we skip rt_free() part,
or I miss something?

Jarek P.

>> -		return 0;
>> +		/*
>> +		 * If we're not caching, just tell the caller we
>> +		 * were successful and don't touch the route.  The
>> +		 * caller hold the sole reference to the cache entry, and
>> +		 * it will be released when the caller is done with it.
>> +		 * If we drop it here, the callers have no way to resolve routes
>> +		 * when we're not caching.  Instead, just point *rp at rt, so
>> +		 * the caller gets a single use out of the route
>> +		 */
>> +		goto report_and_exit;
>>  	}
>>  
>>  	rthp = &rt_hash_table[hash].chain;
>> @@ -1217,6 +1225,8 @@ restart:
>>  	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
>>  
>>  	spin_unlock_bh(rt_hash_lock_addr(hash));
>> +
>> +report_and_exit:
>>  	if (rp)
>>  		*rp = rt;
>>  	else


