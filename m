From: Ben Greear <greearb@candelatech.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Tue, 6 Jun 2017 17:48:30 -0700
Message-ID: <a4700184-2249-1211-ba27-30081ec957bf@candelatech.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
 <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
 <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:41330 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750766AbdFGAsb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 20:48:31 -0400
In-Reply-To: <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2017 05:27 PM, Eric Dumazet wrote:
> On Tue, 2017-06-06 at 18:00 -0600, David Ahern wrote:
>> On 6/6/17 3:06 PM, Ben Greear wrote:
>>> This bug has been around forever, and we recently got an intern and
>>> stuck him with
>>> trying to reproduce it on the latest kernel.  It is still here.  I'm not
>>> super excited
>>> about trying to fix this, but we can easily test patches if someone has a
>>> patch to try.
>>
>> Can you try this (whitespace damaged on paste, but it is moving the lock
>> ahead of the fn_sernum check):
>>
>> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
>> index deea901746c8..7a44c49055c0 100644
>> --- a/net/ipv6/ip6_fib.c
>> +++ b/net/ipv6/ip6_fib.c
>> @@ -378,6 +378,7 @@ static int fib6_dump_table(struct fib6_table *table,
>> struct sk_buff *skb,
>>                         cb->args[5] = w->root->fn_sernum;
>>                 }
>>         } else {
>> +               read_lock_bh(&table->tb6_lock);
>>                 if (cb->args[5] != w->root->fn_sernum) {
>>                         /* Begin at the root if the tree changed */
>>                         cb->args[5] = w->root->fn_sernum;
>> @@ -387,7 +388,6 @@ static int fib6_dump_table(struct fib6_table *table,
>> struct sk_buff *skb,
>>                 } else
>>                         w->skip = 0;
>>
>> -               read_lock_bh(&table->tb6_lock);
>>                 res = fib6_walk_continue(w);
>>                 read_unlock_bh(&table->tb6_lock);
>>                 if (res <= 0) {
>
>
> Good catch, but it looks like similar fix is needed a few lines before.

We will test this tomorrow.

Thanks,
Ben


>
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index deea901746c8570c5e801e40592c91e3b62812e0..b214443dc8346cef3690df7f27cc48a864028865 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -372,12 +372,13 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
>
>  		read_lock_bh(&table->tb6_lock);
>  		res = fib6_walk(net, w);
> -		read_unlock_bh(&table->tb6_lock);
>  		if (res > 0) {
>  			cb->args[4] = 1;
>  			cb->args[5] = w->root->fn_sernum;
>  		}
> +		read_unlock_bh(&table->tb6_lock);
>  	} else {
> +		read_lock_bh(&table->tb6_lock);
>  		if (cb->args[5] != w->root->fn_sernum) {
>  			/* Begin at the root if the tree changed */
>  			cb->args[5] = w->root->fn_sernum;
> @@ -387,7 +388,6 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
>  		} else
>  			w->skip = 0;
>
> -		read_lock_bh(&table->tb6_lock);
>  		res = fib6_walk_continue(w);
>  		read_unlock_bh(&table->tb6_lock);
>  		if (res <= 0) {
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
