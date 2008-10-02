From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-next 9/9] netns: make uplitev6 mib per/namespace
Date: Thu,  2 Oct 2008 14:14:12 +0400
Message-ID: <1222942452-9820-9-git-send-email-den@openvz.org>
References: <1222942394.6327.5.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
        benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1222942394.6327.5.camel-aPCOdVxUTlgvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 include/net/netns/mib.h |    1 +
 include/net/udp.h       |   11 ++++-------
 net/ipv6/af_inet6.c     |   14 ++++++++------
 net/ipv6/proc.c         |    3 ++-
 net/ipv6/udplite.c      |    2 --
 5 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index ba622b2..4e58f05 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -15,6 +15,7 @@ struct netns_mib {
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct proc_dir_entry *proc_net_devsnmp6;
 	DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6);
+	DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 #endif
 };
 
diff --git a/include/net/udp.h b/include/net/udp.h
index e2a5de9..bd0d21a 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -148,9 +148,6 @@ extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
 				   char __user *optval, int optlen,
 				   int (*push_pending_frames)(struct sock *));
 
-/* UDP-Lite does not have a standardized MIB yet, so we inherit from UDP */
-DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
-
 /*
  * 	SNMP statistics for UDP and UDP-Lite
  */
@@ -162,12 +159,12 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 	else		SNMP_INC_STATS_BH((net)->mib.udp_statistics, field);    }  while(0)
 
 #define UDP6_INC_STATS_BH(net, field, is_udplite) 	    do { \
-	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);         \
+	if (is_udplite) SNMP_INC_STATS_BH((net)->mib.udplite_stats_in6, field);\
 	else		SNMP_INC_STATS_BH((net)->mib.udp_stats_in6, field);  \
 } while(0)
-#define UDP6_INC_STATS_USER(net, field, is_udplite)	    do { \
-	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);         \
-	else		SNMP_INC_STATS_USER((net)->mib.udp_stats_in6, field);  \
+#define UDP6_INC_STATS_USER(net, field, __lite)		    do { \
+	if (__lite) SNMP_INC_STATS_USER((net)->mib.udplite_stats_in6, field);  \
+	else	    SNMP_INC_STATS_USER((net)->mib.udp_stats_in6, field);      \
 } while(0)
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index f2933b2..7da9146 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -805,13 +805,8 @@ static int __init init_ipv6_mibs(void)
 	if (snmp_mib_init((void **)icmpv6msg_statistics,
 			  sizeof(struct icmpv6msg_mib)) < 0)
 		goto err_icmpmsg_mib;
-	if (snmp_mib_init((void **)udplite_stats_in6,
-			  sizeof (struct udp_mib)) < 0)
-		goto err_udplite_mib;
 	return 0;
 
-err_udplite_mib:
-	snmp_mib_free((void **)icmpv6msg_statistics);
 err_icmpmsg_mib:
 	snmp_mib_free((void **)icmpv6_statistics);
 err_icmp_mib:
@@ -826,7 +821,6 @@ static void cleanup_ipv6_mibs(void)
 	snmp_mib_free((void **)ipv6_statistics);
 	snmp_mib_free((void **)icmpv6_statistics);
 	snmp_mib_free((void **)icmpv6msg_statistics);
-	snmp_mib_free((void **)udplite_stats_in6);
 }
 
 static int __net_init ipv6_init_mibs(struct net *net)
@@ -834,12 +828,20 @@ static int __net_init ipv6_init_mibs(struct net *net)
 	if (snmp_mib_init((void **)net->mib.udp_stats_in6,
 			  sizeof (struct udp_mib)) < 0)
 		return -ENOMEM;
+	if (snmp_mib_init((void **)net->mib.udplite_stats_in6,
+			  sizeof (struct udp_mib)) < 0)
+		goto err_udplite_mib;
 	return 0;
+
+err_udplite_mib:
+	snmp_mib_free((void **)net->mib.udp_stats_in6);
+	return -ENOMEM;
 }
 
 static void __net_exit ipv6_cleanup_mibs(struct net *net)
 {
 	snmp_mib_free((void **)net->mib.udp_stats_in6);
+	snmp_mib_free((void **)net->mib.udplite_stats_in6);
 }
 
 static int inet6_net_init(struct net *net)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 3eaf20b..c78cf75 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -182,7 +182,8 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 	snmp6_seq_show_icmpv6msg(seq, (void **)icmpv6msg_statistics);
 	snmp6_seq_show_item(seq, (void **)net->mib.udp_stats_in6,
 			    snmp6_udp6_list);
-	snmp6_seq_show_item(seq, (void **)udplite_stats_in6, snmp6_udplite6_list);
+	snmp6_seq_show_item(seq, (void **)net->mib.udplite_stats_in6,
+			    snmp6_udplite6_list);
 	return 0;
 }
 
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index f6cdcb3..3cd1a1a 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -13,8 +13,6 @@
  */
 #include "udp_impl.h"
 
-DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6) __read_mostly;
-
 static int udplitev6_rcv(struct sk_buff *skb)
 {
 	return __udp6_lib_rcv(skb, udplite_hash, IPPROTO_UDPLITE);
-- 
1.5.3.rc5
