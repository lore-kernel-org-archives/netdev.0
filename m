From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 13/14] ipv6: making ip and icmp statistics per/namespace
Date: Wed,  8 Oct 2008 15:52:01 +0400
Message-ID: <1223466722-8169-13-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:40180 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754499AbYJHLyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:54:44 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h      |   10 ++--------
 include/net/netns/mib.h |    3 +++
 net/ipv6/af_inet6.c     |   38 ++++++++++++++++++--------------------
 net/ipv6/proc.c         |    8 +++++---
 4 files changed, 28 insertions(+), 31 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d0538dd..6d5b58a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -113,23 +113,20 @@ extern struct ctl_path net_ipv6_ctl_path[];
 #define _DEVINC(net, statname, modifier, idev, field)			\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
-	(void)(net);							\
 	if (likely(_idev != NULL))					\
 		SNMP_INC_STATS##modifier((_idev)->stats.statname, (field)); \
-	SNMP_INC_STATS##modifier(statname##_statistics, (field));	\
+	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));\
 })
 
 #define _DEVADD(net, statname, modifier, idev, field, val)		\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
-	(void)(net);							\
 	if (likely(_idev != NULL))					\
 		SNMP_ADD_STATS##modifier((_idev)->stats.statname, (field), (val)); \
-	SNMP_ADD_STATS##modifier(statname##_statistics, (field), (val));\
+	SNMP_ADD_STATS##modifier((net)->mib.statname##_statistics, (field), (val));\
 })
 
 /* MIBs */
-DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
 
 #define IP6_INC_STATS(net, idev,field)		\
 		_DEVINC(net, ipv6, , idev, field)
@@ -138,9 +135,6 @@ DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
 #define IP6_ADD_STATS_BH(net, idev,field,val)	\
 		_DEVADD(net, ipv6, _BH, idev, field, val)
 
-DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
-DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
-
 #define ICMP6_INC_STATS(net, idev, field)	\
 		_DEVINC(net, icmpv6, , idev, field)
 #define ICMP6_INC_STATS_BH(net, idev, field)	\
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index 4e58f05..10cb7c3 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -16,6 +16,9 @@ struct netns_mib {
 	struct proc_dir_entry *proc_net_devsnmp6;
 	DEFINE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 	DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
+	DEFINE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
+	DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
+	DEFINE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 #endif
 };
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 127b240..6b509d7 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -797,31 +797,11 @@ static void ipv6_packet_cleanup(void)
 
 static int __init init_ipv6_mibs(void)
 {
-	if (snmp_mib_init((void **)ipv6_statistics,
-			  sizeof(struct ipstats_mib)) < 0)
-		goto err_ip_mib;
-	if (snmp_mib_init((void **)icmpv6_statistics,
-			  sizeof(struct icmpv6_mib)) < 0)
-		goto err_icmp_mib;
-	if (snmp_mib_init((void **)icmpv6msg_statistics,
-			  sizeof(struct icmpv6msg_mib)) < 0)
-		goto err_icmpmsg_mib;
 	return 0;
-
-err_icmpmsg_mib:
-	snmp_mib_free((void **)icmpv6_statistics);
-err_icmp_mib:
-	snmp_mib_free((void **)ipv6_statistics);
-err_ip_mib:
-	return -ENOMEM;
-
 }
 
 static void cleanup_ipv6_mibs(void)
 {
-	snmp_mib_free((void **)ipv6_statistics);
-	snmp_mib_free((void **)icmpv6_statistics);
-	snmp_mib_free((void **)icmpv6msg_statistics);
 }
 
 static int __net_init ipv6_init_mibs(struct net *net)
@@ -832,8 +812,23 @@ static int __net_init ipv6_init_mibs(struct net *net)
 	if (snmp_mib_init((void **)net->mib.udplite_stats_in6,
 			  sizeof (struct udp_mib)) < 0)
 		goto err_udplite_mib;
+	if (snmp_mib_init((void **)net->mib.ipv6_statistics,
+			  sizeof(struct ipstats_mib)) < 0)
+		goto err_ip_mib;
+	if (snmp_mib_init((void **)net->mib.icmpv6_statistics,
+			  sizeof(struct icmpv6_mib)) < 0)
+		goto err_icmp_mib;
+	if (snmp_mib_init((void **)net->mib.icmpv6msg_statistics,
+			  sizeof(struct icmpv6msg_mib)) < 0)
+		goto err_icmpmsg_mib;
 	return 0;
 
+err_icmpmsg_mib:
+	snmp_mib_free((void **)net->mib.icmpv6_statistics);
+err_icmp_mib:
+	snmp_mib_free((void **)net->mib.ipv6_statistics);
+err_ip_mib:
+	snmp_mib_free((void **)net->mib.udplite_stats_in6);
 err_udplite_mib:
 	snmp_mib_free((void **)net->mib.udp_stats_in6);
 	return -ENOMEM;
@@ -843,6 +838,9 @@ static void __net_exit ipv6_cleanup_mibs(struct net *net)
 {
 	snmp_mib_free((void **)net->mib.udp_stats_in6);
 	snmp_mib_free((void **)net->mib.udplite_stats_in6);
+	snmp_mib_free((void **)net->mib.ipv6_statistics);
+	snmp_mib_free((void **)net->mib.icmpv6_statistics);
+	snmp_mib_free((void **)net->mib.icmpv6msg_statistics);
 }
 
 static int inet6_net_init(struct net *net)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index c78cf75..07f0b76 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -177,9 +177,11 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = (struct net *)seq->private;
 
-	snmp6_seq_show_item(seq, (void **)ipv6_statistics, snmp6_ipstats_list);
-	snmp6_seq_show_item(seq, (void **)icmpv6_statistics, snmp6_icmp6_list);
-	snmp6_seq_show_icmpv6msg(seq, (void **)icmpv6msg_statistics);
+	snmp6_seq_show_item(seq, (void **)net->mib.ipv6_statistics,
+			    snmp6_ipstats_list);
+	snmp6_seq_show_item(seq, (void **)net->mib.icmpv6_statistics,
+			    snmp6_icmp6_list);
+	snmp6_seq_show_icmpv6msg(seq, (void **)net->mib.icmpv6msg_statistics);
 	snmp6_seq_show_item(seq, (void **)net->mib.udp_stats_in6,
 			    snmp6_udp6_list);
 	snmp6_seq_show_item(seq, (void **)net->mib.udplite_stats_in6,
-- 
1.5.3.rc5

