From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 3/4] ipv6: use net->rt_genid to check dst
 validity
Date: Mon, 10 Sep 2012 16:34:44 +0200
Message-ID: <504DFA84.40409@6wind.com>
References: <20120907.144828.97793990734588625.davem@davemloft.net> <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com> <1347283338-4249-4-git-send-email-nicolas.dichtel@6wind.com> <504DF950.4010401@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36727 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935Ab2IJOey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 10:34:54 -0400
Received: by eekc1 with SMTP id c1so1200892eek.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 07:34:53 -0700 (PDT)
In-Reply-To: <504DF950.4010401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/09/2012 16:29, Vlad Yasevich a =E9crit :
> On 09/10/2012 09:22 AM, Nicolas Dichtel wrote:
>> IPv6 dst should take care of rt_genid too. When a xfrm policy is ins=
erted or
>> deleted, all dst should be invalidated.
>> To force the validation, dst entries should be created with ->obsole=
te set to
>> DST_OBSOLETE_FORCE_CHK. This was already the case for all functions =
calling
>> ip6_dst_alloc(), except for ip6_rt_copy().
>>
>> As a consequence, we can remove the specific code in inet6_connectio=
n_sock.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   include/net/ip6_fib.h            |  2 +-
>>   net/ipv6/inet6_connection_sock.c | 23 +----------------------
>>   net/ipv6/route.c                 | 17 +++++++++++++----
>>   3 files changed, 15 insertions(+), 27 deletions(-)
>>
>> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
>> index cd64cf3..5eb93f4 100644
>> --- a/include/net/ip6_fib.h
>> +++ b/include/net/ip6_fib.h
>> @@ -113,7 +113,7 @@ struct rt6_info {
>>       unsigned long            _rt6i_peer;
>>
>>   #ifdef CONFIG_XFRM
>> -    u32                rt6i_flow_cache_genid;
>> +    u32                rt6i_genid;
>>   #endif
>>       /* more non-fragment space at head required */
>>       unsigned short            rt6i_nfheader_len;
>> diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_conne=
ction_sock.c
>> index 0251a60..c4f9341 100644
>> --- a/net/ipv6/inet6_connection_sock.c
>> +++ b/net/ipv6/inet6_connection_sock.c
>> @@ -175,33 +175,12 @@ void __inet6_csk_dst_store(struct sock *sk, st=
ruct
>> dst_entry *dst,
>>                  const struct in6_addr *saddr)
>>   {
>>       __ip6_dst_store(sk, dst, daddr, saddr);
>> -
>> -#ifdef CONFIG_XFRM
>> -    {
>> -        struct rt6_info *rt =3D (struct rt6_info  *)dst;
>> -        rt->rt6i_flow_cache_genid =3D atomic_read(&flow_cache_genid=
);
>> -    }
>> -#endif
>>   }
>>
>>   static inline
>>   struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cooki=
e)
>>   {
>> -    struct dst_entry *dst;
>> -
>> -    dst =3D __sk_dst_check(sk, cookie);
>> -
>> -#ifdef CONFIG_XFRM
>> -    if (dst) {
>> -        struct rt6_info *rt =3D (struct rt6_info *)dst;
>> -        if (rt->rt6i_flow_cache_genid !=3D atomic_read(&flow_cache_=
genid)) {
>> -            __sk_dst_reset(sk);
>> -            dst =3D NULL;
>> -        }
>> -    }
>> -#endif
>> -
>> -    return dst;
>> +    return __sk_dst_check(sk, cookie);
>>   }
>>
>>   static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 339d921..db7b78f 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -281,13 +281,16 @@ static inline struct rt6_info *ip6_dst_alloc(s=
truct net
>> *net,
>>                            struct fib6_table *table)
>>   {
>>       struct rt6_info *rt =3D dst_alloc(&net->ipv6.ip6_dst_ops, dev,
>> -                    0, DST_OBSOLETE_NONE, flags);
>> +                    0, DST_OBSOLETE_FORCE_CHK, flags);
>>
>>       if (rt) {
>>           struct dst_entry *dst =3D &rt->dst;
>>
>>           memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
>>           rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.pe=
ers);
>> +#ifdef CONFIG_XFRM
>> +        rt->rt6i_genid =3D rt_genid(net);
>> +#endif
>
> This isn't XFRM dependent any more, is it?
Not dependent, but for IPv6, it's only usefull when xfrm is set. Goal o=
f this=20
ifdef was to avoid the test if xfrm is not used.
