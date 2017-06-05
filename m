From: Florian Weimer <fweimer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: reduce cycles spend on ICMP replies
 that gets rate limited
Date: Mon, 5 Jun 2017 16:22:34 +0200
Message-ID: <1b871feb-8e4c-5fdb-f129-3984a2e5d7fd@redhat.com>
References: <20170109150246.30215.63371.stgit@firesoul>
 <20170109150409.30215.34612.stgit@firesoul>
 <7d432179-5e3a-febe-ced7-39ea33ba4906@redhat.com>
 <20170604163812.602cc089@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        xiyou.wangcong@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59874 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751112AbdFEOWl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 10:22:41 -0400
In-Reply-To: <20170604163812.602cc089@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2017 04:38 PM, Jesper Dangaard Brouer wrote:
> On Sun, 4 Jun 2017 09:11:53 +0200
> Florian Weimer <fweimer@redhat.com> wrote:
> 
>> On 01/09/2017 04:04 PM, Jesper Dangaard Brouer wrote:
>>
>>> This patch split the global and per (inet)peer ICMP-reply limiter
>>> code, and moves the global limit check to earlier in the packet
>>> processing path.  Thus, avoid spending cycles on ICMP replies that
>>> gets limited/suppressed anyhow.
>>>
>>> The global ICMP rate limiter icmp_global_allow() is a good solution,
>>> it just happens too late in the process.  The kernel goes through the
>>> full route lookup (return path) for the ICMP message, before taking
>>> the rate limit decision of not sending the ICMP reply.
>>>
>>> Details: The kernels global rate limiter for ICMP messages got added
>>> in commit 4cdf507d5452 ("icmp: add a global rate limitation").  It is
>>> a token bucket limiter with a global lock.  It brilliantly avoids
>>> locking congestion by only updating when 20ms (HZ/50) were elapsed. It
>>> can then avoids taking lock when credit is exhausted (when under
>>> pressure) and time constraint for refill is not yet meet.  
>>
>> This patch removed the rate limit bypass for localhost.  As a result, it
>> is impossible to write deterministic UDP client tests tests which
>> exercise failover behavior in response to unreachable servers.
> 
> You cannot rely on ICMP responses delivery, too many systems (and
> middleboxes) limit or drop ICMP. Before this patch, loopback dev was
> explicitly excluded from being ICMP rate limited.  Thus, your localhost
> test passed.

Yes, I know that.  But there's a difference between failing a UDP query
immediately and waiting for the timeout to happen.  ICMP responses are
really helpful for that, even though they cannot be relied upon.

> Is there a real use-case behind "failover behavior in response to
> unreachable servers" (which would need to run on localhost)?

It's also relevant during boot when local UDP services are not running.
There, waiting for the timeout can delay the boot process.

It used to be relevant for switching to backup UDP-based servers (such
as name servers), but it seems the Linux kernel has not generated ICMP
messages at a sufficient rate to facilitate that long before the recent
changes.  And of course, it only covers a subset of the failure
scenarios (and arguably only a small subset of them).

In any case, we need a working way to test clients which have ICMP-based
failure detection, and we can't do that if the kernel sends them only
once in a while.

> Adding back outgoing-dev loopback test will require a full
> route-lookup, which is what the hole optimization gain[1] comes from.
> [1] https://git.kernel.org/torvalds/c/9f2f27a9a518
> 
> I've tried to come-up with an alternative solution, see inlined patch
> below...

Looking at the incoming interface doesn't seem unreasonable here.

Thanks,
Florian
