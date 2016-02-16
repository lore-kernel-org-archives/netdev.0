From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] net: igmp: use IS_ENABLED(CONFIG_IP_MULTICAST) instead of ifdef
Date: Tue, 16 Feb 2016 17:32:06 +0100
Message-ID: <1455640333-3769837-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Nikolay Borisov <n.borisov@siteground.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A recent change to use correct network namespace in net/ipv4/igmp.c
caused a couple of harmless build warnings when CONFIG_MULTICAST is
disabled:

net/ipv4/igmp.c: In function 'igmp_group_added':
net/ipv4/igmp.c:1227:14: error: unused variable 'net' [-Werror=unused-variable]
net/ipv4/igmp.c: In function 'ip_mc_inc_group':
net/ipv4/igmp.c:1319:14: error: unused variable 'net' [-Werror=unused-variable]
net/ipv4/igmp.c: In function 'ip_mc_init_dev':
net/ipv4/igmp.c:1646:14: error: unused variable 'net' [-Werror=unused-variable]
net/ipv4/igmp.c: In function 'ip_mc_up':
net/ipv4/igmp.c:1665:14: error: unused variable 'net' [-Werror=unused-variable]

This reworks the entire file to change each instance if '#ifdef
CONFIG_IP_MULTICAST' to 'if (IS_ENABLED(CONFIG_IP_MULTICAST)', which
should avoid these problems forever, and makes the whole file more
readable.

Build-tested only.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Reviewed-by: Nikolay Borisov <kernel@kyup.com>
Fixes: 87a8a2ae65b7 ("igmp: Namespaceify igmp_llm_reports sysctl knob")
---
 net/ipv4/igmp.c | 142 ++++++++++++++++++++++++++------------------------------
 1 file changed, 66 insertions(+), 76 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 7c95335bf85e..2b6dd53adaa4 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -107,7 +107,6 @@
 #include <linux/seq_file.h>
 #endif
 
-#ifdef CONFIG_IP_MULTICAST
 /* Parameter names and values are taken from igmp-v2-06 draft */
 
 #define IGMP_V1_ROUTER_PRESENT_TIMEOUT		(400*HZ)
@@ -166,7 +165,6 @@ static void igmpv3_del_delrec(struct in_device *in_dev, __be32 multiaddr);
 static void igmpv3_clear_delrec(struct in_device *in_dev);
 static int sf_setstate(struct ip_mc_list *pmc);
 static void sf_markstate(struct ip_mc_list *pmc);
-#endif
 static void ip_mc_clear_src(struct ip_mc_list *pmc);
 static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 			 int sfcount, __be32 *psfsrc, int delta);
@@ -189,8 +187,6 @@ static void ip_ma_put(struct ip_mc_list *im)
 	     pmc != NULL;					\
 	     pmc = rtnl_dereference(pmc->next_rcu))
 
-#ifdef CONFIG_IP_MULTICAST
-
 /*
  *	Timer management
  */
@@ -763,7 +759,9 @@ static void igmp_ifc_timer_expire(unsigned long data)
 static void igmp_ifc_event(struct in_device *in_dev)
 {
 	struct net *net = dev_net(in_dev->dev);
-	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev))
+
+	if (!IS_ENABLED(CONFIG_IP_MULTICAST) ||
+	    IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev))
 		return;
 	in_dev->mr_ifc_count = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 	igmp_ifc_start_timer(in_dev, 1);
@@ -1044,9 +1042,6 @@ drop:
 	return 0;
 }
 
-#endif
-
-
 /*
  *	Add a filter to a device
  */
@@ -1080,7 +1075,6 @@ static void ip_mc_filter_del(struct in_device *in_dev, __be32 addr)
 		dev_mc_del(dev, buf);
 }
 
-#ifdef CONFIG_IP_MULTICAST
 /*
  * deleted ip_mc_list manipulation
  */
@@ -1181,22 +1175,20 @@ static void igmpv3_clear_delrec(struct in_device *in_dev)
 	}
 	rcu_read_unlock();
 }
-#endif
 
 static void igmp_group_dropped(struct ip_mc_list *im)
 {
 	struct in_device *in_dev = im->interface;
-#ifdef CONFIG_IP_MULTICAST
 	struct net *net = dev_net(in_dev->dev);
 	int reporter;
-#endif
 
 	if (im->loaded) {
 		im->loaded = 0;
 		ip_mc_filter_del(in_dev, im->multiaddr);
 	}
 
-#ifdef CONFIG_IP_MULTICAST
+	if (!IS_ENABLED(CONFIG_IP_MULTICAST))
+		return;
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
 	if (ipv4_is_local_multicast(im->multiaddr) && !net->ipv4.sysctl_igmp_llm_reports)
@@ -1218,7 +1210,6 @@ static void igmp_group_dropped(struct ip_mc_list *im)
 
 		igmp_ifc_event(in_dev);
 	}
-#endif
 }
 
 static void igmp_group_added(struct ip_mc_list *im)
@@ -1231,7 +1222,9 @@ static void igmp_group_added(struct ip_mc_list *im)
 		ip_mc_filter_add(in_dev, im->multiaddr);
 	}
 
-#ifdef CONFIG_IP_MULTICAST
+	if (!IS_ENABLED(CONFIG_IP_MULTICAST))
+		return;
+
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
 	if (ipv4_is_local_multicast(im->multiaddr) && !net->ipv4.sysctl_igmp_llm_reports)
@@ -1249,7 +1242,6 @@ static void igmp_group_added(struct ip_mc_list *im)
 
 	im->crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 	igmp_ifc_event(in_dev);
-#endif
 }
 
 
@@ -1341,10 +1333,10 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	im->sfcount[MCAST_EXCLUDE] = 1;
 	atomic_set(&im->refcnt, 1);
 	spin_lock_init(&im->lock);
-#ifdef CONFIG_IP_MULTICAST
-	setup_timer(&im->timer, igmp_timer_expire, (unsigned long)im);
-	im->unsolicit_count = net->ipv4.sysctl_igmp_qrv;
-#endif
+	if (IS_ENABLED(CONFIG_IP_MULTICAST)) {
+		setup_timer(&im->timer, igmp_timer_expire, (unsigned long)im);
+		im->unsolicit_count = net->ipv4.sysctl_igmp_qrv;
+	}
 
 	im->next_rcu = in_dev->mc_list;
 	in_dev->mc_count++;
@@ -1352,9 +1344,9 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 
 	ip_mc_hash_add(in_dev, im);
 
-#ifdef CONFIG_IP_MULTICAST
-	igmpv3_del_delrec(in_dev, im->multiaddr);
-#endif
+	if (IS_ENABLED(CONFIG_IP_MULTICAST))
+		igmpv3_del_delrec(in_dev, im->multiaddr);
+
 	igmp_group_added(im);
 	if (!in_dev->dead)
 		ip_rt_multicast_event(in_dev);
@@ -1533,11 +1525,13 @@ EXPORT_SYMBOL(ip_mc_check_igmp);
  */
 static void ip_mc_rejoin_groups(struct in_device *in_dev)
 {
-#ifdef CONFIG_IP_MULTICAST
 	struct ip_mc_list *im;
 	int type;
 	struct net *net = dev_net(in_dev->dev);
 
+	if (!IS_ENABLED(CONFIG_IP_MULTICAST))
+		return;
+
 	ASSERT_RTNL();
 
 	for_each_pmc_rtnl(in_dev, im) {
@@ -1558,7 +1552,6 @@ static void ip_mc_rejoin_groups(struct in_device *in_dev)
 			type = IGMPV3_HOST_MEMBERSHIP_REPORT;
 		igmp_send_report(in_dev, im, type);
 	}
-#endif
 }
 
 /*
@@ -1628,15 +1621,15 @@ void ip_mc_down(struct in_device *in_dev)
 	for_each_pmc_rtnl(in_dev, pmc)
 		igmp_group_dropped(pmc);
 
-#ifdef CONFIG_IP_MULTICAST
-	in_dev->mr_ifc_count = 0;
-	if (del_timer(&in_dev->mr_ifc_timer))
-		__in_dev_put(in_dev);
-	in_dev->mr_gq_running = 0;
-	if (del_timer(&in_dev->mr_gq_timer))
-		__in_dev_put(in_dev);
-	igmpv3_clear_delrec(in_dev);
-#endif
+	if (IS_ENABLED(CONFIG_IP_MULTICAST)) {
+		in_dev->mr_ifc_count = 0;
+		if (del_timer(&in_dev->mr_ifc_timer))
+			__in_dev_put(in_dev);
+		in_dev->mr_gq_running = 0;
+		if (del_timer(&in_dev->mr_gq_timer))
+			__in_dev_put(in_dev);
+		igmpv3_clear_delrec(in_dev);
+	}
 
 	ip_mc_dec_group(in_dev, IGMP_ALL_HOSTS);
 }
@@ -1646,13 +1639,13 @@ void ip_mc_init_dev(struct in_device *in_dev)
 	struct net *net = dev_net(in_dev->dev);
 	ASSERT_RTNL();
 
-#ifdef CONFIG_IP_MULTICAST
-	setup_timer(&in_dev->mr_gq_timer, igmp_gq_timer_expire,
-			(unsigned long)in_dev);
-	setup_timer(&in_dev->mr_ifc_timer, igmp_ifc_timer_expire,
-			(unsigned long)in_dev);
-	in_dev->mr_qrv = net->ipv4.sysctl_igmp_qrv;
-#endif
+	if (IS_ENABLED(CONFIG_IP_MULTICAST)) {
+		setup_timer(&in_dev->mr_gq_timer, igmp_gq_timer_expire,
+				(unsigned long)in_dev);
+		setup_timer(&in_dev->mr_ifc_timer, igmp_ifc_timer_expire,
+				(unsigned long)in_dev);
+		in_dev->mr_qrv = net->ipv4.sysctl_igmp_qrv;
+	}
 
 	spin_lock_init(&in_dev->mc_tomb_lock);
 }
@@ -1666,9 +1659,9 @@ void ip_mc_up(struct in_device *in_dev)
 
 	ASSERT_RTNL();
 
-#ifdef CONFIG_IP_MULTICAST
-	in_dev->mr_qrv = net->ipv4.sysctl_igmp_qrv;
-#endif
+	if (IS_ENABLED(CONFIG_IP_MULTICAST))
+		in_dev->mr_qrv = net->ipv4.sysctl_igmp_qrv;
+
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
 
 	for_each_pmc_rtnl(in_dev, pmc)
@@ -1755,34 +1748,27 @@ static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
 		ip_rt_multicast_event(pmc->interface);
 	}
 	if (!psf->sf_count[MCAST_INCLUDE] && !psf->sf_count[MCAST_EXCLUDE]) {
-#ifdef CONFIG_IP_MULTICAST
 		struct in_device *in_dev = pmc->interface;
 		struct net *net = dev_net(in_dev->dev);
-#endif
 
 		/* no more filters for this source */
 		if (psf_prev)
 			psf_prev->sf_next = psf->sf_next;
 		else
 			pmc->sources = psf->sf_next;
-#ifdef CONFIG_IP_MULTICAST
-		if (psf->sf_oldin &&
+		if (IS_ENABLED(CONFIG_IP_MULTICAST) && psf->sf_oldin &&
 		    !IGMP_V1_SEEN(in_dev) && !IGMP_V2_SEEN(in_dev)) {
 			psf->sf_crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 			psf->sf_next = pmc->tomb;
 			pmc->tomb = psf;
 			rv = 1;
-		} else
-#endif
+		} else {
 			kfree(psf);
+		}
 	}
 	return rv;
 }
 
-#ifndef CONFIG_IP_MULTICAST
-#define igmp_ifc_event(x)	do { } while (0)
-#endif
-
 static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 			 int sfcount, __be32 *psfsrc, int delta)
 {
@@ -1804,9 +1790,9 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	}
 	spin_lock_bh(&pmc->lock);
 	rcu_read_unlock();
-#ifdef CONFIG_IP_MULTICAST
+
 	sf_markstate(pmc);
-#endif
+
 	if (!delta) {
 		err = -EINVAL;
 		if (!pmc->sfcount[sfmode])
@@ -1824,14 +1810,15 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	if (pmc->sfmode == MCAST_EXCLUDE &&
 	    pmc->sfcount[MCAST_EXCLUDE] == 0 &&
 	    pmc->sfcount[MCAST_INCLUDE]) {
-#ifdef CONFIG_IP_MULTICAST
 		struct ip_sf_list *psf;
 		struct net *net = dev_net(in_dev->dev);
-#endif
 
 		/* filter mode change */
 		pmc->sfmode = MCAST_INCLUDE;
-#ifdef CONFIG_IP_MULTICAST
+
+		if (!IS_ENABLED(CONFIG_IP_MULTICAST))
+			goto out_unlock;
+
 		pmc->crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
 		in_dev->mr_ifc_count = pmc->crcount;
 		for (psf = pmc->sources; psf; psf = psf->sf_next)
@@ -1839,7 +1826,6 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 		igmp_ifc_event(pmc->interface);
 	} else if (sf_setstate(pmc) || changerec) {
 		igmp_ifc_event(pmc->interface);
-#endif
 	}
 out_unlock:
 	spin_unlock_bh(&pmc->lock);
@@ -1877,11 +1863,15 @@ static int ip_mc_add1_src(struct ip_mc_list *pmc, int sfmode,
 	return 0;
 }
 
-#ifdef CONFIG_IP_MULTICAST
 static void sf_markstate(struct ip_mc_list *pmc)
 {
 	struct ip_sf_list *psf;
-	int mca_xcount = pmc->sfcount[MCAST_EXCLUDE];
+	int mca_xcount;
+
+	if (!IS_ENABLED(CONFIG_IP_MULTICAST))
+		return;
+
+	mca_xcount = pmc->sfcount[MCAST_EXCLUDE];
 
 	for (psf = pmc->sources; psf; psf = psf->sf_next)
 		if (pmc->sfcount[MCAST_EXCLUDE]) {
@@ -1895,10 +1885,15 @@ static void sf_markstate(struct ip_mc_list *pmc)
 static int sf_setstate(struct ip_mc_list *pmc)
 {
 	struct ip_sf_list *psf, *dpsf;
-	int mca_xcount = pmc->sfcount[MCAST_EXCLUDE];
-	int qrv = pmc->interface->mr_qrv;
+	int mca_xcount;
+	int qrv;
 	int new_in, rv;
 
+	if (!IS_ENABLED(CONFIG_IP_MULTICAST))
+		return 0;
+
+	mca_xcount = pmc->sfcount[MCAST_EXCLUDE];
+	qrv = pmc->interface->mr_qrv;
 	rv = 0;
 	for (psf = pmc->sources; psf; psf = psf->sf_next) {
 		if (pmc->sfcount[MCAST_EXCLUDE]) {
@@ -1950,7 +1945,6 @@ static int sf_setstate(struct ip_mc_list *pmc)
 	}
 	return rv;
 }
-#endif
 
 /*
  * Add multicast source filter list to the interface list
@@ -1977,9 +1971,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	spin_lock_bh(&pmc->lock);
 	rcu_read_unlock();
 
-#ifdef CONFIG_IP_MULTICAST
 	sf_markstate(pmc);
-#endif
 	isexclude = pmc->sfmode == MCAST_EXCLUDE;
 	if (!delta)
 		pmc->sfcount[sfmode]++;
@@ -1997,18 +1989,19 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 		for (j = 0; j < i; j++)
 			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {
-#ifdef CONFIG_IP_MULTICAST
 		struct ip_sf_list *psf;
 		struct net *net = dev_net(pmc->interface->dev);
 		in_dev = pmc->interface;
-#endif
 
 		/* filter mode change */
 		if (pmc->sfcount[MCAST_EXCLUDE])
 			pmc->sfmode = MCAST_EXCLUDE;
 		else if (pmc->sfcount[MCAST_INCLUDE])
 			pmc->sfmode = MCAST_INCLUDE;
-#ifdef CONFIG_IP_MULTICAST
+
+		if (!IS_ENABLED(CONFIG_IP_MULTICAST))
+			goto out_unlock;
+
 		/* else no filters; keep old mode for reports */
 
 		pmc->crcount = in_dev->mr_qrv ?: net->ipv4.sysctl_igmp_qrv;
@@ -2018,8 +2011,8 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 		igmp_ifc_event(in_dev);
 	} else if (sf_setstate(pmc)) {
 		igmp_ifc_event(in_dev);
-#endif
 	}
+out_unlock:
 	spin_unlock_bh(&pmc->lock);
 	return err;
 }
@@ -2711,13 +2704,10 @@ static int igmp_mc_seq_show(struct seq_file *seq, void *v)
 		char   *querier;
 		long delta;
 
-#ifdef CONFIG_IP_MULTICAST
-		querier = IGMP_V1_SEEN(state->in_dev) ? "V1" :
+		querier = !IS_ENABLED(CONFIG_IP_MULTICAST) ? "NONE" :
+			  IGMP_V1_SEEN(state->in_dev) ? "V1" :
 			  IGMP_V2_SEEN(state->in_dev) ? "V2" :
 			  "V3";
-#else
-		querier = "NONE";
-#endif
 
 		if (rcu_access_pointer(state->in_dev->mc_list) == im) {
 			seq_printf(seq, "%d\t%-10s: %5d %7s\n",
-- 
2.7.0
