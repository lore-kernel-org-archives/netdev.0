From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: avoid possible arithmetic overflows
Date: Sat, 20 Sep 2014 12:46:38 -0700
Message-ID: <CAK6E8=etvB4MUBu96ck+7yucbFLgbxvEPJ3TM8X5qBsZLTnhDg@mail.gmail.com>
References: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com> <1411236071.8612.6.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:59237 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757885AbaITTrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 15:47:19 -0400
Received: by mail-ig0-f180.google.com with SMTP id a13so818883igq.13
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 12:47:18 -0700 (PDT)
In-Reply-To: <1411236071.8612.6.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 20, 2014 at 11:01 AM, Joe Perches <joe@perches.com> wrote:
> On Sat, 2014-09-20 at 10:19 -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> icsk_rto is an 32bit field, and icsk_backoff can reach 15 by default,
>> or more if some sysctl (eg tcp_retries2) are changed.
>>
>> Better use 64bit to perform icsk_rto << icsk_backoff operations
>
> Maybe better to use a helper function for this?
>
> something like:
>
> static inline u64 icsk_rto_backoff(const struct inet_connection_sock *icsk)
> {
>         u64 when = (u64)icsk->icsk_rto;
>
>         return when << icsk->icsk_backoff;
> }
Thanks for the fix Eric. I second Joe's idea to use a helper function.

>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> []
>> @@ -3208,9 +3208,12 @@ static void tcp_ack_probe(struct sock *sk)
>>                * This function is not for random using!
>>                */
>>       } else {
>> +             unsigned long when;
>> +
>> +             when = min((u64)icsk->icsk_rto << icsk->icsk_backoff,
>> +                        (u64)TCP_RTO_MAX);
>
> Maybe:
>         u32 when = (u32)min_t(u64, icsk_rto_backoff(icsk), TCP_RTO_MAX);
>
>
