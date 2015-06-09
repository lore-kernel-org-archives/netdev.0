From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: net-next: Panic in switchdev_port_attr_set_work+0x50/0x60
Date: Tue, 9 Jun 2015 09:03:10 -0700
Message-ID: <CAE4R7bCmNTgvH9ZcDrWurX8b+v1BDwPqjdJiW3b=UODNoMy_ug@mail.gmail.com>
References: <CAMUH3-VJDyBr=7DyUJ+O_yo7wwR5bKSbUKZv0QtzPiZPYdDgFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:35318 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbbFIQDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 12:03:31 -0400
Received: by qgg3 with SMTP id 3so7282668qgg.2
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 09:03:30 -0700 (PDT)
In-Reply-To: <CAMUH3-VJDyBr=7DyUJ+O_yo7wwR5bKSbUKZv0QtzPiZPYdDgFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 8, 2015 at 10:04 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> Hi netdev!
>
> I am running a net-next kernel, compiled this morning, git hash of
> 6508060232ee78200a2258aefeeb148ce9ed1526. The distro is Arch linux latest.
> The
> issue is reproducible 100% of the time. I create a new Libvirt VM with some
> default options, no storage (i.e. 1 core, 1GB ram, PXE boot, 1 vNIC). As
> soon as
> I launch the VM, I hit this panic.
>
> If, however, I remove the vNIC from the configuration, there is no issue.
> The
> vNIC is configured to attach to the default libvirt bridge (virbr0).
>
> The below kernel panic is transcribed from a photo, so there is possibility
> of
> minor transcription errors. Apologies if so, and especially sorry that the
> full
> panic dump is not captured. I can try to reproduce and capture a more full
> trace
> if required.
>
> =============== snip ==============
> Workqueue: events switchdev_port_attr_set_work
> task: ffff8808070b8a30 ti: ffff880807f10000 task.ti: ffff880807f10000
> RIP: 0010:[<ffffffff815830b0>] [<ffffffff815830b0>]
> switchdev_port_attr_set_work+0x50/0x60
> RSP: 0018:ffff880807f13de8  EFLAGS: 00010282
> RAX: 00000000ffffffa1 RBX: ffff8808078028a0 RCX: ffff88082ecd5818
> RDX: 0000000000000000 RSI: ffff880807f13d78 RDI: ffff8807ff3f40c0
> RBP: ffff880807f13df8 R08: ffff88082ecd5800 R09: 0000000000000018
> R10: 00000000ffffffff R11: 0000000000021f2a R12: ffff88082ecd5800
> R13: ffff88082ecda200 R14: 0000000000000000 R15: ffff8808078028a0
> FS:  0000000000000000(0000) GS:ffff88082ecc0000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f7e79fc1000 CR3: 0000000002a0b000 CR4: 00000000001427e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Stack:
>  ffff880807626840 ffff880807626840 ffff880807f13e48 ffffffff81091abb
>  ffff88082ecd5800 0000000000000000 ffff88082ecd5818 ffff880807626870
>  ffff88082ecd5800 0000000000000008 ffff88082ecd5818 ffff880807626840
> Call Trace:
>  [<ffffffff81091abb>] process_one_work+0x14b/0x470
>  [<ffffffff81091e28>] worker_thread+0x48/0x4c0
>  [<ffffffff81091de0>] ? process_one_work+0x470/0x470
>  [<ffffffff81091de0>] ? process_one_work+0x470/0x470
>  [<ffffffff81097978>] kthread+0xd8/0xf0
>  [<ffffffff810978a0>] ? kthread_worker_fn+0x170/0x170
>  [<ffffffff81594ca2>] ret_from_fork+0x42/0x70
>  [<ffffffff810978a0>] ? kthread_worker_fn+0x170/0x170
> Code: 75 29 e8 f4 62 f1 ff 48 8b 43 20 48 89 df 48 8b 80 48 04 00 00 65 ff
> 08 e8 ae 44 c4 ff 48 83 c4 08 5b 5d c3 0f 1f 80 00 00 00 00 <0f> 0b 0f 1f 40
> 00 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00
> RIP  [<ffffffff815830b0>] switchdev_port_attr_set_work+0x50/0x60
>  RSP <ffff880807f13de8>
> ---[ end trace x246aa5718676503 ]---
> Kernel panic - not syncing: Fatal exception
> Kernel Offset: disabled
> =============== end snip ==============

Hi Brenden, I think I see the problem.  Would you try this patch on
net/switchdev/switchdev.c and report back?

@@ -103,7 +105,7 @@ static void switchdev_port_attr_set_work(struct
work_struct *work)

        rtnl_lock();
        err = switchdev_port_attr_set(asw->dev, &asw->attr);
-       BUG_ON(err);
+       BUG_ON(err && err != -EOPNOTSUPP);
        rtnl_unlock();
