From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/2] ipv4: implement igmp_qrv sysctl to tune igmp robustness variable
Date: Sat, 30 Aug 2014 04:42:54 +0200
Message-ID: <afd8699c49e9fb10e03213c92cf4da408d966d1d.1409366462.git.hannes@stressinduktion.org>
References: <1880a888c65dff7b7c73aa53eabbb841a65a74ce.1409366462.git.hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59278 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750889AbaH3CnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 22:43:01 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 6BFF82031D
	for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 22:43:01 -0400 (EDT)
Received: from k64.localdomain (unknown [213.55.184.236])
	by mail.messagingengine.com (Postfix) with ESMTPA id CD5DD680140
	for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 22:43:00 -0400 (EDT)
In-Reply-To: <1880a888c65dff7b7c73aa53eabbb841a65a74ce.1409366462.git.hannes@stressinduktion.org>
In-Reply-To: <1880a888c65dff7b7c73aa53eabbb841a65a74ce.1409366462.git.hannes@stressinduktion.org>
References: <1880a888c65dff7b7c73aa53eabbb841a65a74ce.1409366462.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As in IPv6 people might increase the igmp query robustness variable to
make sure unsolicited state change reports aren't lost on the network. Add
and document this new knob to igmp code.

RFCs allow tuning this parameter back to first IGMP RFC, so we also use
this setting for all counters, including source specific multicast.

Also take over sysctl value when upping the interface and don't reuse
the last one seen on the interface.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/networking/ip-sysctl.txt |  3 +++
 include/linux/igmp.h                   |  1 +
 net/ipv4/igmp.c                        | 27 +++++++++++----------------
 net/ipv4/sysctl_net_ipv4.c             |  8 ++++++++
 4 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index b7fe844..a5adddc 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -844,6 +844,9 @@ igmp_max_memberships - INTEGER
 
 	conf/all/*	  is special, changes the settings for all interfaces
 
+igmp_qrv - INTEGER
+	 Controls the IGMP query robustness variable (see RFC2236 8.1).
+
 log_martians - BOOLEAN
 	Log packets with impossible addresses to kernel log.
 	log_martians for the interface will be enabled if at least one of
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f47550d..2c677af 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -39,6 +39,7 @@ static inline struct igmpv3_query *
 
 extern int sysctl_igmp_max_memberships;
 extern int sysctl_igmp_max_msf;
+extern int sysctl_igmp_qrv;
 
 struct ip_sf_socklist {
 	unsigned int		sl_max;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 890c425..1a38651 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -117,7 +117,7 @@
 #define IGMP_V2_Unsolicited_Report_Interval	(10*HZ)
 #define IGMP_V3_Unsolicited_Report_Interval	(1*HZ)
 #define IGMP_Query_Response_Interval		(10*HZ)
-#define IGMP_Unsolicited_Report_Count		2
+#define IGMP_Query_Robustness_Variable		2
 
 
 #define IGMP_Initial_Report_Delay		(1)
@@ -756,8 +756,7 @@ static void igmp_ifc_event(struct in_device *in_dev)
 {
 	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev))
 		return;
-	in_dev->mr_ifc_count = in_dev->mr_qrv ? in_dev->mr_qrv :
-		IGMP_Unsolicited_Report_Count;
+	in_dev->mr_ifc_count = in_dev->mr_qrv ?: sysctl_igmp_qrv;
 	igmp_ifc_start_timer(in_dev, 1);
 }
 
@@ -1086,8 +1085,7 @@ static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 	pmc->interface = im->interface;
 	in_dev_hold(in_dev);
 	pmc->multiaddr = im->multiaddr;
-	pmc->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
-		IGMP_Unsolicited_Report_Count;
+	pmc->crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
 	pmc->sfmode = im->sfmode;
 	if (pmc->sfmode == MCAST_INCLUDE) {
 		struct ip_sf_list *psf;
@@ -1226,8 +1224,7 @@ static void igmp_group_added(struct ip_mc_list *im)
 	}
 	/* else, v3 */
 
-	im->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
-		IGMP_Unsolicited_Report_Count;
+	im->crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
 	igmp_ifc_event(in_dev);
 #endif
 }
@@ -1322,7 +1319,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	spin_lock_init(&im->lock);
 #ifdef CONFIG_IP_MULTICAST
 	setup_timer(&im->timer, igmp_timer_expire, (unsigned long)im);
-	im->unsolicit_count = IGMP_Unsolicited_Report_Count;
+	im->unsolicit_count = sysctl_igmp_qrv;
 #endif
 
 	im->next_rcu = in_dev->mc_list;
@@ -1460,7 +1457,7 @@ void ip_mc_init_dev(struct in_device *in_dev)
 			(unsigned long)in_dev);
 	setup_timer(&in_dev->mr_ifc_timer, igmp_ifc_timer_expire,
 			(unsigned long)in_dev);
-	in_dev->mr_qrv = IGMP_Unsolicited_Report_Count;
+	in_dev->mr_qrv = sysctl_igmp_qrv;
 #endif
 
 	spin_lock_init(&in_dev->mc_tomb_lock);
@@ -1474,6 +1471,7 @@ void ip_mc_up(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
+	in_dev->mr_qrv = sysctl_igmp_qrv;
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
 
 	for_each_pmc_rtnl(in_dev, pmc)
@@ -1540,7 +1538,7 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
  */
 int sysctl_igmp_max_memberships __read_mostly = IP_MAX_MEMBERSHIPS;
 int sysctl_igmp_max_msf __read_mostly = IP_MAX_MSF;
-
+int sysctl_igmp_qrv __read_mostly = IGMP_Query_Robustness_Variable;
 
 static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
 	__be32 *psfsrc)
@@ -1575,8 +1573,7 @@ static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
 #ifdef CONFIG_IP_MULTICAST
 		if (psf->sf_oldin &&
 		    !IGMP_V1_SEEN(in_dev) && !IGMP_V2_SEEN(in_dev)) {
-			psf->sf_crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
-				IGMP_Unsolicited_Report_Count;
+			psf->sf_crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
 			psf->sf_next = pmc->tomb;
 			pmc->tomb = psf;
 			rv = 1;
@@ -1639,8 +1636,7 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 		/* filter mode change */
 		pmc->sfmode = MCAST_INCLUDE;
 #ifdef CONFIG_IP_MULTICAST
-		pmc->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
-			IGMP_Unsolicited_Report_Count;
+		pmc->crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
 		in_dev->mr_ifc_count = pmc->crcount;
 		for (psf = pmc->sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
@@ -1818,8 +1814,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 #ifdef CONFIG_IP_MULTICAST
 		/* else no filters; keep old mode for reports */
 
-		pmc->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
-			IGMP_Unsolicited_Report_Count;
+		pmc->crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
 		in_dev->mr_ifc_count = pmc->crcount;
 		for (psf = pmc->sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 79a007c..a942c48 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -451,6 +451,14 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "igmp_qrv",
+		.data		= &sysctl_igmp_qrv,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one
+	},
+	{
 		.procname	= "inet_peer_threshold",
 		.data		= &inet_peer_threshold,
 		.maxlen		= sizeof(int),
-- 
1.9.3
