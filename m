From: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Mon, 18 Sep 2017 14:11:08 -0400
Message-ID: <7d444584-3854-ace2-008d-0fdef1c9cef4@linux.vnet.ibm.com>
References: <4c7e2924-b10f-0e97-c388-c8809ecfdeeb@linux.vnet.ibm.com>
 <bdd417dc-9e2f-4a2e-534b-c6aa38f002f2@redhat.com>
 <e022cfa7-ef65-550f-06e8-f6e29f1d68a0@redhat.com>
 <627d0c7a-dce5-3094-d5d4-c1507fcb8080@linux.vnet.ibm.com>
 <50891c14-3fc6-f519-8c03-07bdef3090f4@redhat.com>
 <e42083d9-ae7b-7207-e5e6-06483bf6293e@linux.vnet.ibm.com>
 <15abafa1-6d58-cd85-668a-bf361a296f52@redhat.com>
 <7345a69d-5e47-7058-c72b-bdd0f3c69210@linux.vnet.ibm.com>
 <55f9173b-a419-98f0-2516-cbd57299ba5d@redhat.com>
 <c9d43af9-f095-043a-7d46-acd84a18f75a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:47162 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753448AbdIRSLQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 14:11:16 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IIBFCk080383
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 14:11:15 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d2dup5uj2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 14:11:15 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <mjrosato@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 14:11:14 -0400
In-Reply-To: <c9d43af9-f095-043a-7d46-acd84a18f75a@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2017 03:36 AM, Jason Wang wrote:
> 
> 
> On 2017年09月18日 11:13, Jason Wang wrote:
>>
>>
>> On 2017年09月16日 03:19, Matthew Rosato wrote:
>>>> It looks like vhost is slowed down for some reason which leads to more
>>>> idle time on 4.13+VHOST_RX_BATCH=1. Appreciated if you can collect the
>>>> perf.diff on host, one for rx and one for tx.
>>>>
>>> perf data below for the associated vhost threads, baseline=4.12,
>>> delta1=4.13, delta2=4.13+VHOST_RX_BATCH=1
>>>
>>> Client vhost:
>>>
>>> 60.12%  -11.11%  -12.34%  [kernel.vmlinux]   [k] raw_copy_from_user
>>> 13.76%   -1.28%   -0.74%  [kernel.vmlinux]   [k] get_page_from_freelist
>>>   2.00%   +3.69%   +3.54%  [kernel.vmlinux]   [k] __wake_up_sync_key
>>>   1.19%   +0.60%   +0.66%  [kernel.vmlinux]   [k] __alloc_pages_nodemask
>>>   1.12%   +0.76%   +0.86%  [kernel.vmlinux]   [k] copy_page_from_iter
>>>   1.09%   +0.28%   +0.35%  [vhost]            [k] vhost_get_vq_desc
>>>   1.07%   +0.31%   +0.26%  [kernel.vmlinux]   [k] alloc_skb_with_frags
>>>   0.94%   +0.42%   +0.65%  [kernel.vmlinux]   [k] alloc_pages_current
>>>   0.91%   -0.19%   -0.18%  [kernel.vmlinux]   [k] memcpy
>>>   0.88%   +0.26%   +0.30%  [kernel.vmlinux]   [k] __next_zones_zonelist
>>>   0.85%   +0.05%   +0.12%  [kernel.vmlinux]   [k] iov_iter_advance
>>>   0.79%   +0.09%   +0.19%  [vhost]            [k] __vhost_add_used_n
>>>   0.74%                    [kernel.vmlinux]   [k] get_task_policy.part.7
>>>   0.74%   -0.01%   -0.05%  [kernel.vmlinux]   [k] tun_net_xmit
>>>   0.60%   +0.17%   +0.33%  [kernel.vmlinux]   [k] policy_nodemask
>>>   0.58%   -0.15%   -0.12%  [ebtables]         [k] ebt_do_table
>>>   0.52%   -0.25%   -0.22%  [kernel.vmlinux]   [k] __alloc_skb
>>>     ...
>>>   0.42%   +0.58%   +0.59%  [kernel.vmlinux]   [k] eventfd_signal
>>>     ...
>>>   0.32%   +0.96%   +0.93%  [kernel.vmlinux]   [k] finish_task_switch
>>>     ...
>>>           +1.50%   +1.16%  [kernel.vmlinux]   [k] get_task_policy.part.9
>>>           +0.40%   +0.42%  [kernel.vmlinux]   [k] __skb_get_hash_symmetr
>>>           +0.39%   +0.40%  [kernel.vmlinux]   [k] _copy_from_iter_full
>>>           +0.24%   +0.23%  [vhost_net]        [k] vhost_net_buf_peek
>>>
>>> Server vhost:
>>>
>>> 61.93%  -10.72%  -10.91%  [kernel.vmlinux]   [k] raw_copy_to_user
>>>   9.25%   +0.47%   +0.86%  [kernel.vmlinux]   [k] free_hot_cold_page
>>>   5.16%   +1.41%   +1.57%  [vhost]            [k] vhost_get_vq_desc
>>>   5.12%   -3.81%   -3.78%  [kernel.vmlinux]   [k] skb_release_data
>>>   3.30%   +0.42%   +0.55%  [kernel.vmlinux]   [k] raw_copy_from_user
>>>   1.29%   +2.20%   +2.28%  [kernel.vmlinux]   [k] copy_page_to_iter
>>>   1.24%   +1.65%   +0.45%  [vhost_net]        [k] handle_rx
>>>   1.08%   +3.03%   +2.85%  [kernel.vmlinux]   [k] __wake_up_sync_key
>>>   0.96%   +0.70%   +1.10%  [vhost]            [k] translate_desc
>>>   0.69%   -0.20%   -0.22%  [kernel.vmlinux]   [k] tun_do_read.part.10
>>>   0.69%                    [kernel.vmlinux]   [k] tun_peek_len
>>>   0.67%   +0.75%   +0.78%  [kernel.vmlinux]   [k] eventfd_signal
>>>   0.52%   +0.96%   +0.98%  [kernel.vmlinux]   [k] finish_task_switch
>>>   0.50%   +0.05%   +0.09%  [vhost]            [k] vhost_add_used_n
>>>     ...
>>>           +0.63%   +0.58%  [vhost_net]        [k] vhost_net_buf_peek
>>>           +0.32%   +0.32%  [kernel.vmlinux]   [k] _copy_to_iter
>>>           +0.19%   +0.19%  [kernel.vmlinux]   [k] __skb_get_hash_symmetr
>>>           +0.11%   +0.21%  [vhost]            [k] vhost_umem_interval_tr
>>>
>>
>> Looks like for some unknown reason which leads more wakeups.
>>
>> Could you please try to attached patch to see if it solves or mitigate
>> the issue?
>>
>> Thanks 
> 
> My bad, please try this.
> 
> Thanks

Thanks Jason.  Built 4.13 + supplied patch, I see some decrease in
wakeups, but there's still quite a bit more compared to 4.12
(baseline=4.12, delta1=4.13, delta2=4.13+patch):

client:
 2.00%   +3.69%   +2.55%  [kernel.vmlinux]   [k] __wake_up_sync_key

server:
 1.08%   +3.03%   +1.85%  [kernel.vmlinux]   [k] __wake_up_sync_key


Throughput was roughly equivalent to base 4.13 (so, still seeing the
regression w/ this patch applied).
