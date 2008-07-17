From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 6/16] mib: put udp statistics on struct net
Date: Thu, 17 Jul 2008 17:29:28 +0400
Message-ID: <487F4938.5030402@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57570 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755492AbYGQN3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:29:34 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to... ouch, I repeat myself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/netns/mib.h |    1 +
 include/net/udp.h       |    9 ++++-----
 net/ipv4/af_inet.c      |   11 ++++++-----
 net/ipv4/proc.c         |    2 +-
 net/ipv4/udp.c          |    3 ---
 5 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index b5b1115..738c87c 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -7,6 +7,7 @@ struct netns_mib {
 	DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 	DEFINE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 	DEFINE_SNMP_STAT(struct linux_mib, net_statistics);
+	DEFINE_SNMP_STAT(struct udp_mib, udp_statistics);
 };
 
 #endif
diff --git a/include/net/udp.h b/include/net/udp.h
index 3e55159..ba55441 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -148,7 +148,6 @@ extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
 				   char __user *optval, int optlen,
 				   int (*push_pending_frames)(struct sock *));
 
-DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
 DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 
 /* UDP-Lite does not have a standardized MIB yet, so we inherit from UDP */
@@ -158,12 +157,12 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
-#define UDP_INC_STATS_USER(net, field, is_udplite)	      do { (void)net; \
+#define UDP_INC_STATS_USER(net, field, is_udplite)	      do { \
 	if (is_udplite) SNMP_INC_STATS_USER(udplite_statistics, field);       \
-	else		SNMP_INC_STATS_USER(udp_statistics, field);  }  while(0)
-#define UDP_INC_STATS_BH(net, field, is_udplite) 	      do { (void)net; \
+	else		SNMP_INC_STATS_USER((net)->mib.udp_statistics, field);  }  while(0)
+#define UDP_INC_STATS_BH(net, field, is_udplite) 	      do { \
 	if (is_udplite) SNMP_INC_STATS_BH(udplite_statistics, field);         \
-	else		SNMP_INC_STATS_BH(udp_statistics, field);    }  while(0)
+	else		SNMP_INC_STATS_BH((net)->mib.udp_statistics, field);    }  while(0)
 
 #define UDP6_INC_STATS_BH(net, field, is_udplite) 	    do { (void)net;  \
 	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);         \
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 776ed31..1f41816 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1349,10 +1349,15 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 	if (snmp_mib_init((void **)net->mib.net_statistics,
 			  sizeof(struct linux_mib)) < 0)
 		goto err_net_mib;
+	if (snmp_mib_init((void **)net->mib.udp_statistics,
+			  sizeof(struct udp_mib)) < 0)
+		goto err_udp_mib;
 
 	tcp_mib_init(net);
 	return 0;
 
+err_udp_mib:
+	snmp_mib_free((void **)net->mib.net_statistics);
 err_net_mib:
 	snmp_mib_free((void **)net->mib.ip_statistics);
 err_ip_mib:
@@ -1363,6 +1368,7 @@ err_tcp_mib:
 
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
+	snmp_mib_free((void **)net->mib.udp_statistics);
 	snmp_mib_free((void **)net->mib.net_statistics);
 	snmp_mib_free((void **)net->mib.ip_statistics);
 	snmp_mib_free((void **)net->mib.tcp_statistics);
@@ -1381,9 +1387,6 @@ static int __init init_ipv4_mibs(void)
 	if (snmp_mib_init((void **)icmpmsg_statistics,
 			  sizeof(struct icmpmsg_mib)) < 0)
 		goto err_icmpmsg_mib;
-	if (snmp_mib_init((void **)udp_statistics,
-			  sizeof(struct udp_mib)) < 0)
-		goto err_udp_mib;
 	if (snmp_mib_init((void **)udplite_statistics,
 			  sizeof(struct udp_mib)) < 0)
 		goto err_udplite_mib;
@@ -1396,8 +1399,6 @@ static int __init init_ipv4_mibs(void)
 err_net:
 	snmp_mib_free((void **)udplite_statistics);
 err_udplite_mib:
-	snmp_mib_free((void **)udp_statistics);
-err_udp_mib:
 	snmp_mib_free((void **)icmpmsg_statistics);
 err_icmpmsg_mib:
 	snmp_mib_free((void **)icmp_statistics);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index ef38b1d..869085c 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -374,7 +374,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdp:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)udp_statistics,
+			   snmp_fold_field((void **)init_net.mib.udp_statistics,
 					   snmp4_udp_list[i].entry));
 
 	/* the UDP and UDP-Lite MIBs are the same */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1560d11..a751770 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -108,9 +108,6 @@
  *	Snmp MIB for the UDP layer
  */
 
-DEFINE_SNMP_STAT(struct udp_mib, udp_statistics) __read_mostly;
-EXPORT_SYMBOL(udp_statistics);
-
 DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
 EXPORT_SYMBOL(udp_stats_in6);
 
-- 
1.5.5.1

