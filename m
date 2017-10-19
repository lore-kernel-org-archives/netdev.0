From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 3/3] strparser: Generalize strparser
Date: Thu, 19 Oct 2017 13:18:20 -0700
Message-ID: <78776143-0442-f1ce-745c-8371f20124e4@gmail.com>
References: <20170728232243.3040-1-tom@quantonium.net>
 <20170728232243.3040-4-tom@quantonium.net>
 <1508434937.30291.1.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S3765-5oT6UtSQVts4KwWz3F3ub2vhDWO7YemYZPPM0EjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>
To: Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:47268 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751628AbdJSUSi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 16:18:38 -0400
Received: by mail-pf0-f193.google.com with SMTP id z11so7595665pfk.4
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 13:18:38 -0700 (PDT)
In-Reply-To: <CALx6S3765-5oT6UtSQVts4KwWz3F3ub2vhDWO7YemYZPPM0EjA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2017 12:51 PM, Tom Herbert wrote:
> On Thu, Oct 19, 2017 at 10:42 AM, Eric Dumazet <eric.dumazet@gmail.com>
> wrote:
> 
>> On Fri, 2017-07-28 at 16:22 -0700, Tom Herbert wrote:
>>> Generalize strparser from more than just being used in conjunction
>>> with read_sock. strparser will also be used in the send path with
>>> zero proxy. The primary change is to create strp_process function
>>> that performs the critical processing on skbs. The documentation
>>> is also updated to reflect the new uses.
>>>
>>> Signed-off-by: Tom Herbert <tom@quantonium.net>
>>> ---
>>>  Documentation/networking/strparser.txt | 207 +++++++++++++++-------
>>>  include/net/strparser.h                | 119 +++++++------
>>>  net/kcm/kcmproc.c                      |  34 ++--
>>>  net/kcm/kcmsock.c                      |  38 ++--
>>>  net/strparser/strparser.c              | 313
>> ++++++++++++++++++++-------------
>>>  5 files changed, 424 insertions(+), 287 deletions(-)
>>
>> Just found this gem :
>>
>> static void strp_msg_timeout(unsigned long arg)
>> {
>>         struct strparser *strp = (struct strparser *)arg;
>>
>>         /* Message assembly timed out */
>>         STRP_STATS_INCR(strp->stats.msg_timeouts);
>>         strp->cb.lock(strp);
>>         strp->cb.abort_parser(strp, ETIMEDOUT);
>>         strp->cb.unlock(strp);
>> }
>>
>> static void strp_sock_lock(struct strparser *strp)
>> {
>>         lock_sock(strp->sk);
>> }
>>
>> static void strp_sock_unlock(struct strparser *strp)
>> {
>>         release_sock(strp->sk);
>> }
>>
>>
>> A timer runs from BH, and from this interrupt context it is absolutely
>> illegal to call lock_sock() ( and release_sock() )
>>
>> Please fix, thanks !
>>
> 
> Nice catch! I'll fix it.
> 
Can the lock/release be removed and the strp stopped bit can use atomics?

It looks like sk_error_report can be called without sock lock.

Thanks,
John
