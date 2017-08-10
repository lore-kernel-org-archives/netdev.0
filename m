From: Joe Smith <codesoldier1@gmail.com>
Subject: Re: [PATCH v1 net] TCP_USER_TIMEOUT and tcp_keepalive should conform
 to RFC5482
Date: Wed, 9 Aug 2017 17:20:32 -0700
Message-ID: <CABGNeczGSsL6xj-SkXQYTWXXe+mJoyhvrQxuLkiO27pW0y8MtA@mail.gmail.com>
References: <20170807181614.GA16700@caduceus5> <CAK6E8=ehu5uK6bsprzAQc-Nu6WS2YQEcktD0H2RrjgPpS47-Yg@mail.gmail.com>
 <CAPshTCgaYVPEbZxDr9sUz7OFibweQn6fwRtP66cgw5eNrHUOWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Yuchung Cheng <ycheng@google.com>,
        Rao Shoaib <rao.shoaib@oracle.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        netdev <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33363 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdHJAUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:20:33 -0400
Received: by mail-it0-f65.google.com with SMTP id m34so749707iti.0
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 17:20:33 -0700 (PDT)
In-Reply-To: <CAPshTCgaYVPEbZxDr9sUz7OFibweQn6fwRtP66cgw5eNrHUOWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 9, 2017 at 4:52 PM, Jerry Chu <hkchu@google.com> wrote:
> [try to recover from long lost memory]
>
> On Tue, Aug 8, 2017 at 10:25 AM, Yuchung Cheng <ycheng@google.com> wrote:
>> On Mon, Aug 7, 2017 at 11:16 AM, Rao Shoaib <rao.shoaib@oracle.com> wrote:
>>> Change from version 0: Rationale behind the change:
>>>
>>> The man page for tcp(7) states
>>>
>>> when used with the TCP keepalive (SO_KEEPALIVE) option, TCP_USER_TIMEOUT will
>>> override keepalive to  determine  when to close a connection due to keepalive
>>> failure.
>>>
>>> This is ambigious at best. user expectation is most likely that the connection
>>> will be reset after TCP_USER_TIMEOUT milliseconds of inactivity.
>> ccing the original author Jerry Chu who can tell more.
>>
>
> There was a reason for the above otherwise I wouldn't have explicitly
> spelled it out in
> my commit msg. But unfortunately it was seven years ago and I can't
> remember why.
> It could range from micro-optimization (saving a syscall() because
> this facility was
> used by servers handling millions of Android clients) to something more critical
> but I can't remember.

The issue is that the man page is ambiguous and does not conform to
any standard.
Whether  RFC 5482 is in little use or not that was cited as the basis
of this change and
I want to change the behavior to conform to it as users are confused.

I doubt that saving a syscall is of any benefit when the connection
has been idle for 2hrs. If anything the user expects the keep alive
probes to start after TCP_USER_TIMEOUT of inactivity. In which case
keep alive should be adjusted.

>
>>>
>>> The code however waits for the keepalive to kick-in (default 2hrs) and than
>>> after one failure resets the conenction.
>>>
>>> What is the rationale for that ? The same effect can be obtained by simply
>>> changing the value of tcp_keep_alive_probes.
>>>
>>> Since the TCP_USER_TIMEOUT option was added based on RFC 5482 we need to follow
>>> the RFC. Which states
>
> Well the patch has little to do with RFC5482 other than borrowing the name, and
> also conveniently providing a mechanism for RFC5482 apps to program the local
> timeout value. As far as I knew back when I worked on the patch, RFC5482 was
> under little use (told directly by Lars).
>
> Your proposed change may not be unreasonable but my fear is it may
> cause breakage
> on apps that depend on "TCP_USER_TIMEOUT will overtake keepalive to determine
> when to close a connection due to keepalive failure". What is your
> case for "RFC5482
> compliance" after all? I know the TCP_USER_TIMEOUT option has been very popular
> among apps since its inception.

The only use of TCP_USER_TIMEOUT has been for flushing unacknowledged
data (evident from all the fixes). That behavior is not being touched.

Making Linux conform to standards and behavior that is logical seems
like a good enough reason. Mixing keep alive and TCP_USER_TIMEOUT does
not make any sense. I doubt very much if this change will break
anything but if it does than we need to see why that is needed and
implement a proper fix and document it.

Shoaib

>
>>>
>>> 4.2 TCP keep-Alives:
>>>    Some TCP implementations, such as those in BSD systems, use a
>>>    different abort policy for TCP keep-alives than for user data.  Thus,
>>>    the TCP keep-alive mechanism might abort a connection that would
>>>    otherwise have survived the transient period without connectivity.
>>>    Therefore, if a connection that enables keep-alives is also using the
>>>    TCP User Timeout Option, then the keep-alive timer MUST be set to a
>>>    value larger than that of the adopted USER TIMEOUT.
>>>
>>> This patch enforces the MUST and also dis-associates user timeout from keep
>>> alive.  A man page patch will be submitted separately.
>>>
>>> Signed-off-by: Rao Shoaib <rao.shoaib@oracle.com>
>>> ---
>>>  net/ipv4/tcp.c       | 10 ++++++++--
>>>  net/ipv4/tcp_timer.c |  9 +--------
>>>  2 files changed, 9 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>>> index 71ce33d..f2af44d 100644
>>> --- a/net/ipv4/tcp.c
>>> +++ b/net/ipv4/tcp.c
>>> @@ -2628,7 +2628,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>>>                 break;
>>>
>>>         case TCP_KEEPIDLE:
>>> -               if (val < 1 || val > MAX_TCP_KEEPIDLE)
>>> +               /* Per RFC5482 keepalive_time must be > user_timeout */
>>> +               if (val < 1 || val > MAX_TCP_KEEPIDLE ||
>>> +                   ((val * HZ) <= icsk->icsk_user_timeout))
>>>                         err = -EINVAL;
>>>                 else {
>>>                         tp->keepalive_time = val * HZ;
>>> @@ -2724,8 +2726,12 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>>>         case TCP_USER_TIMEOUT:
>>>                 /* Cap the max time in ms TCP will retry or probe the window
>>>                  * before giving up and aborting (ETIMEDOUT) a connection.
>>> +                * Per RFC5482 TCP user timeout must be < keepalive_time.
>>> +                * If the default value changes later -- all bets are off.
>>>                  */
>>> -               if (val < 0)
>>> +               if (val < 0 || (tp->keepalive_time &&
>>> +                               tp->keepalive_time <= msecs_to_jiffies(val)) ||
>>> +                  net->ipv4.sysctl_tcp_keepalive_time <= msecs_to_jiffies(val))
>>>                         err = -EINVAL;
>>>                 else
>>>                         icsk->icsk_user_timeout = msecs_to_jiffies(val);
>>> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>>> index c0feeee..d39fe60 100644
>>> --- a/net/ipv4/tcp_timer.c
>>> +++ b/net/ipv4/tcp_timer.c
>>> @@ -664,14 +664,7 @@ static void tcp_keepalive_timer (unsigned long data)
>>>         elapsed = keepalive_time_elapsed(tp);
>>>
>>>         if (elapsed >= keepalive_time_when(tp)) {
>>> -               /* If the TCP_USER_TIMEOUT option is enabled, use that
>>> -                * to determine when to timeout instead.
>>> -                */
>>> -               if ((icsk->icsk_user_timeout != 0 &&
>>> -                   elapsed >= icsk->icsk_user_timeout &&
>>> -                   icsk->icsk_probes_out > 0) ||
>>> -                   (icsk->icsk_user_timeout == 0 &&
>>> -                   icsk->icsk_probes_out >= keepalive_probes(tp))) {
>>> +               if (icsk->icsk_probes_out >= keepalive_probes(tp)) {
>>>                         tcp_send_active_reset(sk, GFP_ATOMIC);
>>>                         tcp_write_err(sk);
>>>                         goto out;
>>> --
>>> 2.7.4
>>>



-- 
JS
