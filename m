From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 19:40:13 -0400
Message-ID: <ea94bc64-a109-c033-7ecc-c51c19b214c8@mojatatu.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
 <1473717691.18970.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <77bca669-9113-3977-ad3c-478091422ff8@mojatatu.com>
 <1473719192.18970.84.camel@edumazet-glaptop3.roam.corp.google.com>
 <3a1da0eb-b253-ef9c-8679-0290e670238c@mojatatu.com>
 <1473721837.18970.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <1473722404.18970.97.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34748 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752190AbcILXkQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 19:40:16 -0400
Received: by mail-oi0-f67.google.com with SMTP id c129so5758044oih.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:40:15 -0700 (PDT)
In-Reply-To: <1473722404.18970.97.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-12 07:20 PM, Eric Dumazet wrote:
> On Mon, 2016-09-12 at 16:10 -0700, Eric Dumazet wrote:
>
>>
>> diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
>> index 508e051304fb62627e61b5065b2325edd1b84f2e..dc9dd8ae7d5405f76c775278dac7689655b21041 100644
>> --- a/net/core/gen_stats.c
>> +++ b/net/core/gen_stats.c
>> @@ -142,10 +142,14 @@ __gnet_stats_copy_basic(const seqcount_t *running,
>>  		return;
>>  	}
>>  	do {
>> -		if (running)
>> +		if (running) {
>> +			local_bh_disable();
>>  			seq = read_seqcount_begin(running);
>> +		}
>>  		bstats->bytes = b->bytes;
>>  		bstats->packets = b->packets;
>> +		if (running)
>> +			local_bh_enable();
>>  	} while (running && read_seqcount_retry(running, seq));
>>  }
>
> Ah well, forget this patch, re-enabling bh right before
> read_seqcount_retry() is not going to help.
>

I have to say I have seen some odd issues once in a while reading
generic action stats.
I had a program that opened a netlink socket into the kernel.
Every X seconds it does a dump of all the actions to read the
stats.
There is a very reproducible behavior that the stats
are not in sync with the kernel. Given generic stats is lockless
I thought maybe rcu or per-cpu stats was the issue. I havent had time
to look closely.
The solution is instead of keeping the socket open all the time;
I open, read stats, close (repeat every x seconds).

If there is something you want me to try - I could do sometimes
this week. Your patch above may be useful!

cheers,
jamal
