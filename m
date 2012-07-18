From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/15] ipv4: Cache output routes in fib_info nexthops.
Date: Wed, 18 Jul 2012 13:36:47 -0700 (PDT)
Message-ID: <20120718.133647.1948216070418950586.davem@davemloft.net>
References: <20120718.112404.1910372180742347127.davem@davemloft.net>
	<1342643659.2626.3636.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab2GRUgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:36:48 -0400
In-Reply-To: <1342643659.2626.3636.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 22:34:19 +0200

> On Wed, 2012-07-18 at 11:24 -0700, David Miller wrote:
>> If we have an output route that lacks nexthop exceptions, we can cache
>> it in the FIB info nexthop.
>> 
>> Such routes will have DST_HOST cleared because such routes refer to a
>> family of destinations, rather than just one.
> 
> 
>> -			   const struct fib_result *res,
>> +static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
>> +{
>> +	static DEFINE_SPINLOCK(fib_cache_lock);
>> +	struct rtable **p = &nh->nh_rth_output;
>> +
>> +	if (*p)
>> +		return;
>> +
>> +	spin_lock_bh(&fib_cache_lock);
>> +	if (!*p) {
>> +		*p = rt;
>> +		dst_clone(&rt->dst);
>> +	}
>> +	spin_unlock_bh(&fib_cache_lock);
>> +}
>> +
> 
> This probably should use cmpxchg()

Do you really think it's faster/better in this case?  I did consider
it.
