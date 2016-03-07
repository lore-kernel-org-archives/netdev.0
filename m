From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Mon, 7 Mar 2016 09:19:31 -0800
Message-ID: <CANn89iJ6T-j2TWJEZ9VY+LHeH=Ei=MDKCU68v5zxdPS611ESjw@mail.gmail.com>
References: <1456946361-9889-1-git-send-email-tracywwnj@gmail.com>
	<20160306.005528.536271812454698509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37458 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbcCGRTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:19:33 -0500
Received: by mail-wm0-f43.google.com with SMTP id p65so78891661wmp.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 09:19:32 -0800 (PST)
In-Reply-To: <20160306.005528.536271812454698509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 5, 2016 at 9:55 PM, David Miller <davem@davemloft.net> wrote:
> From: Wei Wang <weiwan@google.com>
> Date: Wed,  2 Mar 2016 11:19:21 -0800
>
>> @@ -566,7 +567,16 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>>       if (type == ICMPV6_PKT_TOOBIG) {
>>               if (!ip6_sk_accept_pmtu(sk))
>>                       goto out;
>> -             ip6_sk_update_pmtu(skb, sk, info);
>> +             bh_lock_sock(sk);
>> +             if (sk->sk_state == TCP_ESTABLISHED &&
>> +                 !sock_owned_by_user(sk) &&
>> +                 ipv6_addr_equal(saddr, &sk->sk_v6_rcv_saddr) &&
>> +                 ipv6_addr_equal(daddr, &sk->sk_v6_daddr) &&
>> +                 uh->dest == sk->sk_dport)
>> +                     inet6_csk_update_pmtu(sk, ntohl(info));
>
> If I apply this patch it will hide a bug.
>
> Why isn't ip6_sk_update_pmtu() matching the same route as the
> one attached to the socket?
>
> I'd prefer you figure out what part of the lookup key used is
> wrong, and fix that instead.
>

The dst itself is the same than the socket sk_dst_cache, but
__ip6_rt_update_pmtu() sees rt6_cache_allowed_for_pmtu()

We endup doing :

                nrt6 = ip6_rt_cache_alloc(rt6, daddr, saddr);
                if (nrt6) {
                        rt6_do_update_pmtu(nrt6, mtu);

                        /* ip6_ins_rt(nrt6) will bump the
                         * rt6->rt6i_node->fn_sernum
                         * which will fail the next rt6_check() and
                         * invalidate the sk->sk_dst_cache.
                         */
                        ip6_ins_rt(nrt6);
                }


But apparently the sk->sk_dst_cache is _not_ invalidated, even if the
comment loudly claims so.
