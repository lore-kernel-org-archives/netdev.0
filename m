From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 06/33] netns ct: per-netns unconfirmed list
Date: Mon,  8 Sep 2008 07:02:43 +0400
Message-ID: <1220842990-30500-6-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What is confirmed connection in one netns can very well be unconfirmed
in another one.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 1c37356..b4b45c5 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -72,6 +72,5 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l4proto *proto);
 
 extern spinlock_t nf_conntrack_lock ;
-extern struct hlist_head unconfirmed;
 
 #endif /* _NF_CONNTRACK_CORE_H */
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index e453a33..6ddf58e 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -1,6 +1,7 @@
 #ifndef __NETNS_CONNTRACK_H
 #define __NETNS_CONNTRACK_H
 
+#include <linux/list.h>
 #include <asm/atomic.h>
 
 struct netns_ct {
@@ -8,6 +9,7 @@ struct netns_ct {
 	unsigned int		expect_count;
 	struct hlist_head	*hash;
 	struct hlist_head	*expect_hash;
+	struct hlist_head	unconfirmed;
 	int			hash_vmalloc;
 	int			expect_vmalloc;
 };
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c188ede..2a105db 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -54,7 +54,6 @@ struct nf_conn nf_conntrack_untracked __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
 
 unsigned int nf_ct_log_invalid __read_mostly;
-HLIST_HEAD(unconfirmed);
 static struct kmem_cache *nf_conntrack_cachep __read_mostly;
 
 DEFINE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
@@ -596,7 +595,8 @@ init_conntrack(struct net *net,
 	}
 
 	/* Overload tuple linked list to put us in unconfirmed list. */
-	hlist_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode, &unconfirmed);
+	hlist_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode,
+		       &net->ct.unconfirmed);
 
 	spin_unlock_bh(&nf_conntrack_lock);
 
@@ -957,7 +957,7 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 				goto found;
 		}
 	}
-	hlist_for_each_entry(h, n, &unconfirmed, hnode) {
+	hlist_for_each_entry(h, n, &net->ct.unconfirmed, hnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (iter(ct, data))
 			set_bit(IPS_DYING_BIT, &ct->status);
@@ -1154,6 +1154,7 @@ int nf_conntrack_init(struct net *net)
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
 		goto err_out;
 	}
+	INIT_HLIST_HEAD(&net->ct.unconfirmed);
 
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index c793db8..920e778 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -156,7 +156,7 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	}
 
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_for_each_entry(h, n, &unconfirmed, hnode)
+	hlist_for_each_entry(h, n, &init_net.ct.unconfirmed, hnode)
 		unhelp(h, me);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
 		hlist_for_each_entry(h, n, &init_net.ct.hash[i], hnode)
