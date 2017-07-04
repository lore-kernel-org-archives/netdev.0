From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH 1/2] ipv4: initialize fib_trie prior to register_netdev_notifier call.
Date: Tue,  4 Jul 2017 12:16:20 -0700
Message-ID: <20170704191620.6503-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biederman <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34017 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751960AbdGDTQX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 15:16:23 -0400
Received: by mail-pg0-f67.google.com with SMTP id j186so28406886pge.1
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 12:16:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Net stack initialization currently initializes fib-trie after the
first call to netdevice_notifier() call. It does not cause any problem
since there are no devices UP at this moment, but trying to bring 'lo'
UP at initialization would make this assumption wrong. However changing
order solves the issue.

Fixes following crash

[    8.647095] BUG: unable to handle kernel NULL pointer dereference at 0000000000000014
[    8.654836] IP: kmem_cache_alloc+0xcf/0x1c0
[    8.658966] PGD 0
[    8.658967] P4D 0
[    8.660953]
[    8.664406] Oops: 0000 [#1] SMP
[    8.667505] Modules linked in:
[    8.670519] CPU: 4 PID: 1 Comm: swapper/0 Not tainted 4.12.0-smp-DEV #34
[    8.677138] Hardware name: Intel Grantley,Wellsburg/Ixion_IT_15, BIOS 2.60.0 06/03/2016
[    8.685043] task: ffff8f26b2b00dc0 task.stack: ffff9b1500014000
[    8.690891] RIP: 0010:kmem_cache_alloc+0xcf/0x1c0
[    8.695535] RSP: 0000:ffff9b1500017c28 EFLAGS: 00010246
[    8.700696] RAX: ffffffff96ed4f47 RBX: 0000000000000000 RCX: 0000000000000200
[    8.707743] RDX: 0000000000000400 RSI: 00000000014000c0 RDI: 0000000000000000
[    8.714791] RBP: ffff9b1500017c58 R08: 0000000000000001 R09: 0000000000000000
[    8.721837] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000014000c0
[    8.728886] R13: 00000000014000c0 R14: 0000000000000000 R15: 0000000000000000
[    8.735932] FS:  0000000000000000(0000) GS:ffff8f26bf500000(0000) knlGS:0000000000000000
[    8.743925] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    8.749599] CR2: 0000000000000014 CR3: 0000001d05609000 CR4: 00000000001406e0
[    8.756648] Call Trace:
[    8.759061]  ? alternate_node_alloc+0x76/0xa0
[    8.763364]  fib_table_insert+0x1b7/0x4b0
[    8.767323]  fib_magic.isra.17+0xea/0x120
[    8.771283]  fib_add_ifaddr+0x7b/0x190
[    8.774983]  fib_netdev_event+0xc0/0x130
[    8.778857]  register_netdevice_notifier+0x1c1/0x1d0
[    8.783761]  ip_fib_init+0x72/0x85
[    8.787120]  ip_rt_init+0x187/0x1e9
[    8.790564]  ip_init+0xe/0x1a
[    8.793494]  inet_init+0x171/0x26c
[    8.796851]  ? ipv4_offload_init+0x66/0x66
[    8.800896]  do_one_initcall+0x43/0x160
[    8.804685]  kernel_init_freeable+0x191/0x219
[    8.808987]  ? rest_init+0x80/0x80
[    8.812343]  kernel_init+0xe/0x150
[    8.815702]  ret_from_fork+0x22/0x30
[    8.819229] Code: f6 46 23 04 74 86 4c 89 f7 e8 ae 45 01 00 49 89 c7 4d 85 ff 0f 85 7b ff ff ff 31 db eb 08 4c 89 ff e8 16 47 01 00 48 8b 44 24 38 <45> 8b 6e 14 4d 63 76 74 48 89 04 24 0f 1f 44 00 00 48 83 c4 08
[    8.837882] RIP: kmem_cache_alloc+0xcf/0x1c0 RSP: ffff9b1500017c28
[    8.843986] CR2: 0000000000000014
[    8.847288] ---[ end trace 8fc60994c8a367cb ]---
[    8.851847] Kernel panic - not syncing: Fatal exception
[    8.857035] Rebooting in 10 seconds..

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/ipv4/fib_frontend.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4e678fa892dd..ca22ca47019a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1338,9 +1338,9 @@ void __init ip_fib_init(void)
 	rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL, NULL);
 	rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib, NULL);
 
+	fib_trie_init();
+
 	register_pernet_subsys(&fib_net_ops);
 	register_netdevice_notifier(&fib_netdev_notifier);
 	register_inetaddr_notifier(&fib_inetaddr_notifier);
-
-	fib_trie_init();
 }
-- 
2.13.2.725.g09c95d1e9-goog
