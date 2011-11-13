From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: reduce percpu needs for icmpv6msg mibs
Date: Sun, 13 Nov 2011 12:24:04 +0100
Message-ID: <1321183444.17837.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61245 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab1KMLYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 06:24:10 -0500
Received: by wyh15 with SMTP id 15so5066559wyh.19
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2011 03:24:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading /proc/net/snmp6 on a machine with a lot of cpus is very
expensive (can be ~88000 us).

This is because ICMPV6MSG MIB uses 4096 bytes per cpu, and folding
values for all possible cpus can read 16 Mbytes of memory (32MBytes on
non x86 arches)

ICMP messages are not considered as fast path on a typical server, and
eventually few cpus handle them anyway. We can afford an atomic
operation instead of using percpu data.

This saves 4096 bytes per cpu and per network namespace.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ipv6.h      |   15 ++++++++++++---
 include/net/netns/mib.h |    2 +-
 include/net/snmp.h      |    2 +-
 net/ipv6/af_inet6.c     |    8 ++++----
 net/ipv6/proc.c         |   15 +++++----------
 5 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a366a8a..3f0258d 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -132,6 +132,15 @@ extern struct ctl_path net_ipv6_ctl_path[];
 	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));\
 })
 
+/* per device and per net counters are atomic_long_t */
+#define _DEVINC_ATOMIC_ATOMIC(net, statname, idev, field)		\
+({									\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_INC_STATS_ATOMIC_LONG((_idev)->stats.statname##dev, (field)); \
+	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.statname##_statistics, (field));\
+})
+
 #define _DEVADD(net, statname, modifier, idev, field, val)		\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
@@ -168,11 +177,11 @@ extern struct ctl_path net_ipv6_ctl_path[];
 		_DEVINCATOMIC(net, icmpv6, _BH, idev, field)
 
 #define ICMP6MSGOUT_INC_STATS(net, idev, field)		\
-	_DEVINCATOMIC(net, icmpv6msg, , idev, field +256)
+	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field +256)
 #define ICMP6MSGOUT_INC_STATS_BH(net, idev, field)	\
-	_DEVINCATOMIC(net, icmpv6msg, _BH, idev, field +256)
+	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field +256)
 #define ICMP6MSGIN_INC_STATS_BH(net, idev, field)	\
-	_DEVINCATOMIC(net, icmpv6msg, _BH, idev, field)
+	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field)
 
 struct ip6_ra_chain {
 	struct ip6_ra_chain	*next;
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index f360135..30f6728 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -18,7 +18,7 @@ struct netns_mib {
 	DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 	DEFINE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
 	DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
-	DEFINE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
+	DEFINE_SNMP_STAT_ATOMIC(struct icmpv6msg_mib, icmpv6msg_statistics);
 #endif
 #ifdef CONFIG_XFRM_STATISTICS
 	DEFINE_SNMP_STAT(struct linux_xfrm_mib, xfrm_statistics);
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 0feafa6..2f65e16 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -84,7 +84,7 @@ struct icmpv6_mib_device {
 #define ICMP6MSG_MIB_MAX  __ICMP6MSG_MIB_MAX
 /* per network ns counters */
 struct icmpv6msg_mib {
-	unsigned long	mibs[ICMP6MSG_MIB_MAX];
+	atomic_long_t	mibs[ICMP6MSG_MIB_MAX];
 };
 /* per device counters, (shared on all cpus) */
 struct icmpv6msg_mib_device {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 1040424..282dc7a 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -985,9 +985,9 @@ static int __net_init ipv6_init_mibs(struct net *net)
 			  sizeof(struct icmpv6_mib),
 			  __alignof__(struct icmpv6_mib)) < 0)
 		goto err_icmp_mib;
-	if (snmp_mib_init((void __percpu **)net->mib.icmpv6msg_statistics,
-			  sizeof(struct icmpv6msg_mib),
-			  __alignof__(struct icmpv6msg_mib)) < 0)
+	net->mib.icmpv6msg_statistics = kzalloc(sizeof(struct icmpv6msg_mib),
+						GFP_KERNEL);
+	if (!net->mib.icmpv6msg_statistics)
 		goto err_icmpmsg_mib;
 	return 0;
 
@@ -1008,7 +1008,7 @@ static void ipv6_cleanup_mibs(struct net *net)
 	snmp_mib_free((void __percpu **)net->mib.udplite_stats_in6);
 	snmp_mib_free((void __percpu **)net->mib.ipv6_statistics);
 	snmp_mib_free((void __percpu **)net->mib.icmpv6_statistics);
-	snmp_mib_free((void __percpu **)net->mib.icmpv6msg_statistics);
+	kfree(net->mib.icmpv6msg_statistics);
 }
 
 static int __net_init inet6_net_init(struct net *net)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 1008ce9..fdeb6d0 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -142,11 +142,7 @@ static const struct snmp_mib snmp6_udplite6_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
-/* can be called either with percpu mib (pcpumib != NULL),
- * or shared one (smib != NULL)
- */
-static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void __percpu **pcpumib,
-				     atomic_long_t *smib)
+static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, atomic_long_t *smib)
 {
 	char name[32];
 	int i;
@@ -163,14 +159,14 @@ static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void __percpu **pcpum
 		snprintf(name, sizeof(name), "Icmp6%s%s",
 			i & 0x100 ? "Out" : "In", p);
 		seq_printf(seq, "%-32s\t%lu\n", name,
-			pcpumib ? snmp_fold_field(pcpumib, i) : atomic_long_read(smib + i));
+			   atomic_long_read(smib + i));
 	}
 
 	/* print by number (nonzero only) - ICMPMsgStat format */
 	for (i = 0; i < ICMP6MSG_MIB_MAX; i++) {
 		unsigned long val;
 
-		val = pcpumib ? snmp_fold_field(pcpumib, i) : atomic_long_read(smib + i);
+		val = atomic_long_read(smib + i);
 		if (!val)
 			continue;
 		snprintf(name, sizeof(name), "Icmp6%sType%u",
@@ -215,8 +211,7 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 			    snmp6_ipstats_list, offsetof(struct ipstats_mib, syncp));
 	snmp6_seq_show_item(seq, (void __percpu **)net->mib.icmpv6_statistics,
 			    NULL, snmp6_icmp6_list);
-	snmp6_seq_show_icmpv6msg(seq,
-			    (void __percpu **)net->mib.icmpv6msg_statistics, NULL);
+	snmp6_seq_show_icmpv6msg(seq, net->mib.icmpv6msg_statistics->mibs);
 	snmp6_seq_show_item(seq, (void __percpu **)net->mib.udp_stats_in6,
 			    NULL, snmp6_udp6_list);
 	snmp6_seq_show_item(seq, (void __percpu **)net->mib.udplite_stats_in6,
@@ -246,7 +241,7 @@ static int snmp6_dev_seq_show(struct seq_file *seq, void *v)
 			    snmp6_ipstats_list);
 	snmp6_seq_show_item(seq, NULL, idev->stats.icmpv6dev->mibs,
 			    snmp6_icmp6_list);
-	snmp6_seq_show_icmpv6msg(seq, NULL, idev->stats.icmpv6msgdev->mibs);
+	snmp6_seq_show_icmpv6msg(seq, idev->stats.icmpv6msgdev->mibs);
 	return 0;
 }
 
