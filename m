From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/16] mib: put tcp statistics on struct net
Date: Thu, 17 Jul 2008 17:25:56 +0400
Message-ID: <487F4864.9090209@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39107 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756029AbYGQN0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:26:03 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Proc temporary uses stats from init_net.

BTW, TCP_XXX_STATS are beautiful (w/o do { } while (0) facing) again :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/netns/mib.h |    1 +
 include/net/tcp.h       |    9 ++++-----
 net/ipv4/af_inet.c      |   16 +++++++++-------
 net/ipv4/proc.c         |    4 ++--
 net/ipv4/tcp.c          |    3 ---
 5 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 9f4b31e..8f96079 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -4,6 +4,7 @@
 #include <net/snmp.h>
 
 struct netns_mib {
+	DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 };
 
 #endif
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 60e5be8..92d7b55 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -265,11 +265,10 @@ static inline int tcp_too_many_orphans(struct sock *sk, int num)
 
 extern struct proto tcp_prot;
 
-DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
-#define TCP_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(tcp_statistics, field); } while (0)
-#define TCP_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(tcp_statistics, field); } while (0)
-#define TCP_DEC_STATS(net, field)	do { (void)net; SNMP_DEC_STATS(tcp_statistics, field); } while (0)
-#define TCP_ADD_STATS_USER(net, field, val) do { (void)net; SNMP_ADD_STATS_USER(tcp_statistics, field, val); } while (0)
+#define TCP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.tcp_statistics, field)
+#define TCP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.tcp_statistics, field)
+#define TCP_DEC_STATS(net, field)	SNMP_DEC_STATS((net)->mib.tcp_statistics, field)
+#define TCP_ADD_STATS_USER(net, field, val) SNMP_ADD_STATS_USER((net)->mib.tcp_statistics, field, val)
 
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b4b77aa..c1a3e98 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1342,11 +1342,20 @@ static struct net_protocol icmp_protocol = {
 
 static __net_init int ipv4_mib_init_net(struct net *net)
 {
+	if (snmp_mib_init((void **)net->mib.tcp_statistics,
+			  sizeof(struct tcp_mib)) < 0)
+		goto err_tcp_mib;
+
+	tcp_mib_init(net);
 	return 0;
+
+err_tcp_mib:
+	return -ENOMEM;
 }
 
 static __net_exit void ipv4_mib_exit_net(struct net *net)
 {
+	snmp_mib_free((void **)net->mib.tcp_statistics);
 }
 
 static __net_initdata struct pernet_operations ipv4_mib_ops = {
@@ -1368,9 +1377,6 @@ static int __init init_ipv4_mibs(void)
 	if (snmp_mib_init((void **)icmpmsg_statistics,
 			  sizeof(struct icmpmsg_mib)) < 0)
 		goto err_icmpmsg_mib;
-	if (snmp_mib_init((void **)tcp_statistics,
-			  sizeof(struct tcp_mib)) < 0)
-		goto err_tcp_mib;
 	if (snmp_mib_init((void **)udp_statistics,
 			  sizeof(struct udp_mib)) < 0)
 		goto err_udp_mib;
@@ -1378,8 +1384,6 @@ static int __init init_ipv4_mibs(void)
 			  sizeof(struct udp_mib)) < 0)
 		goto err_udplite_mib;
 
-	tcp_mib_init(&init_net);
-
 	if (register_pernet_subsys(&ipv4_mib_ops))
 		goto err_net;
 
@@ -1390,8 +1394,6 @@ err_net:
 err_udplite_mib:
 	snmp_mib_free((void **)udp_statistics);
 err_udp_mib:
-	snmp_mib_free((void **)tcp_statistics);
-err_tcp_mib:
 	snmp_mib_free((void **)icmpmsg_statistics);
 err_icmpmsg_mib:
 	snmp_mib_free((void **)icmp_statistics);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index eb5cee2..19e1d8e 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -359,11 +359,11 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 		/* MaxConn field is signed, RFC 2012 */
 		if (snmp4_tcp_list[i].entry == TCP_MIB_MAXCONN)
 			seq_printf(seq, " %ld",
-				   snmp_fold_field((void **)tcp_statistics,
+				   snmp_fold_field((void **)init_net.mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 		else
 			seq_printf(seq, " %lu",
-				   snmp_fold_field((void **)tcp_statistics,
+				   snmp_fold_field((void **)init_net.mib.tcp_statistics,
 						   snmp4_tcp_list[i].entry));
 	}
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e00ef15..21136aa 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -277,8 +277,6 @@
 
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
-DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics) __read_mostly;
-
 atomic_t tcp_orphan_count = ATOMIC_INIT(0);
 
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
@@ -2802,4 +2800,3 @@ EXPORT_SYMBOL(tcp_splice_read);
 EXPORT_SYMBOL(tcp_sendpage);
 EXPORT_SYMBOL(tcp_setsockopt);
 EXPORT_SYMBOL(tcp_shutdown);
-EXPORT_SYMBOL(tcp_statistics);
-- 
1.5.5.1

