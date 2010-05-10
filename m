From: kaber@trash.net
Subject: [PATCH 83/84] netfilter: nf_conntrack_proto: fix warning with CONFIG_PROVE_RCU
Date: Mon, 10 May 2010 22:18:54 +0200
Message-ID: <1273522735-24672-84-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54506 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756968Ab0EJUTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:31 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
include/net/netfilter/nf_conntrack_l3proto.h:92 invoked rcu_dereference_check()
without protection!

other info that might help us debug this:

rcu_scheduler_active = 1, debug_locks = 0
2 locks held by iptables/3197:
 #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8149bd8c>]
ip_setsockopt+0x7c/0xa0
 #1:  (&xt[i].mutex){+.+.+.}, at: [<ffffffff8148a5fe>]
xt_find_table_lock+0x3e/0x110

stack backtrace:
Pid: 3197, comm: iptables Not tainted 2.6.34-rc4 #2
Call Trace:
 [<ffffffff8105e2e8>] lockdep_rcu_dereference+0xb8/0xc0
 [<ffffffff8147fb3b>] nf_ct_l3proto_module_put+0x6b/0x70
 [<ffffffff8148d891>] state_mt_destroy+0x11/0x20
 [<ffffffff814d3baf>] cleanup_match+0x2f/0x50
 [<ffffffff814d3c63>] cleanup_entry+0x33/0x90
 [<ffffffff814d5653>] ? __do_replace+0x1a3/0x210
 [<ffffffff814d564c>] __do_replace+0x19c/0x210
 [<ffffffff814d651a>] do_ipt_set_ctl+0x16a/0x1b0
 [<ffffffff8147a610>] nf_sockopt+0x60/0xa0
...

The __nf_ct_l3proto_find() call doesn't actually need rcu read side
protection since the caller holds a reference to the protocol. Use
rcu_read_lock() anyways to avoid the warning.

Kernel bugzilla #15781: https://bugzilla.kernel.org/show_bug.cgi?id=15781

Reported-by: Christian Casteyde <casteyde.christian@free.fr>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_proto.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index a6defc7..5886ba1 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -117,9 +117,13 @@ void nf_ct_l3proto_module_put(unsigned short l3proto)
 {
 	struct nf_conntrack_l3proto *p;
 
-	/* rcu_read_lock not necessary since the caller holds a reference */
+	/* rcu_read_lock not necessary since the caller holds a reference, but
+	 * taken anyways to avoid lockdep warnings in __nf_ct_l3proto_find()
+	 */
+	rcu_read_lock();
 	p = __nf_ct_l3proto_find(l3proto);
 	module_put(p->me);
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_module_put);
 
-- 
1.7.0.4

