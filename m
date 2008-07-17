From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/16] mib: put ip statistics on struct net
Date: Thu, 17 Jul 2008 17:26:58 +0400
Message-ID: <487F48A2.5010108@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39136 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738AbYGQN1E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:27:04 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to tcp one.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h        |    7 +++----
 include/net/netns/mib.h |    1 +
 net/ipv4/af_inet.c      |   11 ++++++-----
 net/ipv4/ip_input.c     |    8 --------
 net/ipv4/proc.c         |    4 ++--
 5 files changed, 12 insertions(+), 19 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 02924fb..ff2535a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -156,10 +156,9 @@ struct ipv4_config
 };
 
 extern struct ipv4_config ipv4_config;
-DECLARE_SNMP_STAT(struct ipstats_mib, ip_statistics);
-#define IP_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(ip_statistics, field); } while (0)
-#define IP_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(ip_statistics, field); } while (0)
-#define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH(ip_statistics, field, val)
+#define IP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ip_statistics, field)
+#define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip_statistics, field)
+#define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH((net)->mib.ip_statistics, field, val)
 DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(net_statistics, field); } while (0)
 #define NET_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(net_statistics, field); } while (0)
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 8f96079..1094ebb 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -5,6 +5,7 @@
 
 struct netns_mib {
 	DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics);
+	DEFINE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 };
 
 #endif
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c1a3e98..3090a93 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1345,16 +1345,22 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 	if (snmp_mib_init((void **)net->mib.tcp_statistics,
 			  sizeof(struct tcp_mib)) < 0)
 		goto err_tcp_mib;
+	if (snmp_mib_init((void **)net->mib.ip_statistics,
+			  sizeof(struct ipstats_mib)) < 0)
+		goto err_ip_mib;
 
 	tcp_mib_init(net);
 	return 0;
 
+err_ip_mib:
+	snmp_mib_free((void **)net->mib.tcp_statistics);
 err_tcp_mib:
 	return -ENOMEM;
 }
 
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
+	snmp_mib_free((void **)net->mib.ip_statistics);
 	snmp_mib_free((void **)net->mib.tcp_statistics);
 }
 
@@ -1368,9 +1374,6 @@ static int __init init_ipv4_mibs(void)
 	if (snmp_mib_init((void **)net_statistics,
 			  sizeof(struct linux_mib)) < 0)
 		goto err_net_mib;
-	if (snmp_mib_init((void **)ip_statistics,
-			  sizeof(struct ipstats_mib)) < 0)
-		goto err_ip_mib;
 	if (snmp_mib_init((void **)icmp_statistics,
 			  sizeof(struct icmp_mib)) < 0)
 		goto err_icmp_mib;
@@ -1398,8 +1401,6 @@ err_udp_mib:
 err_icmpmsg_mib:
 	snmp_mib_free((void **)icmp_statistics);
 err_icmp_mib:
-	snmp_mib_free((void **)ip_statistics);
-err_ip_mib:
 	snmp_mib_free((void **)net_statistics);
 err_net_mib:
 	return -ENOMEM;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 043f640..e0bed56 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -145,12 +145,6 @@
 #include <linux/netlink.h>
 
 /*
- *	SNMP management statistics
- */
-
-DEFINE_SNMP_STAT(struct ipstats_mib, ip_statistics) __read_mostly;
-
-/*
  *	Process Router Attention IP option
  */
 int ip_call_ra_chain(struct sk_buff *skb)
@@ -447,5 +441,3 @@ drop:
 out:
 	return NET_RX_DROP;
 }
-
-EXPORT_SYMBOL(ip_statistics);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 19e1d8e..2698bb2 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -344,7 +344,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)ip_statistics,
+			   snmp_fold_field((void **)init_net.mib.ip_statistics,
 					   snmp4_ipstats_list[i].entry));
 
 	icmp_put(seq);	/* RFC 2011 compatibility */
@@ -431,7 +431,7 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nIpExt:");
 	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)ip_statistics,
+			   snmp_fold_field((void **)init_net.mib.ip_statistics,
 					   snmp4_ipextstats_list[i].entry));
 
 	seq_putc(seq, '\n');
-- 
1.5.5.1

