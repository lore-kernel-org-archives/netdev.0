From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/3] net: ipv6: Allow shorthand delete of
 all nexthops in multipath route
Date: Mon, 16 Jan 2017 20:37:17 -0500 (EST)
Message-ID: <20170116.203717.949572770050738032.davem@davemloft.net>
References: <1484510826-2723-2-git-send-email-dsa@cumulusnetworks.com>
        <20170116.195139.2265183195514595519.davem@davemloft.net>
        <06d4b3c0-0713-04b8-32d2-99b9b083b825@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750782AbdAQBhj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 20:37:39 -0500
In-Reply-To: <06d4b3c0-0713-04b8-32d2-99b9b083b825@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 16 Jan 2017 18:27:36 -0700

> On 1/16/17 5:51 PM, David Miller wrote:
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Sun, 15 Jan 2017 12:07:04 -0800
>> 
>>> @@ -2143,6 +2143,26 @@ int ip6_del_rt(struct rt6_info *rt)
>>>  	return __ip6_del_rt(rt, &info);
>>>  }
>>>  
>>> +/* called with table lock held */
>>  ...
>>> @@ -2176,10 +2196,9 @@ static int ip6_route_del(struct fib6_config *cfg)
>>>  				continue;
>>>  			if (cfg->fc_protocol && cfg->fc_protocol != rt->rt6i_protocol)
>>>  				continue;
>>> -			dst_hold(&rt->dst);
>>> -			read_unlock_bh(&table->tb6_lock);
>>>  
>>> -			return __ip6_del_rt(rt, &cfg->fc_nlinfo);
>>> +			err = __ip6_route_del(rt, cfg);
>>> +			break;
>>>  		}
>> 
>> fib6_del() (invoked by __ip6_route_del()) has to be invoked with the
>> table lock held a sa writer, but here you are only holding it as a
>> reader.
> 
> That table lock is still held. If you look up 2 lines I remove the line that releases the lock.

It's held in this function as a reader, it needs to be held as a writer.

That's why the lock is dropped in the current code and the existing
wrapper around fib6_del() takes it as a writer.

Is it clear now?

	read_lock_bh(&table->lock);
	fib6_del();

is invalid.

	write_lock_bh(&table->lock);
	fib6_del();

is required.
