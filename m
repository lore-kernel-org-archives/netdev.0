From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 11/16] ipv6: replace dst_hold() with
 dst_hold_safe() in routing code
Date: Sat, 07 Oct 2017 03:23:44 +0100 (WEST)
Message-ID: <20171007.032344.1464599410029867578.davem@davemloft.net>
References: <20171006190611.110633-11-tracywwnj@gmail.com>
        <20171006190611.110633-12-tracywwnj@gmail.com>
        <CAPA1RqB14m4BERjrOO5Fryu2WAU9iwqAbC8H7Sb_bNUi9jfLAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: weiwan@google.com, netdev@vger.kernel.org, edumazet@google.com,
        kafai@fb.com, yoshfuji@linux-ipv6.org
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52310 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752155AbdJGCXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 22:23:45 -0400
In-Reply-To: <CAPA1RqB14m4BERjrOO5Fryu2WAU9iwqAbC8H7Sb_bNUi9jfLAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: 吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
Date: Sat, 7 Oct 2017 08:57:49 +0900

> Hi,
> 
> 2017-10-07 4:06 GMT+09:00 Wei Wang <weiwan@google.com>:
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 941c062389d2..aeb349aea429 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
> :
>> @@ -1625,12 +1643,17 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
>>         if (rt_cache)
>>                 rt = rt_cache;
>>
>> -       if (rt == net->ipv6.ip6_null_entry || (rt->rt6i_flags & RTF_CACHE)) {
>> -               dst_use(&rt->dst, jiffies);
>> +       if (rt == net->ipv6.ip6_null_entry) {
>> +               read_unlock_bh(&table->tb6_lock);
>> +               dst_hold(&rt->dst);
>> +               trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
>> +               return rt;
>> +       } else if (rt->rt6i_flags & RTF_CACHE) {
>> +               if (ip6_hold_safe(net, &rt, true)) {
>> +                       dst_use_noref(&rt->dst, jiffies);
>> +                       rt6_dst_from_metrics_check(rt);
>> +               }
>>                 read_unlock_bh(&table->tb6_lock);
>> -
>> -               rt6_dst_from_metrics_check(rt);
>> -
>>                 trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
>>                 return rt;
>>         } else if (unlikely((fl6->flowi6_flags & FLOWI_FLAG_KNOWN_NH) &&
> 
> Is it intended to move rt6_dst_from_metrics_check() inside the table lock?

That lock is replaced with rcu_read_unlock() or similar in patch #15 so I
don't think it matters much in the end.
