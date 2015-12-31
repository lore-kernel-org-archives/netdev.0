From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/netlink: memory leak in netlink_sendmsg
Date: Thu, 31 Dec 2015 12:51:19 +0100
Message-ID: <CACT4Y+bKYO2XfY74tgUiOC7WotQ8DRBcMT=2yy3S=Ubz8bnj_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

The following program causes leak on 2 objects allocated in netlink_sendmsg:

https://gist.githubusercontent.com/dvyukov/e840d00cfefe66c5e064/raw/6e5343a936bd3edd1b0803941cf7c1427050d9a5/gistfile1.txt

unreferenced object 0xffff880014f54840 (size 224):
  comm "a.out", pid 11468, jiffies 4301602943 (age 29.985s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 10 3b 9d 3d 00 88 ff ff  .........;.=....
  backtrace:
    [<     inline     >] kmemleak_alloc_recursive include/linux/kmemleak.h:47
    [<     inline     >] slab_post_alloc_hook mm/slub.c:1335
    [<     inline     >] slab_alloc_node mm/slub.c:2594
    [<ffffffff816cc44d>] kmem_cache_alloc_node+0x16d/0x2e0 mm/slub.c:2630
    [<ffffffff84b782ba>] __alloc_skb+0xba/0x5f0 net/core/skbuff.c:216
    [<     inline     >] alloc_skb include/linux/skbuff.h:814
    [<     inline     >] netlink_alloc_large_skb net/netlink/af_netlink.c:1695
    [<ffffffff84cfd4b4>] netlink_sendmsg+0xfd4/0x1760
net/netlink/af_netlink.c:2486
    [<     inline     >] sock_sendmsg_nosec net/socket.c:610
    [<ffffffff84b5cc5a>] sock_sendmsg+0xca/0x110 net/socket.c:620
    [<ffffffff84b5e689>] ___sys_sendmsg+0x309/0x840 net/socket.c:1946
    [<ffffffff84b60c94>] __sys_sendmmsg+0x134/0x330 net/socket.c:2031
    [<     inline     >] SYSC_sendmmsg net/socket.c:2059
    [<ffffffff84b60ec5>] SyS_sendmmsg+0x35/0x60 net/socket.c:2054
    [<ffffffff85c8eaf6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
unreferenced object 0xffff880014facf60 (size 512):
  comm "a.out", pid 11468, jiffies 4301602943 (age 29.985s)
  hex dump (first 32 bytes):
    48 ea fa 14 00 88 ff ff 00 00 00 00 ad 4e ad de  H............N..
    ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
  backtrace:
    [<     inline     >] kmemleak_alloc_recursive include/linux/kmemleak.h:47
    [<     inline     >] slab_post_alloc_hook mm/slub.c:1335
    [<     inline     >] slab_alloc_node mm/slub.c:2594
    [<ffffffff816d0b77>] __kmalloc_node_track_caller+0x217/0x3e0 mm/slub.c:4096
    [<ffffffff84b75f71>] __kmalloc_reserve.isra.31+0x41/0xe0
net/core/skbuff.c:135
    [<ffffffff84b782f0>] __alloc_skb+0xf0/0x5f0 net/core/skbuff.c:228
    [<     inline     >] alloc_skb include/linux/skbuff.h:814
    [<     inline     >] netlink_alloc_large_skb net/netlink/af_netlink.c:1695
    [<ffffffff84cfd4b4>] netlink_sendmsg+0xfd4/0x1760
net/netlink/af_netlink.c:2486
    [<     inline     >] sock_sendmsg_nosec net/socket.c:610
    [<ffffffff84b5cc5a>] sock_sendmsg+0xca/0x110 net/socket.c:620
    [<ffffffff84b5e689>] ___sys_sendmsg+0x309/0x840 net/socket.c:1946
    [<ffffffff84b60c94>] __sys_sendmmsg+0x134/0x330 net/socket.c:2031
    [<     inline     >] SYSC_sendmmsg net/socket.c:2059
    [<ffffffff84b60ec5>] SyS_sendmmsg+0x35/0x60 net/socket.c:2054
    [<ffffffff85c8eaf6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

On commit 8513342170278468bac126640a5d2d12ffbff106 (Dec 28).
