From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 08/25] netns ct: per-netns unconfirmed list
Date: Sun, 22 Jun 2008 05:07:14 +0400
Message-ID: <20080622010714.GI5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack_core.h |    1 -
 include/net/netns/conntrack.h             |    2 ++
 net/netfilter/nf_conntrack_core.c         |    6 +++---
 net/netfilter/nf_conntrack_helper.c       |    2 +-
 4 files changed, 6 insertions(+), 5 deletions(-)

--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -72,6 +72,5 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l4proto *proto);
 
 extern spinlock_t nf_conntrack_lock ;
-extern struct hlist_head unconfirmed;
 
 #endif /* _NF_CONNTRACK_CORE_H */
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -1,6 +1,7 @@
 #ifndef __NETNS_CONNTRACK_H
 #define __NETNS_CONNTRACK_H
 
+#include <linux/list.h>
 #include <asm/atomic.h>
 
 struct netns_ct {
@@ -10,5 +11,6 @@ struct netns_ct {
 	unsigned int		expect_count;
 	struct hlist_head	*expect_hash;
 	int			expect_vmalloc;
+	struct hlist_head	unconfirmed;
 };
 #endif
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -53,7 +53,6 @@ struct nf_conn nf_conntrack_untracked __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
 
 unsigned int nf_ct_log_invalid __read_mostly;
-HLIST_HEAD(unconfirmed);
 static struct kmem_cache *nf_conntrack_cachep __read_mostly;
 
 DEFINE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
@@ -592,7 +591,7 @@ init_conntrack(struct net *net,
 	}
 
 	/* Overload tuple linked list to put us in unconfirmed list. */
-	hlist_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode, &unconfirmed);
+	hlist_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode, &net->ct.unconfirmed);
 
 	spin_unlock_bh(&nf_conntrack_lock);
 
@@ -946,7 +945,7 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 				goto found;
 		}
 	}
-	hlist_for_each_entry(h, n, &unconfirmed, hnode) {
+	hlist_for_each_entry(h, n, &net->ct.unconfirmed, hnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (iter(ct, data))
 			set_bit(IPS_DYING_BIT, &ct->status);
@@ -1146,6 +1145,7 @@ int nf_conntrack_init(struct net *net)
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
 		goto err_out;
 	}
+	INIT_HLIST_HEAD(&net->ct.unconfirmed);
 
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -155,7 +155,7 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	}
 
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_for_each_entry(h, n, &unconfirmed, hnode)
+	hlist_for_each_entry(h, n, &init_net.ct.unconfirmed, hnode)
 		unhelp(h, me);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
 		hlist_for_each_entry(h, n, &init_net.ct.hash[i], hnode)
-- 
1.5.4.5


