From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: clean up snmp stats code
Date: Mon,  5 May 2014 15:55:55 -0700
Message-ID: <1399330555-4572-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Christoph Lameter <cl@linux.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:61445 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756752AbaEEW4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 18:56:08 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so10395959pab.41
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 15:56:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 8f0ea0fe3a036a47767f9c80e (snmp: reduce percpu needs by 50%)
reduced snmp array size to 1, so technically it doesn't have to be
an array any more. What's more, after the following commit:

	commit 933393f58fef9963eac61db8093689544e29a600
	Date:   Thu Dec 22 11:58:51 2011 -0600

	    percpu: Remove irqsafe_cpu_xxx variants
	    
	    We simply say that regular this_cpu use must be safe regardless of
	    preemption and interrupt state.  That has no material change for x86
	    and s390 implementations of this_cpu operations.  However, arches that
	    do not provide their own implementation for this_cpu operations will
	    now get code generated that disables interrupts instead of preemption.

probably no arch wants to have SNMP_ARRAY_SZ == 2. At least after
almost 3 years, no one complains.

So, just convert the array to a single pointer and remove snmp_mib_init()
and snmp_mib_free() as well.

Cc: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
 include/net/ip.h         | 18 ++--------
 include/net/snmp.h       | 32 ++++++++---------
 net/dccp/proto.c         |  9 ++---
 net/ipv4/af_inet.c       | 93 ++++++++++++++++--------------------------------
 net/ipv4/proc.c          | 24 ++++++-------
 net/ipv6/addrconf.c      | 17 ++++-----
 net/ipv6/addrconf_core.c |  2 +-
 net/ipv6/af_inet6.c      | 42 +++++++++-------------
 net/ipv6/proc.c          |  6 ++--
 net/sctp/protocol.c      |  9 ++---
 net/xfrm/xfrm_policy.c   | 10 +++---
 net/xfrm/xfrm_proc.c     |  3 +-
 12 files changed, 103 insertions(+), 162 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 1988cef..16146b6 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -196,27 +196,15 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 #define NET_ADD_STATS_BH(net, field, adnd) SNMP_ADD_STATS_BH((net)->mib.net_statistics, field, adnd)
 #define NET_ADD_STATS_USER(net, field, adnd) SNMP_ADD_STATS_USER((net)->mib.net_statistics, field, adnd)
 
-unsigned long snmp_fold_field(void __percpu *mib[], int offt);
+unsigned long snmp_fold_field(void __percpu *mib, int offt);
 #if BITS_PER_LONG==32
-u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t sync_off);
+u64 snmp_fold_field64(void __percpu *mib, int offt, size_t sync_off);
 #else
-static inline u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_off)
+static inline u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_off)
 {
 	return snmp_fold_field(mib, offt);
 }
 #endif
-int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align);
-
-static inline void snmp_mib_free(void __percpu *ptr[SNMP_ARRAY_SZ])
-{
-	int i;
-
-	BUG_ON(ptr == NULL);
-	for (i = 0; i < SNMP_ARRAY_SZ; i++) {
-		free_percpu(ptr[i]);
-		ptr[i] = NULL;
-	}
-}
 
 void inet_get_local_port_range(struct net *net, int *low, int *high);
 
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 7159626..f1f27fd 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -116,51 +116,49 @@ struct linux_xfrm_mib {
 	unsigned long	mibs[LINUX_MIB_XFRMMAX];
 };
 
-#define SNMP_ARRAY_SZ 1
-
 #define DEFINE_SNMP_STAT(type, name)	\
-	__typeof__(type) __percpu *name[SNMP_ARRAY_SZ]
+	__typeof__(type) __percpu *name
 #define DEFINE_SNMP_STAT_ATOMIC(type, name)	\
 	__typeof__(type) *name
 #define DECLARE_SNMP_STAT(type, name)	\
-	extern __typeof__(type) __percpu *name[SNMP_ARRAY_SZ]
+	extern __typeof__(type) __percpu *name
 
 #define SNMP_INC_STATS_BH(mib, field)	\
-			__this_cpu_inc(mib[0]->mibs[field])
+			__this_cpu_inc(mib->mibs[field])
 
 #define SNMP_INC_STATS_USER(mib, field)	\
-			this_cpu_inc(mib[0]->mibs[field])
+			this_cpu_inc(mib->mibs[field])
 
 #define SNMP_INC_STATS_ATOMIC_LONG(mib, field)	\
 			atomic_long_inc(&mib->mibs[field])
 
 #define SNMP_INC_STATS(mib, field)	\
-			this_cpu_inc(mib[0]->mibs[field])
+			this_cpu_inc(mib->mibs[field])
 
 #define SNMP_DEC_STATS(mib, field)	\
-			this_cpu_dec(mib[0]->mibs[field])
+			this_cpu_dec(mib->mibs[field])
 
 #define SNMP_ADD_STATS_BH(mib, field, addend)	\
-			__this_cpu_add(mib[0]->mibs[field], addend)
+			__this_cpu_add(mib->mibs[field], addend)
 
 #define SNMP_ADD_STATS_USER(mib, field, addend)	\
-			this_cpu_add(mib[0]->mibs[field], addend)
+			this_cpu_add(mib->mibs[field], addend)
 
 #define SNMP_ADD_STATS(mib, field, addend)	\
-			this_cpu_add(mib[0]->mibs[field], addend)
+			this_cpu_add(mib->mibs[field], addend)
 /*
- * Use "__typeof__(*mib[0]) *ptr" instead of "__typeof__(mib[0]) ptr"
+ * Use "__typeof__(*mib) *ptr" instead of "__typeof__(mib) ptr"
  * to make @ptr a non-percpu pointer.
  */
 #define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
 	do { \
-		__typeof__(*mib[0]->mibs) *ptr = mib[0]->mibs;	\
+		__typeof__(*mib->mibs) *ptr = mib->mibs;	\
 		this_cpu_inc(ptr[basefield##PKTS]);		\
 		this_cpu_add(ptr[basefield##OCTETS], addend);	\
 	} while (0)
 #define SNMP_UPD_PO_STATS_BH(mib, basefield, addend)	\
 	do { \
-		__typeof__(*mib[0]->mibs) *ptr = mib[0]->mibs;	\
+		__typeof__(*mib->mibs) *ptr = mib->mibs;	\
 		__this_cpu_inc(ptr[basefield##PKTS]);		\
 		__this_cpu_add(ptr[basefield##OCTETS], addend);	\
 	} while (0)
@@ -170,7 +168,7 @@ struct linux_xfrm_mib {
 
 #define SNMP_ADD_STATS64_BH(mib, field, addend) 			\
 	do {								\
-		__typeof__(*mib[0]) *ptr = __this_cpu_ptr((mib)[0]);	\
+		__typeof__(*mib) *ptr = __this_cpu_ptr(mib);		\
 		u64_stats_update_begin(&ptr->syncp);			\
 		ptr->mibs[field] += addend;				\
 		u64_stats_update_end(&ptr->syncp);			\
@@ -191,8 +189,8 @@ struct linux_xfrm_mib {
 #define SNMP_INC_STATS64(mib, field) SNMP_ADD_STATS64(mib, field, 1)
 #define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend)			\
 	do {								\
-		__typeof__(*mib[0]) *ptr;				\
-		ptr = __this_cpu_ptr((mib)[0]);				\
+		__typeof__(*mib) *ptr;					\
+		ptr = __this_cpu_ptr(mib);				\
 		u64_stats_update_begin(&ptr->syncp);			\
 		ptr->mibs[basefield##PKTS]++;				\
 		ptr->mibs[basefield##OCTETS] += addend;			\
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index eb892b4..de2c1e7 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1084,14 +1084,15 @@ EXPORT_SYMBOL_GPL(dccp_shutdown);
 
 static inline int dccp_mib_init(void)
 {
-	return snmp_mib_init((void __percpu **)dccp_statistics,
-			     sizeof(struct dccp_mib),
-			     __alignof__(struct dccp_mib));
+	dccp_statistics = alloc_percpu(struct dccp_mib);
+	if (!dccp_statistics)
+		return -ENOMEM;
+	return 0;
 }
 
 static inline void dccp_mib_exit(void)
 {
-	snmp_mib_free((void __percpu **)dccp_statistics);
+	free_percpu(dccp_statistics);
 }
 
 static int thash_entries;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8c54870..6765d91 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1476,22 +1476,20 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 }
 EXPORT_SYMBOL_GPL(inet_ctl_sock_create);
 
-unsigned long snmp_fold_field(void __percpu *mib[], int offt)
+unsigned long snmp_fold_field(void __percpu *mib, int offt)
 {
 	unsigned long res = 0;
-	int i, j;
+	int i;
 
-	for_each_possible_cpu(i) {
-		for (j = 0; j < SNMP_ARRAY_SZ; j++)
-			res += *(((unsigned long *) per_cpu_ptr(mib[j], i)) + offt);
-	}
+	for_each_possible_cpu(i)
+		res += *(((unsigned long *) per_cpu_ptr(mib, i)) + offt);
 	return res;
 }
 EXPORT_SYMBOL_GPL(snmp_fold_field);
 
 #if BITS_PER_LONG==32
 
-u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_offset)
+u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 {
 	u64 res = 0;
 	int cpu;
@@ -1502,7 +1500,7 @@ u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_offset)
 		u64 v;
 		unsigned int start;
 
-		bhptr = per_cpu_ptr(mib[0], cpu);
+		bhptr = per_cpu_ptr(mib, cpu);
 		syncp = (struct u64_stats_sync *)(bhptr + syncp_offset);
 		do {
 			start = u64_stats_fetch_begin_irq(syncp);
@@ -1516,25 +1514,6 @@ u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_offset)
 EXPORT_SYMBOL_GPL(snmp_fold_field64);
 #endif
 
-int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align)
-{
-	BUG_ON(ptr == NULL);
-	ptr[0] = __alloc_percpu(mibsize, align);
-	if (!ptr[0])
-		return -ENOMEM;
-
-#if SNMP_ARRAY_SZ == 2
-	ptr[1] = __alloc_percpu(mibsize, align);
-	if (!ptr[1]) {
-		free_percpu(ptr[0]);
-		ptr[0] = NULL;
-		return -ENOMEM;
-	}
-#endif
-	return 0;
-}
-EXPORT_SYMBOL_GPL(snmp_mib_init);
-
 #ifdef CONFIG_IP_MULTICAST
 static const struct net_protocol igmp_protocol = {
 	.handler =	igmp_rcv,
@@ -1570,40 +1549,30 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 {
 	int i;
 
-	if (snmp_mib_init((void __percpu **)net->mib.tcp_statistics,
-			  sizeof(struct tcp_mib),
-			  __alignof__(struct tcp_mib)) < 0)
+	net->mib.tcp_statistics = alloc_percpu(struct tcp_mib);
+	if (!net->mib.tcp_statistics)
 		goto err_tcp_mib;
-	if (snmp_mib_init((void __percpu **)net->mib.ip_statistics,
-			  sizeof(struct ipstats_mib),
-			  __alignof__(struct ipstats_mib)) < 0)
+	net->mib.ip_statistics = alloc_percpu(struct ipstats_mib);
+	if (!net->mib.ip_statistics)
 		goto err_ip_mib;
 
 	for_each_possible_cpu(i) {
 		struct ipstats_mib *af_inet_stats;
-		af_inet_stats = per_cpu_ptr(net->mib.ip_statistics[0], i);
+		af_inet_stats = per_cpu_ptr(net->mib.ip_statistics, i);
 		u64_stats_init(&af_inet_stats->syncp);
-#if SNMP_ARRAY_SZ == 2
-		af_inet_stats = per_cpu_ptr(net->mib.ip_statistics[1], i);
-		u64_stats_init(&af_inet_stats->syncp);
-#endif
 	}
 
-	if (snmp_mib_init((void __percpu **)net->mib.net_statistics,
-			  sizeof(struct linux_mib),
-			  __alignof__(struct linux_mib)) < 0)
+	net->mib.net_statistics = alloc_percpu(struct linux_mib);
+	if (!net->mib.net_statistics)
 		goto err_net_mib;
-	if (snmp_mib_init((void __percpu **)net->mib.udp_statistics,
-			  sizeof(struct udp_mib),
-			  __alignof__(struct udp_mib)) < 0)
+	net->mib.udp_statistics = alloc_percpu(struct udp_mib);
+	if (!net->mib.udp_statistics)
 		goto err_udp_mib;
-	if (snmp_mib_init((void __percpu **)net->mib.udplite_statistics,
-			  sizeof(struct udp_mib),
-			  __alignof__(struct udp_mib)) < 0)
+	net->mib.udplite_statistics = alloc_percpu(struct udp_mib);
+	if (!net->mib.udplite_statistics)
 		goto err_udplite_mib;
-	if (snmp_mib_init((void __percpu **)net->mib.icmp_statistics,
-			  sizeof(struct icmp_mib),
-			  __alignof__(struct icmp_mib)) < 0)
+	net->mib.icmp_statistics = alloc_percpu(struct icmp_mib);
+	if (!net->mib.icmp_statistics)
 		goto err_icmp_mib;
 	net->mib.icmpmsg_statistics = kzalloc(sizeof(struct icmpmsg_mib),
 					      GFP_KERNEL);
@@ -1614,17 +1583,17 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 	return 0;
 
 err_icmpmsg_mib:
-	snmp_mib_free((void __percpu **)net->mib.icmp_statistics);
+	free_percpu(net->mib.icmp_statistics);
 err_icmp_mib:
-	snmp_mib_free((void __percpu **)net->mib.udplite_statistics);
+	free_percpu(net->mib.udplite_statistics);
 err_udplite_mib:
-	snmp_mib_free((void __percpu **)net->mib.udp_statistics);
+	free_percpu(net->mib.udp_statistics);
 err_udp_mib:
-	snmp_mib_free((void __percpu **)net->mib.net_statistics);
+	free_percpu(net->mib.net_statistics);
 err_net_mib:
-	snmp_mib_free((void __percpu **)net->mib.ip_statistics);
+	free_percpu(net->mib.ip_statistics);
 err_ip_mib:
-	snmp_mib_free((void __percpu **)net->mib.tcp_statistics);
+	free_percpu(net->mib.tcp_statistics);
 err_tcp_mib:
 	return -ENOMEM;
 }
@@ -1632,12 +1601,12 @@ err_tcp_mib:
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
 	kfree(net->mib.icmpmsg_statistics);
-	snmp_mib_free((void __percpu **)net->mib.icmp_statistics);
-	snmp_mib_free((void __percpu **)net->mib.udplite_statistics);
-	snmp_mib_free((void __percpu **)net->mib.udp_statistics);
-	snmp_mib_free((void __percpu **)net->mib.net_statistics);
-	snmp_mib_free((void __percpu **)net->mib.ip_statistics);
-	snmp_mib_free((void __percpu **)net->mib.tcp_statistics);
+	free_percpu(net->mib.icmp_statistics);
+	free_percpu(net->mib.udplite_statistics);
+	free_percpu(net->mib.udp_statistics);
+	free_percpu(net->mib.net_statistics);
+	free_percpu(net->mib.ip_statistics);
+	free_percpu(net->mib.tcp_statistics);
 }
 
 static __net_initdata struct pernet_operations ipv4_mib_ops = {
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index ad737fa..ae0af93 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -345,15 +345,15 @@ static void icmp_put(struct seq_file *seq)
 	for (i = 0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " Out%s", icmpmibmap[i].name);
 	seq_printf(seq, "\nIcmp: %lu %lu %lu",
-		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INMSGS),
-		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INERRORS),
-		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_CSUMERRORS));
+		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_INMSGS),
+		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_INERRORS),
+		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_CSUMERRORS));
 	for (i = 0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
 			   atomic_long_read(ptr + icmpmibmap[i].index));
 	seq_printf(seq, " %lu %lu",
-		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTMSGS),
-		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTERRORS));
+		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_OUTMSGS),
+		snmp_fold_field(net->mib.icmp_statistics, ICMP_MIB_OUTERRORS));
 	for (i = 0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
 			   atomic_long_read(ptr + (icmpmibmap[i].index | 0x100)));
@@ -379,7 +379,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	BUILD_BUG_ON(offsetof(struct ipstats_mib, mibs) != 0);
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %llu",
-			   snmp_fold_field64((void __percpu **)net->mib.ip_statistics,
+			   snmp_fold_field64(net->mib.ip_statistics,
 					     snmp4_ipstats_list[i].entry,
 					     offsetof(struct ipstats_mib, syncp)));
 
@@ -395,11 +395,11 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 		/* MaxConn field is signed, RFC 2012 */
 		if (snmp4_tcp_list[i].entry == TCP_MIB_MAXCONN)
 			seq_printf(seq, " %ld",
-				   snmp_fold_field((void __percpu **)net->mib.tcp_statistics,
+				   snmp_fold_field(net->mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 		else
 			seq_printf(seq, " %lu",
-				   snmp_fold_field((void __percpu **)net->mib.tcp_statistics,
+				   snmp_fold_field(net->mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 	}
 
@@ -410,7 +410,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdp:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void __percpu **)net->mib.udp_statistics,
+			   snmp_fold_field(net->mib.udp_statistics,
 					   snmp4_udp_list[i].entry));
 
 	/* the UDP and UDP-Lite MIBs are the same */
@@ -421,7 +421,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdpLite:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void __percpu **)net->mib.udplite_statistics,
+			   snmp_fold_field(net->mib.udplite_statistics,
 					   snmp4_udp_list[i].entry));
 
 	seq_putc(seq, '\n');
@@ -458,7 +458,7 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nTcpExt:");
 	for (i = 0; snmp4_net_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void __percpu **)net->mib.net_statistics,
+			   snmp_fold_field(net->mib.net_statistics,
 					   snmp4_net_list[i].entry));
 
 	seq_puts(seq, "\nIpExt:");
@@ -468,7 +468,7 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nIpExt:");
 	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %llu",
-			   snmp_fold_field64((void __percpu **)net->mib.ip_statistics,
+			   snmp_fold_field64(net->mib.ip_statistics,
 					     snmp4_ipextstats_list[i].entry,
 					     offsetof(struct ipstats_mib, syncp)));
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1ac13c0..5667b30 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -275,19 +275,14 @@ static int snmp6_alloc_dev(struct inet6_dev *idev)
 {
 	int i;
 
-	if (snmp_mib_init((void __percpu **)idev->stats.ipv6,
-			  sizeof(struct ipstats_mib),
-			  __alignof__(struct ipstats_mib)) < 0)
+	idev->stats.ipv6 = alloc_percpu(struct ipstats_mib);
+	if (!idev->stats.ipv6)
 		goto err_ip;
 
 	for_each_possible_cpu(i) {
 		struct ipstats_mib *addrconf_stats;
-		addrconf_stats = per_cpu_ptr(idev->stats.ipv6[0], i);
+		addrconf_stats = per_cpu_ptr(idev->stats.ipv6, i);
 		u64_stats_init(&addrconf_stats->syncp);
-#if SNMP_ARRAY_SZ == 2
-		addrconf_stats = per_cpu_ptr(idev->stats.ipv6[1], i);
-		u64_stats_init(&addrconf_stats->syncp);
-#endif
 	}
 
 
@@ -305,7 +300,7 @@ static int snmp6_alloc_dev(struct inet6_dev *idev)
 err_icmpmsg:
 	kfree(idev->stats.icmpv6dev);
 err_icmp:
-	snmp_mib_free((void __percpu **)idev->stats.ipv6);
+	free_percpu(idev->stats.ipv6);
 err_ip:
 	return -ENOMEM;
 }
@@ -4363,7 +4358,7 @@ static inline void __snmp6_fill_statsdev(u64 *stats, atomic_long_t *mib,
 	memset(&stats[items], 0, pad);
 }
 
-static inline void __snmp6_fill_stats64(u64 *stats, void __percpu **mib,
+static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
 				      int items, int bytes, size_t syncpoff)
 {
 	int i;
@@ -4383,7 +4378,7 @@ static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 {
 	switch (attrtype) {
 	case IFLA_INET6_STATS:
-		__snmp6_fill_stats64(stats, (void __percpu **)idev->stats.ipv6,
+		__snmp6_fill_stats64(stats, idev->stats.ipv6,
 				     IPSTATS_MIB_MAX, bytes, offsetof(struct ipstats_mib, syncp));
 		break;
 	case IFLA_INET6_ICMP6STATS:
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 4c11cbc..e696045 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -123,7 +123,7 @@ static void snmp6_free_dev(struct inet6_dev *idev)
 {
 	kfree(idev->stats.icmpv6msgdev);
 	kfree(idev->stats.icmpv6dev);
-	snmp_mib_free((void __percpu **)idev->stats.ipv6);
+	free_percpu(idev->stats.ipv6);
 }
 
 /* Nobody refers to this device, we may destroy it. */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d935889..dc47cc7 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -715,33 +715,25 @@ static int __net_init ipv6_init_mibs(struct net *net)
 {
 	int i;
 
-	if (snmp_mib_init((void __percpu **)net->mib.udp_stats_in6,
-			  sizeof(struct udp_mib),
-			  __alignof__(struct udp_mib)) < 0)
+	net->mib.udp_stats_in6 = alloc_percpu(struct udp_mib);
+	if (!net->mib.udp_stats_in6)
 		return -ENOMEM;
-	if (snmp_mib_init((void __percpu **)net->mib.udplite_stats_in6,
-			  sizeof(struct udp_mib),
-			  __alignof__(struct udp_mib)) < 0)
+	net->mib.udplite_stats_in6 = alloc_percpu(struct udp_mib);
+	if (!net->mib.udplite_stats_in6)
 		goto err_udplite_mib;
-	if (snmp_mib_init((void __percpu **)net->mib.ipv6_statistics,
-			  sizeof(struct ipstats_mib),
-			  __alignof__(struct ipstats_mib)) < 0)
+	net->mib.ipv6_statistics = alloc_percpu(struct ipstats_mib);
+	if (!net->mib.ipv6_statistics)
 		goto err_ip_mib;
 
 	for_each_possible_cpu(i) {
 		struct ipstats_mib *af_inet6_stats;
-		af_inet6_stats = per_cpu_ptr(net->mib.ipv6_statistics[0], i);
+		af_inet6_stats = per_cpu_ptr(net->mib.ipv6_statistics, i);
 		u64_stats_init(&af_inet6_stats->syncp);
-#if SNMP_ARRAY_SZ == 2
-		af_inet6_stats = per_cpu_ptr(net->mib.ipv6_statistics[1], i);
-		u64_stats_init(&af_inet6_stats->syncp);
-#endif
 	}
 
 
-	if (snmp_mib_init((void __percpu **)net->mib.icmpv6_statistics,
-			  sizeof(struct icmpv6_mib),
-			  __alignof__(struct icmpv6_mib)) < 0)
+	net->mib.icmpv6_statistics = alloc_percpu(struct icmpv6_mib);
+	if (!net->mib.icmpv6_statistics)
 		goto err_icmp_mib;
 	net->mib.icmpv6msg_statistics = kzalloc(sizeof(struct icmpv6msg_mib),
 						GFP_KERNEL);
@@ -750,22 +742,22 @@ static int __net_init ipv6_init_mibs(struct net *net)
 	return 0;
 
 err_icmpmsg_mib:
-	snmp_mib_free((void __percpu **)net->mib.icmpv6_statistics);
+	free_percpu(net->mib.icmpv6_statistics);
 err_icmp_mib:
-	snmp_mib_free((void __percpu **)net->mib.ipv6_statistics);
+	free_percpu(net->mib.ipv6_statistics);
 err_ip_mib:
-	snmp_mib_free((void __percpu **)net->mib.udplite_stats_in6);
+	free_percpu(net->mib.udplite_stats_in6);
 err_udplite_mib:
-	snmp_mib_free((void __percpu **)net->mib.udp_stats_in6);
+	free_percpu(net->mib.udp_stats_in6);
 	return -ENOMEM;
 }
 
 static void ipv6_cleanup_mibs(struct net *net)
 {
-	snmp_mib_free((void __percpu **)net->mib.udp_stats_in6);
-	snmp_mib_free((void __percpu **)net->mib.udplite_stats_in6);
-	snmp_mib_free((void __percpu **)net->mib.ipv6_statistics);
-	snmp_mib_free((void __percpu **)net->mib.icmpv6_statistics);
+	free_percpu(net->mib.udp_stats_in6);
+	free_percpu(net->mib.udplite_stats_in6);
+	free_percpu(net->mib.ipv6_statistics);
+	free_percpu(net->mib.icmpv6_statistics);
 	kfree(net->mib.icmpv6msg_statistics);
 }
 
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 091d066..69cb476 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -201,7 +201,7 @@ static void snmp6_seq_show_item(struct seq_file *seq, void __percpu **pcpumib,
 	}
 }
 
-static void snmp6_seq_show_item64(struct seq_file *seq, void __percpu **mib,
+static void snmp6_seq_show_item64(struct seq_file *seq, void __percpu *mib,
 				  const struct snmp_mib *itemlist, size_t syncpoff)
 {
 	int i;
@@ -215,7 +215,7 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = (struct net *)seq->private;
 
-	snmp6_seq_show_item64(seq, (void __percpu **)net->mib.ipv6_statistics,
+	snmp6_seq_show_item64(seq, net->mib.ipv6_statistics,
 			    snmp6_ipstats_list, offsetof(struct ipstats_mib, syncp));
 	snmp6_seq_show_item(seq, (void __percpu **)net->mib.icmpv6_statistics,
 			    NULL, snmp6_icmp6_list);
@@ -245,7 +245,7 @@ static int snmp6_dev_seq_show(struct seq_file *seq, void *v)
 	struct inet6_dev *idev = (struct inet6_dev *)seq->private;
 
 	seq_printf(seq, "%-32s\t%u\n", "ifIndex", idev->dev->ifindex);
-	snmp6_seq_show_item64(seq, (void __percpu **)idev->stats.ipv6,
+	snmp6_seq_show_item64(seq, idev->stats.ipv6,
 			    snmp6_ipstats_list, offsetof(struct ipstats_mib, syncp));
 	snmp6_seq_show_item(seq, NULL, idev->stats.icmpv6dev->mibs,
 			    snmp6_icmp6_list);
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index c09757f..074b60e 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1100,14 +1100,15 @@ int sctp_register_pf(struct sctp_pf *pf, sa_family_t family)
 
 static inline int init_sctp_mibs(struct net *net)
 {
-	return snmp_mib_init((void __percpu **)net->sctp.sctp_statistics,
-			     sizeof(struct sctp_mib),
-			     __alignof__(struct sctp_mib));
+	net->sctp.sctp_statistics = alloc_percpu(struct sctp_mib);
+	if (!net->sctp.sctp_statistics)
+		return -ENOMEM;
+	return 0;
 }
 
 static inline void cleanup_sctp_mibs(struct net *net)
 {
-	snmp_mib_free((void __percpu **)net->sctp.sctp_statistics);
+	free_percpu(net->sctp.sctp_statistics);
 }
 
 static void sctp_v4_pf_init(void)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c08fbd1..e63f242 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2783,21 +2783,19 @@ static struct notifier_block xfrm_dev_notifier = {
 static int __net_init xfrm_statistics_init(struct net *net)
 {
 	int rv;
-
-	if (snmp_mib_init((void __percpu **)net->mib.xfrm_statistics,
-			  sizeof(struct linux_xfrm_mib),
-			  __alignof__(struct linux_xfrm_mib)) < 0)
+	net->mib.xfrm_statistics = alloc_percpu(struct linux_xfrm_mib);
+	if (!net->mib.xfrm_statistics)
 		return -ENOMEM;
 	rv = xfrm_proc_init(net);
 	if (rv < 0)
-		snmp_mib_free((void __percpu **)net->mib.xfrm_statistics);
+		free_percpu(net->mib.xfrm_statistics);
 	return rv;
 }
 
 static void xfrm_statistics_fini(struct net *net)
 {
 	xfrm_proc_fini(net);
-	snmp_mib_free((void __percpu **)net->mib.xfrm_statistics);
+	free_percpu(net->mib.xfrm_statistics);
 }
 #else
 static int __net_init xfrm_statistics_init(struct net *net)
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index fc5abd0..9c4fbd8 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -54,8 +54,7 @@ static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
 	int i;
 	for (i = 0; xfrm_mib_list[i].name; i++)
 		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
-			   snmp_fold_field((void __percpu **)
-					   net->mib.xfrm_statistics,
+			   snmp_fold_field(net->mib.xfrm_statistics,
 					   xfrm_mib_list[i].entry));
 	return 0;
 }
