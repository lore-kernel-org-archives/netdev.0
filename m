From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: 4.9 conntrack performance issues
Date: Sun, 15 Jan 2017 02:18:45 +0200
Message-ID: <d6dfdd8cf83933fc8f548da62a147775@nuclearcat.com>
References: <1a71d807acf63135bb037c7144fcd8d9@nuclearcat.com>
 <20170114235333.GA13421@breakpoint.cc>
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
Received: from nuclearcat.com ([144.76.183.226]:53070 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750743AbdAOASv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Jan 2017 19:18:51 -0500
In-Reply-To: <20170114235333.GA13421@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-01-15 01:53, Florian Westphal wrote:
> Denys Fedoryshchenko <nuclearcat@nuclearcat.com> wrote:
> 
> [ CC Nicolas since he also played with gc heuristics in the past ]
> 
>> Sorry if i added someone wrongly to CC, please let me know, if i 
>> should
>> remove.
>> I just run successfully 4.9 on my nat several days ago, and seems 
>> panic
>> issue disappeared. But i started to face another issue, it seems 
>> garbage
>> collector is hogging one of CPU's.
>> 
>> It was handling load very well at 4.8 and below, it might be still 
>> fine, but
>> i suspect queues that belong to hogged cpu might experience issues.
> 
> The worker doesn't grab locks for long and calls scheduler for every
> bucket to give a chance for other threads to run.
> 
> It also doesn't block softinterrupts.
> 
>> Is there anything can be done to improve cpu load distribution or 
>> reduce
>> single core load?
> 
> No, I am afraid we don't export any of the heuristics as tuneables so
> far.
> 
> You could try changing defaults in net/netfilter/nf_conntrack_core.c:
> 
> #define GC_MAX_BUCKETS_DIV      64u
> /* upper bound of scan intervals */
> #define GC_INTERVAL_MAX         (2 * HZ)
> /* maximum conntracks to evict per gc run */
> #define GC_MAX_EVICTS           256u
> 
> (the first two result in ~2 minute worst case timeout detection
>  on a fully idle system).
> 
> For instance you could use
> 
> GC_MAX_BUCKETS_DIV -> 128
> GC_INTERVAL_MAX    -> 30 * HZ
> 
> (This means that it takes one hour for a dead connection to be picked
>  up on an idle system, but thats only relevant in case you use
>  conntrack events to log when connection went down and need more 
> precise
>  accounting).
Not a big deal in my case.

> 
> I suspect you might also have to change
> 
> 1011         } else if (expired_count) {
> 1012                 gc_work->next_gc_run /= 2U;
> 1013                 next_run = msecs_to_jiffies(1);
> 1014         } else {
> 
> line 2013 to
> 	next_run = msecs_to_jiffies(HZ / 2);
> 
> or something like this to not have frequent rescans.
OK
> 
> The gc is also done from the packet path (i.e. accounted
> towards (k)softirq).
> 
> How many total connections is the machine handling on average?
> And how many new/delete events happen per second?
1-2 million connections, at current moment 988k
I dont know if it is correct method to measure events rate:

NAT ~ # timeout -t 5 conntrack -E -e NEW | wc -l
conntrack v1.4.2 (conntrack-tools): 40027 flow events have been shown.
40027
NAT ~ # timeout -t 5 conntrack -E -e DESTROY | wc -l
conntrack v1.4.2 (conntrack-tools): 40951 flow events have been shown.
40951

It is not peak time, so values can be 2-3 higher at peak time, but even 
right now, it is hogging one core, leaving only 20% idle left,
while others are 80-83% idle.

> 
>>     88.98%     0.00%  kworker/24:1  [kernel.kallsyms]       [k]
>> process_one_work
>>             |
>>             ---process_one_work
>>                |
>>                |--54.65%--gc_worker
>>                |          |
>>                |           --3.58%--nf_ct_gc_expired
>>                |                     |
>>                |                     |--1.90%--nf_ct_delete
> 
> I'd be interested to see how often that shows up on other cores
> (from packet path).
Other CPU's totally different:
This is top entry
     99.60%     0.00%  swapper  [kernel.kallsyms]    [k] start_secondary
             |
             ---start_secondary
                |
                 --99.42%--cpu_startup_entry
                           |
                            --98.04%--default_idle_call
                                      arch_cpu_idle
                                      |
                                      
|--48.58%--call_function_single_interrupt
                                      |          |
                                      |           
--46.36%--smp_call_function_single_interrupt
                                      |                     
smp_trace_call_function_single_interrupt
                                      |                     |
                                      |                     
|--44.18%--irq_exit
                                      |                     |          |
                                      |                     |          
|--43.37%--__do_softirq
                                      |                     |          |  
         |
                                      |                     |          |  
          --43.18%--net_rx_action
                                      |                     |          |  
                    |
                                      |                     |          |  
                    |--36.02%--process_backlog
                                      |                     |          |  
                    |          |
                                      |                     |          |  
                    |           --35.64%--__netif_receive_skb


gc_worker didnt appeared on other core at all.
Or i am checking something wrong?
