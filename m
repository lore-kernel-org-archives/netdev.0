From: Jason Wang <jasowang@redhat.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Fri, 15 Sep 2017 16:55:40 +0800
Message-ID: <15abafa1-6d58-cd85-668a-bf361a296f52@redhat.com>
References: <4c7e2924-b10f-0e97-c388-c8809ecfdeeb@linux.vnet.ibm.com>
 <bdd417dc-9e2f-4a2e-534b-c6aa38f002f2@redhat.com>
 <e022cfa7-ef65-550f-06e8-f6e29f1d68a0@redhat.com>
 <627d0c7a-dce5-3094-d5d4-c1507fcb8080@linux.vnet.ibm.com>
 <50891c14-3fc6-f519-8c03-07bdef3090f4@redhat.com>
 <e42083d9-ae7b-7207-e5e6-06483bf6293e@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mst@redhat.com
To: Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55220 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751146AbdIOIzs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 04:55:48 -0400
In-Reply-To: <e42083d9-ae7b-7207-e5e6-06483bf6293e@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年09月15日 11:36, Matthew Rosato wrote:
>> Is the issue gone if you reduce VHOST_RX_BATCH to 1? And it would be
>> also helpful to collect perf diff to see if anything interesting.
>> (Consider 4.4 shows more obvious regression, please use 4.4).
>>
> Issue still exists when I force VHOST_RX_BATCH = 1

Interesting, so this looks more like an issue of the changes in 
vhost_net instead of batch dequeuing itself. I try this on Intel but 
still can't meet it.

>
> Collected perf data, with 4.12 as the baseline, 4.13 as delta1 and
> 4.13+VHOST_RX_BATCH=1 as delta2. All guests running 4.4.  Same scenario,
> 2 uperf client guests, 2 uperf slave guests - I collected perf data
> against 1 uperf client process and 1 uperf slave process.  Here are the
> significant diffs:
>
> uperf client:
>
> 75.09%   +9.32%   +8.52%  [kernel.kallsyms]   [k] enabled_wait
>   9.04%   -4.11%   -3.79%  [kernel.kallsyms]   [k] __copy_from_user
>   2.30%   -0.79%   -0.71%  [kernel.kallsyms]   [k] arch_free_page
>   2.17%   -0.65%   -0.58%  [kernel.kallsyms]   [k] arch_alloc_page
>   0.69%   -0.25%   -0.24%  [kernel.kallsyms]   [k] get_page_from_freelist
>   0.56%   +0.08%   +0.14%  [kernel.kallsyms]   [k] virtio_ccw_kvm_notify
>   0.42%   -0.11%   -0.09%  [kernel.kallsyms]   [k] tcp_sendmsg
>   0.31%   -0.15%   -0.14%  [kernel.kallsyms]   [k] tcp_write_xmit
>
> uperf slave:
>
> 72.44%   +8.99%   +8.85%  [kernel.kallsyms]   [k] enabled_wait
>   8.99%   -3.67%   -3.51%  [kernel.kallsyms]   [k] __copy_to_user
>   2.31%   -0.71%   -0.67%  [kernel.kallsyms]   [k] arch_free_page
>   2.16%   -0.67%   -0.63%  [kernel.kallsyms]   [k] arch_alloc_page
>   0.89%   -0.14%   -0.11%  [kernel.kallsyms]   [k] virtio_ccw_kvm_notify
>   0.71%   -0.30%   -0.30%  [kernel.kallsyms]   [k] get_page_from_freelist
>   0.70%   -0.25%   -0.29%  [kernel.kallsyms]   [k] __wake_up_sync_key
>   0.61%   -0.22%   -0.22%  [kernel.kallsyms]   [k] virtqueue_add_inbuf

It looks like vhost is slowed down for some reason which leads to more 
idle time on 4.13+VHOST_RX_BATCH=1. Appreciated if you can collect the 
perf.diff on host, one for rx and one for tx.

>
>
>> May worth to try disable zerocopy or do the test form host to guest
>> instead of guest to guest to exclude the possible issue of sender.
>>
> With zerocopy disabled, still seeing the regression.  The provided perf
> #s have zerocopy enabled.
>
> I replaced 1 uperf guest and instead ran that uperf client as a host
> process, pointing at a guest.  All traffic still over the virtual
> bridge.  In this setup, it's still easy to see the regression for the
> remaining guest1<->guest2 uperf run, but the host<->guest3 run does NOT
> exhibit a reliable regression pattern.  The significant perf diffs from
> the host uperf process (baseline=4.12, delta=4.13):
>
>
> 59.96%   +5.03%  [kernel.kallsyms]           [k] enabled_wait
>   6.47%   -2.27%  [kernel.kallsyms]           [k] raw_copy_to_user
>   5.52%   -1.63%  [kernel.kallsyms]           [k] raw_copy_from_user
>   0.87%   -0.30%  [kernel.kallsyms]           [k] get_page_from_freelist
>   0.69%   +0.30%  [kernel.kallsyms]           [k] finish_task_switch
>   0.66%   -0.15%  [kernel.kallsyms]           [k] swake_up
>   0.58%   -0.00%  [vhost]                     [k] vhost_get_vq_desc
>     ...
>   0.42%   +0.50%  [kernel.kallsyms]           [k] ckc_irq_pending

Another hint to perf vhost threads.

>
> I also tried flipping the uperf stream around (a guest uperf client is
> communicating to a slave uperf process on the host) and also cannot see
> the regression pattern.  So it seems to require a guest on both ends of
> the connection.
>

Yes. Will try to get a s390 environment.

Thanks
