From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 5/16] mib: put net statistics on struct net
Date: Thu, 17 Jul 2008 17:28:00 +0400
Message-ID: <487F48E0.8050804@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57549 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756239AbYGQN2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:28:06 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to ip and tcp ones :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h        |   11 +++++------
 include/net/netns/mib.h |    1 +
 net/ipv4/af_inet.c      |   14 ++++++--------
 net/ipv4/proc.c         |    2 +-
 4 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index ff2535a..b5862b9 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -159,12 +159,11 @@ extern struct ipv4_config ipv4_config;
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ip_statistics, field)
 #define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip_statistics, field)
 #define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH((net)->mib.ip_statistics, field, val)
-DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
-#define NET_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(net_statistics, field); } while (0)
-#define NET_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(net_statistics, field); } while (0)
-#define NET_INC_STATS_USER(net, field) 	do { (void)net; SNMP_INC_STATS_USER(net_statistics, field); } while (0)
-#define NET_ADD_STATS_BH(net, field, adnd) do { (void)net; SNMP_ADD_STATS_BH(net_statistics, field, adnd); } while (0)
-#define NET_ADD_STATS_USER(net, field, adnd) do { (void)net; SNMP_ADD_STATS_USER(net_statistics, field, adnd); } while (0)
+#define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
+#define NET_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.net_statistics, field)
+#define NET_INC_STATS_USER(net, field) 	SNMP_INC_STATS_USER((net)->mib.net_statistics, field)
+#define NET_ADD_STATS_BH(net, field, adnd) SNMP_ADD_STATS_BH((net)->mib.net_statistics, field, adnd)
+#define NET_ADD_STATS_USER(net, field, adnd) SNMP_ADD_STATS_USER((net)->mib.net_statistics, field, adnd)
 
 extern unsigned long snmp_fold_field(void *mib[], int offt);
 extern int snmp_mib_init(void *ptr[2], size_t mibsize);
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 1094ebb..b5b1115 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -6,6 +6,7 @@
 struct netns_mib {
 	DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 	DEFINE_SNMP_STAT(struct ipstats_mib, ip_statistics);
+	DEFINE_SNMP_STAT(struct linux_mib, net_statistics);
 };
 
 #endif
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 3090a93..776ed31 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -115,8 +115,6 @@
 #include <linux/mroute.h>
 #endif
 
-DEFINE_SNMP_STAT(struct linux_mib, net_statistics) __read_mostly;
-
 extern void ip_mc_drop_socket(struct sock *sk);
 
 /* The inetsw table contains everything that inet_create needs to
@@ -1348,10 +1346,15 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 	if (snmp_mib_init((void **)net->mib.ip_statistics,
 			  sizeof(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
+	if (snmp_mib_init((void **)net->mib.net_statistics,
+			  sizeof(struct linux_mib)) < 0)
+		goto err_net_mib;
 
 	tcp_mib_init(net);
 	return 0;
 
+err_net_mib:
+	snmp_mib_free((void **)net->mib.ip_statistics);
 err_ip_mib:
 	snmp_mib_free((void **)net->mib.tcp_statistics);
 err_tcp_mib:
@@ -1360,6 +1363,7 @@ err_tcp_mib:
 
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
+	snmp_mib_free((void **)net->mib.net_statistics);
 	snmp_mib_free((void **)net->mib.ip_statistics);
 	snmp_mib_free((void **)net->mib.tcp_statistics);
 }
@@ -1371,9 +1375,6 @@ static __net_initdata struct pernet_operations ipv4_mib_ops = {
 
 static int __init init_ipv4_mibs(void)
 {
-	if (snmp_mib_init((void **)net_statistics,
-			  sizeof(struct linux_mib)) < 0)
-		goto err_net_mib;
 	if (snmp_mib_init((void **)icmp_statistics,
 			  sizeof(struct icmp_mib)) < 0)
 		goto err_icmp_mib;
@@ -1401,8 +1402,6 @@ err_udp_mib:
 err_icmpmsg_mib:
 	snmp_mib_free((void **)icmp_statistics);
 err_icmp_mib:
-	snmp_mib_free((void **)net_statistics);
-err_net_mib:
 	return -ENOMEM;
 }
 
@@ -1582,5 +1581,4 @@ EXPORT_SYMBOL(inet_sock_destruct);
 EXPORT_SYMBOL(inet_stream_connect);
 EXPORT_SYMBOL(inet_stream_ops);
 EXPORT_SYMBOL(inet_unregister_protosw);
-EXPORT_SYMBOL(net_statistics);
 EXPORT_SYMBOL(sysctl_ip_nonlocal_bind);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 2698bb2..ef38b1d 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -421,7 +421,7 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nTcpExt:");
 	for (i = 0; snmp4_net_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)net_statistics,
+			   snmp_fold_field((void **)init_net.mib.net_statistics,
 					   snmp4_net_list[i].entry));
 
 	seq_puts(seq, "\nIpExt:");
-- 
1.5.5.1

