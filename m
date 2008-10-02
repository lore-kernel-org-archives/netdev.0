From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 8/9] netns: make udpv6 mib per/namespace
Date: Thu,  2 Oct 2008 14:14:11 +0400
Message-ID: <1222942452-9820-8-git-send-email-den@openvz.org>
References: <1222942394.6327.5.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	den@openvz.org, benjamin.thery@bull.net, dlezcano@fr.ibm.com,
	xemul@openvz.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:40813 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344AbYJBKPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 06:15:16 -0400
In-Reply-To: <1222942394.6327.5.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/netns/mib.h |    1 +
 include/net/udp.h       |   12 ++++++------
 net/ipv4/udp.c          |    3 ---
 net/ipv6/af_inet6.c     |    9 ++++-----
 net/ipv6/proc.c         |    3 ++-
 5 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index ffcef5d..ba622b2 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -14,6 +14,7 @@ struct netns_mib {
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct proc_dir_entry *proc_net_devsnmp6;
+	DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 #endif
 };
 
diff --git a/include/net/udp.h b/include/net/udp.h
index addcdc6..e2a5de9 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -148,8 +148,6 @@ extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
 				   char __user *optval, int optlen,
 				   int (*push_pending_frames)(struct sock *));
 
-DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
-
 /* UDP-Lite does not have a standardized MIB yet, so we inherit from UDP */
 DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 
@@ -163,12 +161,14 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 	if (is_udplite) SNMP_INC_STATS_BH((net)->mib.udplite_statistics, field);         \
 	else		SNMP_INC_STATS_BH((net)->mib.udp_statistics, field);    }  while(0)
 
-#define UDP6_INC_STATS_BH(net, field, is_udplite) 	    do { (void)net;  \
+#define UDP6_INC_STATS_BH(net, field, is_udplite) 	    do { \
 	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);         \
-	else		SNMP_INC_STATS_BH(udp_stats_in6, field);    } while(0)
-#define UDP6_INC_STATS_USER(net, field, is_udplite)	    do { (void)net;    \
+	else		SNMP_INC_STATS_BH((net)->mib.udp_stats_in6, field);  \
+} while(0)
+#define UDP6_INC_STATS_USER(net, field, is_udplite)	    do { \
 	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);         \
-	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
+	else		SNMP_INC_STATS_USER((net)->mib.udp_stats_in6, field);  \
+} while(0)
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #define UDPX_INC_STATS_BH(sk, field) \
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8e42fbb..4903420 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -108,9 +108,6 @@
  *	Snmp MIB for the UDP layer
  */
 
-DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6) __read_mostly;
-EXPORT_SYMBOL(udp_stats_in6);
-
 struct hlist_head udp_hash[UDP_HTABLE_SIZE];
 DEFINE_RWLOCK(udp_hash_lock);
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 46d4e62..f2933b2 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -805,16 +805,12 @@ static int __init init_ipv6_mibs(void)
 	if (snmp_mib_init((void **)icmpv6msg_statistics,
 			  sizeof(struct icmpv6msg_mib)) < 0)
 		goto err_icmpmsg_mib;
-	if (snmp_mib_init((void **)udp_stats_in6, sizeof (struct udp_mib)) < 0)
-		goto err_udp_mib;
 	if (snmp_mib_init((void **)udplite_stats_in6,
 			  sizeof (struct udp_mib)) < 0)
 		goto err_udplite_mib;
 	return 0;
 
 err_udplite_mib:
-	snmp_mib_free((void **)udp_stats_in6);
-err_udp_mib:
 	snmp_mib_free((void **)icmpv6msg_statistics);
 err_icmpmsg_mib:
 	snmp_mib_free((void **)icmpv6_statistics);
@@ -830,17 +826,20 @@ static void cleanup_ipv6_mibs(void)
 	snmp_mib_free((void **)ipv6_statistics);
 	snmp_mib_free((void **)icmpv6_statistics);
 	snmp_mib_free((void **)icmpv6msg_statistics);
-	snmp_mib_free((void **)udp_stats_in6);
 	snmp_mib_free((void **)udplite_stats_in6);
 }
 
 static int __net_init ipv6_init_mibs(struct net *net)
 {
+	if (snmp_mib_init((void **)net->mib.udp_stats_in6,
+			  sizeof (struct udp_mib)) < 0)
+		return -ENOMEM;
 	return 0;
 }
 
 static void __net_exit ipv6_cleanup_mibs(struct net *net)
 {
+	snmp_mib_free((void **)net->mib.udp_stats_in6);
 }
 
 static int inet6_net_init(struct net *net)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 23e567f..3eaf20b 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -180,7 +180,8 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 	snmp6_seq_show_item(seq, (void **)ipv6_statistics, snmp6_ipstats_list);
 	snmp6_seq_show_item(seq, (void **)icmpv6_statistics, snmp6_icmp6_list);
 	snmp6_seq_show_icmpv6msg(seq, (void **)icmpv6msg_statistics);
-	snmp6_seq_show_item(seq, (void **)udp_stats_in6, snmp6_udp6_list);
+	snmp6_seq_show_item(seq, (void **)net->mib.udp_stats_in6,
+			    snmp6_udp6_list);
 	snmp6_seq_show_item(seq, (void **)udplite_stats_in6, snmp6_udplite6_list);
 	return 0;
 }
-- 
1.5.3.rc5

