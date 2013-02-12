From: Tommi Rantala <tt.rantala@gmail.com>
Subject: Re: soft lockup at __skb_recv_datagram() when fuzzing with trinity as
 root in VM
Date: Tue, 12 Feb 2013 09:42:00 +0200
Message-ID: <CA+ydwtoBttwiVz+oy0hnetUTQMi7XHyS9bfGzjuP1L41srBk=g@mail.gmail.com>
References: <CA+ydwtphWsC-B9Y2WwWOPEWtPPj62Wf6Pt2iZ+tAGaTvg_7gCg@mail.gmail.com>
	<1360628371.20362.28.camel@edumazet-glaptop>
	<1360638903.20362.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f45.google.com ([209.85.212.45]:37647 "EHLO
	mail-vb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757306Ab3BLHmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 02:42:02 -0500
Received: by mail-vb0-f45.google.com with SMTP id p1so16516vbi.4
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 23:42:01 -0800 (PST)
In-Reply-To: <1360638903.20362.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/12 Eric Dumazet <eric.dumazet@gmail.com>:
> On Mon, 2013-02-11 at 16:19 -0800, Eric Dumazet wrote:
>> On Mon, 2013-02-11 at 21:25 +0200, Tommi Rantala wrote:
>> > Hello,
>> >
>> > I am quite easily reproducing this lockup when fuzzing with Trinity as
>> > the root user in a virtual machine. It seems to be busy-looping in the
>> > do-while loop in __skb_recv_datagram().
>> >
>> > [   83.541011] INFO: rcu_sched detected stalls on CPUs/tasks: {}
>> > (detected by 0, t=26002 jiffies, g=27673, c=27672, q=75)
>> > [   83.541011] INFO: Stall ended before state dump start
>> > [  108.067010] BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child31:2847]
>> > [  108.067010] irq event stamp: 244034822
>> > [  108.067010] hardirqs last  enabled at (244034821):
>> > [<ffffffff81ca2da5>] _raw_spin_unlock_irqrestore+0x55/0x70
>> > [  108.067010] hardirqs last disabled at (244034822):
>> > [<ffffffff81ca4fad>] apic_timer_interrupt+0x6d/0x80
>> > [  108.067010] softirqs last  enabled at (244030010):
>> > [<ffffffff810a086a>] __do_softirq+0x1ca/0x240
>> > [  108.067010] softirqs last disabled at (244030005):
>> > [<ffffffff81ca56fc>] call_softirq+0x1c/0x30
>> > [  108.067010] CPU 0
>> > [  108.067010] Pid: 2847, comm: trinity-child31 Tainted: G        W
>> > 3.8.0-rc7+ #73 Bochs Bochs
>> > [  108.067010] RIP: 0010:[<ffffffff81ca2daa>]  [<ffffffff81ca2daa>]
>> > _raw_spin_unlock_irqrestore+0x5a/0x70
>> > [  108.067010] RSP: 0018:ffff88002fb5db38  EFLAGS: 00000286
>> > [  108.067010] RAX: ffff8800201ec520 RBX: ffffffff810d54fa RCX: 0000000000005220
>> > [  108.067010] RDX: ffff8800201ec520 RSI: 0000000000000001 RDI: 0000000000000286
>> > [  108.067010] RBP: ffff88002fb5db48 R08: 0000000000000068 R09: 0000000000000001
>> > [  108.067010] R10: 0000000000000001 R11: 0000000000000000 R12: ffffffff810f5b9d
>> > [  108.067010] R13: ffff88002fb5daa8 R14: 00000019294ba499 R15: 0000000000000086
>> > [  108.067010] FS:  00007f6aabc57700(0000) GS:ffff88003e000000(0000)
>> > knlGS:0000000000000000
>> > [  108.067010] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> > [  108.067010] CR2: 0000000000000009 CR3: 000000002fb08000 CR4: 00000000000006f0
>> > [  108.067010] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> > [  108.067010] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> > [  108.067010] Process trinity-child31 (pid: 2847, threadinfo
>> > ffff88002fb5c000, task ffff8800201ec520)
>> > [  108.067010] Stack:
>> > [  108.067010]  ffff88002fb5dc10 ffff88002fb5dc14 ffff88002fb5dbf8
>> > ffffffff818cc103
>> > [  108.067010]  ffff8800391a7d80 ffff8800201ec520 ffff88002fb5dbb8
>> > 7fffffffffffffff
>> > [  108.067010]  ffff88002fb5dc54 40001202810d54fa ffff8800201ec520
>> > ffff8800277f87e8
>> > [  108.067010] Call Trace:
>> > [  108.067010]  [<ffffffff818cc103>] __skb_recv_datagram+0x1a3/0x3b0
>> > [  108.067010]  [<ffffffff818cbbe0>] ?
>> > csum_partial_copy_fromiovecend+0x220/0x220
>> > [  108.067010]  [<ffffffff818cc33d>] skb_recv_datagram+0x2d/0x30
>> > [  108.067010]  [<ffffffff813029a0>] ? selinux_syslog+0x70/0x70
>> > [  108.067010]  [<ffffffff819ed43d>] rawv6_recvmsg+0xad/0x240
>> > [  108.067010]  [<ffffffff818c4b04>] sock_common_recvmsg+0x34/0x50
>> > [  108.067010]  [<ffffffff818bc8ec>] sock_recvmsg+0xbc/0xf0
>> > [  108.067010]  [<ffffffff81084adf>] ? kvm_clock_read+0x1f/0x30
>> > [  108.067010]  [<ffffffff810612d9>] ? sched_clock+0x9/0x10
>> > [  108.067010]  [<ffffffff818bf31e>] sys_recvfrom+0xde/0x150
>> > [  108.067010]  [<ffffffff810f5abd>] ? trace_hardirqs_on+0xd/0x10
>> > [  108.067010]  [<ffffffff81ca2deb>] ? _raw_spin_unlock_irq+0x2b/0x40
>> > [  108.067010]  [<ffffffff81ca4355>] ? sysret_check+0x22/0x5d
>> > [  108.067010]  [<ffffffff810f5a15>] ? trace_hardirqs_on_caller+0x155/0x1f0
>> > [  108.067010]  [<ffffffff8135718e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>> > [  108.067010]  [<ffffffff81ca4329>] system_call_fastpath+0x16/0x1b
>> > [  108.067010] Code: ff f6 c7 02 75 1b 48 89 df 57 9d 0f 1f 44 00 00
>> > e8 fc 2d 45 ff eb 19 66 2e 0f 1f 84 00 00 00 00 00 e8 0b 2d 45 ff 48
>> > 89 df 57 9d <0f> 1f 44 00 00 48 8b 5d f0 4c 8b 65 f8 c9 c3 0f 1f 80 00
>> > 00 00
>> >
>> > Tommi
>>
>> Seems MSG_PEEK issue
>>
>> wait_for_packet() is unable to wait if one packet is in receive_queue.
>>
>> So yes, we basically loop forever.
>>
>> Bug added in commit 3f518bf745cbd6007d8069100fb9cb09e960c872
>> (datagram: Add offset argument to __skb_recv_datagram)
>>
>> CC Pavel Emelyanov
>>
>
> If I am not mistaken, we can have skb with 0 bytes in them

Thanks Eric, with the patch applied, I am no longer able to reproduce
the bug with Trinity.

Tommi

> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index 0337e2b..368f9c3 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -187,7 +187,7 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
>                 skb_queue_walk(queue, skb) {
>                         *peeked = skb->peeked;
>                         if (flags & MSG_PEEK) {
> -                               if (*off >= skb->len) {
> +                               if (*off >= skb->len && skb->len) {
>                                         *off -= skb->len;
>                                         continue;
>                                 }
>
>
