From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 05/25] netns ct: per-netns conntrack count
Date: Sun, 22 Jun 2008 05:04:11 +0400
Message-ID: <20080622010411.GF5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:3537 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbYFVBIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 21:08:20 -0400
Received: by ug-out-1314.google.com with SMTP id h2so244303ugf.16
        for <netdev@vger.kernel.org>; Sat, 21 Jun 2008 18:08:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

proc and sysctl are stubbed to init_net's value, that's for later.

Note: conntracks are recycled RCU-way, netns as well.
During destruction, conntrack count of netns is decremented.
I'm not sure it's not racy and it will not decrement in freed netns
since conntrack doesn't pin netns (and pinning it is out of question).
Probably, decrement should be moved earlier.

FWIW, I haven't seen this race (if it exists at all). But my cloning
proggie sucks big way, so don't count on me. :^)

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
@@ -291,7 +291,6 @@ static inline int nf_ct_is_untracked(const struct sk_buff *skb)
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
+	atomic_t	count;
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
 
@@ -475,13 +471,13 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
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
@@ -493,7 +489,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	ct = kmem_cache_zalloc(nf_conntrack_cachep, GFP_ATOMIC);
 	if (ct == NULL) {
 		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
-		atomic_dec(&nf_conntrack_count);
+		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -514,10 +510,11 @@ EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
 static void nf_conntrack_free_rcu(struct rcu_head *head)
 {
 	struct nf_conn *ct = container_of(head, struct nf_conn, rcu);
+	struct net *net = ct_net(ct);
 
 	nf_ct_ext_free(ct);
 	kmem_cache_free(nf_conntrack_cachep, ct);
-	atomic_dec(&nf_conntrack_count);
+	atomic_dec(&net->ct.count);
 }
 
 void nf_conntrack_free(struct nf_conn *ct)
@@ -1015,7 +1012,7 @@ void nf_conntrack_cleanup(struct net *net)
 	nf_ct_event_cache_flush();
  i_see_dead_people:
 	nf_conntrack_flush();
-	if (atomic_read(&nf_conntrack_count) != 0) {
+	if (atomic_read(&net->ct.count) != 0) {
 		schedule();
 		goto i_see_dead_people;
 	}
@@ -1141,6 +1138,7 @@ int nf_conntrack_init(struct net *net)
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


