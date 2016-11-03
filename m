From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/netlink: another global-out-of-bounds in genl_family_rcv_msg/validate_nla
Date: Fri, 4 Nov 2016 00:04:26 +0100
Message-ID: <CAAeHK+yzXs-JTNpEuEWyHZpJvfWHb5poP--M-vYTs-oQhQFdBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        Florian Westphal <fw@strlen.de>,
        netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while running the syzkaller fuzzer:

BUG: KASAN: global-out-of-bounds in validate_nla+0x49b/0x4e0 at addr
ffffffff84452de0
Read of size 2 by task syz-executor/19055
Address belongs to variable ip_vs_cmd_policy+0x20/0x40
CPU: 1 PID: 19055 Comm: syz-executor Not tainted 4.9.0-rc3+ #350
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88006b547638 ffffffff81b46934 ffff88006b5476c8 ffffffff847a361f
 ffffffff84452dc0 ffffffff84452de0 ffff88006b5476b8 ffffffff8150ac7c
 ffffffff859bdf80 ffffffff85f44280 ffff88003df282c0 0000000000000292
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b46934>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<     inline     >] print_address_description mm/kasan/report.c:204
 [<ffffffff8150ac7c>] kasan_report_error+0x49c/0x4d0 mm/kasan/report.c:283
 [<     inline     >] kasan_report mm/kasan/report.c:303
 [<ffffffff8150ad2e>] __asan_report_load2_noabort+0x3e/0x40
mm/kasan/report.c:322
 [<ffffffff81be27eb>] validate_nla+0x49b/0x4e0 lib/nlattr.c:41
 [<ffffffff81be2ab5>] nla_parse+0x115/0x280 lib/nlattr.c:195
 [<     inline     >] nlmsg_parse include/net/netlink.h:386
 [<ffffffff82dc2723>] genl_family_rcv_msg+0x543/0xc80
net/netlink/genetlink.c:613
 [<ffffffff82dc3016>] genl_rcv_msg+0x1b6/0x270 net/netlink/genetlink.c:658
 [<ffffffff82dc10a0>] netlink_rcv_skb+0x2c0/0x3b0 net/netlink/af_netlink.c:2281
 [<ffffffff82dc21c8>] genl_rcv+0x28/0x40 net/netlink/genetlink.c:669
 [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
 [<ffffffff82dbf959>] netlink_unicast+0x5a9/0x880 net/netlink/af_netlink.c:1240
 [<ffffffff82dc05e7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
 [<     inline     >] sock_sendmsg_nosec net/socket.c:606
 [<ffffffff82b6f75c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
 [<ffffffff82b6f9c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
 [<     inline     >] new_sync_write fs/read_write.c:499
 [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
 [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
 [<     inline     >] SYSC_write fs/read_write.c:607
 [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
 [<ffffffff81006465>] do_syscall_64+0x195/0x490 arch/x86/entry/common.c:280
 [<ffffffff83fc0409>] entry_SYSCALL64_slow_path+0x25/0x25
Memory state around the buggy address:
 ffffffff84452c80: fa fa fa fa 00 00 00 00 00 00 04 fa fa fa fa fa
 ffffffff84452d00: 00 00 00 00 00 00 04 fa fa fa fa fa 00 00 00 00
>ffffffff84452d80: 04 fa fa fa fa fa fa fa 00 00 00 04 fa fa fa fa
                                                       ^
 ffffffff84452e00: 00 fa fa fa fa fa fa fa 00 00 fa fa fa fa fa fa
 ffffffff84452e80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================

This time the out-of-bounds is on the ip_vs_cmd_policy variable.

On commit 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).

Thanks!
