From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5: net_device.addr_list_lock usage before initialization
Date: Tue, 13 Dec 2016 16:48:44 +0200
Message-ID: <CALzJLG9_Yvhw50Q4u62oqyoXEkqykUmdqxqZ8_W09AKaCoiO1Q@mail.gmail.com>
References: <alpine.LFD.2.20.1612131405080.4914@schleppi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35677 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933116AbcLMOtH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 09:49:07 -0500
Received: by mail-lf0-f43.google.com with SMTP id b14so28761566lfg.2
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 06:49:06 -0800 (PST)
In-Reply-To: <alpine.LFD.2.20.1612131405080.4914@schleppi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 3:22 PM, Sebastian Ott
<sebott@linux.vnet.ibm.com> wrote:
> Hi,
>
> I ran into the following lockdep complaint:
>
> [    7.059561] INFO: trying to register non-static key.
> [    7.059566] the code is fine but needs lockdep annotation.
> [    7.059570] turning off the locking correctness validator.
> [    7.059579] CPU: 6 PID: 6 Comm: kworker/u32:0 Not tainted 4.9.0-02683-g784243e-dirty #77
> [    7.059582] Hardware name: IBM              2964 N96              704              (LPAR)
> [    7.061260] Workqueue: mlx5e mlx5e_set_rx_mode_work [mlx5_core]
> [    7.061268] Stack:
> [    7.061270]        00000000f95739c0 00000000f9573a50 0000000000000003 0000000000000000
> [    7.061278]        00000000f9573af0 00000000f9573a68 00000000f9573a68 0000000000000020
> [    7.061286]        0000000000000000 0000000000000020 000000000000000a 000000000000000a
> [    7.061294]        000000000000000c 00000000f9573ab8 0000000000000000 0000000000000000
> [    7.061301]        00000000008a1038 0000000000112a50 00000000f9573a50 00000000f9573aa8
> [    7.061314] Call Trace:
> [    7.061321] ([<000000000011292a>] show_trace+0x8a/0xe0)
> [    7.061327]  [<0000000000112a00>] show_stack+0x80/0xd8
> [    7.061334]  [<00000000005cdce6>] dump_stack+0x96/0xd8
> [    7.061338]  [<00000000001ae352>] register_lock_class+0x1d2/0x530
> [    7.061341]  [<00000000001b33f6>] __lock_acquire+0xfe/0x7d8
> [    7.061345]  [<00000000001b4394>] lock_acquire+0x30c/0x358
> [    7.061352]  [<000000000089454c>] _raw_spin_lock_bh+0x64/0xa0
> [    7.062171]  [<000003ff81465858>] mlx5e_set_rx_mode_work+0x248/0x490 [mlx5_core]
> [    7.062178]  [<0000000000163864>] process_one_work+0x41c/0x830
> [    7.062181]  [<0000000000163f2c>] worker_thread+0x2b4/0x478
> [    7.062186]  [<000000000016c46c>] kthread+0x15c/0x170
> [    7.062190]  [<0000000000895a52>] kernel_thread_starter+0x6/0xc
> [    7.062193]  [<0000000000895a4c>] kernel_thread_starter+0x0/0xc
> [    7.062196] INFO: lockdep is turned off.
>
> The problematic lock is net_device.addr_list_lock whose usage is
> asynchronously triggered by:
>
> mlx5e_add -> mlx5e_attach -> mlx5e_attach_netdev -> mlx5e_nic_enable
> [workq] mlx5e_set_rx_mode_work -> mlx5e_handle_netdev_addr -> mlx5e_sync_netdev_addr
>
> Initialization of this lock is triggered by:
> mlx5e_add -> register_netdev
>
> ...after the call to mlx5e_attach which is obviously racy.
>

Thanks Sebastian for the report,

indeed there is an issue, I wonder why the net_device.addr_list_lock
is initialized so late (at register_netdevice) IMHO it should be
initialized at
alloc_netdev_mqs->dev_addr_init
where all the other net_device fields are initialized!

We will handle this.

Thanks,
Saeed.
