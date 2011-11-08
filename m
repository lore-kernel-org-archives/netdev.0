From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: reduce percpu needs for icmpmsg mibs
Date: Wed, 09 Nov 2011 00:04:43 +0100
Message-ID: <1320793483.26025.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62241 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353Ab1KHXEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 18:04:47 -0500
Received: by wyh15 with SMTP id 15so1056325wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 15:04:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading /proc/net/snmp on a machine with a lot of cpus is very expensive
(can be ~88000 us).

This is because ICMPMSG MIB uses 4096 bytes per cpu, and folding values
for all possible cpus can read 16 Mbytes of memory.

ICMP messages are not considered as fast path on a typical server, and
eventually few cpus handle them anyway. We can afford an atomic
operation instead of using percpu data.

This saves 4096 bytes per cpu and per network namespace.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
If this patch is accepted, I'll submit the IPv6 part as well.

 include/net/icmp.h      |    4 ++--
 include/net/netns/mib.h |    2 +-
 include/net/snmp.h      |    2 +-
 net/ipv4/af_inet.c      |    8 ++++----
 net/ipv4/proc.c         |    9 ++++-----
 5 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index f0698b9..75d6156 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -31,8 +31,8 @@ struct icmp_err {
 extern const struct icmp_err icmp_err_convert[];
 #define ICMP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmp_statistics, field)
 #define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.icmp_statistics, field)
-#define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmpmsg_statistics, field+256)
-#define ICMPMSGIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.icmpmsg_statistics, field)
+#define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field+256)
+#define ICMPMSGIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field)
 
 struct dst_entry;
 struct net_proto_family;
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 0b44112..f360135 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -10,7 +10,7 @@ struct netns_mib {
 	DEFINE_SNMP_STAT(struct udp_mib, udp_statistics);
 	DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics);
 	DEFINE_SNMP_STAT(struct icmp_mib, icmp_statistics);
-	DEFINE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
+	DEFINE_SNMP_STAT_ATOMIC(struct icmpmsg_mib, icmpmsg_statistics);
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct proc_dir_entry *proc_net_devsnmp6;
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 8f0f9ac..0feafa6 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -67,7 +67,7 @@ struct icmp_mib {
 
 #define ICMPMSG_MIB_MAX	__ICMPMSG_MIB_MAX
 struct icmpmsg_mib {
-	unsigned long	mibs[ICMPMSG_MIB_MAX];
+	atomic_long_t	mibs[ICMPMSG_MIB_MAX];
 };
 
 /* ICMP6 (IPv6-ICMP) */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1b5096a..b2bbcd0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1572,9 +1572,9 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 			  sizeof(struct icmp_mib),
 			  __alignof__(struct icmp_mib)) < 0)
 		goto err_icmp_mib;
-	if (snmp_mib_init((void __percpu **)net->mib.icmpmsg_statistics,
-			  sizeof(struct icmpmsg_mib),
-			  __alignof__(struct icmpmsg_mib)) < 0)
+	net->mib.icmpmsg_statistics = kzalloc(sizeof(struct icmpmsg_mib),
+					      GFP_KERNEL);
+	if (!net->mib.icmpmsg_statistics)
 		goto err_icmpmsg_mib;
 
 	tcp_mib_init(net);
@@ -1598,7 +1598,7 @@ err_tcp_mib:
 
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
-	snmp_mib_free((void __percpu **)net->mib.icmpmsg_statistics);
+	kfree(net->mib.icmpmsg_statistics);
 	snmp_mib_free((void __percpu **)net->mib.icmp_statistics);
 	snmp_mib_free((void __percpu **)net->mib.udplite_statistics);
 	snmp_mib_free((void __percpu **)net->mib.udp_statistics);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 466ea8b..961eed4 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -288,7 +288,7 @@ static void icmpmsg_put(struct seq_file *seq)
 
 	count = 0;
 	for (i = 0; i < ICMPMSG_MIB_MAX; i++) {
-		val = snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics, i);
+		val = atomic_long_read(&net->mib.icmpmsg_statistics->mibs[i]);
 		if (val) {
 			type[count] = i;
 			vals[count++] = val;
@@ -307,6 +307,7 @@ static void icmp_put(struct seq_file *seq)
 {
 	int i;
 	struct net *net = seq->private;
+	atomic_long_t *ptr = net->mib.icmpmsg_statistics->mibs;
 
 	seq_puts(seq, "\nIcmp: InMsgs InErrors");
 	for (i=0; icmpmibmap[i].name != NULL; i++)
@@ -319,15 +320,13 @@ static void icmp_put(struct seq_file *seq)
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_INERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics,
-				icmpmibmap[i].index));
+			   atomic_long_read(ptr + icmpmibmap[i].index));
 	seq_printf(seq, " %lu %lu",
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTMSGS),
 		snmp_fold_field((void __percpu **) net->mib.icmp_statistics, ICMP_MIB_OUTERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			snmp_fold_field((void __percpu **) net->mib.icmpmsg_statistics,
-				icmpmibmap[i].index | 0x100));
+			   atomic_long_read(ptr + (icmpmibmap[i].index | 0x100)));
 }
 
 /*
