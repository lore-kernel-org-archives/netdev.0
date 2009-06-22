From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/07: nf_conntrack: death_by_timeout() fix
Date: Mon, 22 Jun 2009 14:53:50 +0200 (MEST)
Message-ID: <20090622125350.6531.19896.sendpatchset@x2.localnet>
References: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39230 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbZFVMxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 08:53:48 -0400
In-Reply-To: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 8cc20198cfccd06cef705c14fd50bde603e2e306
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Mon Jun 22 14:13:55 2009 +0200

    netfilter: nf_conntrack: death_by_timeout() fix
    
    death_by_timeout() might delete a conntrack from hash list
    and insert it in dying list.
    
     nf_ct_delete_from_lists(ct);
     nf_ct_insert_dying_list(ct);
    
    I believe a (lockless) reader could *catch* ct while doing a lookup
    and miss the end of its chain.
    (nulls lookup algo must check the null value at the end of lookup and
    should restart if the null value is not the expected one.
    cf Documentation/RCU/rculist_nulls.txt for details)
    
    We need to change nf_conntrack_init_net() and use a different "null" value,
    guaranteed not being used in regular lists. Choose very large values, since
    hash table uses [0..size-1] null values.
    
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5f72b94..5276a2d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1267,13 +1267,19 @@ err_cache:
 	return ret;
 }
 
+/*
+ * We need to use special "null" values, not used in hash table
+ */
+#define UNCONFIRMED_NULLS_VAL	((1<<30)+0)
+#define DYING_NULLS_VAL		((1<<30)+1)
+
 static int nf_conntrack_init_net(struct net *net)
 {
 	int ret;
 
 	atomic_set(&net->ct.count, 0);
-	INIT_HLIST_NULLS_HEAD(&net->ct.unconfirmed, 0);
-	INIT_HLIST_NULLS_HEAD(&net->ct.dying, 0);
+	INIT_HLIST_NULLS_HEAD(&net->ct.unconfirmed, UNCONFIRMED_NULLS_VAL);
+	INIT_HLIST_NULLS_HEAD(&net->ct.dying, DYING_NULLS_VAL);
 	net->ct.stat = alloc_percpu(struct ip_conntrack_stat);
 	if (!net->ct.stat) {
 		ret = -ENOMEM;
