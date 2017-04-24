From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] bridge: shutdown bridge device before removing it
Date: Mon, 24 Apr 2017 22:41:17 +0800
Message-ID: <CADvbK_ckVO19iPnhVLoSKXsRPLcb3kJ_H+fN-UEwaF4T=JY0dQ@mail.gmail.com>
References: <a8b2b2c876f416431dac031a0beb7ce079c7d0a9.1493018730.git.lucien.xin@gmail.com>
 <3d77b47d-c8c3-de57-946e-59096a88964e@cumulusnetworks.com> <6144408f-4cfd-dd87-7444-8c61269b105a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33458 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1172742AbdDXOlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 10:41:18 -0400
Received: by mail-qt0-f196.google.com with SMTP id c45so20676542qtb.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 07:41:18 -0700 (PDT)
In-Reply-To: <6144408f-4cfd-dd87-7444-8c61269b105a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 8:07 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 24/04/17 14:01, Nikolay Aleksandrov wrote:
>> On 24/04/17 10:25, Xin Long wrote:
>>> During removing a bridge device, if the bridge is still up, a new mdb entry
>>> still can be added in br_multicast_add_group() after all mdb entries are
>>> removed in br_multicast_dev_del(). Like the path:
>>>
>>>   mld_ifc_timer_expire ->
>>>     mld_sendpack -> ...
>>>       br_multicast_rcv ->
>>>         br_multicast_add_group
>>>
>>> The new mp's timer will be set up. If the timer expires after the bridge
>>> is freed, it may cause use-after-free panic in br_multicast_group_expired.
>>> This can happen when ip link remove a bridge or destroy a netns with a
>>> bridge device inside.
>>>
>>> As we can see in br_del_bridge, brctl is also supposed to remove a bridge
>>> device after it's shutdown.
>>>
>>> This patch is to call dev_close at the beginning of br_dev_delete so that
>>> netif_running check in br_multicast_add_group can avoid this issue. But
>>> to keep consistent with before, it will not remove the IFF_UP check in
>>> br_del_bridge for brctl.
>>>
>>> Reported-by: Jianwen Ji <jiji@redhat.com>
>>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>>> ---
>>>  net/bridge/br_if.c | 2 ++
>>>  1 file changed, 2 insertions(+)
>>>
>>
>> +CC bridge maintainers
>>
>> I can see how this could happen, could you also provide the traceback ?
>>
>> The patch looks good to me, actually I think it fixes another issue with
>> mcast stats where the percpu pointer can be accessed after it's freed if
>> an mcast packet can get sent via br->dev after the br_multicast_dev_del() call.
>> This is definitely stable material, if I'm not mistaken the issue is there since
>> the introduction of br_dev_delete:
>> commit e10177abf842
>> Author: Satish Ashok <sashok@cumulusnetworks.com>
>> Date:   Wed Jul 15 07:16:51 2015 -0700
>>
>>     bridge: multicast: fix handling of temp and perm entries
>>
>>
>>
>> Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>
> Actually I have a better idea for a fix because dev_close() for a single device is rather heavy.
> Why don't you move the mdb flush logic in the bridge's ndo_uninit() callback ?
> That should have the same effect and be much faster.
Yes. But it seems that all cleanups for bridge should be done after
it's shutdown since beginning according to brctl. I'm not sure if there
are still other problems caused by this. maybe safer to use dev_close.
I need to check more to confirm this.

I also have another question about mp->timer removing.
As we can see, now it removes this timer with del_timer, instead of
del_timer_sync. What if the timer is running when del_timer ?
How can we be sure that br_multicast_group_expired will be done
before the bridge dev is freed. synchronize_net ?

>
> By the way I just noticed that there's also a memory leak - the mdb hash is reallocated
> and not freed due to the mdb rehash, here's also kmemleak's object:
>
yeps, ;-)

> unreferenced object 0xffff8800540ba800 (size 2048):
>   comm "softirq", pid 0, jiffies 4520588901 (age 5787.284s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff816e2287>] kmemleak_alloc+0x67/0xc0
>     [<ffffffff81260bea>] __kmalloc+0x1ba/0x3e0
>     [<ffffffffa05c60ee>] br_mdb_rehash+0x5e/0x340 [bridge]
>     [<ffffffffa05c74af>] br_multicast_new_group+0x43f/0x6e0 [bridge]
>     [<ffffffffa05c7aa3>] br_multicast_add_group+0x203/0x260 [bridge]
>     [<ffffffffa05ca4b5>] br_multicast_rcv+0x945/0x11d0 [bridge]
>     [<ffffffffa05b6b10>] br_dev_xmit+0x180/0x470 [bridge]
>     [<ffffffff815c781b>] dev_hard_start_xmit+0xbb/0x3d0
>     [<ffffffff815c8743>] __dev_queue_xmit+0xb13/0xc10
>     [<ffffffff815c8850>] dev_queue_xmit+0x10/0x20
>     [<ffffffffa02f8d7a>] ip6_finish_output2+0x5ca/0xac0 [ipv6]
>     [<ffffffffa02fbfc6>] ip6_finish_output+0x126/0x2c0 [ipv6]
>     [<ffffffffa02fc245>] ip6_output+0xe5/0x390 [ipv6]
>     [<ffffffffa032b92c>] NF_HOOK.constprop.44+0x6c/0x240 [ipv6]
>     [<ffffffffa032bd16>] mld_sendpack+0x216/0x3e0 [ipv6]
>     [<ffffffffa032d5eb>] mld_ifc_timer_expire+0x18b/0x2b0 [ipv6]
>
>
>
