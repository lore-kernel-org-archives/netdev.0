From: Tom Herbert <tom@herbertland.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Tue, 13 Dec 2016 12:51:29 -0800
Message-ID: <CALx6S34S82kFVqYW1M0ZuHx_Mxut4QaLFVerLX4aEsksrFirXg@mail.gmail.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
 <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
 <1481233016.11849.1@smtp.office365.com> <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
 <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com> <1481335192.3663.0@smtp.office365.com>
 <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481343298.4930.208.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481565929.24490.0@smtp.office365.com> <3c022731-e703-34ac-55f1-60f5b94b6d62@stressinduktion.org>
 <1481581466.24490.2@smtp.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:36110 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941010AbcLMUvb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 15:51:31 -0500
Received: by mail-qt0-f177.google.com with SMTP id w33so119010385qtc.3
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 12:51:30 -0800 (PST)
In-Reply-To: <1481581466.24490.2@smtp.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think there may be some suspicious code in inet_csk_get_port. At
tb_found there is:

                if (((tb->fastreuse > 0 && reuse) ||
                     (tb->fastreuseport > 0 &&
                      !rcu_access_pointer(sk->sk_reuseport_cb) &&
                      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
                    smallest_size == -1)
                        goto success;
                if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
                        if ((reuse ||
                             (tb->fastreuseport > 0 &&
                              sk->sk_reuseport &&
                              !rcu_access_pointer(sk->sk_reuseport_cb) &&
                              uid_eq(tb->fastuid, uid))) &&
                            smallest_size != -1 && --attempts >= 0) {
                                spin_unlock_bh(&head->lock);
                                goto again;
                        }
                        goto fail_unlock;
                }

AFAICT there is redundancy in these two conditionals.  The same clause
is being checked in both: (tb->fastreuseport > 0 &&
!rcu_access_pointer(sk->sk_reuseport_cb) && sk->sk_reuseport &&
uid_eq(tb->fastuid, uid))) && smallest_size == -1. If this is true the
first conditional should be hit, goto done,  and the second will never
evaluate that part to true-- unless the sk is changed (do we need
READ_ONCE for sk->sk_reuseport_cb?).

Another potential issue is the that the goto again goes back to doing
the port scan, but if snum had been set originally that doesn't seem
like what we want.

Thanks,
Tom




On Mon, Dec 12, 2016 at 2:24 PM, Josef Bacik <jbacik@fb.com> wrote:
>
> On Mon, Dec 12, 2016 at 1:44 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>>
>> On 12.12.2016 19:05, Josef Bacik wrote:
>>>
>>>  On Fri, Dec 9, 2016 at 11:14 PM, Eric Dumazet <eric.dumazet@gmail.com>
>>>  wrote:
>>>>
>>>>  On Fri, 2016-12-09 at 19:47 -0800, Eric Dumazet wrote:
>>>>
>>>>>
>>>>>   Hmm... Is your ephemeral port range includes the port your load
>>>>>   balancing app is using ?
>>>>
>>>>
>>>>  I suspect that you might have processes doing bind( port = 0) that are
>>>>  trapped into the bind_conflict() scan ?
>>>>
>>>>  With 100,000 + timewaits there, this possibly hurts.
>>>>
>>>>  Can you try the following loop breaker ?
>>>
>>>
>>>  It doesn't appear that the app is doing bind(port = 0) during normal
>>>  operation.  I tested this patch and it made no difference.  I'm going to
>>>  test simply restarting the app without changing to the SO_REUSEPORT
>>>  option.  Thanks,
>>
>>
>> Would it be possible to trace the time the function uses with trace? If
>> we don't see the number growing considerably over time we probably can
>> rule out that we loop somewhere in there (I would instrument
>> inet_csk_bind_conflict, __inet_hash_connect and inet_csk_get_port).
>>
>> __inet_hash_connect -> __inet_check_established also takes a lock
>> (inet_ehash_lockp) which can be locked from inet_diag code path during
>> socket diag info dumping.
>>
>> Unfortunately we couldn't reproduce it so far. :/
>
>
> So I had a bcc script running to time how long we spent in
> inet_csk_bind_conflict, __inet_hash_connect and inet_csk_get_port, but of
> course I'm an idiot and didn't actually separate out the stats so I could
> tell _which_ one was taking forever.  But anyway here's a normal
> distribution on the box
>
>     Some shit           : count     distribution
>         0 -> 1          : 0        |                                       |
>         2 -> 3          : 0        |                                       |
>         4 -> 7          : 0        |                                       |
>         8 -> 15         : 0        |                                       |
>        16 -> 31         : 0        |                                       |
>        32 -> 63         : 0        |                                       |
>        64 -> 127        : 0        |                                       |
>       128 -> 255        : 0        |                                       |
>       256 -> 511        : 0        |                                       |
>       512 -> 1023       : 0        |                                       |
>      1024 -> 2047       : 74       |                                       |
>      2048 -> 4095       : 10537
> |****************************************|
>      4096 -> 8191       : 8497     |********************************       |
>      8192 -> 16383      : 3745     |**************                         |
>     16384 -> 32767      : 300      |*                                      |
>     32768 -> 65535      : 250      |                                       |
>     65536 -> 131071     : 180      |                                       |
>    131072 -> 262143     : 71       |                                       |
>    262144 -> 524287     : 18       |                                       |
>    524288 -> 1048575    : 5        |                                       |
>
> With the times in nanoseconds, and here's the distribution during the
> problem
>
>     Some shit           : count     distribution
>         0 -> 1          : 0        |                                       |
>         2 -> 3          : 0        |                                       |
>         4 -> 7          : 0        |                                       |
>         8 -> 15         : 0        |                                       |
>        16 -> 31         : 0        |                                       |
>        32 -> 63         : 0        |                                       |
>        64 -> 127        : 0        |                                       |
>       128 -> 255        : 0        |                                       |
>       256 -> 511        : 0        |                                       |
>       512 -> 1023       : 0        |                                       |
>      1024 -> 2047       : 21       |                                       |
>      2048 -> 4095       : 21820
> |****************************************|
>      4096 -> 8191       : 11598    |*********************                  |
>      8192 -> 16383      : 4337     |*******                                |
>     16384 -> 32767      : 290      |                                       |
>     32768 -> 65535      : 59       |                                       |
>     65536 -> 131071     : 23       |                                       |
>    131072 -> 262143     : 12       |                                       |
>    262144 -> 524287     : 6        |                                       |
>    524288 -> 1048575    : 19       |                                       |
>   1048576 -> 2097151    : 1079     |*                                      |
>   2097152 -> 4194303    : 0        |                                       |
>   4194304 -> 8388607    : 1        |                                       |
>   8388608 -> 16777215   : 0        |                                       |
>  16777216 -> 33554431   : 0        |                                       |
>  33554432 -> 67108863   : 1192     |**                                     |
>               Some shit                     : count     distribution
>                   0 -> 1                    : 0        |                   |
>                   2 -> 3                    : 0        |                   |
>                   4 -> 7                    : 0        |                   |
>                   8 -> 15                   : 0        |                   |
>                  16 -> 31                   : 0        |                   |
>                  32 -> 63                   : 0        |                   |
>                  64 -> 127                  : 0        |                   |
>                 128 -> 255                  : 0        |                   |
>                 256 -> 511                  : 0        |                   |
>                 512 -> 1023                 : 0        |                   |
>                1024 -> 2047                 : 48       |                   |
>                2048 -> 4095                 : 14714
> |********************|
>                4096 -> 8191                 : 6769     |*********          |
>                8192 -> 16383                : 2234     |***                |
>               16384 -> 32767                : 422      |                   |
>               32768 -> 65535                : 208      |                   |
>               65536 -> 131071               : 61       |                   |
>              131072 -> 262143               : 10       |                   |
>              262144 -> 524287               : 416      |                   |
>              524288 -> 1048575              : 826      |*                  |
>             1048576 -> 2097151              : 598      |                   |
>             2097152 -> 4194303              : 10       |                   |
>             4194304 -> 8388607              : 0        |                   |
>             8388608 -> 16777215             : 1        |                   |
>            16777216 -> 33554431             : 289      |                   |
>            33554432 -> 67108863             : 921      |*                  |
>            67108864 -> 134217727            : 74       |                   |
>           134217728 -> 268435455            : 75       |                   |
>           268435456 -> 536870911            : 48       |                   |
>           536870912 -> 1073741823           : 25       |                   |
>          1073741824 -> 2147483647           : 3        |                   |
>          2147483648 -> 4294967295           : 2        |                   |
>          4294967296 -> 8589934591           : 1        |                   |
>
> As you can see we start getting tail latencies of up to 4-8 seconds.
> Tomorrow I'll separate out the stats so we can know which function is the
> problem child.  Sorry about not doing that first.  Thanks,
>
> Josef
>
