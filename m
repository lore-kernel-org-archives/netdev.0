From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Mon, 13 Feb 2017 16:17:12 +0100
Message-ID: <CACT4Y+bdZRYC5EyifuqBQWNNZ-sHBDXyVBvnzPCq8eg4-SHJ9Q@mail.gmail.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
 <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
 <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486697003.7793.121.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXHktH+Wo7GtJC4afY_Wm11PpKcNFx41f_x4Vs93J-bMA@mail.gmail.com>
 <1486749566.7793.150.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486749763.7793.152.camel@edumazet-glaptop3.roam.corp.google.com> <20170213014239.GA21934@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Anoob Soman <anoob.soman@citrix.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        Philip Pettersson <philip.pettersson@gmail.com>,
        weongyo.linux@gmail.com, netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:35878 "EHLO
        mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752243AbdBMPRe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 10:17:34 -0500
Received: by mail-vk0-f54.google.com with SMTP id t8so62312790vke.3
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 07:17:33 -0800 (PST)
In-Reply-To: <20170213014239.GA21934@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 2:42 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (02/10/17 10:02), Eric Dumazet wrote:
>> At least, Anoob patch is making a step into the right direction ;)
>> https://patchwork.ozlabs.org/patch/726532/
>
> I've not been able to reproduce Dmitry's panic (though I did not try
> very hard either) but there's a call to fanout_release from packet_release
> before the synchronize_net() - I wonder if this could end up kfree'ing f
> when there are threads in the middle of dev_queue_xmit_nit().


Another similar one:

BUG: KASAN: use-after-free in fanout_demux_rollover+0x681/0x6b0
net/packet/af_packet.c:1387 at addr ffff8801cf083df0
Read of size 8 by task syz-executor1/21190
CPU: 1 PID: 21190 Comm: syz-executor1 Not tainted 4.9.0 #7
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff8801c2616850 ffffffff8234ce1f ffffffff00000001 1ffff100384c2c9d
 ffffed00384c2c95 0000000041b58ab3 ffffffff84b38258 ffffffff8234cb31
 ffffe8ffffd2b3b8 0000000000000000 ffffffff84aef298 ffffffff8155e0a0
Call Trace:
 [<ffffffff8234ce1f>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff8234ce1f>] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 [<ffffffff819e242c>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
 [<ffffffff819e26c5>] print_address_description mm/kasan/report.c:200 [inline]
 [<ffffffff819e26c5>] kasan_report_error mm/kasan/report.c:289 [inline]
 [<ffffffff819e26c5>] kasan_report.part.2+0x1e5/0x4b0 mm/kasan/report.c:311
 [<ffffffff819e2a49>] kasan_report mm/kasan/report.c:332 [inline]
 [<ffffffff819e2a49>] __asan_report_load8_noabort+0x29/0x30
mm/kasan/report.c:332
 [<ffffffff83acaf61>] fanout_demux_rollover+0x681/0x6b0
net/packet/af_packet.c:1387
 [<ffffffff83ad35fe>] packet_rcv_fanout+0x56e/0x800 net/packet/af_packet.c:1473
 [<ffffffff8357b9ea>] dev_queue_xmit_nit+0x73a/0xa90 net/core/dev.c:1904
 [<ffffffff8358d78b>] xmit_one net/core/dev.c:2910 [inline]
 [<ffffffff8358d78b>] dev_hard_start_xmit+0x16b/0xab0 net/core/dev.c:2930
 [<ffffffff8358fac4>] __dev_queue_xmit+0x16e4/0x1e70 net/core/dev.c:3391
 [<ffffffff83590267>] dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
 [<ffffffff8373771e>] neigh_hh_output include/net/neighbour.h:468 [inline]
 [<ffffffff8373771e>] dst_neigh_output include/net/dst.h:462 [inline]
 [<ffffffff8373771e>] ip_finish_output2+0xf0e/0x1520 net/ipv4/ip_output.c:224
 [<ffffffff8373b659>] ip_finish_output+0x909/0xc60 net/ipv4/ip_output.c:305
 [<ffffffff837402b7>] NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 [<ffffffff837402b7>] ip_output+0x1f7/0x860 net/ipv4/ip_output.c:379
 [<ffffffff8373c2c5>] dst_output include/net/dst.h:501 [inline]
 [<ffffffff8373c2c5>] ip_local_out+0x95/0x170 net/ipv4/ip_output.c:123
 [<ffffffff8374348c>] ip_send_skb+0x3c/0xc0 net/ipv4/ip_output.c:1461
 [<ffffffff83743574>] ip_push_pending_frames+0x64/0x80 net/ipv4/ip_output.c:1481
 [<ffffffff838102b0>] raw_sendmsg+0x19c0/0x2070 net/ipv4/raw.c:650
 [<ffffffff83857370>] inet_sendmsg+0x380/0x580 net/ipv4/af_inet.c:734
 [<ffffffff834f6aaa>] sock_sendmsg_nosec net/socket.c:621 [inline]
 [<ffffffff834f6aaa>] sock_sendmsg+0xca/0x110 net/socket.c:631
 [<ffffffff834f82f0>] SYSC_sendto+0x660/0x810 net/socket.c:1656
 [<ffffffff834fb260>] SyS_sendto+0x40/0x50 net/socket.c:1624
 [<ffffffff843778c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Object at ffff8801cf0836c0, in cache kmalloc-2048 size: 2048
Allocated:
PID = 21136
 [  142.233815] [<ffffffff8129c696>] save_stack_trace+0x16/0x20
arch/x86/kernel/stacktrace.c:57
 [  142.241057] [<ffffffff819e16c3>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
 [  142.247780] [<ffffffff819e194a>] set_track mm/kasan/kasan.c:507 [inline]
 [  142.247780] [<ffffffff819e194a>] kasan_kmalloc+0xaa/0xd0
mm/kasan/kasan.c:598
 [  142.254778] [<ffffffff819dcf2c>] __do_kmalloc mm/slab.c:3737 [inline]
 [  142.254778] [<ffffffff819dcf2c>] __kmalloc+0x12c/0x690 mm/slab.c:3746
 [  142.261585] [<ffffffff83501881>] kmalloc include/linux/slab.h:497 [inline]
 [  142.261585] [<ffffffff83501881>] sk_prot_alloc+0x101/0x2a0
net/core/sock.c:1333
 [  142.268791] [<ffffffff8350a20c>] sk_alloc+0x8c/0x460 net/core/sock.c:1389
 [  142.275425] [<ffffffff83ac9673>] packet_create+0x163/0xb00
net/packet/af_packet.c:3181
 [  142.282590] [<ffffffff834f9f24>] __sock_create+0x4e4/0x870 net/socket.c:1168
 [  142.289754] [<ffffffff834fa4e9>] sock_create net/socket.c:1208 [inline]
 [  142.289754] [<ffffffff834fa4e9>] SYSC_socket net/socket.c:1238 [inline]
 [  142.289754] [<ffffffff834fa4e9>] SyS_socket+0xf9/0x230 net/socket.c:1218
 [  142.296558] [<ffffffff843778c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 21163
 [  142.309281] [<ffffffff8129c696>] save_stack_trace+0x16/0x20
arch/x86/kernel/stacktrace.c:57
 [  142.316556] [<ffffffff819e16c3>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
 [  142.323282] [<ffffffff819e1fbf>] set_track mm/kasan/kasan.c:507 [inline]
 [  142.323282] [<ffffffff819e1fbf>] kasan_slab_free+0x6f/0xb0
mm/kasan/kasan.c:571
 [  142.330450] [<ffffffff819dfeb3>] __cache_free mm/slab.c:3515 [inline]
 [  142.330450] [<ffffffff819dfeb3>] kfree+0xd3/0x250 mm/slab.c:3832
 [  142.336840] [<ffffffff83505615>] sk_prot_free net/core/sock.c:1372 [inline]
 [  142.336840] [<ffffffff83505615>] __sk_destruct+0x5a5/0x6a0
net/core/sock.c:1445
 [  142.344013] [<ffffffff8350fa77>] sk_destruct+0x47/0x80 net/core/sock.c:1453
 [  142.350819] [<ffffffff8350fb07>] __sk_free+0x57/0x230 net/core/sock.c:1461
 [  142.357535] [<ffffffff8350fd03>] sk_free+0x23/0x30 net/core/sock.c:1472
 [  142.364024] [<ffffffff83ace53c>] sock_put include/net/sock.h:1591 [inline]
 [  142.364024] [<ffffffff83ace53c>] packet_release+0x7ac/0x970
net/packet/af_packet.c:3021
 [  142.371267] [<ffffffff834f258d>] sock_release+0x8d/0x1e0 net/socket.c:585
 [  142.378247] [<ffffffff834f26f6>] sock_close+0x16/0x20 net/socket.c:1032
 [  142.384968] [<ffffffff81a34772>] __fput+0x332/0x7f0 fs/file_table.c:208
 [  142.391512] [<ffffffff81a34cb5>] ____fput+0x15/0x20 fs/file_table.c:244
 [  142.398088] [<ffffffff814a58ca>] task_work_run+0x18a/0x260
kernel/task_work.c:116
 [  142.405266] [<ffffffff8142ff8f>] exit_task_work
include/linux/task_work.h:21 [inline]
 [  142.405266] [<ffffffff8142ff8f>] do_exit+0x18ef/0x2890 kernel/exit.c:830
 [  142.412090] [<ffffffff81435989>] do_group_exit+0x149/0x420 kernel/exit.c:934
 [  142.419243] [<ffffffff81465120>] get_signal+0x7e0/0x1820
kernel/signal.c:2307
 [  142.426220] [<ffffffff812665a2>] do_signal+0xd2/0x2120
arch/x86/kernel/signal.c:807
 [  142.433057] [<ffffffff81007900>] exit_to_usermode_loop+0x200/0x2a0
arch/x86/entry/common.c:156
 [  142.440908] [<ffffffff81009413>] prepare_exit_to_usermode
arch/x86/entry/common.c:190 [inline]
 [  142.440908] [<ffffffff81009413>]
syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
 [  142.448950] [<ffffffff84377962>] entry_SYSCALL_64_fastpath+0xc0/0xc2
Memory state around the buggy address:
 ffff8801cf083c80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801cf083d00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff8801cf083d80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                                             ^
 ffff8801cf083e00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801cf083e80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
==================================================================
