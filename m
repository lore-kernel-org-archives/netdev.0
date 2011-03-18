From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 24/36] net,rcu: convert call_rcu(net_generic_release) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:06:32 +0800
Message-ID: <4D82DA48.2070305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmai
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64393 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751031Ab1CREEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 00:04:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback net_generic_release() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(net_generic_release).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/core/net_namespace.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 3f86026..297bb92 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -27,14 +27,6 @@ EXPORT_SYMBOL(init_net);
 
 #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
 
-static void net_generic_release(struct rcu_head *rcu)
-{
-	struct net_generic *ng;
-
-	ng = container_of(rcu, struct net_generic, rcu);
-	kfree(ng);
-}
-
 static int net_assign_generic(struct net *net, int id, void *data)
 {
 	struct net_generic *ng, *old_ng;
@@ -68,7 +60,7 @@ static int net_assign_generic(struct net *net, int id, void *data)
 	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len * sizeof(void*));
 
 	rcu_assign_pointer(net->gen, ng);
-	call_rcu(&old_ng->rcu, net_generic_release);
+	kfree_rcu(old_ng, rcu);
 assign:
 	ng->ptr[id - 1] = data;
 	return 0;
-- 
1.7.4
