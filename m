From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 22/25] netns ct: per-netns nf_conntrack_max
Date: Sun, 22 Jun 2008 05:19:23 +0400
Message-ID: <20080622011923.GX5392@martell.zuzino.mipt.ru>
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

 include/net/netfilter/nf_conntrack.h           |    1 -
 include/net/netns/conntrack.h                  |    3 ++-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/netfilter/nf_conntrack_core.c              |   12 ++++--------
 net/netfilter/nf_conntrack_standalone.c        |    4 ++--
 5 files changed, 9 insertions(+), 13 deletions(-)

--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -291,7 +291,6 @@ static inline int nf_ct_is_untracked(const struct sk_buff *skb)
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
 extern int nf_conntrack_checksum;
-extern int nf_conntrack_max;
 
 DECLARE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
 #define NF_CT_STAT_INC(count) (__get_cpu_var(nf_conntrack_stat).count++)
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -5,7 +5,8 @@
 #include <asm/atomic.h>
 
 struct netns_ct {
-	atomic_t	count;
+	atomic_t		count;
+	int			max;
 	struct hlist_head	*hash;
 	int			hash_vmalloc;
 	unsigned int		expect_count;
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -246,7 +246,7 @@ static ctl_table ip_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_MAX,
 		.procname	= "ip_conntrack_max",
-		.data		= &nf_conntrack_max,
+		.data		= &init_net.ct.max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -46,9 +46,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_lock);
 unsigned int nf_conntrack_htable_size __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 
-int nf_conntrack_max __read_mostly;
-EXPORT_SYMBOL_GPL(nf_conntrack_max);
-
 struct nf_conn nf_conntrack_untracked __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
 
@@ -473,8 +470,8 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	/* We don't want any race condition at early drop stage */
 	atomic_inc(&net->ct.count);
 
-	if (nf_conntrack_max &&
-	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
+	if (net->ct.max &&
+	    unlikely(atomic_read(&net->ct.count) > net->ct.max)) {
 		unsigned int hash = hash_conntrack(orig);
 		if (!early_drop(net, hash)) {
 			atomic_dec(&net->ct.count);
@@ -1160,12 +1157,11 @@ int nf_conntrack_init(struct net *net)
 	}
 	INIT_HLIST_HEAD(&net->ct.unconfirmed);
 
+	net->ct.max = max_factor * nf_conntrack_htable_size;
 	if (net == &init_net) {
-		nf_conntrack_max = max_factor * nf_conntrack_htable_size;
-
 		printk("nf_conntrack version %s (%u buckets, %d max)\n",
 			NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
-			nf_conntrack_max);
+			net->ct.max);
 
 		nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn),
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -344,7 +344,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 	{
 		.ctl_name	= NET_NF_CONNTRACK_MAX,
 		.procname	= "nf_conntrack_max",
-		.data		= &nf_conntrack_max,
+		.data		= &init_net.ct.max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
@@ -407,7 +407,7 @@ static ctl_table nf_ct_netfilter_table[] = {
 	{
 		.ctl_name	= NET_NF_CONNTRACK_MAX,
 		.procname	= "nf_conntrack_max",
-		.data		= &nf_conntrack_max,
+		.data		= &init_net.ct.max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
-- 
1.5.4.5


