From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/8] percpu: add __percpu sparse annotations to net
Date: Tue, 26 Jan 2010 00:22:10 +0900
Message-ID: <1264432935-10453-4-git-send-email-tj@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Patrick McHardy <kaber@trash.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42998 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753938Ab0AYPTP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 10:19:15 -0500
In-Reply-To: <1264432935-10453-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __percpu sparse annotations to net.

These annotations are to make sparse consider percpu variables to be
in a different address space and warn if accessed without going
through percpu accessors.  This patch doesn't affect normal builds.

The macro and type tricks around snmp stats make things a bit
interesting.  DEFINE/DECLARE_SNMP_STAT() macros mark the target field
as __percpu and SNMP_UPD_PO_STATS() macro is updated accordingly.  All
snmp_mib_*() users which used to cast the argument to (void **) are
updated to cast it to (void __percpu **).

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org
---
 include/net/ip.h              |    6 ++--
 include/net/ipcomp.h          |    2 +-
 include/net/neighbour.h       |    2 +-
 include/net/netns/conntrack.h |    2 +-
 include/net/netns/core.h      |    2 +-
 include/net/route.h           |    2 +-
 include/net/snmp.h            |   12 +++++++---
 include/net/tcp.h             |    2 +-
 net/8021q/vlan.h              |    2 +-
 net/dccp/proto.c              |    5 ++-
 net/ipv4/af_inet.c            |   46 ++++++++++++++++++++--------------------
 net/ipv4/proc.c               |   28 ++++++++++++------------
 net/ipv4/route.c              |    2 +-
 net/ipv4/tcp.c                |   21 ++++++++++--------
 net/ipv6/addrconf.c           |   24 ++++++++++----------
 net/ipv6/af_inet6.c           |   28 ++++++++++++------------
 net/ipv6/proc.c               |   24 ++++++++++++---------
 net/sctp/proc.c               |    2 +-
 net/sctp/protocol.c           |    5 ++-
 net/xfrm/xfrm_ipcomp.c        |   16 +++++++-------
 net/xfrm/xfrm_policy.c        |    6 ++--
 net/xfrm/xfrm_proc.c          |    3 +-
 22 files changed, 128 insertions(+), 114 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index fb63371..667a55b 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -174,9 +174,9 @@ extern struct ipv4_config ipv4_config;
 #define NET_ADD_STATS_BH(net, field, adnd) SNMP_ADD_STATS_BH((net)->mib.net_statistics, field, adnd)
 #define NET_ADD_STATS_USER(net, field, adnd) SNMP_ADD_STATS_USER((net)->mib.net_statistics, field, adnd)
 
-extern unsigned long snmp_fold_field(void *mib[], int offt);
-extern int snmp_mib_init(void *ptr[2], size_t mibsize);
-extern void snmp_mib_free(void *ptr[2]);
+extern unsigned long snmp_fold_field(void __percpu *mib[], int offt);
+extern int snmp_mib_init(void __percpu *ptr[2], size_t mibsize);
+extern void snmp_mib_free(void __percpu *ptr[2]);
 
 extern struct local_ports {
 	seqlock_t	lock;
diff --git a/include/net/ipcomp.h b/include/net/ipcomp.h
index 2a1092a..cc4f30c 100644
--- a/include/net/ipcomp.h
+++ b/include/net/ipcomp.h
@@ -9,7 +9,7 @@ struct crypto_comp;
 
 struct ipcomp_data {
 	u16 threshold;
-	struct crypto_comp **tfms;
+	struct crypto_comp * __percpu *tfms;
 };
 
 struct ip_comp_hdr;
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index b017320..daf935b 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -164,7 +164,7 @@ struct neigh_table {
 	rwlock_t		lock;
 	unsigned long		last_rand;
 	struct kmem_cache		*kmem_cachep;
-	struct neigh_statistics	*stats;
+	struct neigh_statistics	__percpu *stats;
 	struct neighbour	**hash_buckets;
 	unsigned int		hash_mask;
 	__u32			hash_rnd;
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index ba1ba0c..1531c07 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -15,7 +15,7 @@ struct netns_ct {
 	struct hlist_head	*expect_hash;
 	struct hlist_nulls_head	unconfirmed;
 	struct hlist_nulls_head	dying;
-	struct ip_conntrack_stat *stat;
+	struct ip_conntrack_stat __percpu *stat;
 	int			sysctl_events;
 	unsigned int		sysctl_events_retry_timeout;
 	int			sysctl_acct;
diff --git a/include/net/netns/core.h b/include/net/netns/core.h
index 24d4be7..78eb1ff 100644
--- a/include/net/netns/core.h
+++ b/include/net/netns/core.h
@@ -10,7 +10,7 @@ struct netns_core {
 
 	int	sysctl_somaxconn;
 
-	struct prot_inuse	*inuse;
+	struct prot_inuse __percpu *inuse;
 };
 
 #endif
diff --git a/include/net/route.h b/include/net/route.h
index bce6dd6..2c9fba7 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -101,7 +101,7 @@ struct rt_cache_stat {
         unsigned int out_hlist_search;
 };
 
-extern struct ip_rt_acct *ip_rt_acct;
+extern struct ip_rt_acct __percpu *ip_rt_acct;
 
 struct in_device;
 extern int		ip_rt_init(void);
diff --git a/include/net/snmp.h b/include/net/snmp.h
index f0d756f..d065976 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -129,9 +129,9 @@ struct linux_xfrm_mib {
  * nonlocked_atomic_inc() primitives -AK
  */ 
 #define DEFINE_SNMP_STAT(type, name)	\
-	__typeof__(type) *name[2]
+	__typeof__(type) __percpu *name[2]
 #define DECLARE_SNMP_STAT(type, name)	\
-	extern __typeof__(type) *name[2]
+	extern __typeof__(type) __percpu *name[2]
 
 #define SNMP_STAT_BHPTR(name)	(name[0])
 #define SNMP_STAT_USRPTR(name)	(name[1])
@@ -148,9 +148,13 @@ struct linux_xfrm_mib {
 			__this_cpu_add(mib[0]->mibs[field], addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend)	\
 			this_cpu_add(mib[1]->mibs[field], addend)
+/*
+ * Use "__typeof__(*mib[0]) *ptr" instead of "__typeof__(mib[0]) ptr"
+ * to make @ptr a non-percpu pointer.
+ */
 #define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
 	do { \
-		__typeof__(mib[0]) ptr; \
+		__typeof__(*mib[0]) *ptr; \
 		preempt_disable(); \
 		ptr = this_cpu_ptr((mib)[!in_softirq()]); \
 		ptr->mibs[basefield##PKTS]++; \
@@ -159,7 +163,7 @@ struct linux_xfrm_mib {
 	} while (0)
 #define SNMP_UPD_PO_STATS_BH(mib, basefield, addend)	\
 	do { \
-		__typeof__(mib[0]) ptr = \
+		__typeof__(*mib[0]) *ptr = \
 			__this_cpu_ptr((mib)[!in_softirq()]); \
 		ptr->mibs[basefield##PKTS]++; \
 		ptr->mibs[basefield##OCTETS] += addend;\
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 34f5cc2..0511317 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1193,7 +1193,7 @@ extern int			tcp_v4_md5_do_del(struct sock *sk,
 #define tcp_twsk_md5_key(twsk)	NULL
 #endif
 
-extern struct tcp_md5sig_pool	**tcp_alloc_md5sig_pool(struct sock *);
+extern struct tcp_md5sig_pool * __percpu *tcp_alloc_md5sig_pool(struct sock *);
 extern void			tcp_free_md5sig_pool(void);
 
 extern struct tcp_md5sig_pool	*__tcp_get_md5sig_pool(int cpu);
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 5685296..6abdcac 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -61,7 +61,7 @@ struct vlan_dev_info {
 	struct proc_dir_entry			*dent;
 	unsigned long				cnt_inc_headroom_on_tx;
 	unsigned long				cnt_encap_on_xmit;
-	struct vlan_rx_stats			*vlan_rx_stats;
+	struct vlan_rx_stats __percpu		*vlan_rx_stats;
 };
 
 static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 671cd14..fb3b9f8 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1003,12 +1003,13 @@ EXPORT_SYMBOL_GPL(dccp_shutdown);
 
 static inline int dccp_mib_init(void)
 {
-	return snmp_mib_init((void**)dccp_statistics, sizeof(struct dccp_mib));
+	return snmp_mib_init((void __percpu **)dccp_statistics,
+			     sizeof(struct dccp_mib));
 }
 
 static inline void dccp_mib_exit(void)
 {
-	snmp_mib_free((void**)dccp_statistics);
+	snmp_mib_free((void __percpu **)dccp_statistics);
 }
 
 static int thash_entries;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7d12c6a..33b7dff 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1385,7 +1385,7 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 }
 EXPORT_SYMBOL_GPL(inet_ctl_sock_create);
 
-unsigned long snmp_fold_field(void *mib[], int offt)
+unsigned long snmp_fold_field(void __percpu *mib[], int offt)
 {
 	unsigned long res = 0;
 	int i;
@@ -1398,7 +1398,7 @@ unsigned long snmp_fold_field(void *mib[], int offt)
 }
 EXPORT_SYMBOL_GPL(snmp_fold_field);
 
-int snmp_mib_init(void *ptr[2], size_t mibsize)
+int snmp_mib_init(void __percpu *ptr[2], size_t mibsize)
 {
 	BUG_ON(ptr == NULL);
 	ptr[0] = __alloc_percpu(mibsize, __alignof__(unsigned long long));
@@ -1416,7 +1416,7 @@ err0:
 }
 EXPORT_SYMBOL_GPL(snmp_mib_init);
 
-void snmp_mib_free(void *ptr[2])
+void snmp_mib_free(void __percpu *ptr[2])
 {
 	BUG_ON(ptr == NULL);
 	free_percpu(ptr[0]);
@@ -1460,25 +1460,25 @@ static const struct net_protocol icmp_protocol = {
 
 static __net_init int ipv4_mib_init_net(struct net *net)
 {
-	if (snmp_mib_init((void **)net->mib.tcp_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.tcp_statistics,
 			  sizeof(struct tcp_mib)) < 0)
 		goto err_tcp_mib;
-	if (snmp_mib_init((void **)net->mib.ip_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.ip_statistics,
 			  sizeof(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
-	if (snmp_mib_init((void **)net->mib.net_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.net_statistics,
 			  sizeof(struct linux_mib)) < 0)
 		goto err_net_mib;
-	if (snmp_mib_init((void **)net->mib.udp_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.udp_statistics,
 			  sizeof(struct udp_mib)) < 0)
 		goto err_udp_mib;
-	if (snmp_mib_init((void **)net->mib.udplite_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.udplite_statistics,
 			  sizeof(struct udp_mib)) < 0)
 		goto err_udplite_mib;
-	if (snmp_mib_init((void **)net->mib.icmp_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.icmp_statistics,
 			  sizeof(struct icmp_mib)) < 0)
 		goto err_icmp_mib;
-	if (snmp_mib_init((void **)net->mib.icmpmsg_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.icmpmsg_statistics,
 			  sizeof(struct icmpmsg_mib)) < 0)
 		goto err_icmpmsg_mib;
 
@@ -1486,30 +1486,30 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 	return 0;
 
 err_icmpmsg_mib:
-	snmp_mib_free((void **)net->mib.icmp_statistics);
+	snmp_mib_free((void __percpu **)net->mib.icmp_statistics);
 err_icmp_mib:
-	snmp_mib_free((void **)net->mib.udplite_statistics);
+	snmp_mib_free((void __percpu **)net->mib.udplite_statistics);
 err_udplite_mib:
-	snmp_mib_free((void **)net->mib.udp_statistics);
+	snmp_mib_free((void __percpu **)net->mib.udp_statistics);
 err_udp_mib:
-	snmp_mib_free((void **)net->mib.net_statistics);
+	snmp_mib_free((void __percpu **)net->mib.net_statistics);
 err_net_mib:
-	snmp_mib_free((void **)net->mib.ip_statistics);
+	snmp_mib_free((void __percpu **)net->mib.ip_statistics);
 err_ip_mib:
-	snmp_mib_free((void **)net->mib.tcp_statistics);
+	snmp_mib_free((void __percpu **)net->mib.tcp_statistics);
 err_tcp_mib:
 	return -ENOMEM;
 }
 
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
-	snmp_mib_free((void **)net->mib.icmpmsg_statistics);
-	snmp_mib_free((void **)net->mib.icmp_statistics);
-	snmp_mib_free((void **)net->mib.udplite_statistics);
-	snmp_mib_free((void **)net->mib.udp_statistics);
-	snmp_mib_free((void **)net->mib.net_statistics);
-	snmp_mib_free((void **)net->mib.ip_statistics);
-	snmp_mib_free((void **)net->mib.tcp_statistics);
+	snmp_mib_free((void __percpu **)net->mib.icmpmsg_statistics);
+	snmp_mib_free((void __percpu **)net->mib.icmp_statistics);
+	snmp_mib_free((void __percpu **)net->mib.udplite_statistics);
+	snmp_mib_free((void __percpu **)net->mib.udp_statistics);
+	snmp_mib_free((void __percpu **)net->mib.net_statistics);
+	snmp_mib_free((void __percpu **)net->mib.ip_statistics);
+	snmp_mib_free((void __percpu **)net->mib.tcp_statistics);
 }
 
 static __net_initdata struct pernet_operations ipv4_mib_ops = {
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index f25542c..1561eb6 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -280,7 +280,7 @@ static void icmpmsg_put(struct seq_file *seq)
 
 	count = 0;
 	for (i = 0; i < ICMPMSG_MIB_MAX; i++) {
-		val = snmp_fold_field((void **) net->mib.icmpmsg_statistics, i);
+		val = snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics, i);
 		if (val) {
 			type[count] = i;
 			vals[count++] = val;
@@ -307,18 +307,18 @@ static void icmp_put(struct seq_file *seq)
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " Out%s", icmpmibmap[i].name);
 	seq_printf(seq, "\nIcmp: %lu %lu",
-		snmp_fold_field((void **) net->mib.icmp_statistics, ICMP_MIB_INMSGS),
-		snmp_fold_field((void **) net->mib.icmp_statistics, ICMP_MIB_INERRORS));
+		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INMSGS),
+		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			snmp_fold_field((void **) net->mib.icmpmsg_statistics,
+			snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics,
 				icmpmibmap[i].index));
 	seq_printf(seq, " %lu %lu",
-		snmp_fold_field((void **) net->mib.icmp_statistics, ICMP_MIB_OUTMSGS),
-		snmp_fold_field((void **) net->mib.icmp_statistics, ICMP_MIB_OUTERRORS));
+		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTMSGS),
+		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			snmp_fold_field((void **) net->mib.icmpmsg_statistics,
+			snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics,
 				icmpmibmap[i].index | 0x100));
 }
 
@@ -341,7 +341,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)net->mib.ip_statistics,
+			   snmp_fold_field((void __percpu **)net->mib.ip_statistics,
 					   snmp4_ipstats_list[i].entry));
 
 	icmp_put(seq);	/* RFC 2011 compatibility */
@@ -356,11 +356,11 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 		/* MaxConn field is signed, RFC 2012 */
 		if (snmp4_tcp_list[i].entry == TCP_MIB_MAXCONN)
 			seq_printf(seq, " %ld",
-				   snmp_fold_field((void **)net->mib.tcp_statistics,
+				   snmp_fold_field((void __percpu **)net->mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 		else
 			seq_printf(seq, " %lu",
-				   snmp_fold_field((void **)net->mib.tcp_statistics,
+				   snmp_fold_field((void __percpu **)net->mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 	}
 
@@ -371,7 +371,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdp:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)net->mib.udp_statistics,
+			   snmp_fold_field((void __percpu **)net->mib.udp_statistics,
 					   snmp4_udp_list[i].entry));
 
 	/* the UDP and UDP-Lite MIBs are the same */
@@ -382,7 +382,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdpLite:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)net->mib.udplite_statistics,
+			   snmp_fold_field((void __percpu **)net->mib.udplite_statistics,
 					   snmp4_udp_list[i].entry));
 
 	seq_putc(seq, '\n');
@@ -419,7 +419,7 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nTcpExt:");
 	for (i = 0; snmp4_net_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)net->mib.net_statistics,
+			   snmp_fold_field((void __percpu **)net->mib.net_statistics,
 					   snmp4_net_list[i].entry));
 
 	seq_puts(seq, "\nIpExt:");
@@ -429,7 +429,7 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nIpExt:");
 	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)net->mib.ip_statistics,
+			   snmp_fold_field((void __percpu **)net->mib.ip_statistics,
 					   snmp4_ipextstats_list[i].entry));
 
 	seq_putc(seq, '\n');
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e446496..515d906 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3327,7 +3327,7 @@ static __net_initdata struct pernet_operations rt_secret_timer_ops = {
 
 
 #ifdef CONFIG_NET_CLS_ROUTE
-struct ip_rt_acct *ip_rt_acct __read_mostly;
+struct ip_rt_acct __percpu *ip_rt_acct __read_mostly;
 #endif /* CONFIG_NET_CLS_ROUTE */
 
 static __initdata unsigned long rhash_entries;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b0a26bb..bc04e66 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2788,10 +2788,10 @@ EXPORT_SYMBOL(tcp_gro_complete);
 
 #ifdef CONFIG_TCP_MD5SIG
 static unsigned long tcp_md5sig_users;
-static struct tcp_md5sig_pool **tcp_md5sig_pool;
+static struct tcp_md5sig_pool * __percpu *tcp_md5sig_pool;
 static DEFINE_SPINLOCK(tcp_md5sig_pool_lock);
 
-static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool **pool)
+static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool * __percpu *pool)
 {
 	int cpu;
 	for_each_possible_cpu(cpu) {
@@ -2808,7 +2808,7 @@ static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool **pool)
 
 void tcp_free_md5sig_pool(void)
 {
-	struct tcp_md5sig_pool **pool = NULL;
+	struct tcp_md5sig_pool * __percpu *pool = NULL;
 
 	spin_lock_bh(&tcp_md5sig_pool_lock);
 	if (--tcp_md5sig_users == 0) {
@@ -2822,10 +2822,11 @@ void tcp_free_md5sig_pool(void)
 
 EXPORT_SYMBOL(tcp_free_md5sig_pool);
 
-static struct tcp_md5sig_pool **__tcp_alloc_md5sig_pool(struct sock *sk)
+static struct tcp_md5sig_pool * __percpu *
+__tcp_alloc_md5sig_pool(struct sock *sk)
 {
 	int cpu;
-	struct tcp_md5sig_pool **pool;
+	struct tcp_md5sig_pool * __percpu *pool;
 
 	pool = alloc_percpu(struct tcp_md5sig_pool *);
 	if (!pool)
@@ -2852,9 +2853,9 @@ out_free:
 	return NULL;
 }
 
-struct tcp_md5sig_pool **tcp_alloc_md5sig_pool(struct sock *sk)
+struct tcp_md5sig_pool * __percpu *tcp_alloc_md5sig_pool(struct sock *sk)
 {
-	struct tcp_md5sig_pool **pool;
+	struct tcp_md5sig_pool * __percpu *pool;
 	int alloc = 0;
 
 retry:
@@ -2873,7 +2874,9 @@ retry:
 
 	if (alloc) {
 		/* we cannot hold spinlock here because this may sleep. */
-		struct tcp_md5sig_pool **p = __tcp_alloc_md5sig_pool(sk);
+		struct tcp_md5sig_pool * __percpu *p;
+
+		p = __tcp_alloc_md5sig_pool(sk);
 		spin_lock_bh(&tcp_md5sig_pool_lock);
 		if (!p) {
 			tcp_md5sig_users--;
@@ -2897,7 +2900,7 @@ EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
 
 struct tcp_md5sig_pool *__tcp_get_md5sig_pool(int cpu)
 {
-	struct tcp_md5sig_pool **p;
+	struct tcp_md5sig_pool * __percpu *p;
 	spin_lock_bh(&tcp_md5sig_pool_lock);
 	p = tcp_md5sig_pool;
 	if (p)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index de7a194..1b5f2ed 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -278,31 +278,31 @@ static void addrconf_mod_timer(struct inet6_ifaddr *ifp,
 
 static int snmp6_alloc_dev(struct inet6_dev *idev)
 {
-	if (snmp_mib_init((void **)idev->stats.ipv6,
+	if (snmp_mib_init((void __percpu **)idev->stats.ipv6,
 			  sizeof(struct ipstats_mib)) < 0)
 		goto err_ip;
-	if (snmp_mib_init((void **)idev->stats.icmpv6,
+	if (snmp_mib_init((void __percpu **)idev->stats.icmpv6,
 			  sizeof(struct icmpv6_mib)) < 0)
 		goto err_icmp;
-	if (snmp_mib_init((void **)idev->stats.icmpv6msg,
+	if (snmp_mib_init((void __percpu **)idev->stats.icmpv6msg,
 			  sizeof(struct icmpv6msg_mib)) < 0)
 		goto err_icmpmsg;
 
 	return 0;
 
 err_icmpmsg:
-	snmp_mib_free((void **)idev->stats.icmpv6);
+	snmp_mib_free((void __percpu **)idev->stats.icmpv6);
 err_icmp:
-	snmp_mib_free((void **)idev->stats.ipv6);
+	snmp_mib_free((void __percpu **)idev->stats.ipv6);
 err_ip:
 	return -ENOMEM;
 }
 
 static void snmp6_free_dev(struct inet6_dev *idev)
 {
-	snmp_mib_free((void **)idev->stats.icmpv6msg);
-	snmp_mib_free((void **)idev->stats.icmpv6);
-	snmp_mib_free((void **)idev->stats.ipv6);
+	snmp_mib_free((void __percpu **)idev->stats.icmpv6msg);
+	snmp_mib_free((void __percpu **)idev->stats.icmpv6);
+	snmp_mib_free((void __percpu **)idev->stats.ipv6);
 }
 
 /* Nobody refers to this device, we may destroy it. */
@@ -3752,8 +3752,8 @@ static inline size_t inet6_if_nlmsg_size(void)
 		 );
 }
 
-static inline void __snmp6_fill_stats(u64 *stats, void **mib, int items,
-				      int bytes)
+static inline void __snmp6_fill_stats(u64 *stats, void __percpu **mib,
+				      int items, int bytes)
 {
 	int i;
 	int pad = bytes - sizeof(u64) * items;
@@ -3772,10 +3772,10 @@ static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 {
 	switch(attrtype) {
 	case IFLA_INET6_STATS:
-		__snmp6_fill_stats(stats, (void **)idev->stats.ipv6, IPSTATS_MIB_MAX, bytes);
+		__snmp6_fill_stats(stats, (void __percpu **)idev->stats.ipv6, IPSTATS_MIB_MAX, bytes);
 		break;
 	case IFLA_INET6_ICMP6STATS:
-		__snmp6_fill_stats(stats, (void **)idev->stats.icmpv6, ICMP6_MIB_MAX, bytes);
+		__snmp6_fill_stats(stats, (void __percpu **)idev->stats.icmpv6, ICMP6_MIB_MAX, bytes);
 		break;
 	}
 }
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 12e69d3..36b42af 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -971,41 +971,41 @@ static void ipv6_packet_cleanup(void)
 
 static int __net_init ipv6_init_mibs(struct net *net)
 {
-	if (snmp_mib_init((void **)net->mib.udp_stats_in6,
+	if (snmp_mib_init((void __percpu **)net->mib.udp_stats_in6,
 			  sizeof (struct udp_mib)) < 0)
 		return -ENOMEM;
-	if (snmp_mib_init((void **)net->mib.udplite_stats_in6,
+	if (snmp_mib_init((void __percpu **)net->mib.udplite_stats_in6,
 			  sizeof (struct udp_mib)) < 0)
 		goto err_udplite_mib;
-	if (snmp_mib_init((void **)net->mib.ipv6_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.ipv6_statistics,
 			  sizeof(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
-	if (snmp_mib_init((void **)net->mib.icmpv6_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.icmpv6_statistics,
 			  sizeof(struct icmpv6_mib)) < 0)
 		goto err_icmp_mib;
-	if (snmp_mib_init((void **)net->mib.icmpv6msg_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.icmpv6msg_statistics,
 			  sizeof(struct icmpv6msg_mib)) < 0)
 		goto err_icmpmsg_mib;
 	return 0;
 
 err_icmpmsg_mib:
-	snmp_mib_free((void **)net->mib.icmpv6_statistics);
+	snmp_mib_free((void __percpu **)net->mib.icmpv6_statistics);
 err_icmp_mib:
-	snmp_mib_free((void **)net->mib.ipv6_statistics);
+	snmp_mib_free((void __percpu **)net->mib.ipv6_statistics);
 err_ip_mib:
-	snmp_mib_free((void **)net->mib.udplite_stats_in6);
+	snmp_mib_free((void __percpu **)net->mib.udplite_stats_in6);
 err_udplite_mib:
-	snmp_mib_free((void **)net->mib.udp_stats_in6);
+	snmp_mib_free((void __percpu **)net->mib.udp_stats_in6);
 	return -ENOMEM;
 }
 
 static void __net_exit ipv6_cleanup_mibs(struct net *net)
 {
-	snmp_mib_free((void **)net->mib.udp_stats_in6);
-	snmp_mib_free((void **)net->mib.udplite_stats_in6);
-	snmp_mib_free((void **)net->mib.ipv6_statistics);
-	snmp_mib_free((void **)net->mib.icmpv6_statistics);
-	snmp_mib_free((void **)net->mib.icmpv6msg_statistics);
+	snmp_mib_free((void __percpu **)net->mib.udp_stats_in6);
+	snmp_mib_free((void __percpu **)net->mib.udplite_stats_in6);
+	snmp_mib_free((void __percpu **)net->mib.ipv6_statistics);
+	snmp_mib_free((void __percpu **)net->mib.icmpv6_statistics);
+	snmp_mib_free((void __percpu **)net->mib.icmpv6msg_statistics);
 }
 
 static int __net_init inet6_net_init(struct net *net)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index c9605c3..e3744d1 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -136,7 +136,7 @@ static struct snmp_mib snmp6_udplite6_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
-static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void **mib)
+static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void __percpu **mib)
 {
 	char name[32];
 	int i;
@@ -171,7 +171,8 @@ static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void **mib)
 }
 
 static inline void
-snmp6_seq_show_item(struct seq_file *seq, void **mib, struct snmp_mib *itemlist)
+snmp6_seq_show_item(struct seq_file *seq, void __percpu **mib,
+		    struct snmp_mib *itemlist)
 {
 	int i;
 	for (i=0; itemlist[i].name; i++)
@@ -183,14 +184,15 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = (struct net *)seq->private;
 
-	snmp6_seq_show_item(seq, (void **)net->mib.ipv6_statistics,
+	snmp6_seq_show_item(seq, (void __percpu **)net->mib.ipv6_statistics,
 			    snmp6_ipstats_list);
-	snmp6_seq_show_item(seq, (void **)net->mib.icmpv6_statistics,
+	snmp6_seq_show_item(seq, (void __percpu **)net->mib.icmpv6_statistics,
 			    snmp6_icmp6_list);
-	snmp6_seq_show_icmpv6msg(seq, (void **)net->mib.icmpv6msg_statistics);
-	snmp6_seq_show_item(seq, (void **)net->mib.udp_stats_in6,
+	snmp6_seq_show_icmpv6msg(seq,
+			    (void __percpu **)net->mib.icmpv6msg_statistics);
+	snmp6_seq_show_item(seq, (void __percpu **)net->mib.udp_stats_in6,
 			    snmp6_udp6_list);
-	snmp6_seq_show_item(seq, (void **)net->mib.udplite_stats_in6,
+	snmp6_seq_show_item(seq, (void __percpu **)net->mib.udplite_stats_in6,
 			    snmp6_udplite6_list);
 	return 0;
 }
@@ -213,9 +215,11 @@ static int snmp6_dev_seq_show(struct seq_file *seq, void *v)
 	struct inet6_dev *idev = (struct inet6_dev *)seq->private;
 
 	seq_printf(seq, "%-32s\t%u\n", "ifIndex", idev->dev->ifindex);
-	snmp6_seq_show_item(seq, (void **)idev->stats.ipv6, snmp6_ipstats_list);
-	snmp6_seq_show_item(seq, (void **)idev->stats.icmpv6, snmp6_icmp6_list);
-	snmp6_seq_show_icmpv6msg(seq, (void **)idev->stats.icmpv6msg);
+	snmp6_seq_show_item(seq, (void __percpu **)idev->stats.ipv6,
+			    snmp6_ipstats_list);
+	snmp6_seq_show_item(seq, (void __percpu **)idev->stats.icmpv6,
+			    snmp6_icmp6_list);
+	snmp6_seq_show_icmpv6msg(seq, (void __percpu **)idev->stats.icmpv6msg);
 	return 0;
 }
 
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index d093cbf..e1e04c6 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -83,7 +83,7 @@ static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 
 	for (i = 0; sctp_snmp_list[i].name != NULL; i++)
 		seq_printf(seq, "%-32s\t%ld\n", sctp_snmp_list[i].name,
-			   snmp_fold_field((void **)sctp_statistics,
+			   snmp_fold_field((void __percpu **)sctp_statistics,
 				      sctp_snmp_list[i].entry));
 
 	return 0;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index a3c8988..9687177 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -996,12 +996,13 @@ int sctp_register_pf(struct sctp_pf *pf, sa_family_t family)
 
 static inline int init_sctp_mibs(void)
 {
-	return snmp_mib_init((void**)sctp_statistics, sizeof(struct sctp_mib));
+	return snmp_mib_init((void __percpu **)sctp_statistics,
+			     sizeof(struct sctp_mib));
 }
 
 static inline void cleanup_sctp_mibs(void)
 {
-	snmp_mib_free((void**)sctp_statistics);
+	snmp_mib_free((void __percpu **)sctp_statistics);
 }
 
 static void sctp_v4_pf_init(void)
diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index 42cd183..0fc5ff6 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -30,12 +30,12 @@
 
 struct ipcomp_tfms {
 	struct list_head list;
-	struct crypto_comp **tfms;
+	struct crypto_comp * __percpu *tfms;
 	int users;
 };
 
 static DEFINE_MUTEX(ipcomp_resource_mutex);
-static void **ipcomp_scratches;
+static void * __percpu *ipcomp_scratches;
 static int ipcomp_scratch_users;
 static LIST_HEAD(ipcomp_tfms_list);
 
@@ -200,7 +200,7 @@ EXPORT_SYMBOL_GPL(ipcomp_output);
 static void ipcomp_free_scratches(void)
 {
 	int i;
-	void **scratches;
+	void * __percpu *scratches;
 
 	if (--ipcomp_scratch_users)
 		return;
@@ -215,10 +215,10 @@ static void ipcomp_free_scratches(void)
 	free_percpu(scratches);
 }
 
-static void **ipcomp_alloc_scratches(void)
+static void * __percpu *ipcomp_alloc_scratches(void)
 {
 	int i;
-	void **scratches;
+	void * __percpu *scratches;
 
 	if (ipcomp_scratch_users++)
 		return ipcomp_scratches;
@@ -239,7 +239,7 @@ static void **ipcomp_alloc_scratches(void)
 	return scratches;
 }
 
-static void ipcomp_free_tfms(struct crypto_comp **tfms)
+static void ipcomp_free_tfms(struct crypto_comp * __percpu *tfms)
 {
 	struct ipcomp_tfms *pos;
 	int cpu;
@@ -267,10 +267,10 @@ static void ipcomp_free_tfms(struct crypto_comp **tfms)
 	free_percpu(tfms);
 }
 
-static struct crypto_comp **ipcomp_alloc_tfms(const char *alg_name)
+static struct crypto_comp * __percpu *ipcomp_alloc_tfms(const char *alg_name)
 {
 	struct ipcomp_tfms *pos;
-	struct crypto_comp **tfms;
+	struct crypto_comp * __percpu *tfms;
 	int cpu;
 
 	/* This can be any valid CPU ID so we don't need locking. */
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4725a54..a8c3ced 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2369,19 +2369,19 @@ static int __net_init xfrm_statistics_init(struct net *net)
 {
 	int rv;
 
-	if (snmp_mib_init((void **)net->mib.xfrm_statistics,
+	if (snmp_mib_init((void __percpu **)net->mib.xfrm_statistics,
 			  sizeof(struct linux_xfrm_mib)) < 0)
 		return -ENOMEM;
 	rv = xfrm_proc_init(net);
 	if (rv < 0)
-		snmp_mib_free((void **)net->mib.xfrm_statistics);
+		snmp_mib_free((void __percpu **)net->mib.xfrm_statistics);
 	return rv;
 }
 
 static void xfrm_statistics_fini(struct net *net)
 {
 	xfrm_proc_fini(net);
-	snmp_mib_free((void **)net->mib.xfrm_statistics);
+	snmp_mib_free((void __percpu **)net->mib.xfrm_statistics);
 }
 #else
 static int __net_init xfrm_statistics_init(struct net *net)
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index fef8db5..54ad2a8 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -50,7 +50,8 @@ static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
 	int i;
 	for (i=0; xfrm_mib_list[i].name; i++)
 		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
-			   snmp_fold_field((void **)net->mib.xfrm_statistics,
+			   snmp_fold_field((void __percpu **)
+					   net->mib.xfrm_statistics,
 					   xfrm_mib_list[i].entry));
 	return 0;
 }
-- 
1.6.4.2

