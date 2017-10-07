From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/16] ipv6: replace rwlock with rcu and
 spinlock in fib6 table
Date: Sat, 07 Oct 2017 21:28:31 +0100 (WEST)
Message-ID: <20171007.212831.1578627314815022241.davem@davemloft.net>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
        <1507333795.14419.23.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAPA1RqBSKi9ra_UBur6L9HHExZzk9BxSrwSKn2xtvAC5K54N+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, weiwan@google.com, netdev@vger.kernel.org,
        edumazet@google.com, kafai@fb.com, yoshfuji@linux-ipv6.org
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752997AbdJGU2p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 16:28:45 -0400
In-Reply-To: <CAPA1RqBSKi9ra_UBur6L9HHExZzk9BxSrwSKn2xtvAC5K54N+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: 吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
Date: Sat, 7 Oct 2017 18:25:13 +0900

> Hi,
> 
> 2017-10-07 8:49 GMT+09:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> On Fri, 2017-10-06 at 12:05 -0700, Wei Wang wrote:
>>> From: Wei Wang <weiwan@google.com>
>>>
>>> Currently, fib6 table is protected by rwlock. During route lookup,
>>> reader lock is taken and during route insertion, deletion or
>>> modification, writer lock is taken. This is a very inefficient
>>> implementation because the fastpath always has to do the operation
>>> to grab the reader lock.
>>> According to my latest syn flood test on an iota ivybridage machine
>>> with 2 10G mlx nics bonded together, each with 8 rx queues on 2 NUMA
>>> nodes, and with the upstream net-next kernel:
>>> ipv4 stack can handle around 4.2Mpps
>>> ipv6 stack can handle around 1.3Mpps
>>>
>>> In order to close the gap of the performance number between ipv4
>>> and ipv6 stack, this patch series tries to get rid of the usage of
>>> the rwlock and replace it with rcu and spinlock protection. This will
>>> greatly speed up the fastpath performance as it only needs to hold
>>> rcu which is much less expensive than grabbing the reader lock. It
>>> also makes ipv6 fib implementation more consistent with ipv4.
 ...
>> Awesome work Wei.
>>
>> For the whole series :
>>
>> Reviewed-by: Eric Dumazet <edumazet@google.com>
> 
> It looks ok to me.
> Reviewed-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

I have some reservations about these changes, fib6_info gets bigger,
etc.

And even with the amazing developers that helped review and
audit these changes already, I can guarantee there are some
bugs in here just like there were bugs in the ipv4 routing
cache removal I did :-)

But those don't block integration, for sure.

So series applied, thanks a lot for doing this!

I think there is some code that doesn't use proper RCU accessors
for rt6i_exception_bucket.  For example there are some assignments
of it to NULL that should use RCU_ASSIGN_FOO() or similar.  Please
take a lok and fix those up.

Thanks!
