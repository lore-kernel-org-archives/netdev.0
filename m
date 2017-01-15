From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: 4.9 conntrack performance issues
Date: Sun, 15 Jan 2017 02:42:37 +0200
Message-ID: <c75f3f7b9fefe55d24402f2d9b49b5ae@nuclearcat.com>
References: <1a71d807acf63135bb037c7144fcd8d9@nuclearcat.com>
 <20170114235333.GA13421@breakpoint.cc>
 <d6dfdd8cf83933fc8f548da62a147775@nuclearcat.com>
 <20170115002936.GC13421@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guillaume Nault <g.nault@alphalink.fr>,
        Netfilter Devel <netfilter-devel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        nicolas.dichtel@6wind.com, netdev-owner@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:54158 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750718AbdAOAmk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Jan 2017 19:42:40 -0500
In-Reply-To: <20170115002936.GC13421@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-01-15 02:29, Florian Westphal wrote:
> Denys Fedoryshchenko <nuclearcat@nuclearcat.com> wrote:
>> On 2017-01-15 01:53, Florian Westphal wrote:
>> >Denys Fedoryshchenko <nuclearcat@nuclearcat.com> wrote:
>> >
>> >I suspect you might also have to change
>> >
>> >1011         } else if (expired_count) {
>> >1012                 gc_work->next_gc_run /= 2U;
>> >1013                 next_run = msecs_to_jiffies(1);
>> >1014         } else {
>> >
>> >line 2013 to
>> >	next_run = msecs_to_jiffies(HZ / 2);
> 
> I think its wrong to rely on "expired_count", with these
> kinds of numbers (up to 10k entries are scanned per round
> in Denys setup, its basically always going to be > 0.
> 
> I think we should only decide to scan more frequently if
> eviction ratio is large, say, we found more than 1/4 of
> entries to be stale.
> 
> I sent a small patch offlist that does just that.
> 
>> >How many total connections is the machine handling on average?
>> >And how many new/delete events happen per second?
>> 1-2 million connections, at current moment 988k
>> I dont know if it is correct method to measure events rate:
>> 
>> NAT ~ # timeout -t 5 conntrack -E -e NEW | wc -l
>> conntrack v1.4.2 (conntrack-tools): 40027 flow events have been shown.
>> 40027
>> NAT ~ # timeout -t 5 conntrack -E -e DESTROY | wc -l
>> conntrack v1.4.2 (conntrack-tools): 40951 flow events have been shown.
>> 40951
> 
> Thanks, thats exactly what I was looking for.
> So I am not at all surprised that gc_worker eats cpu cycles...
> 
>> It is not peak time, so values can be 2-3 higher at peak time, but 
>> even
>> right now, it is hogging one core, leaving only 20% idle left,
>> while others are 80-83% idle.
> 
> I agree its a bug.
> 
>> >>               |--54.65%--gc_worker
>> >>               |          |
>> >>               |           --3.58%--nf_ct_gc_expired
>> >>               |                     |
>> >>               |                     |--1.90%--nf_ct_delete
>> >
>> >I'd be interested to see how often that shows up on other cores
>> >(from packet path).
>> Other CPU's totally different:
>> This is top entry
>>     99.60%     0.00%  swapper  [kernel.kallsyms]    [k] 
>> start_secondary
>>             |
>>             ---start_secondary
>>                |
>>                 --99.42%--cpu_startup_entry
>>                           |
> [..]
> 
>> |--36.02%--process_backlog
>>                                      |                     |          
>> |
>> |          |
>>                                      |                     |          
>> |
>> |           --35.64%--__netif_receive_skb
>> 
>> gc_worker didnt appeared on other core at all.
>> Or i am checking something wrong?
> 
> Look for "nf_ct_gc_expired" and "nf_ct_delete".
> Its going to be deep down in the call graph.
I tried my best to record as much data as possible, but it doesnt show 
it in callgraph, just a little bit in statistics:

      0.01%     0.00%  swapper      [nf_conntrack]            [k] 
nf_ct_delete
      0.01%     0.00%  swapper      [nf_conntrack]            [k] 
nf_ct_gc_expired
And thats it.
