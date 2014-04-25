From: Chris Mason <clm@fb.com>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for /proc/net/ipv6_route
Date: Fri, 25 Apr 2014 16:27:21 -0400
Message-ID: <535AC529.4030107@fb.com>
References: <535918BC.5030708@fb.com> <20140425.160929.1031376209639331549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52077 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753289AbaDYU0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 16:26:41 -0400
In-Reply-To: <20140425.160929.1031376209639331549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2014 04:09 PM, David Miller wrote:
> From: Chris Mason <clm@fb.com>
> Date: Thu, 24 Apr 2014 09:59:24 -0400
>
>> The ipv6 code to dump routes in /proc/net/ipv6_route can hold
>> a read lock on the table for a very long time.  This ends up blocking
>> writers and triggering softlockups.
>>
>> This patch is a simple work around to limit the number of entries
>> we'll walk while processing /proc/net/ipv6_route.  It intentionally
>> slows down proc file reading to make sure we don't lock out the
>> real ipv6 traffic.
>>
>> This patch is also horrible, and doesn't actually fix the entire
>> problem.  We still have rcu_read_lock held the whole time we cat
>> /proc/net/ipv6_route.  On an unpatched machine, I've clocked the
>> time required to cat /proc/net/ipv6_route at 14 minutes.
>
> There is another way to more effectively mitigate this.
>
> Take the rtnl mutex over the traversals.
>
> The tables cannot change if you hold it.
>
> Then you can use rcu_dereference_rtnl() in the table traversals and
> get rid of the RCU locking entirely.

Ah ok, so the rtnl mutex can replace rcu_read_lock().  Will it end up 
blocking any traffic? (sorry, filesystem guys are a little slow)

>
> Now you're only left with the read locking over the individual trees.
> And as in your patch we can drop it temporarily after a limit is hit.

That would be wonderful because I can use some cond_resched() variant, 
and get rid of the max_walk counter completely.

>
> But yes, longer term we need to convert the ipv6 route trees over to
> RCU or similar.

Instead of the ->skip counter, can we get a cursor into the tree and 
just resume walking at the first entry after that cursor?  It would have 
to be a key that we copy out instead of a pointer so we can drop the 
rcu_read_lock()

>
> Even better would be to align the ipv6 routing with how ipv4 works
> since the routing-cache removal.
>

I'll shop task that around here.

-chris
