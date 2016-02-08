From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 3/4] igmp: Namespaceify igmp_llm_reports sysctl knob
Date: Mon,  8 Feb 2016 23:29:23 +0200
Message-ID: <1454966964-13559-4-git-send-email-kernel@kyup.com>
References: <1454966964-13559-1-git-send-email-kernel@kyup.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, edumazet@google.com,
	pdowney@brocade.com, dsa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35952 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932395AbcBHV3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 16:29:32 -0500
Received: by mail-wm0-f53.google.com with SMTP id p63so132760419wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 13:29:32 -0800 (PST)
In-Reply-To: <1454966964-13559-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was initially introduced in commit df2cf4a78e48 ("IGMP: Inhibit
reports for local multicast groups") by defining the sysctl in the
ipv4_net_table array, however it was never implemented to be
namespace aware. Fix this by changing the code accordingly.

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/linux/igmp.h       |  1 -
 include/net/netns/ipv4.h   |  1 +
 net/ipv4/igmp.c            | 26 +++++++++++++++-----------
 net/ipv4/sysctl_net_ipv4.c |  2 +-
 net/ipv4/tcp_ipv4.c        |  2 ++
 5 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index a91ec9f575e7..c683f4bf642b 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -37,7 +37,6 @@ static inline struct igmpv3_query *
 	return (struct igmpv3_query *)skb_transport_header(skb);
 }
 
-extern int sysctl_igmp_llm_reports;
 extern int sysctl_igmp_qrv;
 
 struct ip_sf_socklist {
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 522a2cfe1ad9..cbbf8115e8a7 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -110,6 +110,7 @@ struct netns_ipv4 {
 
 	int sysctl_igmp_max_memberships;
 	int sysctl_igmp_max_msf;
+	int sysctl_igmp_llm_reports;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 6da2e467b63c..53ce9dd08b7a 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -107,9 +107,6 @@
 #include <linux/seq_file.h>
 #endif
 
-/* IGMP reports for link-local multicast groups are enabled by default */
-int sysctl_igmp_llm_reports __read_mostly = 1;
-
 #ifdef CONFIG_IP_MULTICAST
 /* Parameter names and values are taken from igmp-v2-06 draft */
 
@@ -430,6 +427,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 	int type, int gdeleted, int sdeleted)
 {
 	struct net_device *dev = pmc->interface->dev;
+	struct net *net = dev_net(dev);
 	struct igmpv3_report *pih;
 	struct igmpv3_grec *pgr = NULL;
 	struct ip_sf_list *psf, *psf_next, *psf_prev, **psf_list;
@@ -437,7 +435,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 
 	if (pmc->multiaddr == IGMP_ALL_HOSTS)
 		return skb;
-	if (ipv4_is_local_multicast(pmc->multiaddr) && !sysctl_igmp_llm_reports)
+	if (ipv4_is_local_multicast(pmc->multiaddr) && !net->ipv4.sysctl_igmp_llm_reports)
 		return skb;
 
 	isquery = type == IGMPV3_MODE_IS_INCLUDE ||
@@ -540,6 +538,7 @@ empty_source:
 static int igmpv3_send_report(struct in_device *in_dev, struct ip_mc_list *pmc)
 {
 	struct sk_buff *skb = NULL;
+	struct net *net = dev_net(in_dev->dev);
 	int type;
 
 	if (!pmc) {
@@ -548,7 +547,7 @@ static int igmpv3_send_report(struct in_device *in_dev, struct ip_mc_list *pmc)
 			if (pmc->multiaddr == IGMP_ALL_HOSTS)
 				continue;
 			if (ipv4_is_local_multicast(pmc->multiaddr) &&
-			     !sysctl_igmp_llm_reports)
+			     !net->ipv4.sysctl_igmp_llm_reports)
 				continue;
 			spin_lock_bh(&pmc->lock);
 			if (pmc->sfcount[MCAST_EXCLUDE])
@@ -684,7 +683,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	if (type == IGMPV3_HOST_MEMBERSHIP_REPORT)
 		return igmpv3_send_report(in_dev, pmc);
 
-	if (ipv4_is_local_multicast(group) && !sysctl_igmp_llm_reports)
+	if (ipv4_is_local_multicast(group) && !net->ipv4.sysctl_igmp_llm_reports)
 		return 0;
 
 	if (type == IGMP_HOST_LEAVE_MESSAGE)
@@ -855,12 +854,13 @@ static int igmp_marksources(struct ip_mc_list *pmc, int nsrcs, __be32 *srcs)
 static bool igmp_heard_report(struct in_device *in_dev, __be32 group)
 {
 	struct ip_mc_list *im;
+	struct net *net = dev_net(in_dev->dev);
 
 	/* Timers are only set for non-local groups */
 
 	if (group == IGMP_ALL_HOSTS)
 		return false;
-	if (ipv4_is_local_multicast(group) && !sysctl_igmp_llm_reports)
+	if (ipv4_is_local_multicast(group) && !net->ipv4.sysctl_igmp_llm_reports)
 		return false;
 
 	rcu_read_lock();
@@ -884,6 +884,7 @@ static bool igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 	__be32			group = ih->group;
 	int			max_delay;
 	int			mark = 0;
+	struct net		*net = dev_net(in_dev->dev);
 
 
 	if (len == 8) {
@@ -969,7 +970,7 @@ static bool igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 		if (im->multiaddr == IGMP_ALL_HOSTS)
 			continue;
 		if (ipv4_is_local_multicast(im->multiaddr) &&
-		    !sysctl_igmp_llm_reports)
+		    !net->ipv4.sysctl_igmp_llm_reports)
 			continue;
 		spin_lock_bh(&im->lock);
 		if (im->tm_running)
@@ -1183,6 +1184,7 @@ static void igmpv3_clear_delrec(struct in_device *in_dev)
 static void igmp_group_dropped(struct ip_mc_list *im)
 {
 	struct in_device *in_dev = im->interface;
+	struct net *net = dev_net(in_dev->dev);
 #ifdef CONFIG_IP_MULTICAST
 	int reporter;
 #endif
@@ -1195,7 +1197,7 @@ static void igmp_group_dropped(struct ip_mc_list *im)
 #ifdef CONFIG_IP_MULTICAST
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
-	if (ipv4_is_local_multicast(im->multiaddr) && !sysctl_igmp_llm_reports)
+	if (ipv4_is_local_multicast(im->multiaddr) && !net->ipv4.sysctl_igmp_llm_reports)
 		return;
 
 	reporter = im->reporter;
@@ -1220,6 +1222,7 @@ static void igmp_group_dropped(struct ip_mc_list *im)
 static void igmp_group_added(struct ip_mc_list *im)
 {
 	struct in_device *in_dev = im->interface;
+	struct net *net = dev_net(in_dev->dev);
 
 	if (im->loaded == 0) {
 		im->loaded = 1;
@@ -1229,7 +1232,7 @@ static void igmp_group_added(struct ip_mc_list *im)
 #ifdef CONFIG_IP_MULTICAST
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
-	if (ipv4_is_local_multicast(im->multiaddr) && !sysctl_igmp_llm_reports)
+	if (ipv4_is_local_multicast(im->multiaddr) && !net->ipv4.sysctl_igmp_llm_reports)
 		return;
 
 	if (in_dev->dead)
@@ -1530,6 +1533,7 @@ static void ip_mc_rejoin_groups(struct in_device *in_dev)
 #ifdef CONFIG_IP_MULTICAST
 	struct ip_mc_list *im;
 	int type;
+	struct net *net = dev_net(in_dev->dev);
 
 	ASSERT_RTNL();
 
@@ -1537,7 +1541,7 @@ static void ip_mc_rejoin_groups(struct in_device *in_dev)
 		if (im->multiaddr == IGMP_ALL_HOSTS)
 			continue;
 		if (ipv4_is_local_multicast(im->multiaddr) &&
-		    !sysctl_igmp_llm_reports)
+		    !net->ipv4.sysctl_igmp_llm_reports)
 			continue;
 
 		/* a failover is happening and switches
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 225659a02cf2..fc40fa1303d3 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -852,7 +852,7 @@ static struct ctl_table ipv4_net_table[] = {
 	},
 	{
 		.procname	= "igmp_link_local_mcast_reports",
-		.data		= &sysctl_igmp_llm_reports,
+		.data		= &init_net.ipv4.sysctl_igmp_llm_reports,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d0ac43b95378..5f30f9f6dfcf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2399,6 +2399,8 @@ static int __net_init tcp_sk_init(struct net *net)
 
 	net->ipv4.sysctl_igmp_max_memberships = 20;
 	net->ipv4.sysctl_igmp_max_msf = 10;
+	/* IGMP reports for link-local multicast groups are enabled by default */
+	net->ipv4.sysctl_igmp_llm_reports = 1;
 
 	return 0;
 fail:
-- 
2.5.0
