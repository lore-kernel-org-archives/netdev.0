From: Philip Downey <pdowney@brocade.com>
Subject: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Wed, 12 Aug 2015 17:13:53 +0100
Message-ID: <1439396033-6264-1-git-send-email-pdowney@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Philip Downey <pdowney@brocade.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IGMP reports are generated for link local multicast groups (224.0.0.1
- 224.0.0.255) used by the routing protocols such as RIP, OSPF etc.
In general routers do not generate reports for local multicast groups.

IGMP reports for local multicast groups can now be inhibited by means
of a system control variable (setting the value to zero).

To retain backwards compatibility the previous behaviour is retained by
default on system boot.

Signed-off-by: Philip Downey <pdowney@brocade.com>
---
 include/linux/igmp.h       |    1 +
 net/ipv4/igmp.c            |   29 ++++++++++++++++++++++++++++-
 net/ipv4/sysctl_net_ipv4.c |    7 +++++++
 3 files changed, 36 insertions(+), 1 deletion(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 193ad48..e3e0dae 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -37,6 +37,7 @@ static inline struct igmpv3_query *
 	return (struct igmpv3_query *)skb_transport_header(skb);
 }
 
+extern int sysctl_igmp_link_local_reports;
 extern int sysctl_igmp_max_memberships;
 extern int sysctl_igmp_max_msf;
 extern int sysctl_igmp_qrv;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 651cdf6..2e4d5b8 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -110,6 +110,15 @@
 #define IP_MAX_MEMBERSHIPS	20
 #define IP_MAX_MSF		10
 
+/* IGMP reports for link-local multicast groups are enabled by default */
+#define IGMP_ENABLE_LLM         1
+
+int sysctl_igmp_link_local_reports __read_mostly = IGMP_ENABLE_LLM;
+
+#define IGMP_INHIBIT_LINK_LOCAL_REPORTS(_ipaddr) \
+	(ipv4_is_local_multicast(_ipaddr) && \
+	 (sysctl_igmp_link_local_reports == 0))
+
 #ifdef CONFIG_IP_MULTICAST
 /* Parameter names and values are taken from igmp-v2-06 draft */
 
@@ -437,6 +446,8 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 
 	if (pmc->multiaddr == IGMP_ALL_HOSTS)
 		return skb;
+	if (IGMP_INHIBIT_LINK_LOCAL_REPORTS(pmc->multiaddr))
+		return skb;
 
 	isquery = type == IGMPV3_MODE_IS_INCLUDE ||
 		  type == IGMPV3_MODE_IS_EXCLUDE;
@@ -545,6 +556,8 @@ static int igmpv3_send_report(struct in_device *in_dev, struct ip_mc_list *pmc)
 		for_each_pmc_rcu(in_dev, pmc) {
 			if (pmc->multiaddr == IGMP_ALL_HOSTS)
 				continue;
+			if (IGMP_INHIBIT_LINK_LOCAL_REPORTS(pmc->multiaddr))
+				continue;
 			spin_lock_bh(&pmc->lock);
 			if (pmc->sfcount[MCAST_EXCLUDE])
 				type = IGMPV3_MODE_IS_EXCLUDE;
@@ -678,7 +691,11 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 
 	if (type == IGMPV3_HOST_MEMBERSHIP_REPORT)
 		return igmpv3_send_report(in_dev, pmc);
-	else if (type == IGMP_HOST_LEAVE_MESSAGE)
+
+	if (IGMP_INHIBIT_LINK_LOCAL_REPORTS(group))
+		return 0;
+
+	if (type == IGMP_HOST_LEAVE_MESSAGE)
 		dst = IGMP_ALL_ROUTER;
 	else
 		dst = group;
@@ -851,6 +868,8 @@ static bool igmp_heard_report(struct in_device *in_dev, __be32 group)
 
 	if (group == IGMP_ALL_HOSTS)
 		return false;
+	if (IGMP_INHIBIT_LINK_LOCAL_REPORTS(group))
+		return false;
 
 	rcu_read_lock();
 	for_each_pmc_rcu(in_dev, im) {
@@ -957,6 +976,8 @@ static bool igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 			continue;
 		if (im->multiaddr == IGMP_ALL_HOSTS)
 			continue;
+		if (IGMP_INHIBIT_LINK_LOCAL_REPORTS(im->multiaddr))
+			continue;
 		spin_lock_bh(&im->lock);
 		if (im->tm_running)
 			im->gsquery = im->gsquery && mark;
@@ -1181,6 +1202,8 @@ static void igmp_group_dropped(struct ip_mc_list *im)
 #ifdef CONFIG_IP_MULTICAST
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
+	if (IGMP_INHIBIT_LINK_LOCAL_REPORTS(im->multiaddr))
+		return;
 
 	reporter = im->reporter;
 	igmp_stop_timer(im);
@@ -1213,6 +1236,8 @@ static void igmp_group_added(struct ip_mc_list *im)
 #ifdef CONFIG_IP_MULTICAST
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
+	if (IGMP_INHIBIT_LINK_LOCAL_REPORTS(im->multiaddr))
+		return;
 
 	if (in_dev->dead)
 		return;
@@ -1515,6 +1540,8 @@ static void ip_mc_rejoin_groups(struct in_device *in_dev)
 	for_each_pmc_rtnl(in_dev, im) {
 		if (im->multiaddr == IGMP_ALL_HOSTS)
 			continue;
+		if (IGMP_INHIBIT_LINK_LOCAL_REPORTS(im->multiaddr))
+			continue;
 
 		/* a failover is happening and switches
 		 * must be notified immediately
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 433231c..e7fd509 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -912,6 +912,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "igmp_link_local_reports",
+		.data		= &sysctl_igmp_link_local_reports,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
-- 
1.7.10.4
