From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC net-next-2.6] snmp: ipstats_mib becomes u64 for all arches
Date: Thu, 24 Jun 2010 18:47:31 +0200
Message-ID: <1277398051.2816.644.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:50859 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522Ab0FXQyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 12:54:38 -0400
Received: by wwi17 with SMTP id 17so400035wwi.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 09:54:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David,

I will respin this patch after net-next-2.6 tree stabilizes a bit.

(It needs u64_stats_fetch_begin_bh() and u64_stats_fetch_retry_bh(), and
probably the SNMP fix I sent earlier, currently in net-2.6 only)

Thanks

[RFC net-next-2.6] snmp: ipstats_mib becomes u64 for all arches

/proc/net/snmp and /proc/net/netstat expose SNMP counters.

Width of these counters is either 32 or 64 bits, depending on the size
of "unsigned long" in kernel.

This means user program parsing these files must already be prepared to
deal with 64bit values, regardless of user program being 32 or 64 bit.

This patch introduces 64bit snmp values for IPSTAT mib, where some
counters can wrap pretty fast if they are 32bit wide.

This uses u64_stats_sync infrastructure.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ip.h    |   20 ++++++--
 include/net/ipv6.h  |   12 ++---
 include/net/snmp.h  |   98 ++++++++++++++++++++++++++++++++++++++----
 net/ipv4/af_inet.c  |   33 ++++++++++++++
 net/ipv4/proc.c     |   12 ++---
 net/ipv6/addrconf.c |   18 +++++++
 net/ipv6/proc.c     |   13 ++++-
 7 files changed, 176 insertions(+), 30 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 3b524df..890f972 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -165,12 +165,12 @@ struct ipv4_config {
 };
 
 extern struct ipv4_config ipv4_config;
-#define IP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ip_statistics, field)
-#define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip_statistics, field)
-#define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.ip_statistics, field, val)
-#define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH((net)->mib.ip_statistics, field, val)
-#define IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS((net)->mib.ip_statistics, field, val)
-#define IP_UPD_PO_STATS_BH(net, field, val) SNMP_UPD_PO_STATS_BH((net)->mib.ip_statistics, field, val)
+#define IP_INC_STATS(net, field)	SNMP_INC_STATS64((net)->mib.ip_statistics, field)
+#define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS64_BH((net)->mib.ip_statistics, field)
+#define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS64((net)->mib.ip_statistics, field, val)
+#define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS64_BH((net)->mib.ip_statistics, field, val)
+#define IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS64((net)->mib.ip_statistics, field, val)
+#define IP_UPD_PO_STATS_BH(net, field, val) SNMP_UPD_PO_STATS64_BH((net)->mib.ip_statistics, field, val)
 #define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
 #define NET_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.net_statistics, field)
 #define NET_INC_STATS_USER(net, field) 	SNMP_INC_STATS_USER((net)->mib.net_statistics, field)
@@ -178,6 +178,14 @@ extern struct ipv4_config ipv4_config;
 #define NET_ADD_STATS_USER(net, field, adnd) SNMP_ADD_STATS_USER((net)->mib.net_statistics, field, adnd)
 
 extern unsigned long snmp_fold_field(void __percpu *mib[], int offt);
+#if BITS_PER_LONG==32
+extern u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t sync_off);
+#else
+static inline u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_off)
+{
+	return snmp_fold_field(mib, offt);
+}
+#endif
 extern int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align);
 extern void snmp_mib_free(void __percpu *ptr[2]);
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f5808d5..1f84124 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -136,17 +136,17 @@ extern struct ctl_path net_ipv6_ctl_path[];
 /* MIBs */
 
 #define IP6_INC_STATS(net, idev,field)		\
-		_DEVINC(net, ipv6, , idev, field)
+		_DEVINC(net, ipv6, 64, idev, field)
 #define IP6_INC_STATS_BH(net, idev,field)	\
-		_DEVINC(net, ipv6, _BH, idev, field)
+		_DEVINC(net, ipv6, 64_BH, idev, field)
 #define IP6_ADD_STATS(net, idev,field,val)	\
-		_DEVADD(net, ipv6, , idev, field, val)
+		_DEVADD(net, ipv6, 64, idev, field, val)
 #define IP6_ADD_STATS_BH(net, idev,field,val)	\
-		_DEVADD(net, ipv6, _BH, idev, field, val)
+		_DEVADD(net, ipv6, 64_BH, idev, field, val)
 #define IP6_UPD_PO_STATS(net, idev,field,val)   \
-		_DEVUPD(net, ipv6, , idev, field, val)
+		_DEVUPD(net, ipv6, 64, idev, field, val)
 #define IP6_UPD_PO_STATS_BH(net, idev,field,val)   \
-		_DEVUPD(net, ipv6, _BH, idev, field, val)
+		_DEVUPD(net, ipv6, 64_BH, idev, field, val)
 #define ICMP6_INC_STATS(net, idev, field)	\
 		_DEVINC(net, icmpv6, , idev, field)
 #define ICMP6_INC_STATS_BH(net, idev, field)	\
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 92456f1..af7e9dc 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -47,15 +47,15 @@ struct snmp_mib {
 }
 
 /*
- * We use all unsigned longs. Linux will soon be so reliable that even 
- * these will rapidly get too small 8-). Seriously consider the IpInReceives 
- * count on the 20Gb/s + networks people expect in a few years time!
+ * We use unsigned longs for most mibs but u64 for ipstats.
  */
+#include <linux/u64_stats_sync.h>
 
 /* IPstats */
 #define IPSTATS_MIB_MAX	__IPSTATS_MIB_MAX
 struct ipstats_mib {
-	unsigned long	mibs[IPSTATS_MIB_MAX];
+	u64		mibs[IPSTATS_MIB_MAX];
+	struct u64_stats_sync syncp;
 };
 
 /* ICMP */
@@ -122,19 +122,31 @@ struct linux_xfrm_mib {
 #define SNMP_STAT_USRPTR(name)	(name[1])
 
 #define SNMP_INC_STATS_BH(mib, field)	\
-			__this_cpu_inc(mib[0]->mibs[field])
+	do {									\
+		BUILD_BUG_ON(sizeof(mib[0]->mibs[field]) > sizeof(long));	\
+		__this_cpu_inc(mib[0]->mibs[field]);				\
+	} while (0)
 #define SNMP_INC_STATS_USER(mib, field)	\
-			this_cpu_inc(mib[1]->mibs[field])
+	do {									\
+		BUILD_BUG_ON(sizeof(mib[1]->mibs[field]) > sizeof(long));	\
+		this_cpu_inc(mib[1]->mibs[field]);				\
+	} while (0)
 #define SNMP_INC_STATS(mib, field)	\
-			this_cpu_inc(mib[!in_softirq()]->mibs[field])
+	do {									\
+		BUILD_BUG_ON(sizeof(mib[0]->mibs[field]) > sizeof(long));	\
+		this_cpu_inc(mib[!in_softirq()]->mibs[field]);			\
+	} while (0)
 #define SNMP_DEC_STATS(mib, field)	\
-			this_cpu_dec(mib[!in_softirq()]->mibs[field])
+	do {									\
+		BUILD_BUG_ON(sizeof(mib[0]->mibs[field]) > sizeof(long));	\
+		this_cpu_dec(mib[!in_softirq()]->mibs[field]);			\
+	} while (0)
 #define SNMP_ADD_STATS_BH(mib, field, addend)	\
 			__this_cpu_add(mib[0]->mibs[field], addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend)	\
 			this_cpu_add(mib[1]->mibs[field], addend)
 #define SNMP_ADD_STATS(mib, field, addend)	\
-			this_cpu_add(mib[0]->mibs[field], addend)
+			this_cpu_add(mib[!in_softirq()]->mibs[field], addend)
 /*
  * Use "__typeof__(*mib[0]) *ptr" instead of "__typeof__(mib[0]) ptr"
  * to make @ptr a non-percpu pointer.
@@ -144,6 +156,7 @@ struct linux_xfrm_mib {
 		__typeof__(*mib[0]) *ptr; \
 		preempt_disable(); \
 		ptr = this_cpu_ptr((mib)[!in_softirq()]); \
+		BUILD_BUG_ON(sizeof(mib[0]->mibs[0]) > sizeof(long)); \
 		ptr->mibs[basefield##PKTS]++; \
 		ptr->mibs[basefield##OCTETS] += addend;\
 		preempt_enable(); \
@@ -152,7 +165,74 @@ struct linux_xfrm_mib {
 	do { \
 		__typeof__(*mib[0]) *ptr = \
 			__this_cpu_ptr((mib)[!in_softirq()]); \
+		BUILD_BUG_ON(sizeof(mib[0]->mibs[0]) > sizeof(long)); \
 		ptr->mibs[basefield##PKTS]++; \
 		ptr->mibs[basefield##OCTETS] += addend;\
 	} while (0)
+
+
+#if BITS_PER_LONG==32
+
+#define SNMP_ADD_STATS64_BH(mib, field, addend) 			\
+	do {								\
+		__typeof__(*mib[0]) *ptr = __this_cpu_ptr((mib)[0]);	\
+		u64_stats_update_begin(&ptr->syncp);			\
+		ptr->mibs[field] += addend;				\
+		u64_stats_update_end(&ptr->syncp);			\
+	} while (0)
+#define SNMP_ADD_STATS64_USER(mib, field, addend) 			\
+	do {								\
+		__typeof__(*mib[0]) *ptr;				\
+		preempt_disable();					\
+		ptr = __this_cpu_ptr((mib)[1]);				\
+		u64_stats_update_begin(&ptr->syncp);			\
+		ptr->mibs[field] += addend;				\
+		u64_stats_update_end(&ptr->syncp);			\
+		preempt_enable();					\
+	} while (0)
+#define SNMP_ADD_STATS64(mib, field, addend)				\
+	do {								\
+		__typeof__(*mib[0]) *ptr;				\
+		preempt_disable();					\
+		ptr = __this_cpu_ptr((mib)[!in_softirq()]);		\
+		u64_stats_update_begin(&ptr->syncp);			\
+		ptr->mibs[field] += addend;				\
+		u64_stats_update_end(&ptr->syncp);			\
+		preempt_enable();					\
+	} while (0)
+#define SNMP_INC_STATS64_BH(mib, field) SNMP_ADD_STATS64_BH(mib, field, 1)
+#define SNMP_INC_STATS64_USER(mib, field) SNMP_ADD_STATS64_USER(mib, field, 1)
+#define SNMP_INC_STATS64(mib, field) SNMP_ADD_STATS64(mib, field, 1)
+#define SNMP_UPD_PO_STATS64(mib, basefield, addend)			\
+	do {								\
+		__typeof__(*mib[0]) *ptr;				\
+		preempt_disable();					\
+		ptr = __this_cpu_ptr((mib)[!in_softirq()]);		\
+		u64_stats_update_begin(&ptr->syncp);			\
+		ptr->mibs[basefield##PKTS]++;				\
+		ptr->mibs[basefield##OCTETS] += addend;			\
+		u64_stats_update_end(&ptr->syncp);			\
+		preempt_enable();					\
+	} while (0)
+#define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend)			\
+	do {								\
+		__typeof__(*mib[0]) *ptr;				\
+		ptr = __this_cpu_ptr((mib)[!in_softirq()]);		\
+		u64_stats_update_begin(&ptr->syncp);			\
+		ptr->mibs[basefield##PKTS]++;				\
+		ptr->mibs[basefield##OCTETS] += addend;			\
+		u64_stats_update_end(&ptr->syncp);			\
+	} while (0)
+#else
+#define SNMP_INC_STATS64_BH(mib, field)		SNMP_INC_STATS_BH(mib, field)
+#define SNMP_INC_STATS64_USER(mib, field)	SNMP_INC_STATS_USER(mib, field)
+#define SNMP_INC_STATS64(mib, field)		SNMP_INC_STATS(mib, field)
+#define SNMP_DEC_STATS64(mib, field)		SNMP_DEC_STATS(mib, field)
+#define SNMP_ADD_STATS64_BH(mib, field, addend) SNMP_ADD_STATS_BH(mib, field, addend)
+#define SNMP_ADD_STATS64_USER(mib, field, addend) SNMP_ADD_STATS_USER(mib, field, addend)
+#define SNMP_ADD_STATS64(mib, field, addend)	SNMP_ADD_STATS(mib, field, addend)
+#define SNMP_UPD_PO_STATS64(mib, basefield, addend) SNMP_UPD_PO_STATS(mib, basefield, addend)
+#define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend) SNMP_UPD_PO_STATS_BH(mib, basefield, addend)
+#endif
+
 #endif
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 640db9b..aeb178e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1427,6 +1427,39 @@ unsigned long snmp_fold_field(void __percpu *mib[], int offt)
 }
 EXPORT_SYMBOL_GPL(snmp_fold_field);
 
+#if BITS_PER_LONG==32
+
+u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_offset)
+{
+	u64 res = 0;
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct u64_stats_sync *syncp;
+		u64 v0, v1;
+		unsigned int start;
+
+		/* first mib used by softirq context */
+		syncp = (struct u64_stats_sync *)(per_cpu_ptr(mib[0], i) + syncp_offset);
+		do {
+			start = u64_stats_fetch_begin_bh(syncp);
+			v0 = *(((u64 *) per_cpu_ptr(mib[0], i)) + offt);
+		} while (u64_stats_fetch_retry_bh(syncp, start));
+
+		/* second mib used in USER context */
+		syncp = (struct u64_stats_sync *)(per_cpu_ptr(mib[1], i) + syncp_offset);
+		do {
+			start = u64_stats_fetch_begin(syncp);
+			v1 = *(((u64 *) per_cpu_ptr(mib[1], i)) + offt);
+		} while (u64_stats_fetch_retry(syncp, start));
+
+		res += v0 + v1;
+	}
+	return res;
+}
+EXPORT_SYMBOL_GPL(snmp_fold_field64);
+#endif
+
 int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align)
 {
 	BUG_ON(ptr == NULL);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index e320ca6..d41cf26 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -344,9 +344,9 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 		   sysctl_ip_default_ttl);
 
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
-		seq_printf(seq, " %lu",
-			   snmp_fold_field((void __percpu **)net->mib.ip_statistics,
-					   snmp4_ipstats_list[i].entry));
+		seq_printf(seq, " %llu",
+			   snmp_fold_field64((void __percpu **)net->mib.ip_statistics,
+					   snmp4_ipstats_list[i].entry, offsetof(struct ipstats_mib, syncp)));
 
 	icmp_put(seq);	/* RFC 2011 compatibility */
 	icmpmsg_put(seq);
@@ -432,9 +432,9 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 
 	seq_puts(seq, "\nIpExt:");
 	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
-		seq_printf(seq, " %lu",
-			   snmp_fold_field((void __percpu **)net->mib.ip_statistics,
-					   snmp4_ipextstats_list[i].entry));
+		seq_printf(seq, " %llu",
+			   snmp_fold_field64((void __percpu **)net->mib.ip_statistics,
+					   snmp4_ipextstats_list[i].entry, offsetof(struct ipstats_mib, syncp)));
 
 	seq_putc(seq, '\n');
 	return 0;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c20a7c2..56165ae 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3858,12 +3858,28 @@ static inline void __snmp6_fill_stats(u64 *stats, void __percpu **mib,
 	memset(&stats[items], 0, pad);
 }
 
+static inline void __snmp6_fill_stats64(u64 *stats, void __percpu **mib,
+				      int items, int bytes, size_t syncpoff)
+{
+	int i;
+	int pad = bytes - sizeof(u64) * items;
+	BUG_ON(pad < 0);
+
+	/* Use put_unaligned() because stats may not be aligned for u64. */
+	put_unaligned(items, &stats[0]);
+	for (i = 1; i < items; i++)
+		put_unaligned(snmp_fold_field64(mib, i, syncpoff), &stats[i]);
+
+	memset(&stats[items], 0, pad);
+}
+
 static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 			     int bytes)
 {
 	switch (attrtype) {
 	case IFLA_INET6_STATS:
-		__snmp6_fill_stats(stats, (void __percpu **)idev->stats.ipv6, IPSTATS_MIB_MAX, bytes);
+		__snmp6_fill_stats64(stats, (void __percpu **)idev->stats.ipv6,
+				     IPSTATS_MIB_MAX, bytes, offsetof(struct ipstats_mib, syncp));
 		break;
 	case IFLA_INET6_ICMP6STATS:
 		__snmp6_fill_stats(stats, (void __percpu **)idev->stats.icmpv6, ICMP6_MIB_MAX, bytes);
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 566798d..acc1960 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -179,12 +179,21 @@ static void snmp6_seq_show_item(struct seq_file *seq, void __percpu **mib,
 			   snmp_fold_field(mib, itemlist[i].entry));
 }
 
+static void snmp6_seq_show_item64(struct seq_file *seq, void __percpu **mib,
+				const struct snmp_mib *itemlist, size_t syncpoff)
+{
+	int i;
+	for (i=0; itemlist[i].name; i++)
+		seq_printf(seq, "%-32s\t%llu\n", itemlist[i].name,
+			   snmp_fold_field64(mib, itemlist[i].entry, syncpoff));
+}
+
 static int snmp6_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = (struct net *)seq->private;
 
-	snmp6_seq_show_item(seq, (void __percpu **)net->mib.ipv6_statistics,
-			    snmp6_ipstats_list);
+	snmp6_seq_show_item64(seq, (void __percpu **)net->mib.ipv6_statistics,
+			    snmp6_ipstats_list, offsetof(struct ipstats_mib, syncp));
 	snmp6_seq_show_item(seq, (void __percpu **)net->mib.icmpv6_statistics,
 			    snmp6_icmp6_list);
 	snmp6_seq_show_icmpv6msg(seq,


