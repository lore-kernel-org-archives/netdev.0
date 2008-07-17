From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 8/16] mib: put icmp statistics on struct net
Date: Thu, 17 Jul 2008 17:31:10 +0400
Message-ID: <487F499E.6050802@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57589 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754652AbYGQNbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:31:15 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/icmp.h      |    5 ++---
 include/net/netns/mib.h |    1 +
 net/ipv4/af_inet.c      |   11 ++++++-----
 net/ipv4/icmp.c         |    2 --
 net/ipv4/proc.c         |    8 ++++----
 5 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 03b9972..e14f2c0 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -29,10 +29,9 @@ struct icmp_err {
 };
 
 extern struct icmp_err icmp_err_convert[];
-DECLARE_SNMP_STAT(struct icmp_mib, icmp_statistics);
 DECLARE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
-#define ICMP_INC_STATS(net, field)	SNMP_INC_STATS(icmp_statistics, field)
-#define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH(icmp_statistics, field)
+#define ICMP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmp_statistics, field)
+#define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.icmp_statistics, field)
 #define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS(icmpmsg_statistics, field+256)
 #define ICMPMSGIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH(icmpmsg_statistics, field)
 
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 23e699f..03f5abd 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -9,6 +9,7 @@ struct netns_mib {
 	DEFINE_SNMP_STAT(struct linux_mib, net_statistics);
 	DEFINE_SNMP_STAT(struct udp_mib, udp_statistics);
 	DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics);
+	DEFINE_SNMP_STAT(struct icmp_mib, icmp_statistics);
 };
 
 #endif
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index bf1f200..5c72bb3 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1355,10 +1355,15 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 	if (snmp_mib_init((void **)net->mib.udplite_statistics,
 			  sizeof(struct udp_mib)) < 0)
 		goto err_udplite_mib;
+	if (snmp_mib_init((void **)net->mib.icmp_statistics,
+			  sizeof(struct icmp_mib)) < 0)
+		goto err_icmp_mib;
 
 	tcp_mib_init(net);
 	return 0;
 
+err_icmp_mib:
+	snmp_mib_free((void **)net->mib.udplite_statistics);
 err_udplite_mib:
 	snmp_mib_free((void **)net->mib.udp_statistics);
 err_udp_mib:
@@ -1373,6 +1378,7 @@ err_tcp_mib:
 
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
+	snmp_mib_free((void **)net->mib.icmp_statistics);
 	snmp_mib_free((void **)net->mib.udplite_statistics);
 	snmp_mib_free((void **)net->mib.udp_statistics);
 	snmp_mib_free((void **)net->mib.net_statistics);
@@ -1387,9 +1393,6 @@ static __net_initdata struct pernet_operations ipv4_mib_ops = {
 
 static int __init init_ipv4_mibs(void)
 {
-	if (snmp_mib_init((void **)icmp_statistics,
-			  sizeof(struct icmp_mib)) < 0)
-		goto err_icmp_mib;
 	if (snmp_mib_init((void **)icmpmsg_statistics,
 			  sizeof(struct icmpmsg_mib)) < 0)
 		goto err_icmpmsg_mib;
@@ -1402,8 +1405,6 @@ static int __init init_ipv4_mibs(void)
 err_net:
 	snmp_mib_free((void **)icmpmsg_statistics);
 err_icmpmsg_mib:
-	snmp_mib_free((void **)icmp_statistics);
-err_icmp_mib:
 	return -ENOMEM;
 }
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index ea60ad4..33f9589 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -114,7 +114,6 @@ struct icmp_bxm {
 /*
  *	Statistics
  */
-DEFINE_SNMP_STAT(struct icmp_mib, icmp_statistics) __read_mostly;
 DEFINE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics) __read_mostly;
 
 /* An array of errno for error messages from dest unreach. */
@@ -1213,5 +1212,4 @@ int __init icmp_init(void)
 
 EXPORT_SYMBOL(icmp_err_convert);
 EXPORT_SYMBOL(icmp_send);
-EXPORT_SYMBOL(icmp_statistics);
 EXPORT_SYMBOL(xrlim_allow);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 7654183..6b43cce 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -311,15 +311,15 @@ static void icmp_put(struct seq_file *seq)
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " Out%s", icmpmibmap[i].name);
 	seq_printf(seq, "\nIcmp: %lu %lu",
-		snmp_fold_field((void **) icmp_statistics, ICMP_MIB_INMSGS),
-		snmp_fold_field((void **) icmp_statistics, ICMP_MIB_INERRORS));
+		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_INMSGS),
+		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_INERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
 			snmp_fold_field((void **) icmpmsg_statistics,
 				icmpmibmap[i].index));
 	seq_printf(seq, " %lu %lu",
-		snmp_fold_field((void **) icmp_statistics, ICMP_MIB_OUTMSGS),
-		snmp_fold_field((void **) icmp_statistics, ICMP_MIB_OUTERRORS));
+		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_OUTMSGS),
+		snmp_fold_field((void **) init_net.mib.icmp_statistics, ICMP_MIB_OUTERRORS));
 	for (i=0; icmpmibmap[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
 			snmp_fold_field((void **) icmpmsg_statistics,
-- 
1.5.5.1

