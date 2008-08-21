From: adobriyan@gmail.com
Subject: [PATCH 08/38] netns ct: per-netns conntrack count
Date: Fri, 22 Aug 2008 01:59:52 +0400
Message-ID: <20080821215952.GH31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sysctls and proc files are stubbed to init_net's one. This is temporary.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netfilter/nf_conntrack.h                  |    1 -
 include/net/netns/conntrack.h                         |    3 +++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c        |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    2 +-
 net/netfilter/nf_conntrack_core.c                     |   18 ++++++++----------
 net/netfilter/nf_conntrack_standalone.c               |    5 ++---
 6 files changed, 15 insertions(+), 16 deletions(-)

--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -288,7 +288,6 @@ static inline int nf_ct_is_untracked(const struct sk_buff *skb)
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
@@ -314,7 +314,7 @@ static void ct_cpu_seq_stop(struct seq_file *seq, void *v)
 
 static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 {
-	unsigned int nr_conntracks = atomic_read(&nf_conntrack_count);
+	unsigned int nr_conntracks = atomic_read(&init_net.ct.count);
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -44,10 +44,6 @@
 DEFINE_SPINLOCK(nf_conntrack_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_lock);
 
-/* nf_conntrack_standalone needs this */
-atomic_t nf_conntrack_count = ATOMIC_INIT(0);
-EXPORT_SYMBOL_GPL(nf_conntrack_count);
-
 unsigned int nf_conntrack_htable_size __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 
@@ -477,13 +473,13 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
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
@@ -495,7 +491,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	ct = kmem_cache_zalloc(nf_conntrack_cachep, gfp);
 	if (ct == NULL) {
 		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
-		atomic_dec(&nf_conntrack_count);
+		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -516,10 +512,11 @@ EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
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
@@ -1023,7 +1020,7 @@ void nf_conntrack_cleanup(struct net *net)
 	nf_ct_event_cache_flush();
  i_see_dead_people:
 	nf_conntrack_flush();
-	if (atomic_read(&nf_conntrack_count) != 0) {
+	if (atomic_read(&net->ct.count) != 0) {
 		schedule();
 		goto i_see_dead_people;
 	}
@@ -1147,6 +1144,7 @@ int nf_conntrack_init(struct net *net)
 		 * entries. */
 		max_factor = 4;
 	}
+	atomic_set(&net->ct.count, 0);
 	nf_conntrack_hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
 						  &nf_conntrack_vmalloc);
 	if (!nf_conntrack_hash) {
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -226,7 +226,7 @@ static void ct_cpu_seq_stop(struct seq_file *seq, void *v)
 
 static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 {
-	unsigned int nr_conntracks = atomic_read(&nf_conntrack_count);
+	unsigned int nr_conntracks = atomic_read(&init_net.ct.count);
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
@@ -338,7 +338,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_NF_CONNTRACK_COUNT,
 		.procname	= "nf_conntrack_count",
-		.data		= &nf_conntrack_count,
+		.data		= &init_net.ct.count,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
 		.proc_handler	= &proc_dointvec,
-- 
1.5.6.3


