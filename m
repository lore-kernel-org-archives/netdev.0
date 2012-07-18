From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH v2] net: cgroup: null ptr dereference in netprio cgroup during
	init
Date: Wed, 18 Jul 2012 11:34:09 -0700
Message-ID: <20120718183408.27037.16130.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: davem@davemloft.net, gaofeng@cn.fujitsu.com, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59883 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755338Ab2GRSt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 14:49:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the netprio cgroup is built in the kernel cgroup_init will call
cgrp_create which eventually calls update_netdev_tables. This is
being called before do_initcalls() so a null ptr dereference occurs
on init_net.

This patch adds a check on init_net.count to verify the structure
has been initialized. The failure was introduced here,

commit ef209f15980360f6945873df3cd710c5f62f2a3e
Author: Gao feng <gaofeng@cn.fujitsu.com>
Date:   Wed Jul 11 21:50:15 2012 +0000

    net: cgroup: fix access the unallocated memory in netprio cgroup

Tested with ping with netprio_cgroup as a module and built in.

[    0.256451] Initializing cgroup subsys net_prio
[    0.269948] BUG: unable to handle kernel NULL pointer dereference at
0000000000000698
[    0.293303] IP: [<ffffffff81512e37>] cgrp_create+0x107/0x1c0
[    0.310175] PGD 0
[    0.316157] Oops: 0000 [#1] SMP
[    0.325775] CPU 0
[    0.331227] Modules linked in:
[    0.340846]
[    0.345264] Pid: 0, comm: swapper/0 Not tainted 3.5.0-rc7+ #1 AMD Dinar/Dinar
[    0.366555] RIP: 0010:[<ffffffff81512e37>]  [<ffffffff81512e37>]
cgrp_create+0x107/0x1c0
[    0.390681] RSP: 0000:ffffffff81c01ea8  EFLAGS: 00010213
[    0.406501] RAX: 0000000000000000 RBX: ffffffffffffff10 RCX: 0000000000000000
[    0.427764] RDX: 0000000000000000 RSI: 0000000000000246 RDI: ffffffff81c9d840
[    0.449026] RBP: ffffffff81c01ed8 R08: 00000000000164e0 R09: 0000000000000000
[    0.470289] R10: ffff8804278303c0 R11: 0000000000000000 R12: 0000000000000001
[    0.491553] R13: ffff8804278303c0 R14: ffff881036fd0700 R15: 0000000000000000
[    0.512819] FS:  0000000000000000(0000) GS:ffff880427c00000(0000)
knlGS:0000000000000000
[    0.536932] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.554049] CR2: 0000000000000698 CR3: 0000000001c0b000 CR4: 00000000000406b0
[    0.575311] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    0.596574] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    0.617838] Process swapper/0 (pid: 0, threadinfo ffffffff81c00000, task
ffffffff81c13420)
[    0.642471] Stack:
[    0.648442]  ffffffff81c01eb8 ffffffff81c9f320 ffffffff81c9f320
ffffffff81c9f320
[    0.670522]  ffffffff81c9f320 ffffffff81d482c0 ffffffff81c01ef8
ffffffff81d10397
[    0.692604]  ffffffff81e99790 0000000000000048 ffffffff81c01f18
ffffffff81d1062e
[    0.714687] Call Trace:
[    0.721960]  [<ffffffff81d10397>] cgroup_init_subsys+0x51/0xdf
[    0.739337]  [<ffffffff81d1062e>] cgroup_init+0x36/0x119
[    0.755160]  [<ffffffff81cf5c02>] start_kernel+0x38f/0x3c4
[    0.771501]  [<ffffffff81cf5672>] ? repair_env_string+0x5e/0x5e
[    0.789138]  [<ffffffff81cf5356>] x86_64_start_reservations+0x131/0x135
[    0.808849]  [<ffffffff81cf545a>] x86_64_start_kernel+0x100/0x10f


Reported-by: Mark Rustad <mark.d.rustad@intel.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/net_namespace.c  |    4 +++-
 net/core/netprio_cgroup.c |    3 +++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index dddbacb..faa33bb 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -27,7 +27,9 @@ static DEFINE_MUTEX(net_mutex);
 LIST_HEAD(net_namespace_list);
 EXPORT_SYMBOL_GPL(net_namespace_list);
 
-struct net init_net;
+struct net init_net = {
+	.count = ATOMIC_INIT(0),
+};
 EXPORT_SYMBOL(init_net);
 
 #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index b2e9caa..e9fd7fd 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -116,6 +116,9 @@ static int update_netdev_tables(void)
 	u32 max_len;
 	struct netprio_map *map;
 
+	if (!atomic_read(&init_net.count))
+		return ret;
+
 	rtnl_lock();
 	max_len = atomic_read(&max_prioidx) + 1;
 	for_each_netdev(&init_net, dev) {
