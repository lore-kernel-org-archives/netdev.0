From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Patch net-next] net_sched: move the empty tp check from
 ->destroy() to ->delete()
Date: Sun, 27 Nov 2016 18:51:56 -0800
Message-ID: <583B9BCC.2020904@gmail.com>
References: <1479952708-26763-1-git-send-email-xiyou.wangcong@gmail.com>
 <5836A4D4.2010500@mellanox.com> <5836BD82.6080407@iogearbox.net>
 <5836C87E.8050506@mellanox.com> <58370558.9070004@iogearbox.net>
 <CAM_iQpVxevmk3rgsnALC0JCqx7pOF2OBc=kpg9QDK8Cwb6P9Zw@mail.gmail.com>
 <58396D71.8070703@iogearbox.net> <583A29E3.8030809@iogearbox.net>
 <583A6567.30003@mellanox.com> <583A7D67.50003@mellanox.com>
 <583B95CE.7080309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>
To: Roi Dayan <roid@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34877 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753640AbcK1Cw1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 21:52:27 -0500
Received: by mail-pg0-f49.google.com with SMTP id p66so51606485pga.2
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 18:52:27 -0800 (PST)
In-Reply-To: <583B95CE.7080309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-27 06:26 PM, John Fastabend wrote:
> On 16-11-26 10:29 PM, Roi Dayan wrote:
>>
>>
>> On 27/11/2016 06:47, Roi Dayan wrote:
>>>
>>>
>>> On 27/11/2016 02:33, Daniel Borkmann wrote:
>>>> On 11/26/2016 12:09 PM, Daniel Borkmann wrote:
>>>>> On 11/26/2016 07:46 AM, Cong Wang wrote:
>>>>>> On Thu, Nov 24, 2016 at 7:20 AM, Daniel Borkmann
>>>>>> <daniel@iogearbox.net> wrote:
>>>> [...]
>>>>>>> Ok, strange, qdisc_destroy() calls into ops->destroy(), where ingress
>>>>>>> drops its entire chain via tcf_destroy_chain(), so that will be NULL
>>>>>>> eventually. The tps are freed by call_rcu() as well as qdisc itself
>>>>>>> later on via qdisc_rcu_free(), where it frees per-cpu bstats as well.
>>>>>>> Outstanding readers should either bail out due to if (!cl) or can
>>>>>>> still
>>>>>>> process the chain until read section ends, but during that time,
>>>>>>> cl->q
>>>>>>> resp. bstats should be good. Do you happen to know what's at address
>>>>>>> ffff880a68b04028? I was wondering wrt call_rcu() vs call_rcu_bh(),
>>>>>>> but
>>>>>>> at least on ingress (netif_receive_skb_internal()) we hold
>>>>>>> rcu_read_lock()
>>>>>>> here. The KASAN report is reliably happening at this location, right?
>>>>>>
>>>>>> I am confused as well, I don't see how it could be related to my
>>>>>> patch yet.
>>>>>> I will take a deep look in the weekend.
>>>
>>>
>>>
>>> Hi Cong,
>>>
>>> When reported the new trace I didn't mean it's related to your patch,
>>> I just wanted to point it out it exposed something. I should have been
>>> clear about it.
>>>
>>>
>>>>>
>>>>> Ok, I'm currently on the run. Got too late yesterday night, but I'll
>>>>> write what I found in the evening today, not related to ingress though.
>>>>
>>>> Just pushed out my analysis to netdev under "[PATCH net] net, sched:
>>>> respect
>>>> rcu grace period on cls destruction". My conclusion is that both
>>>> issues are
>>>> actually separate, and that one is small enough where we could route
>>>> it via
>>>> net actually. Perhaps this at the same time shrinks your "[PATCH
>>>> net-next]
>>>> net_sched: move the empty tp check from ->destroy() to ->delete()" to a
>>>> reasonable size that it's suitable to net as well. Your
>>>> ->delete()/->destroy()
>>>> one is definitely needed, too. The tp->root one is independant of
>>>> ->delete()/
>>>> ->destroy() as they are different races and tp->root could also
>>>> happen when
>>>> you just destroy the whole tp directly. I think that seems like a
>>>> good path
>>>> forward to me.
>>>>
>>>> Thanks,
>>>> Daniel
>>>
>>>
>>>
>>> Hi Daniel,
>>>
>>> As for the tainted kernel. I was in old (week or two) net-next tree
>>> and only cherry-picked from latest net-next related patches to
>>> Mellanox HCA, cls_api, cls_flower, devlink. so those are the tainted
>>> modules.
>>> I have the issue reproducing in that tree so wanted it to check it
>>> with Cong's patch instead of latest net-next.
>>> I'll try running reproducing the issue with your new patch and later
>>> try latest net-next as well.
>>>
>>> Thanks,
>>> Roi
>>>
>>
>> Hi,
>>
>> I tested "[PATCH net] net, sched: respect rcu grace period on cls
>> destruction" and could not reproduce my original issue.
> 
> Hi Roi,
> 
> Just so I'm 100% clear. No issue with just the above "respect rcu grace
> period on cls destruction" per above statement.
> 
>> I rebased "[Patch net-next] net_sched: move the empty tp check from
>> ->destroy() to ->delete()" over to test it in the same tree and got into
>> a new trace in fl_delete.
> 
> In this case did you test with "net_sched: move the empty tp check from
> ->destroy() to ->delete()" _only_ or did this include both patches when
> you see the error below.
> 
> From my inspection we really need both patches to get correct behavior.
> 
> Thanks!
> John

Ah dang nevermind I just read both patches in detail and applying them
both at the same time is nonsense. Let me reply with comments directly
to the patches.

Thanks. sorry for the noise.

> 
>>
>> [35659.012123] BUG: KASAN: wild-memory-access on address 1ffffffff803ca31
>> [35659.020042] Write of size 1 by task ovs-vswitchd/20135
>> [35659.025878] CPU: 19 PID: 20135 Comm: ovs-vswitchd Tainted:
>> G           O    4.9.0-rc3+ #18
>> [35659.035948] Hardware name: HP ProLiant DL380p Gen8, BIOS P70 07/01/2015
>> [35659.043730] Call Trace:
>> [35659.046619]  [<ffffffff95b6dc42>] dump_stack+0x63/0x81
>> [35659.052456]  [<ffffffff955fbbf8>] kasan_report_error+0x408/0x4e0
>> [35659.059402]  [<ffffffff955fc2e8>] kasan_report+0x58/0x60
>> [35659.065428]  [<ffffffff952d5e8d>] ? call_rcu_sched+0x1d/0x20
>> [35659.072119]  [<ffffffffc01e0701>] ? fl_destroy_filter+0x21/0x30
>> [cls_flower]
>> [35659.080217]  [<ffffffffc01e1ccf>] ? fl_delete+0x1df/0x2e0 [cls_flower]
>> [35659.087580]  [<ffffffff955fa4ca>] __asan_store1+0x4a/0x50
>> [35659.093697]  [<ffffffffc01e1ccf>] fl_delete+0x1df/0x2e0 [cls_flower]
>> [35659.100870]  [<ffffffff9653ecba>] tc_ctl_tfilter+0x10da/0x1b90
>>
>>
>> 0x1d02 is in fl_delete (net/sched/cls_flower.c:805).
>> 800             struct cls_fl_filter *f = (struct cls_fl_filter *) arg;
>> 801
>> 802             rhashtable_remove_fast(&head->ht, &f->ht_node,
>> 803                                    head->ht_params);
>> 804             __fl_delete(tp, f);
>> 805             *last = list_empty(&head->filters);
>> 806             return 0;
>> 807     }
>>
>>
>> Thanks,
>> Roi
> 
