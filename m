From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 4/4] igmp: Namespacify igmp_qrv sysctl knob
Date: Mon,  8 Feb 2016 23:29:24 +0200
Message-ID: <1454966964-13559-5-git-send-email-kernel@kyup.com>
References: <1454966964-13559-1-git-send-email-kernel@kyup.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, edumazet@google.com,
	pdowney@brocade.com, dsa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35756 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863AbcBHV3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 16:29:34 -0500
Received: by mail-wm0-f42.google.com with SMTP id c200so34872774wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 13:29:33 -0800 (PST)
In-Reply-To: <1454966964-13559-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/linux/igmp.h       |  2 --
 include/net/netns/ipv4.h   |  1 +
 net/ipv4/igmp.c            | 29 +++++++++++++++++------------
 net/ipv4/sysctl_net_ipv4.c | 20 ++++++++++----------
 net/ipv4/tcp_ipv4.c        |  1 +
 5 files changed, 29 insertions(+), 24 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index c683f4bf642b..12f6fba6d21a 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -37,8 +37,6 @@ static inline struct igmpv3_query *
 	return (struct igmpv3_query *)skb_transport_header(skb);
 }
 
-extern int sysctl_igmp_qrv;
-
 struct ip_sf_socklist {
 	unsigned int		sl_max;
 	unsigned int		sl_count;
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index cbbf8115e8a7..848fe8056534 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -111,6 +111,7 @@ struct netns_ipv4 {
 	int sysctl_igmp_max_memberships;
 	int sysctl_igmp_max_msf;
 	int sysctl_igmp_llm_reports;
+	int sysctl_igmp_qrv;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 53ce9dd08b7a..52d4a6d5cf81 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -762,9 +762,10 @@ static void igmp_ifc_timer_expire(unsigned long data)
 
 static void igmp_ifc_event(struct in_device *in_dev)
 {
+	struct net *net = dev_net(in_dev->dev);
 	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev))
 		return;
-	in_dev->mr_ifc_count = in_dev->mr_qrv ?: sysctl_igmp_qrv;
+	in_dev->mr_ifc_count = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 	igmp_ifc_start_timer(in_dev, 1);
 }
 
@@ -1086,6 +1087,7 @@ static void ip_mc_filter_del(struct in_device *in_dev, __be32 addr)
 static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 {
 	struct ip_mc_list *pmc;
+	struct net *net = dev_net(in_dev->dev);
 
 	/* this is an "ip_mc_list" for convenience; only the fields below
 	 * are actually used. In particular, the refcnt and users are not
@@ -1100,7 +1102,7 @@ static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 	pmc->interface = im->interface;
 	in_dev_hold(in_dev);
 	pmc->multiaddr = im->multiaddr;
-	pmc->crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
+	pmc->crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 	pmc->sfmode = im->sfmode;
 	if (pmc->sfmode == MCAST_INCLUDE) {
 		struct ip_sf_list *psf;
@@ -1245,7 +1247,7 @@ static void igmp_group_added(struct ip_mc_list *im)
 	}
 	/* else, v3 */
 
-	im->crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
+	im->crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 	igmp_ifc_event(in_dev);
 #endif
 }
@@ -1314,6 +1316,7 @@ static void ip_mc_hash_remove(struct in_device *in_dev,
 void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 {
 	struct ip_mc_list *im;
+	struct net *net = dev_net(in_dev->dev);
 
 	ASSERT_RTNL();
 
@@ -1340,7 +1343,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	spin_lock_init(&im->lock);
 #ifdef CONFIG_IP_MULTICAST
 	setup_timer(&im->timer, igmp_timer_expire, (unsigned long)im);
-	im->unsolicit_count = sysctl_igmp_qrv;
+	im->unsolicit_count = net->ipv4.sysctl_igmp_qrv;
 #endif
 
 	im->next_rcu = in_dev->mc_list;
@@ -1640,6 +1643,7 @@ void ip_mc_down(struct in_device *in_dev)
 
 void ip_mc_init_dev(struct in_device *in_dev)
 {
+	struct net *net = dev_net(in_dev->dev);
 	ASSERT_RTNL();
 
 #ifdef CONFIG_IP_MULTICAST
@@ -1647,7 +1651,7 @@ void ip_mc_init_dev(struct in_device *in_dev)
 			(unsigned long)in_dev);
 	setup_timer(&in_dev->mr_ifc_timer, igmp_ifc_timer_expire,
 			(unsigned long)in_dev);
-	in_dev->mr_qrv = sysctl_igmp_qrv;
+	in_dev->mr_qrv = net->ipv4.sysctl_igmp_qrv;
 #endif
 
 	spin_lock_init(&in_dev->mc_tomb_lock);
@@ -1658,11 +1662,12 @@ void ip_mc_init_dev(struct in_device *in_dev)
 void ip_mc_up(struct in_device *in_dev)
 {
 	struct ip_mc_list *pmc;
+	struct net *net = dev_net(in_dev->dev);
 
 	ASSERT_RTNL();
 
 #ifdef CONFIG_IP_MULTICAST
-	in_dev->mr_qrv = sysctl_igmp_qrv;
+	in_dev->mr_qrv = net->ipv4.sysctl_igmp_qrv;
 #endif
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
 
@@ -1728,9 +1733,6 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 /*
  *	Join a socket to a group
  */
-#ifdef CONFIG_IP_MULTICAST
-int sysctl_igmp_qrv __read_mostly = IGMP_QUERY_ROBUSTNESS_VARIABLE;
-#endif
 
 static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
 	__be32 *psfsrc)
@@ -1755,6 +1757,7 @@ static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
 	if (!psf->sf_count[MCAST_INCLUDE] && !psf->sf_count[MCAST_EXCLUDE]) {
 #ifdef CONFIG_IP_MULTICAST
 		struct in_device *in_dev = pmc->interface;
+		struct net *net = dev_net(in_dev->dev);
 #endif
 
 		/* no more filters for this source */
@@ -1765,7 +1768,7 @@ static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
 #ifdef CONFIG_IP_MULTICAST
 		if (psf->sf_oldin &&
 		    !IGMP_V1_SEEN(in_dev) && !IGMP_V2_SEEN(in_dev)) {
-			psf->sf_crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
+			psf->sf_crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 			psf->sf_next = pmc->tomb;
 			pmc->tomb = psf;
 			rv = 1;
@@ -1823,12 +1826,13 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	    pmc->sfcount[MCAST_INCLUDE]) {
 #ifdef CONFIG_IP_MULTICAST
 		struct ip_sf_list *psf;
+		struct net *net = dev_net(in_dev->dev);
 #endif
 
 		/* filter mode change */
 		pmc->sfmode = MCAST_INCLUDE;
 #ifdef CONFIG_IP_MULTICAST
-		pmc->crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
+		pmc->crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 		in_dev->mr_ifc_count = pmc->crcount;
 		for (psf = pmc->sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
@@ -1995,6 +1999,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	} else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {
 #ifdef CONFIG_IP_MULTICAST
 		struct ip_sf_list *psf;
+		struct net *net = dev_net(pmc->interface->dev);
 		in_dev = pmc->interface;
 #endif
 
@@ -2006,7 +2011,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 #ifdef CONFIG_IP_MULTICAST
 		/* else no filters; keep old mode for reports */
 
-		pmc->crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
+		pmc->crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 		in_dev->mr_ifc_count = pmc->crcount;
 		for (psf = pmc->sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index fc40fa1303d3..b537338f5c97 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -367,16 +367,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-#ifdef CONFIG_IP_MULTICAST
-	{
-		.procname	= "igmp_qrv",
-		.data		= &sysctl_igmp_qrv,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &one
-	},
-#endif
 	{
 		.procname	= "inet_peer_threshold",
 		.data		= &inet_peer_threshold,
@@ -871,6 +861,16 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+#ifdef CONFIG_IP_MULTICAST
+	{
+		.procname	= "igmp_qrv",
+		.data		= &init_net.ipv4.sysctl_igmp_qrv,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one
+	},
+#endif
 	{
 		.procname	= "tcp_keepalive_time",
 		.data		= &init_net.ipv4.sysctl_tcp_keepalive_time,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5f30f9f6dfcf..52220f877626 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2401,6 +2401,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_igmp_max_msf = 10;
 	/* IGMP reports for link-local multicast groups are enabled by default */
 	net->ipv4.sysctl_igmp_llm_reports = 1;
+	net->ipv4.sysctl_igmp_qrv = 2;
 
 	return 0;
 fail:
-- 
2.5.0
