From: Ben Greear <greearb@candelatech.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Tue, 13 Jun 2017 13:39:59 -0700
Message-ID: <f46ac4a5-3b07-c1b3-372c-0acc6acd1798@candelatech.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
 <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
 <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com>
 <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
 <CAM_iQpXM3G=J0tw=n1_mKno=i41Kmoxb00+nDyBWofWskj5P_A@mail.gmail.com>
 <7e0c97fa-cd6e-ed0f-bf99-0e4af40fbd2f@gmail.com>
 <1497043557.736.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <9cb61ef0-37c0-8f35-bb5c-e3d8e63cbe2f@candelatech.com>
 <42400e72-d93d-4c2b-7864-efd40e0bd981@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:37406 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752109AbdFMUkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 16:40:01 -0400
In-Reply-To: <42400e72-d93d-4c2b-7864-efd40e0bd981@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2017 01:28 PM, David Ahern wrote:
> On 6/13/17 2:16 PM, Ben Greear wrote:
>> On 06/09/2017 02:25 PM, Eric Dumazet wrote:
>>> On Fri, 2017-06-09 at 07:27 -0600, David Ahern wrote:
>>>> On 6/8/17 11:55 PM, Cong Wang wrote:
>>>>> On Thu, Jun 8, 2017 at 2:27 PM, Ben Greear <greearb@candelatech.com>
>>>>> wrote:
>>>>>>
>>>>>> As far as I can tell, the patch did not help, or at least we still
>>>>>> reproduce
>>>>>> the
>>>>>> crash easily.
>>>>>
>>>>> netlink dump is serialized by nlk->cb_mutex so I don't think that
>>>>> patch makes any sense w.r.t race condition.
>>>>
>>>> From what I can see fn_sernum should be accessed under table lock, so
>>>> when saving and checking it during a walk make sure it the lock is held.
>>>> That has nothing to do with the netlink dump, but the table changing
>>>> during a walk.
>>>
>>>
>>> Yes, your patch makes total sense, of course.
>>
>> I guess someone should go ahead and make an official patch and
>> submit it, even if it doesn't fix my problem.
>
> I can do that; was hoping to root cause the problem first.
>
>
>>
>>>>>> (gdb) l *(fib6_walk_continue+0x76)
>>>>>> 0x188c6 is in fib6_walk_continue
>>>>>> (/home/greearb/git/linux-2.6/net/ipv6/ip6_fib.c:1593).
>>>>>> 1588                            if (fn == w->root)
>>>>>> 1589                                    return 0;
>>>>>> 1590                            pn = fn->parent;
>>>>>> 1591                            w->node = pn;
>>>>>> 1592    #ifdef CONFIG_IPV6_SUBTREES
>>>>>> 1593                            if (FIB6_SUBTREE(pn) == fn) {
>>>>>
>>>>> Apparently fn->parent is NULL here for some reason, but
>>>>> I don't know if that is expected or not. If a simple NULL check
>>>>> is not enough here, we have to trace why it is NULL.
>>>>
>>>> From my understanding, parent should not be null hence the attempts to
>>>> fix access to table nodes under a lock. ie., figuring out why it is null
>>>> here.
>>
>> If someone has more suggestions, I'll be happy to test.
>
> I have looked at the code again and nothing is jumping out. Will look
> again later today.
>

I noticed there is some code to help fix up the walkers when nodes are deleted.  They
use lock:  	read_lock(&net->ipv6.fib6_walker_lock);

The code you were tweaking uses a different lock:  read_lock_bh(&table->tb6_lock);

In is certainly not simple code, so I don't know if that is correct or not, but
might possibly be a place to start looking.

I'm going to re-test with a WARN_ON to see if that triggers since previous suggestion
was that f->parent was NULL.


diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 51cd637..86295df 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1571,6 +1571,10 @@ static int fib6_walk_continue(struct fib6_walker *w)
                 case FWS_U:
                         if (fn == w->root)
                                 return 0;
+                       if (!fn->parent) {
+                               WARN_ON_ONCE(0);
+                               return 0;
+                       }
                         pn = fn->parent;
                         w->node = pn;
  #ifdef CONFIG_IPV6_SUBTREES


Thanks,
Ben

Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
