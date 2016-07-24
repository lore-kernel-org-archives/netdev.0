From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] netfilter: x_tables: fix kmemcheck warning.
Date: Sun, 24 Jul 2016 11:31:15 +0900
Message-ID: <1469327475-9028-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Cc: netdev@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:29078 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbcGXCbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 22:31:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kmemcheck complains that some of struct nf_hook_ops members allocated at
xt_hook_ops_alloc() are not initialized before nf_register_net_hook() is
called. Add __GFP_ZERO to initialize explicitly.

[  367.411936] nf_conntrack version 0.5.0 (6144 buckets, 24576 max)
[  367.458540] ip_tables: (C) 2000-2006 Netfilter Core Team
[  367.463977] WARNING: kmemcheck: Caught 64-bit read from uninitialized memory (ffff88003af7f300)
[  367.465633] 00000000000000000000000000000000303f5381ffffffff0000000000000000
[  367.468185]  u u u u u u u u u u u u u u u u i i i i i i i i u u u u u u u u
[  367.470687]  ^
[  367.471079] RIP: 0010:[<ffffffff814caa0f>]  [<ffffffff814caa0f>] nf_register_net_hook+0x2f/0x160
[  367.472846] RSP: 0018:ffff88003f5abcb0  EFLAGS: 00010286
[  367.473821] RAX: ffff88003adb73c0 RBX: ffff88003af7f300 RCX: 0000000000000000
[  367.475122] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff88003adb7400
[  367.476485] RBP: ffff88003f5abcc8 R08: 0000000000000067 R09: 0000000000000000
[  367.477764] R10: ffff88003adb83c0 R11: 0000000000000000 R12: ffffffff81876760
[  367.479053] R13: ffff88003adb73c0 R14: 0000000000000003 R15: ffff88003af7f300
[  367.480351] FS:  0000000000000000(0000) GS:ffffffff8182c000(0000) knlGS:0000000000000000
[  367.482018] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  367.483069] CR2: ffff88003f404280 CR3: 000000003ad30000 CR4: 00000000001406f0
[  367.484357]  [<ffffffff814cadec>] nf_register_net_hooks+0x3c/0xa0
[  367.485617]  [<ffffffff8153328f>] ipt_register_table+0xef/0x130
[  367.486765]  [<ffffffff81533ec1>] iptable_filter_table_init.part.1+0x51/0x70
[  367.488125]  [<ffffffff81533f2a>] iptable_filter_net_init+0x2a/0x30
[  367.489375]  [<ffffffff8148f58c>] ops_init+0x3c/0x130
[  367.490410]  [<ffffffff8148f8c8>] register_pernet_operations+0x108/0x1c0
[  367.491746]  [<ffffffff8148f9a3>] register_pernet_subsys+0x23/0x40
[  367.492933]  [<ffffffff818d5e25>] iptable_filter_init+0x33/0x4b
[  367.494053]  [<ffffffff8100041a>] do_one_initcall+0x4a/0x180
[  367.495168]  [<ffffffff818981d0>] kernel_init_freeable+0x15b/0x201
[  367.496332]  [<ffffffff8159eff9>] kernel_init+0x9/0x100
[  367.497369]  [<ffffffff815a9c0f>] ret_from_fork+0x1f/0x40
[  367.498449]  [<ffffffffffffffff>] 0xffffffffffffffff
[  367.499523] Initializing XFRM netlink socket
[  367.500404] NET: Registered protocol family 10
[  367.501792] ip6_tables: (C) 2000-2006 Netfilter Core Team
[  367.502971] NET: Registered protocol family 17

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/netfilter/x_tables.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index e0aa7c1..fc261fe 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1513,7 +1513,7 @@ xt_hook_ops_alloc(const struct xt_table *table, nf_hookfn *fn)
 	if (!num_hooks)
 		return ERR_PTR(-EINVAL);
 
-	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
+	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL | __GFP_ZERO);
 	if (ops == NULL)
 		return ERR_PTR(-ENOMEM);
 
-- 
1.8.3.1
