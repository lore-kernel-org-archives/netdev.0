From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 7/16] mib: put udplite statistics on struct net
Date: Thu, 17 Jul 2008 17:30:14 +0400
Message-ID: <487F4966.5080707@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57581 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754692AbYGQNaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:30:20 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/netns/mib.h |    1 +
 include/net/udp.h       |    5 ++---
 net/ipv4/af_inet.c      |   11 ++++++-----
 net/ipv4/proc.c         |    2 +-
 net/ipv4/udplite.c      |    1 -
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 738c87c..23e699f 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -8,6 +8,7 @@ struct netns_mib {
 	DEFINE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 	DEFINE_SNMP_STAT(struct linux_mib, net_statistics);
 	DEFINE_SNMP_STAT(struct udp_mib, udp_statistics);
+	DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics);
 };
 
 #endif
diff --git a/include/net/udp.h b/include/net/udp.h
index ba55441..addcdc6 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -151,17 +151,16 @@ extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
 DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 
 /* UDP-Lite does not have a standardized MIB yet, so we inherit from UDP */
-DECLARE_SNMP_STAT(struct udp_mib, udplite_statistics);
 DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
 #define UDP_INC_STATS_USER(net, field, is_udplite)	      do { \
-	if (is_udplite) SNMP_INC_STATS_USER(udplite_statistics, field);       \
+	if (is_udplite) SNMP_INC_STATS_USER((net)->mib.udplite_statistics, field);       \
 	else		SNMP_INC_STATS_USER((net)->mib.udp_statistics, field);  }  while(0)
 #define UDP_INC_STATS_BH(net, field, is_udplite) 	      do { \
-	if (is_udplite) SNMP_INC_STATS_BH(udplite_statistics, field);         \
+	if (is_udplite) SNMP_INC_STATS_BH((net)->mib.udplite_statistics, field);         \
 	else		SNMP_INC_STATS_BH((net)->mib.udp_statistics, field);    }  while(0)
 
 #define UDP6_INC_STATS_BH(net, field, is_udplite) 	    do { (void)net;  \
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1f41816..bf1f200 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1352,10 +1352,15 @@ static __net_init int ipv4_mib_init_net(struct net *net)
 	if (snmp_mib_init((void **)net->mib.udp_statistics,
 			  sizeof(struct udp_mib)) < 0)
 		goto err_udp_mib;
+	if (snmp_mib_init((void **)net->mib.udplite_statistics,
+			  sizeof(struct udp_mib)) < 0)
+		goto err_udplite_mib;
 
 	tcp_mib_init(net);
 	return 0;
 
+err_udplite_mib:
+	snmp_mib_free((void **)net->mib.udp_statistics);
 err_udp_mib:
 	snmp_mib_free((void **)net->mib.net_statistics);
 err_net_mib:
@@ -1368,6 +1373,7 @@ err_tcp_mib:
 
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
+	snmp_mib_free((void **)net->mib.udplite_statistics);
 	snmp_mib_free((void **)net->mib.udp_statistics);
 	snmp_mib_free((void **)net->mib.net_statistics);
 	snmp_mib_free((void **)net->mib.ip_statistics);
@@ -1387,9 +1393,6 @@ static int __init init_ipv4_mibs(void)
 	if (snmp_mib_init((void **)icmpmsg_statistics,
 			  sizeof(struct icmpmsg_mib)) < 0)
 		goto err_icmpmsg_mib;
-	if (snmp_mib_init((void **)udplite_statistics,
-			  sizeof(struct udp_mib)) < 0)
-		goto err_udplite_mib;
 
 	if (register_pernet_subsys(&ipv4_mib_ops))
 		goto err_net;
@@ -1397,8 +1400,6 @@ static int __init init_ipv4_mibs(void)
 	return 0;
 
 err_net:
-	snmp_mib_free((void **)udplite_statistics);
-err_udplite_mib:
 	snmp_mib_free((void **)icmpmsg_statistics);
 err_icmpmsg_mib:
 	snmp_mib_free((void **)icmp_statistics);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 869085c..7654183 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -385,7 +385,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 	seq_puts(seq, "\nUdpLite:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %lu",
-			   snmp_fold_field((void **)udplite_statistics,
+			   snmp_fold_field((void **)init_net.mib.udplite_statistics,
 					   snmp4_udp_list[i].entry));
 
 	seq_putc(seq, '\n');
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 4ad16b6..3c80796 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -11,7 +11,6 @@
  *		2 of the License, or (at your option) any later version.
  */
 #include "udp_impl.h"
-DEFINE_SNMP_STAT(struct udp_mib, udplite_statistics)	__read_mostly;
 
 struct hlist_head 	udplite_hash[UDP_HTABLE_SIZE];
 
-- 
1.5.5.1

