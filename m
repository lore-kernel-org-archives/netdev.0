From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 09/31] netns ct: per-netns conntrack count
Date: Mon, 21 Jul 2008 20:37:21 +0400
Message-ID: <20080721163721.GM13264@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, den@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack.h                  |    1 -
 include/net/netns/conntrack.h                         |    3 +++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c        |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    2 +-
 net/netfilter/nf_conntrack_core.c                     |   18 ++++++++----------
 net/netfilter/nf_conntrack_standalone.c               |    4 ++--
 6 files changed, 15 insertions(+), 15 deletions(-)

--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -294,7 +294,6 @@ static inline int nf_ct_is_untracked(const struct sk_buff *skb)
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
 extern int nf_conntrack_checksum;
-extern atomic_t nf_conntrack_count;
 extern int nf_conntrack_max;
 
 DECLARE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -1,6 +1,9 @@
 #ifndef __NETNS_CONNTRACK_H
 #define __NETNS_CONNTRACK_H
 
+#include <asm/atomic.h>
+
 struct netns_ct {
+	atomic_t		count;
 };
 #endif
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -254,7 +254,7 @@ static ctl_table ip_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_COUNT,
 		.procname	= "ip_conntrack_count",
-		.data		= &nf_conntrack_count,
+		.data		= &init_net.ct.count,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
 		.proc_handler	= &proc_dointvec,
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -326,7 +326,7 @@ static void ct_cpu_seq_stop(struct seq_file *seq, void *v)
 
 static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 {
-	unsigned int nr_conntracks = atomic_read(&nf_conntrack_count);
+	unsigned int nr_conntracks = atomic_read(&init_net.ct.count);
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -43,10 +43,6 @@
 DEFINE_SPINLOCK(nf_conntrack_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_lock);
 
-/* nf_conntrack_standalone needs this */
-atomic_t nf_conntrack_count = ATOMIC_INIT(0);
-EXPORT_SYMBOL_GPL(nf_conntrack_count);
-
 unsigned int nf_conntrack_htable_size __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 
@@ -476,13 +472,13 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	}
 
 	/* We don't want any race condition at early drop stage */
-	atomic_inc(&nf_conntrack_count);
+	atomic_inc(&net->ct.count);
 
 	if (nf_conntrack_max &&
-	    unlikely(atomic_read(&nf_conntrack_count) > nf_conntrack_max)) {
+	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
 		unsigned int hash = hash_conntrack(orig);
 		if (!early_drop(hash)) {
-			atomic_dec(&nf_conntrack_count);
+			atomic_dec(&net->ct.count);
 			if (net_ratelimit())
 				printk(KERN_WARNING
 				       "nf_conntrack: table full, dropping"
@@ -494,7 +490,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	ct = kmem_cache_zalloc(nf_conntrack_cachep, gfp);
 	if (ct == NULL) {
 		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
-		atomic_dec(&nf_conntrack_count);
+		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -515,10 +511,11 @@ EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
 static void nf_conntrack_free_rcu(struct rcu_head *head)
 {
 	struct nf_conn *ct = container_of(head, struct nf_conn, rcu);
+	struct net *net = nf_ct_net(ct);
 
 	nf_ct_ext_free(ct);
 	kmem_cache_free(nf_conntrack_cachep, ct);
-	atomic_dec(&nf_conntrack_count);
+	atomic_dec(&net->ct.count);
 }
 
 void nf_conntrack_free(struct nf_conn *ct)
@@ -1017,7 +1014,7 @@ void nf_conntrack_cleanup(struct net *net)
 	nf_ct_event_cache_flush();
  i_see_dead_people:
 	nf_conntrack_flush();
-	if (atomic_read(&nf_conntrack_count) != 0) {
+	if (atomic_read(&net->ct.count) != 0) {
 		schedule();
 		goto i_see_dead_people;
 	}
@@ -1140,6 +1137,7 @@ int nf_conntrack_init(struct net *net)
 		 * entries. */
 		max_factor = 4;
 	}
+	atomic_set(&net->ct.count, 0);
 	nf_conntrack_hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
 						  &nf_conntrack_vmalloc);
 	if (!nf_conntrack_hash) {
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -238,7 +238,7 @@ static void ct_cpu_seq_stop(struct seq_file *seq, void *v)
 
 static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 {
-	unsigned int nr_conntracks = atomic_read(&nf_conntrack_count);
+	unsigned int nr_conntracks = atomic_read(&init_net.ct.count);
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
@@ -349,7 +349,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_NF_CONNTRACK_COUNT,
 		.procname	= "nf_conntrack_count",
-		.data		= &nf_conntrack_count,
+		.data		= &init_net.ct.count,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
 		.proc_handler	= &proc_dointvec,
-- 
1.5.4.5


