From: Patrick McHardy <kaber@trash.net>
Subject: nf_conntrack 01/04: Use rcu_barrier()
Date: Mon, 29 Jun 2009 16:20:14 +0200 (MEST)
Message-ID: <20090629142009.5728.27914.sendpatchset@x2.localnet>
References: <20090629142007.5728.63458.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090629142007.5728.63458.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 308ff823ebd749a94d3b6ac26b95bc0eb114c39e
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Thu Jun 25 16:32:52 2009 +0200

    nf_conntrack: Use rcu_barrier()
    
    RCU barriers, rcu_barrier(), is inserted two places.
    
     In nf_conntrack_expect.c nf_conntrack_expect_fini() before the
     kmem_cache_destroy().  Firstly to make sure the callback to the
     nf_ct_expect_free_rcu() code is still around.  Secondly because I'm
     unsure about the consequence of having in flight
     nf_ct_expect_free_rcu/kmem_cache_free() calls while doing a
     kmem_cache_destroy() slab destroy.
    
     And in nf_conntrack_extend.c nf_ct_extend_unregister(), inorder to
     wait for completion of callbacks to __nf_ct_ext_free_rcu(), which is
     invoked by __nf_ct_ext_add().  It might be more efficient to call
     rcu_barrier() in nf_conntrack_core.c nf_conntrack_cleanup_net(), but
     thats make it more difficult to read the code (as the callback code
     in located in nf_conntrack_extend.c).
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index afde8f9..2032dfe 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -617,8 +617,10 @@ err1:
 void nf_conntrack_expect_fini(struct net *net)
 {
 	exp_proc_remove(net);
-	if (net_eq(net, &init_net))
+	if (net_eq(net, &init_net)) {
+		rcu_barrier(); /* Wait for call_rcu() before destroy */
 		kmem_cache_destroy(nf_ct_expect_cachep);
+	}
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
 }
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 4b2c769..fef95be 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -186,6 +186,6 @@ void nf_ct_extend_unregister(struct nf_ct_ext_type *type)
 	rcu_assign_pointer(nf_ct_ext_types[type->id], NULL);
 	update_alloc_size(type);
 	mutex_unlock(&nf_ct_ext_type_mutex);
-	synchronize_rcu();
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 EXPORT_SYMBOL_GPL(nf_ct_extend_unregister);
