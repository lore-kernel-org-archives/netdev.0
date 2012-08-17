From: Fan Du <fan.du@windriver.com>
Subject: [PATCH] xfrm:Use rcu_dereference_bh to deference pointer protected by rcu_read_lock_bh
Date: Fri, 17 Aug 2012 14:19:09 +0800
Message-ID: <1345184349-5849-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49505 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab2HQGTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 02:19:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

418a99ac6ad487dc9c42e6b0e85f941af56330f2 "Replace rwlock on xfrm_policy_afinfo with rcu"
triggers below warnings, which is caused by abusing rcu_dereference_bh with rcu_read_lock.

RCU rules must be honored:
 - rcu_dereference_bh paired with rcu_read_lock_bh/rcu_read_unlock_bh
 - rcu_dereference  paired with rcu_read_lock/rcu_read_unlock

[    0.921216]
[    0.921645] ===============================
[    0.922766] [ INFO: suspicious RCU usage. ]
[    0.923887] 3.5.0-01540-g1669891 #64 Not tainted
[    0.925123] -------------------------------
[    0.932860] /c/kernel-tests/src/tip/net/xfrm/xfrm_policy.c:2504 suspicious rcu_dereference_check() usage!
[    0.935361]
[    0.935361] other info that might help us debug this:
[    0.935361]
[    0.937472]
[    0.937472] rcu_scheduler_active = 1, debug_locks = 0
[    0.939182] 2 locks held by swapper/1:
[    0.940171]  #0:  (net_mutex){+.+.+.}, at: [<ffffffff814e1ad0>] register_pernet_subsys+0x21/0x57
[    0.942705]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff822c7329>] xfrm_net_init+0x1e4/0x437
[    0.951507]
[    0.951507] stack backtrace:
[    0.952660] Pid: 1, comm: swapper Not tainted 3.5.0-01540-g1669891 #64
[    0.954364] Call Trace:
[    0.955074]  [<ffffffff8108b375>] lockdep_rcu_suspicious+0x174/0x187
[    0.956736]  [<ffffffff822c7453>] xfrm_net_init+0x30e/0x437
[    0.958205]  [<ffffffff822c7329>] ? xfrm_net_init+0x1e4/0x437
[    0.959712]  [<ffffffff814e134a>] ops_init+0x1bb/0x1ff
[    0.961067]  [<ffffffff810861f9>] ? trace_hardirqs_on+0x1b/0x24
[    0.962644]  [<ffffffff814e17cd>] register_pernet_operations.isra.5+0x9d/0xfe
[    0.971376]  [<ffffffff814e1adf>] register_pernet_subsys+0x30/0x57
[    0.972992]  [<ffffffff822c7130>] xfrm_init+0x17/0x2c
[    0.974316]  [<ffffffff822c2f8c>] ip_rt_init+0x82/0xe7
[    0.975668]  [<ffffffff822c31dc>] ip_init+0x10/0x25
[    0.976952]  [<ffffffff822c3f77>] inet_init+0x235/0x360
[    0.978352]  [<ffffffff822c3d42>] ? devinet_init+0xf2/0xf2
[    0.979808]  [<ffffffff82283252>] do_one_initcall+0xb4/0x203
[    0.981313]  [<ffffffff8228354a>] kernel_init+0x1a9/0x29a
[    0.982732]  [<ffffffff822826d9>] ? loglevel+0x46/0x46
[    0.990889]  [<ffffffff816d3d84>] kernel_thread_helper+0x4/0x10
[    0.992472]  [<ffffffff816d262c>] ? retint_restore_args+0x13/0x13
[    0.994076]  [<ffffffff822833a1>] ? do_one_initcall+0x203/0x203
[    0.995636]  [<ffffffff816d3d80>] ? gs_change+0x13/0x13
[    0.997197] TCP established hash table entries: 8192 (order: 5, 131072 bytes)
[    1.000074] TCP bind hash table entries: 8192 (order: 7, 655360 bytes)

Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Tested-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 5ad4d2c..6405764 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2501,11 +2501,11 @@ static void __net_init xfrm_dst_ops_init(struct net *net)
 	struct xfrm_policy_afinfo *afinfo;
 
 	rcu_read_lock_bh();
-	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET]);
+	afinfo = rcu_dereference_bh(xfrm_policy_afinfo[AF_INET]);
 	if (afinfo)
 		net->xfrm.xfrm4_dst_ops = *afinfo->dst_ops;
 #if IS_ENABLED(CONFIG_IPV6)
-	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET6]);
+	afinfo = rcu_dereference_bh(xfrm_policy_afinfo[AF_INET6]);
 	if (afinfo)
 		net->xfrm.xfrm6_dst_ops = *afinfo->dst_ops;
 #endif
-- 
1.7.1
