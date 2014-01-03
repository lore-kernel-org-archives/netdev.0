From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] ipv4: move rt_genid to different cache line
Date: Fri, 3 Jan 2014 10:01:47 -0800
Message-ID: <CA+mtBx_HKz3BNF=_FRTS-a-JZj9ss5TWaJU9d=oFewZbCu1_NQ@mail.gmail.com>
References: <alpine.DEB.2.02.1401021155330.32674@tomh.mtv.corp.google.com>
	<1388709534.12212.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36100 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaACSBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 13:01:48 -0500
Received: by mail-ig0-f181.google.com with SMTP id k19so1663855igc.2
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 10:01:47 -0800 (PST)
In-Reply-To: <1388709534.12212.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 4:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-01-02 at 12:00 -0800, Tom Herbert wrote:
>> Running a simple netperf TCP_RR test with 200 clients shows that
>> ipv4_dst_check is high on the list of functions in 'perf top'. The
>> pertinent action in this function is in the call to rt_is_expired
>> which checks the route genid (rt->rt_gentid) against the global value.
>> rt_genid is in the same cacheline as dst->__refcnt which is causing
>> false sharing.
>>
>> This fix moves rt_genid into the first cacheline of the dst structure.
>> The dst structue is explicitly packed for cacheline optimization, so to
>> make room for the genid, I moved xfrm to cacheline with __refcnt (under
>> the assumption it is less likely to be in the critical path).
>
> This looks like a difficult to check assumption to me ....
>
> rcu_head surely could be moved without performance impact.
>
Yes, I had thought about that. It's two pointers so this will generate
a extra hole, probably not worth moving it for 64 bit pointer case I
suppose. I can try a patch for that.

> Again, optimizing network stack for 200 TCP_RR special case is very
> questionable. The dst must be refcounted because of special prequeue
> mode, where a thread is blocked in a recvmsg() call.
>
If you can suggest an alternate test we should be running that
reflects the "real world", I can run that.

> Any modern application handling lot of sockets uses poll()/epoll()
> anyway and prequeue is disabled : No refcount is taken, as the dst is
> released (no refcount touch because of RCU) before the skb is queued
> into socket receive queue.
>
Notwithstanding that we can't feasibly audit a million applications to
verify that they follow the "correct" design, it is still common to
dispatch individual sockets to worker threads which will do blocking
reads for long lived requests.

It seems to me you have more of an issue with prequeue itself. Maybe
it is worth considering removing it to eliminate the disparate
behavior between read and poll+read, but then removing a long lived
optimization has is own pitfalls.

>
>
