From: Philip Downey <pdowney@brocade.com>
Subject: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Thu, 27 Aug 2015 16:46:26 +0100
Message-ID: <6112e6ccb97c5015b6f8125d8c0f75c179b53198.1440689853.git.pdowney@brocade.com>
References: <1>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Philip Downey <pdowney@brocade.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The range of addresses between 224.0.0.0 and 224.0.0.255 inclusive, is
reserved for the use of routing protocols and other low-level topology
discovery or maintenance protocols, such as gateway discovery and
group membership reporting.  Multicast routers should not forward any
multicast datagram with destination addresses in this range,
regardless of its TTL.

Currently, IGMP reports are generated for this reserved range of
addresses even though a router will ignore this information since it
has no purpose.  However, the presence of reserved group addresses in
an IGMP membership report uses up network bandwidth and can also
obscure addresses of interest when inspecting membership reports using
packet inspection or debug messages.

Although the RFCs for the various version of IGMP (e.g.RFC 3376 for
v3) do not specify that the reserved addresses be excluded from
membership reports, it should do no harm in doing so.  In particular
there should be no adverse effect in any IGMP snooping functionality
since 224.0.0.x is specifically excluded as per RFC 4541 (IGMP and MLD
Snooping Switches Considerations) section 2.1.2. Data Forwarding
Rules:

    2) Packets with a destination IP (DIP) address in the 224.0.0.X
       range which are not IGMP must be forwarded on all ports.

IGMP reports for local multicast groups can now be optionally
inhibited by means of a system control variable (by setting the value
to zero) e.g.:
    echo 0 > /proc/sys/net/ipv4/igmp_link_local_mcast_reports

To retain backwards compatibility the previous behaviour is retained
by default on system boot or reverted by setting the value back to
non-zero e.g.:
    echo 1 >  /proc/sys/net/ipv4/igmp_link_local_mcast_reports

Signed-off-by: Philip Downey <pdowney@brocade.com>
---
 include/linux/igmp.h       |    1 +
 net/ipv4/igmp.c            |   26 +++++++++++++++++++++++++-
 net/ipv4/sysctl_net_ipv4.c |    7 +++++++
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 193ad48..9084292 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -37,6 +37,7 @@ static inline struct igmpv3_query *
 	return (struct igmpv3_query *)skb_transport_header(skb);
 }
 
+extern int sysctl_igmp_llm_reports;
 extern int sysctl_igmp_max_memberships;
 extern int sysctl_igmp_max_msf;
 extern int sysctl_igmp_qrv;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 9fdfd9d..d38b8b6 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -110,6 +110,9 @@
 #define IP_MAX_MEMBERSHIPS	20
 #define IP_MAX_MSF		10
 
+/* IGMP reports for link-local multicast groups are enabled by default */
+int sysctl_igmp_llm_reports __read_mostly = 1;
+
 #ifdef CONFIG_IP_MULTICAST
 /* Parameter names and values are taken from igmp-v2-06 draft */
 
@@ -437,6 +440,8 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 
 	if (pmc->multiaddr == IGMP_ALL_HOSTS)
 		return skb;
+	if (ipv4_is_local_multicast(pmc->multiaddr) && !sysctl_igmp_llm_reports)
+		return skb;
 
 	isquery = type == IGMPV3_MODE_IS_INCLUDE ||
 		  type == IGMPV3_MODE_IS_EXCLUDE;
@@ -545,6 +550,9 @@ static int igmpv3_send_report(struct in_device *in_dev, struct ip_mc_list *pmc)
 		for_each_pmc_rcu(in_dev, pmc) {
 			if (pmc->multiaddr == IGMP_ALL_HOSTS)
 				continue;
+			if (ipv4_is_local_multicast(pmc->multiaddr) &&
+			     !sysctl_igmp_llm_reports)
+				continue;
 			spin_lock_bh(&pmc->lock);
 			if (pmc->sfcount[MCAST_EXCLUDE])
 				type = IGMPV3_MODE_IS_EXCLUDE;
@@ -678,7 +686,11 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 
 	if (type == IGMPV3_HOST_MEMBERSHIP_REPORT)
 		return igmpv3_send_report(in_dev, pmc);
-	else if (type == IGMP_HOST_LEAVE_MESSAGE)
+
+	if (ipv4_is_local_multicast(group) && !sysctl_igmp_llm_reports)
+		return 0;
+
+	if (type == IGMP_HOST_LEAVE_MESSAGE)
 		dst = IGMP_ALL_ROUTER;
 	else
 		dst = group;
@@ -851,6 +863,8 @@ static bool igmp_heard_report(struct in_device *in_dev, __be32 group)
 
 	if (group == IGMP_ALL_HOSTS)
 		return false;
+	if (ipv4_is_local_multicast(group) && !sysctl_igmp_llm_reports)
+		return false;
 
 	rcu_read_lock();
 	for_each_pmc_rcu(in_dev, im) {
@@ -957,6 +971,9 @@ static bool igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 			continue;
 		if (im->multiaddr == IGMP_ALL_HOSTS)
 			continue;
+		if (ipv4_is_local_multicast(im->multiaddr) &&
+		    !sysctl_igmp_llm_reports)
+			continue;
 		spin_lock_bh(&im->lock);
 		if (im->tm_running)
 			im->gsquery = im->gsquery && mark;
@@ -1181,6 +1198,8 @@ static void igmp_group_dropped(struct ip_mc_list *im)
 #ifdef CONFIG_IP_MULTICAST
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
+	if (ipv4_is_local_multicast(im->multiaddr) && !sysctl_igmp_llm_reports)
+		return;
 
 	reporter = im->reporter;
 	igmp_stop_timer(im);
@@ -1213,6 +1232,8 @@ static void igmp_group_added(struct ip_mc_list *im)
 #ifdef CONFIG_IP_MULTICAST
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
+	if (ipv4_is_local_multicast(im->multiaddr) && !sysctl_igmp_llm_reports)
+		return;
 
 	if (in_dev->dead)
 		return;
@@ -1518,6 +1539,9 @@ static void ip_mc_rejoin_groups(struct in_device *in_dev)
 	for_each_pmc_rtnl(in_dev, im) {
 		if (im->multiaddr == IGMP_ALL_HOSTS)
 			continue;
+		if (ipv4_is_local_multicast(im->multiaddr) &&
+		    !sysctl_igmp_llm_reports)
+			continue;
 
 		/* a failover is happening and switches
 		 * must be notified immediately
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 0330ab2..74eede2 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -910,6 +910,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "igmp_link_local_mcast_reports",
+		.data		= &sysctl_igmp_llm_reports,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
-- 
1.7.10.4
