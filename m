From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] igmp: do not remove igmp souce list info when set link down
Date: Mon,  7 Nov 2016 15:02:02 +0800
Message-ID: <1478502122-6570-1-git-send-email-liuhangbin@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34518 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbcKGHCP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 02:02:15 -0500
Received: by mail-pf0-f193.google.com with SMTP id y68so15354884pfb.1
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2016 23:02:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 24cf3af(igmp: call ip_mc_clear_src...), we forgot to remove
igmpv3_clear_delrec() in ip_mc_down(), which also called ip_mc_clear_src().
This make us clear all IGMPv3 source filter info after NETDEV_DOWN.
Move igmpv3_clear_delrec() to ip_mc_destroy_dev() and then no need
ip_mc_clear_src() in ip_mc_destroy_dev().

On the other hand, we should restore back instead of free all source filter
info in igmpv3_del_delrec(). Or we will not able to restore IGMPv3 source
filter info after NETDEV_UP and NETDEV_POST_TYPE_CHANGE.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv4/igmp.c | 47 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 33 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 606cc3e..97ef4a7 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -162,7 +162,7 @@ static int unsolicited_report_interval(struct in_device *in_dev)
 }
 
 static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im);
-static void igmpv3_del_delrec(struct in_device *in_dev, __be32 multiaddr);
+static void igmpv3_del_delrec(struct in_device *in_dev, struct ip_mc_list *im);
 static void igmpv3_clear_delrec(struct in_device *in_dev);
 static int sf_setstate(struct ip_mc_list *pmc);
 static void sf_markstate(struct ip_mc_list *pmc);
@@ -1130,10 +1130,14 @@ static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 	spin_unlock_bh(&in_dev->mc_tomb_lock);
 }
 
-static void igmpv3_del_delrec(struct in_device *in_dev, __be32 multiaddr)
+/*
+ * restore ip_mc_list deleted records
+ */
+static void igmpv3_del_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 {
 	struct ip_mc_list *pmc, *pmc_prev;
-	struct ip_sf_list *psf, *psf_next;
+	struct ip_sf_list *psf;
+	__be32 multiaddr = im->multiaddr;
 
 	spin_lock_bh(&in_dev->mc_tomb_lock);
 	pmc_prev = NULL;
@@ -1149,16 +1153,26 @@ static void igmpv3_del_delrec(struct in_device *in_dev, __be32 multiaddr)
 			in_dev->mc_tomb = pmc->next;
 	}
 	spin_unlock_bh(&in_dev->mc_tomb_lock);
+
+	spin_lock_bh(&im->lock);
 	if (pmc) {
-		for (psf = pmc->tomb; psf; psf = psf_next) {
-			psf_next = psf->sf_next;
-			kfree(psf);
+		im->interface = pmc->interface;
+		im->crcount = in_dev->mr_qrv ?: sysctl_igmp_qrv;
+		im->sfmode = pmc->sfmode;
+		if (pmc->sfmode == MCAST_INCLUDE) {
+			im->tomb = pmc->tomb;
+			im->sources = pmc->sources;
+			for (psf = im->sources; psf; psf = psf->sf_next)
+				psf->sf_crcount = im->crcount;
 		}
 		in_dev_put(pmc->interface);
-		kfree(pmc);
 	}
+	spin_unlock_bh(&im->lock);
 }
 
+/*
+ * flush ip_mc_list deleted records
+ */
 static void igmpv3_clear_delrec(struct in_device *in_dev)
 {
 	struct ip_mc_list *pmc, *nextpmc;
@@ -1366,7 +1380,7 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	ip_mc_hash_add(in_dev, im);
 
 #ifdef CONFIG_IP_MULTICAST
-	igmpv3_del_delrec(in_dev, im->multiaddr);
+	igmpv3_del_delrec(in_dev, im);
 #endif
 	igmp_group_added(im);
 	if (!in_dev->dead)
@@ -1626,8 +1640,12 @@ void ip_mc_remap(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-	for_each_pmc_rtnl(in_dev, pmc)
+	for_each_pmc_rtnl(in_dev, pmc) {
+#ifdef CONFIG_IP_MULTICAST
+		igmpv3_del_delrec(in_dev, pmc);
+#endif
 		igmp_group_added(pmc);
+	}
 }
 
 /* Device going down */
@@ -1648,7 +1666,6 @@ void ip_mc_down(struct in_device *in_dev)
 	in_dev->mr_gq_running = 0;
 	if (del_timer(&in_dev->mr_gq_timer))
 		__in_dev_put(in_dev);
-	igmpv3_clear_delrec(in_dev);
 #endif
 
 	ip_mc_dec_group(in_dev, IGMP_ALL_HOSTS);
@@ -1688,8 +1705,12 @@ void ip_mc_up(struct in_device *in_dev)
 #endif
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
 
-	for_each_pmc_rtnl(in_dev, pmc)
+	for_each_pmc_rtnl(in_dev, pmc) {
+#ifdef CONFIG_IP_MULTICAST
+		igmpv3_del_delrec(in_dev, pmc);
+#endif
 		igmp_group_added(pmc);
+	}
 }
 
 /*
@@ -1704,13 +1725,11 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 
 	/* Deactivate timers */
 	ip_mc_down(in_dev);
+	igmpv3_clear_delrec(in_dev);
 
 	while ((i = rtnl_dereference(in_dev->mc_list)) != NULL) {
 		in_dev->mc_list = i->next_rcu;
 		in_dev->mc_count--;
-
-		/* We've dropped the groups in ip_mc_down already */
-		ip_mc_clear_src(i);
 		ip_ma_put(i);
 	}
 }
-- 
2.5.5
