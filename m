From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 18:22:13 -0400
Message-ID: <48D81A95.5080207@redhat.com>
References: <48C6C300.4050102@redhat.com> <20080909.125934.150042096.davem@davemloft.net> <20080922.034933.119934091.davem@davemloft.net> <20080922.040912.193700258.davem@davemloft.net> <20080922203042.GY25711@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60299 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494AbYIVWVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 18:21:53 -0400
In-Reply-To: <20080922203042.GY25711@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> On Mon, Sep 22, 2008 at 04:09:12AM -0700, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Mon, 22 Sep 2008 03:49:33 -0700 (PDT)
>>
>>> I'll try to figure out why Andi's patch doesn't behave as expected.
>> Andi's patch uses proc_dointvec_jiffies, which is for sysctl values
>> stored as seconds, whereas these things are used to record values with
>> smaller granulatiry, are stored in jiffies, and that's why we get zero
>> on read and writes have crazy effects.
> 
> Oops. Assume me with brown paper bag etc.etc.
> 
> It was a typo for proc_dointvec_ms_jiffies
> 
> 
>> Also, as Andi stated, this is not the way to deal with this problem.
>>
>> So we have a broken patch, which even if implemented properly isn't the
>> way forward, so I consider this discussion dead in the water until we
>> have some test cases.

It's proven a little harder than anticipated to create a trivial test case, but 
I should be able to post some traces from a freely-available app soon.

> The patch is easy to fix with a s/_jiffies/_ms_jiffies/g

Thanks, will try.

> Also it was more intended for him to play around and get some data
> points. I guess for that it's still useful.

Indeed.  Setting tcp_delack_min to 0 completely eliminated the undesired 
latencies, though of course that would be a bit dangerous with naive apps 
talking across the network.  Changing tcp_ato_min didn't do anything interesting 
for this case.

> Also while for that it's probably not the right solution, but 
> I could imagine in some other situations where it might be useful
> to tune these values. After all they are not written down in stone.

The problem is that we're trying to use one set of values for links with 
extremely different performance characteristics.  We need to initialize TCP 
sockets with min/default/max values that are safe and perform well.

How horrendous of a layering violation would it be to attach TCP performance 
parameters (either user-supplied or based on interface stats) to route table 
entries, like route metrics but intended to guide TCP autotuning?  It seems like 
it shouldn't be that hard to teach TCP that it doesn't need to optimize my lo 
connections much, and that it should be optimizing my eth0 subnet connections 
for lower latency and higher bandwidth than the connections that go through my 
gateway into the great beyond.

> I wonder if it would even make sense to consider hr timers for TCP
> now.
> 
> =Andi

As long as we have hardcoded minimum delays > 10ms, I don't think there's much 
of a point, but it's something to keep in mind for the future.

-- Chris
