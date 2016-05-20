From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] fou: avoid using sk_user_data before it is initialised
Date: Fri, 20 May 2016 09:51:08 -0700
Message-ID: <CAM_iQpX0326oh8vcqrXO2YrurePykJ0XF9jYCchsyuB7010cdA@mail.gmail.com>
References: <1463723837-9098-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34958 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbcETQv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 12:51:28 -0400
Received: by mail-yw0-f193.google.com with SMTP id n16so2396048ywd.2
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 09:51:28 -0700 (PDT)
In-Reply-To: <1463723837-9098-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 10:57 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> During initialisation sk->sk_user_data should not be used before
> it is initialised.
>
> Found by bisection after noticing the following:
>
> $ ip fou add port 8888 ipproto 47
> [    0.383417] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> [    0.384132] IP: [<ffffffff81327691>] fou_nl_cmd_add_port+0x1e1/0x230
> [    0.384707] PGD 1fafc067 PUD 1fb72067 PMD 0
> [    0.385110] Oops: 0002 [#1] SMP
> [    0.385387] Modules linked in:
> [    0.385667] CPU: 0 PID: 55 Comm: ip Not tainted 4.6.0-03623-g0b7962a6c4a3 #430
> [    0.386244] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [    0.386244] task: ffff88001fb9cac0 ti: ffff88001fbc8000 task.ti: ffff88001fbc8000
> [    0.386244] RIP: 0010:[<ffffffff81327691>]  [<ffffffff81327691>] fou_nl_cmd_add_port+0x1e1/0x230
> [    0.386244] RSP: 0018:ffff88001fbcbb78  EFLAGS: 00010246
> [    0.386244] RAX: 0000000000000001 RBX: ffff88001fb8eb40 RCX: 000000000000002f
> [    0.386244] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880019fcafc0
> [    0.386244] RBP: ffff880019fcaf80 R08: ffffffff8130c370 R09: ffff880019fcaf80
> [    0.386244] R10: ffff880019e12b8c R11: 0000000000000000 R12: 0000000000000004
> [    0.386244] R13: 0000000000000014 R14: ffff88001fb1a300 R15: ffffffff816634c0
> [    0.386244] FS:  00007f016eb4d700(0000) GS:ffff88001a200000(0000) knlGS:0000000000000000
> [    0.386244] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.386244] CR2: 0000000000000008 CR3: 000000001fb69000 CR4: 00000000000006b0
> [    0.386244] Stack:
> [    0.386244]  ffff88001faaea24 ffff8800192426c0 00000002002f0001 0000000000000000
> [    0.386244]  0000000000000000 0000000000000000 0000000000000000 000000000000b822
> [    0.386244]  ffffffff81461480 ffff88001faaea14 0000000000000004 ffffffff812b0e17
> [    0.386244] Call Trace:
> [    0.386244]  [<ffffffff812b0e17>] ? genl_family_rcv_msg+0x197/0x320
> [    0.386244]  [<ffffffff812b0fa0>] ? genl_family_rcv_msg+0x320/0x320
> [    0.386244]  [<ffffffff812b1010>] ? genl_rcv_msg+0x70/0xb0
> [    0.386244]  [<ffffffff812b01c1>] ? netlink_rcv_skb+0xa1/0xc0
> [    0.386244]  [<ffffffff812b0c64>] ? genl_rcv+0x24/0x40
> [    0.386244]  [<ffffffff812afb33>] ? netlink_unicast+0x143/0x1d0
> [    0.386244]  [<ffffffff812affd6>] ? netlink_sendmsg+0x366/0x390
> [    0.386244]  [<ffffffff8110a2a8>] ? rw_copy_check_uvector+0x68/0x110
> [    0.386244]  [<ffffffff8126a030>] ? sock_sendmsg+0x10/0x20
> [    0.386244]  [<ffffffff8126a661>] ? ___sys_sendmsg+0x1f1/0x200
> [    0.386244]  [<ffffffff81110000>] ? pipe_write+0x1a0/0x420
> [    0.386244]  [<ffffffff81116c32>] ? do_filp_open+0x92/0xe0
> [    0.386244]  [<ffffffff8126b541>] ? __sys_sendmsg+0x41/0x70
> [    0.386244]  [<ffffffff8139c81b>] ? entry_SYSCALL_64_fastpath+0x13/0x8f
> [    0.386244] Code: 4c 24 12 48 8b 93 28 02 00 00 48 c7 83 68 03 00 00 e0 76 32 81 48 c7 83 78 03 00 00 50 61 32 81 48 c7 83 80 03 00 00 e0 64 32 81 <88> 4a 08 e9 20 ff ff ff 4c 89 e7 bb 8e ff ff ff e8 1a 34 07 00
> [    0.386244] RIP  [<ffffffff81327691>] fou_nl_cmd_add_port+0x1e1/0x230
> [    0.386244]  RSP <ffff88001fbcbb78>
> [    0.386244] CR2: 0000000000000008
> [    0.407176] ---[ end trace 13bf0d24a4b7f9c3 ]---
>
> Fixes: d92283e338f6 ("fou: change to use UDP socket GRO")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
