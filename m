From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next V4 0/6] switch to use tx skb array in tun
Date: Wed, 6 Jul 2016 13:45:58 -0400
Message-ID: <CAEfhGixKLfLOj11ERgPhpVB+UXbqxrvkQKgQgn19bDjroO_4dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mst@redhat.com, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33358 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490AbcGFRqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 13:46:04 -0400
Received: by mail-lf0-f66.google.com with SMTP id l188so22992766lfe.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 10:46:02 -0700 (PDT)
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com. [209.85.215.46])
        by smtp.gmail.com with ESMTPSA id 12sm88301ljf.17.2016.07.06.10.45.59
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 10:46:00 -0700 (PDT)
Received: by mail-lf0-f46.google.com with SMTP id h129so159628143lfh.1
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 10:45:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 2:45 AM, Jason Wang <jasowang@redhat.com> wrote:
> Hi all:
>
> This series tries to switch to use skb array in tun. This is used to
> eliminate the spinlock contention between producer and consumer. The
> conversion was straightforward: just introdce a tx skb array and use
> it instead of sk_receive_queue.

I'm seeing the splat below after this series.  I'm still wrapping my
head around this code, but it appears to be happening because the
tun_struct passed into tun_queue_resize is uninitialized.
Specifically, iteration over the disabled list_head fails because prev
= next = NULL.  This seems to happen when a startup script on my test
machine changes the queue length.  I'll try to figure out what's
happening, but if it's obvious to someone else from the stack, please
let me know.

[   72.322236] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000010
[   72.329993] IP: [<ffffffff8153c1a0>] tun_device_event+0x110/0x340
[   72.336032] PGD 7f054f1067 PUD 7ef6f3f067 PMD 0
[   72.340616] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[   72.345498] gsmi: Log Shutdown Reason 0x03
[   72.349541] Modules linked in: w1_therm wire cdc_acm ehci_pci
ehci_hcd mlx4_en ib_uverbs mlx4_ib ib_core mlx4_core
[   72.359870] CPU: 12 PID: 7820 Comm: set.ixion-haswe Not tainted
4.7.0-dbx-DEV #10
[   72.360253] mlx4_en: eth0: Link Up
[   72.370618] Hardware name: Intel Grantley,Wellsburg/Ixion_IT_15,
BIOS 2.50.0 01/21/2016
[   72.378525] task: ffff883f2501e8c0 ti: ffff883f3ef08000 task.ti:
ffff883f3ef08000
[   72.385917] RIP: 0010:[<ffffffff8153c1a0>]  [<ffffffff8153c1a0>]
tun_device_event+0x110/0x340
[   72.394353] RSP: 0018:ffff883f3ef0bbe8  EFLAGS: 00010202
[   72.399599] RAX: fffffffffffffae8 RBX: ffff887ef9883378 RCX: 0000000000000000
[   72.406647] RDX: 0000000000000000 RSI: 0000000000000028 RDI: 0000000000000000
[   72.413694] RBP: ffff883f3ef0bc58 R08: 0000000000000000 R09: 0000000000000001
[   72.420742] R10: 0000000000000004 R11: 0000000000000000 R12: 0000000000000010
[   72.427789] R13: 0000000000000000 R14: 0000000000000001 R15: ffff883f3ef0bd10
[   72.434837] FS:  00007fac4e5dd700(0000) GS:ffff883f7f700000(0000)
knlGS:0000000000000000
[   72.442832] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   72.448507] CR2: 0000000000000010 CR3: 0000007ef66ac000 CR4: 00000000001406e0
[   72.455555] Stack:
[   72.457541]  ffff883f3ef0bc18 0000000000000246 000000000000001e
ffff887ef9880000
[   72.464880]  ffff883f3ef0bd10 0000000000000000 0000000000000000
ffffffff00000000
[   72.472219]  ffff883f3ef0bc58 ffffffff81d24070 00000000fffffff9
ffffffff81cec7a0
[   72.479559] Call Trace:
[   72.481986]  [<ffffffff810eeb0d>] notifier_call_chain+0x5d/0x80
[   72.487844]  [<ffffffff816365c0>] ? show_tx_maxrate+0x30/0x30
[   72.493520]  [<ffffffff810eeb3e>] __raw_notifier_call_chain+0xe/0x10
[   72.499801]  [<ffffffff810eeb56>] raw_notifier_call_chain+0x16/0x20
[   72.506001]  [<ffffffff8160eb30>] call_netdevice_notifiers_info+0x40/0x70
[   72.512706]  [<ffffffff8160ec36>] call_netdevice_notifiers+0x16/0x20
[   72.518986]  [<ffffffff816365f8>] change_tx_queue_len+0x38/0x80
[   72.524838]  [<ffffffff816381cf>] netdev_store.isra.5+0xbf/0xd0
[   72.530688]  [<ffffffff81638330>] tx_queue_len_store+0x50/0x60
[   72.536459]  [<ffffffff814a6798>] dev_attr_store+0x18/0x30
[   72.541888]  [<ffffffff812ea3ff>] sysfs_kf_write+0x4f/0x70
[   72.547306]  [<ffffffff812e9507>] kernfs_fop_write+0x147/0x1d0
[   72.553077]  [<ffffffff81134a4f>] ? rcu_read_lock_sched_held+0x8f/0xa0
[   72.559534]  [<ffffffff8125a108>] __vfs_write+0x28/0x120
[   72.564781]  [<ffffffff8111b137>] ? percpu_down_read+0x57/0x90
[   72.570542]  [<ffffffff8125d7d8>] ? __sb_start_write+0xc8/0xe0
[   72.576303]  [<ffffffff8125d7d8>] ? __sb_start_write+0xc8/0xe0
[   72.582063]  [<ffffffff8125bd5e>] vfs_write+0xbe/0x1b0
[   72.587138]  [<ffffffff8125c092>] SyS_write+0x52/0xa0
[   72.592135]  [<ffffffff817528a5>] entry_SYSCALL_64_fastpath+0x18/0xa8
[   72.598497] Code: 45 31 f6 48 8b 93 78 33 00 00 48 81 c3 78 33 00
00 48 39 d3 48 8d 82 e8 fa ff ff 74 25 48 8d b0 40 05 00 00 49 63 d6
41 83 c6 01 <49> 89 34 d4 48 8b 90 18 05 00 00 48 39 d3 48 8d 82 e8 fa
ff ff
[   72.617767] RIP  [<ffffffff8153c1a0>] tun_device_event+0x110/0x340
[   72.623883]  RSP <ffff883f3ef0bbe8>
[   72.627327] CR2: 0000000000000010
[   72.630638] ---[ end trace b0c54137cf861b91 ]---
