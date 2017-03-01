From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 09/14] netfilter: conntrack: refine gc worker heuristics,
 redux
Date: Wed, 1 Mar 2017 16:02:53 +0100
Message-ID: <dd8b8fe3-5c73-c7b9-314f-70ceb0abd2b0@6wind.com>
References: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
 <1485448687-6072-10-git-send-email-pablo@netfilter.org>
 <09f1081e-ade3-6099-a3c6-b1b912592f54@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <09f1081e-ade3-6099-a3c6-b1b912592f54@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 27/01/2017 à 17:51, Nicolas Dichtel a écrit :
> Le 26/01/2017 à 17:38, Pablo Neira Ayuso a écrit :
>> From: Florian Westphal <fw@strlen.de>
>>
>> This further refines the changes made to conntrack gc_worker in
>> commit e0df8cae6c16 ("netfilter: conntrack: refine gc worker heuristics").
>>
>> The main idea of that change was to reduce the scan interval when evictions
>> take place.
>>
>> However, on the reporters' setup, there are 1-2 million conntrack entries
>> in total and roughly 8k new (and closing) connections per second.
>>
>> In this case we'll always evict at least one entry per gc cycle and scan
>> interval is always at 1 jiffy because of this test:
>>
>>  } else if (expired_count) {
>>      gc_work->next_gc_run /= 2U;
>>      next_run = msecs_to_jiffies(1);
>>
>> being true almost all the time.
>>
>> Given we scan ~10k entries per run its clearly wrong to reduce interval
>> based on nonzero eviction count, it will only waste cpu cycles since a vast
>> majorities of conntracks are not timed out.
>>
>> Thus only look at the ratio (scanned entries vs. evicted entries) to make
>> a decision on whether to reduce or not.
>>
>> Because evictor is supposed to only kick in when system turns idle after
>> a busy period, pick a high ratio -- this makes it 50%.  We thus keep
>> the idea of increasing scan rate when its likely that table contains many
>> expired entries.
>>
>> In order to not let timed-out entries hang around for too long
>> (important when using event logging, in which case we want to timely
>> destroy events), we now scan the full table within at most
>> GC_MAX_SCAN_JIFFIES (16 seconds) even in worst-case scenario where all
>> timed-out entries sit in same slot.
>>
>> I tested this with a vm under synflood (with
>> sysctl net.netfilter.nf_conntrack_tcp_timeout_syn_recv=3).
>>
>> While flood is ongoing, interval now stays at its max rate
>> (GC_MAX_SCAN_JIFFIES / GC_MAX_BUCKETS_DIV -> 125ms).
>>
>> With feedback from Nicolas Dichtel.
>>
>> Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
>> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Fixes: b87a2f9199ea82eaadc ("netfilter: conntrack: add gc worker to remove timed-out entries")
>> Signed-off-by: Florian Westphal <fw@strlen.de>
>> Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Tested-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
>> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Pablo, is it possible to queue this patch (and the previous: 08/14) for the 4.9
> stable?

Pablo, should I submit it formally?


Regards,
Nicolas
