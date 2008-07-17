From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 9/16] mib: put icmpmsg statistics on struct net
Date: Thu, 17 Jul 2008 17:32:00 +0400
Message-ID: <487F49D0.7070501@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57593 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353AbYGQNcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:32:07 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/icmp.h      |    5 ++---
 include/net/netns/mib.h |    1 +
 net/ipv4/af_inet.c      |   12 ++++++------
 net/ipv4/icmp.c         |    5 -----
 net/ipv4/proc.c         |   10 +++++-----
 5 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index e14f2c0..dfa72d4 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -29,11 +29,10 @@ struct icmp_err {
 };
 
 extern struct icmp_err icmp_err_convert[];
-DECLARE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
 #define ICMP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmp_statistics, field)
 #define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.icmp_statistics, field)
-#define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS(icmpmsg_statistics, field+256)
-#define ICMPMSGIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH(icmpmsg_statistics, field)
+#define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmpmsg_statistics, field+256)
+#define ICMPMSGIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.icmpmsg_statistics, field)
 
 struct dst_entry;
 struct net_proto_family;
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 03f5abd..4491476 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -10,6 +10,7 @@ struct netns_mib {
 	DEFINE_SNMP_STAT(struct udp_mib, udp_statistics);
 	DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics);
 	DEFINE_SNMP_STAT(struct icmp_mib, icmp_statistics);
+	DEFINE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
 };
 
 #endif
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5c72bb3..36ff6dc 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1358,10 +1358,15 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 	if (snmp_mib_init((void **)net->mib.icmp_statistics,
 			  sizeof(struct icmp_mib)) < 0)
 		goto err_icmp_mib;
+	if (snmp_mib_init((void **)net->mib.icmpmsg_statistics,
+			  sizeof(struct icmpmsg_mib)) < 0)
+		goto err_icmpmsg_mib;
 
 	tcp_mib_init(net);
 	return 0;
 
+err_icmpmsg_mib:
+	snmp_mib_free((void **)net->mib.icmp_statistics);
 err_icmp_mib:
 	snmp_mib_free((void **)net->mib.udplite_statistics);
 err_udplite_mib:
@@ -1378,6 +1383,7 @@ err_tcp_mib:
 
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
+	snmp_mib_free((void **)net->mib.icmpmsg_statistics);
 	snmp_mib_free((void **)net->mib.icmp_statistics);
 	snmp_mib_free((void **)net->mib.udplite_statistics);
 	snmp_mib_free((void **)net->mib.udp_statistics);
@@ -1393,18 +1399,12 @@ static __net_initdata struct pernet_operations ipv4_mib_ops = {
 
 static int __init init_ipv4_mibs(void)
 {
-	if (snmp_mib_init((void **)icmpmsg_statistics,
-			  sizeof(struct icmpmsg_mib)) < 0)
-		goto err_icmpmsg_mib;
-
 	if (register_pernet_subsys(&ipv4_mib_ops))
 		goto err_net;
 
 	return 0;
 
 err_net:
-	snmp_mib_free((void **)icmpmsg_statistics);
-err_icmpmsg_mib:
 	return -ENOMEM;
 }
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 33f9589..8605586 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -111,11 +111,6 @@ struct icmp_bxm {
 	unsigned char  optbuf[40];
 };
 
-/*
- *	Statistics
- */
-DEFINE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics) __read_mostly;
-
 /* An array of errno for error messages from dest unreach. */
 /* RFC 1122: 3.2.2.1 States that NET_UNREACH, HOST_UNREACH and SR_FAILED MUST be considered 'transient errs'. */
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 6b43cce..e11144b 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -270,7 +270,7 @@ static void icmpmsg_put(struct seq_file *seq)
 	count = 0;
 	for (i = 0; i < ICMPMSG_MIB_MAX; i++) {
 
-		if (snmp_fold_field((void **) icmpmsg_statistics, i))
+		if (snmp_fold_field((void **) init_net.mib.icmpmsg_statistics, i))
 			out[count++] = i;
 		if (count < PERLINE)
 			continue;
@@ -282,7 +282,7 @@ static void icmpmsg_put(struct seq_file *seq)
 		seq_printf(seq, "\nIcmpMsg: ");
 		for (j = 0; j < PERLINE; ++j)
 			seq_printf(seq, " %lu",
-				snmp_fold_field((void **) icmpmsg_statistics,
+				snmp_fold_field((void **) init_net.mib.icmpmsg_statistics,
 				out[j]));
 		seq_putc(seq, '\n');
 	}
@@ -294,7 +294,7 @@ static void icmpmsg_put(struct seq_file *seq)
 		seq_printf(seq, "\nIcmpMsg:");
 		for (j = 0; j < count; ++j)
 			seq_printf(seq, " %lu", snmp_fold_field((void **)
-				icmpmsg_statistics, out[j]));
+				init_net.mib.icmpmsg_statistics, out[j]));
 	}
 
 #undef PERLINE
@@ -315,14 +315,14 @@ static void icmp_put(struct seq_file *seq)
 		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_INERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			snmp_fold_field((void **) icmpmsg_statistics,
+			snmp_fold_field((void **) init_net.mib.icmpmsg_statistics,
 				icmpmibmap[i].index));
 	seq_printf(seq, " %lu %lu",
 		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_OUTMSGS),
 		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_OUTERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			snmp_fold_field((void **) icmpmsg_statistics,
+			snmp_fold_field((void **) init_net.mib.icmpmsg_statistics,
 				icmpmibmap[i].index | 0x100));
 }
 
-- 
1.5.5.1

