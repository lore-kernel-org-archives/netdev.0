From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] xfrm: use rcu_dereference_bh() when BH is disabled
Date: Thu, 16 Aug 2012 22:09:59 +0800
Message-ID: <1345126199-4758-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Priyanka Jain <Priyanka.Jain@freescale.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138Ab2HPOKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 10:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following RCU warning:

 ===============================
 [ INFO: suspicious RCU usage. ]
 3.5.0+ #64 Not tainted
 -------------------------------
 net/xfrm/xfrm_policy.c:2504 suspicious rcu_dereference_check() usage!

 other info that might help us debug this:


 rcu_scheduler_active = 1, debug_locks = 0
 2 locks held by swapper/1:
  #0:  (net_mutex){+.+.+.}, at: [<ffffffff814e1ad0>] register_pernet_subsys+0x21/0x57
  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff822c7329>] xfrm_net_init+0x1e4/0x437

 stack backtrace:
 Pid: 1, comm: swapper Not tainted 3.5.0-01540-g1669891 #64
 Call Trace:
  [<ffffffff8108b375>] lockdep_rcu_suspicious+0x174/0x187
  [<ffffffff822c7453>] xfrm_net_init+0x30e/0x437
  [<ffffffff822c7329>] ? xfrm_net_init+0x1e4/0x437
  [<ffffffff814e134a>] ops_init+0x1bb/0x1ff
  [<ffffffff810861f9>] ? trace_hardirqs_on+0x1b/0x24
  [<ffffffff814e17cd>] register_pernet_operations.isra.5+0x9d/0xfe
  [<ffffffff814e1adf>] register_pernet_subsys+0x30/0x57
  [<ffffffff822c7130>] xfrm_init+0x17/0x2c
  [<ffffffff822c2f8c>] ip_rt_init+0x82/0xe7
  [<ffffffff822c31dc>] ip_init+0x10/0x25
  [<ffffffff822c3f77>] inet_init+0x235/0x360
  [<ffffffff822c3d42>] ? devinet_init+0xf2/0xf2
  [<ffffffff82283252>] do_one_initcall+0xb4/0x203
  [<ffffffff8228354a>] kernel_init+0x1a9/0x29a
  [<ffffffff822826d9>] ? loglevel+0x46/0x46
  [<ffffffff816d3d84>] kernel_thread_helper+0x4/0x10
  [<ffffffff816d262c>] ? retint_restore_args+0x13/0x13
  [<ffffffff822833a1>] ? do_one_initcall+0x203/0x203
  [<ffffffff816d3d80>] ? gs_change+0x13/0x13


which is caused by:

commit 418a99ac6ad487dc9c42e6b0e85f941af56330f2
Author: Priyanka Jain <Priyanka.Jain@freescale.com>
Date:   Sun Aug 12 21:22:29 2012 +0000

    Replace rwlock on xfrm_policy_afinfo with rcu


Cc: "David S. Miller" <davem@davemloft.net>
Cc: Priyanka Jain <Priyanka.Jain@freescale.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
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
