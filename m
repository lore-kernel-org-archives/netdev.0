From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 03/10] vxlan: move IGMP join/leave to work queue
Date: Wed, 5 Jun 2013 16:00:36 +0800
Message-ID: <CAM_iQpXv2V+EBuWr7g+dOOhXSss9Zqs5FLFg47RB8BzY_Znjxg@mail.gmail.com>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
	<1370406254-6341-3-git-send-email-stephen@networkplumber.org>
	<kommuo$ma8$1@ger.gmane.org>
	<CAF1J0HODhf3Mtg-XupN8K3oXWYV4GKWptDOgWsvvkSX-embfbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:57822 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500Ab3FEIAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 04:00:37 -0400
Received: by mail-oa0-f41.google.com with SMTP id n9so864151oag.28
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 01:00:36 -0700 (PDT)
In-Reply-To: <CAF1J0HODhf3Mtg-XupN8K3oXWYV4GKWptDOgWsvvkSX-embfbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 5, 2013 at 3:29 PM, Mike Rapoport
<mike.rapoport@ravellosystems.com> wrote:
> On Wed, Jun 5, 2013 at 9:47 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Wed, 05 Jun 2013 at 04:24 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
>>> Do join/leave from work queue to avoid lock inversion problems
>>> between normal socket and RTNL. The code comes out cleaner
>>> as well.
>>>
>>> Uses Cong Wang's suggestion to turn refcnt into a real atomic
>>> since now need to handle case where last use of socket is IGMP
>>> worker.
>>>
>>> Also fixes race where vxlan_stop could be called after
>>> device was deleted on module removal. The call to rtnl_link_unregister
>>> would call dellink while vxlan device was still up. Reordering
>>> the calls fixes it.
>>>
>>
>> After the first 3 patches applied, I got:
>>
>> [   55.010954] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
>> [   55.013309] CPU: 1 PID: 163 Comm: kworker/1:2 Not tainted
>> 3.10.0-rc2+ #1150
>> [   55.013309] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
>> [   55.013309] Workqueue: events vxlan_igmp_work
>
> I think the problem happens because vxlan_dellink does
> unregister_netdevice_queue and then immediately calls
> vxlan_sock_release and thus vs_sock is released before igmp_work
> starts


Yeah, seems something wrong with refcnt.

Thanks!

>
>> [   55.013309] task: ffff880070eac900 ti: ffff8800716d4000 task.ti:
>> ffff8800716d4000
>> [   55.013309] RIP: 0010:[<ffffffff815df704>]  [<ffffffff815df704>]
>> vxlan_sock_release+0x25/0x55
>> [   55.013309] RSP: 0018:ffff8800716d5cf8  EFLAGS: 00010246
>> [   55.013309] RAX: 0000000000000000 RBX: ffff88006fd7c000 RCX:
>> 0000000ccee84d06
>> [   55.013309] RDX: dead000000200200 RSI: ffff880070ead048 RDI:
>> ffff88006fd7c070
>> [   55.013309] RBP: ffff8800716d5d08 R08: 0000000000000000 R09:
>> ffff8800716d5c48
>> [   55.013309] R10: 000000000000b6c4 R11: 000000000000b163 R12:
>> ffff88006ebb7400
>> [   55.013309] R13: ffff88006fd7c000 R14: ffff8800723b4520 R15:
>> 0000000000000000
>> [   55.013309] FS:  0000000000000000(0000) GS:ffff88007f800000(0000)
>> knlGS:0000000000000000
>> [   55.013309] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [   55.013309] CR2: 00007fa99dc0a000 CR3: 0000000070c17000 CR4:
>> 00000000000006e0
>> [   55.013309] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> [   55.013309] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> [   55.013309] Stack:
>> [   55.013309]  ffff880070eac900 ffff880070fc0b58 ffff8800716d5d48
>> ffffffff815e0a73
>> [   55.013309]  080808e0716d5d28 0000000f00000000 ffff8800714ef008
>> ffff880070fc0b58
>> [   55.013309]  ffff88007f9d6200 ffff88007f9d38c0 ffff8800716d5de8
>> ffffffff8106872f
>> [   55.013309] Call Trace:
>> [   55.013309]  [<ffffffff815e0a73>] vxlan_igmp_work+0xa8/0xcf
>> [   55.013309]  [<ffffffff8106872f>] process_one_work+0x240/0x408
>> [   55.013309]  [<ffffffff81068662>] ? process_one_work+0x173/0x408
>> [   55.013309]  [<ffffffff81068c82>] worker_thread+0x15d/0x1f1
>> [   55.013309]  [<ffffffff81068b25>] ? rescuer_thread+0x1ff/0x1ff
>> [   55.013309]  [<ffffffff81070c19>] kthread+0xb1/0xb9
>> [   55.013309]  [<ffffffff81070b68>] ? freezing+0x17/0x17
>> [   55.013309]  [<ffffffff81976bdc>] ret_from_fork+0x7c/0xb0
>> [   55.013309]  [<ffffffff81070b68>] ? freezing+0x17/0x17
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
> --
> Sincerely yours,
> Mike.
