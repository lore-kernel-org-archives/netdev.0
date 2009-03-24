From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 41/41: nf_conntrack: Reduce conntrack count in nf_conntrack_free()
Date: Tue, 24 Mar 2009 15:04:01 +0100 (MET)
Message-ID: <20090324140357.31401.39776.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34856 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758569AbZCXOEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:04:04 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1d45209d89e647e9f27e4afa1f47338df73bc112
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Tue Mar 24 14:26:50 2009 +0100

    netfilter: nf_conntrack: Reduce conntrack count in nf_conntrack_free()
    
    We use RCU to defer freeing of conntrack structures. In DOS situation, RCU might
    accumulate about 10.000 elements per CPU in its internal queues. To get accurate
    conntrack counts (at the expense of slightly more RAM used), we might consider
    conntrack counter not taking into account "about to be freed elements, waiting
    in RCU queues". We thus decrement it in nf_conntrack_free(), not in the RCU
    callback.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Tested-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ebc2756..55befe5 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -517,16 +517,17 @@ EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
 static void nf_conntrack_free_rcu(struct rcu_head *head)
 {
 	struct nf_conn *ct = container_of(head, struct nf_conn, rcu);
-	struct net *net = nf_ct_net(ct);
 
 	nf_ct_ext_free(ct);
 	kmem_cache_free(nf_conntrack_cachep, ct);
-	atomic_dec(&net->ct.count);
 }
 
 void nf_conntrack_free(struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
+
 	nf_ct_ext_destroy(ct);
+	atomic_dec(&net->ct.count);
 	call_rcu(&ct->rcu, nf_conntrack_free_rcu);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_free);
