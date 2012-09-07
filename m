From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 1/2] dst: take into account policy update on check()
Date: Fri, 07 Sep 2012 16:47:06 +0200
Message-ID: <504A08EA.3080506@6wind.com>
References: <5049FAE3.2050403@6wind.com>  <1347033467-3757-1-git-send-email-nicolas.dichtel@6wind.com>  <1347033467-3757-2-git-send-email-nicolas.dichtel@6wind.com> <1347028510.2484.736.camel@edumazet-glaptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vyasevich@gmail.com, davem@davemloft.net, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43033 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290Ab2IGOrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 10:47:12 -0400
Received: by eekc1 with SMTP id c1so1217734eek.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 07:47:11 -0700 (PDT)
In-Reply-To: <1347028510.2484.736.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/09/2012 16:35, Eric Dumazet a =C3=A9crit :
> On Fri, 2012-09-07 at 17:57 +0200, Nicolas Dichtel wrote:
>> When a xfrm policy is inserted or deleted, we must invalidate
>> all dst and recalculate the route.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   include/net/dst.h     | 7 +++++++
>>   net/core/dst.c        | 1 +
>>   net/core/sock.c       | 4 ++--
>>   net/ipv6/ip6_tunnel.c | 3 +--
>>   4 files changed, 11 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/net/dst.h b/include/net/dst.h
>> index 9a78810..478e55a 100644
>> --- a/include/net/dst.h
>> +++ b/include/net/dst.h
>> @@ -101,6 +101,9 @@ struct dst_entry {
>>   	atomic_t		__refcnt;	/* client references	*/
>>   	int			__use;
>>   	unsigned long		lastuse;
>> +#ifdef CONFIG_XFRM
>> +	u32			flow_cache_genid;
>> +#endif
>>   	union {
>>   		struct dst_entry	*next;
>>   		struct rtable __rcu	*rt_next;
>> @@ -457,6 +460,10 @@ static inline int dst_input(struct sk_buff *skb=
)
>>
>>   static inline struct dst_entry *dst_check(struct dst_entry *dst, u=
32 cookie)
>>   {
>> +#ifdef CONFIG_XFRM
>> +	if (dst->flow_cache_genid !=3D atomic_read(&flow_cache_genid))
>> +		return NULL;
>> +#endif
>
> Hmm... cant we reuse rt_genid ?
>
> (When changing flow_cache_genid, change &net->ipv4.rt_genid)

And so adding a new field in net->ipv6?


Regards,
Nicolas
