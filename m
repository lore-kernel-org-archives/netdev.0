From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH v2 net] soreuseport: Fix TCP listener hash collision
Date: Thu, 28 Apr 2016 18:03:16 -0400
Message-ID: <CAEfhGizHHvQROD0-b3jPM3-7X1KEz2nJaXVf4U8Fh0A3h1Eddg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33991 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbcD1WDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 18:03:20 -0400
Received: by mail-lf0-f68.google.com with SMTP id m101so15558578lfi.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 15:03:19 -0700 (PDT)
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com. [209.85.215.53])
        by smtp.gmail.com with ESMTPSA id q137sm1664374lfq.24.2016.04.28.15.03.16
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 15:03:17 -0700 (PDT)
Received: by mail-lf0-f53.google.com with SMTP id u64so99410790lff.3
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 15:03:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 5:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-04-28 at 17:07 -0400, Craig Gallek wrote:
>> From: Craig Gallek <kraig@google.com>
>>
>> I forgot to include a check for listener port equality when deciding
>> if two sockets should belong to the same reuseport group.  This was
>> not caught previously because it's only necessary when two listening
>> sockets for the same user happen to hash to the same listener bucket.
>> This change also includes a check for network namespace equality.
>> The same error does not exist in the UDP path.
>>
>> Fixes: c125e80b8868("soreuseport: fast reuseport TCP socket selection")
>> Signed-off-by: Craig Gallek <kraig@google.com>
>> ---
>> v2 Changes
>>   - Suggestions from Eric Dumazet to include network namespace equality
>>     check and to avoid a dreference by simply checking inet_bind_bucket
>>     pointer equality.
>> ---
>>  net/ipv4/inet_hashtables.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
>> index bc68eced0105..5c5658268d5e 100644
>> --- a/net/ipv4/inet_hashtables.c
>> +++ b/net/ipv4/inet_hashtables.c
>> @@ -470,15 +470,19 @@ static int inet_reuseport_add_sock(struct sock *sk,
>>                                                    const struct sock *sk2,
>>                                                    bool match_wildcard))
>>  {
>> +     struct inet_bind_bucket *tb = inet_csk(sk)->icsk_bind_hash;
>> +     struct net *net = sock_net(sk);
>>       struct sock *sk2;
>>       struct hlist_nulls_node *node;
>>       kuid_t uid = sock_i_uid(sk);
>>
>>       sk_nulls_for_each_rcu(sk2, node, &ilb->head) {
>> -             if (sk2 != sk &&
>> +             if (net_eq(sock_net(sk2), net) &&
>> +                 sk2 != sk &&
>>                   sk2->sk_family == sk->sk_family &&
>>                   ipv6_only_sock(sk2) == ipv6_only_sock(sk) &&
>>                   sk2->sk_bound_dev_if == sk->sk_bound_dev_if &&
>> +                 inet_csk(sk2)->icsk_bind_hash == tb &&
>>                   sk2->sk_reuseport && uid_eq(uid, sock_i_uid(sk2)) &&
>>                   saddr_same(sk, sk2, false))
>>                       return reuseport_add_sock(sk, sk2);
>
> Note that I suggested to only use "inet_csk(sk2)->icsk_bind_hash == tb"
>
> If test is true, it means that sockets share same name space and same
> port ;)
>
> Therefore the added net_eq(sock_net(sk2), net) test is redundant.
Thanks for the quick review Eric, sorry I miss read :\  I'll send a v3...

> No strong opinion, as this patch works, and this is not fast path
> anyway.
>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
>
