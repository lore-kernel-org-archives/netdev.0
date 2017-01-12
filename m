From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] mld: do not remove mld souce list info when set link down
Date: Thu, 12 Jan 2017 21:19:37 +0800
Message-ID: <1484227177-7857-1-git-send-email-liuhangbin@gmail.com>
Cc: David Miller <davem@davemloft.net>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34699 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbdALNUh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:20:37 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so3587593pfb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 05:20:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an IPv6 version of commit 24803f38a5c0 ("igmp: do not remove igmp
souce list..."). In mld_del_delrec(), we will restore back all source filter
info instead of flush them.

Move mld_clear_delrec() from ipv6_mc_down() to ipv6_mc_destroy_dev() since
we should not remove source list info when set link down. Remove
igmp6_group_dropped() in ipv6_mc_destroy_dev() since we have called it in
ipv6_mc_down().

Also clear all source info after igmp6_group_dropped() instead of in it
because ipv6_mc_down() will call igmp6_group_dropped().

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv6/mcast.c | 51 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 30 insertions(+), 21 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 14a3903..7139fff 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -81,7 +81,7 @@ static void mld_gq_timer_expire(unsigned long data);
 static void mld_ifc_timer_expire(unsigned long data);
 static void mld_ifc_event(struct inet6_dev *idev);
 static void mld_add_delrec(struct inet6_dev *idev, struct ifmcaddr6 *pmc);
-static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *addr);
+static void mld_del_delrec(struct inet6_dev *idev, struct ifmcaddr6 *pmc);
 static void mld_clear_delrec(struct inet6_dev *idev);
 static bool mld_in_v1_mode(const struct inet6_dev *idev);
 static int sf_setstate(struct ifmcaddr6 *pmc);
@@ -692,9 +692,9 @@ static void igmp6_group_dropped(struct ifmcaddr6 *mc)
 			dev_mc_del(dev, buf);
 	}
 
-	if (mc->mca_flags & MAF_NOREPORT)
-		goto done;
 	spin_unlock_bh(&mc->mca_lock);
+	if (mc->mca_flags & MAF_NOREPORT)
+		return;
 
 	if (!mc->idev->dead)
 		igmp6_leave_group(mc);
@@ -702,8 +702,6 @@ static void igmp6_group_dropped(struct ifmcaddr6 *mc)
 	spin_lock_bh(&mc->mca_lock);
 	if (del_timer(&mc->mca_timer))
 		atomic_dec(&mc->mca_refcnt);
-done:
-	ip6_mc_clear_src(mc);
 	spin_unlock_bh(&mc->mca_lock);
 }
 
@@ -748,10 +746,11 @@ static void mld_add_delrec(struct inet6_dev *idev, struct ifmcaddr6 *im)
 	spin_unlock_bh(&idev->mc_lock);
 }
 
-static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *pmca)
+static void mld_del_delrec(struct inet6_dev *idev, struct ifmcaddr6 *im)
 {
 	struct ifmcaddr6 *pmc, *pmc_prev;
-	struct ip6_sf_list *psf, *psf_next;
+	struct ip6_sf_list *psf;
+	struct in6_addr *pmca = &im->mca_addr;
 
 	spin_lock_bh(&idev->mc_lock);
 	pmc_prev = NULL;
@@ -768,14 +767,20 @@ static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *pmca)
 	}
 	spin_unlock_bh(&idev->mc_lock);
 
+	spin_lock_bh(&im->mca_lock);
 	if (pmc) {
-		for (psf = pmc->mca_tomb; psf; psf = psf_next) {
-			psf_next = psf->sf_next;
-			kfree(psf);
+		im->idev = pmc->idev;
+		im->mca_crcount = idev->mc_qrv;
+		im->mca_sfmode = pmc->mca_sfmode;
+		if (pmc->mca_sfmode == MCAST_INCLUDE) {
+			im->mca_tomb = pmc->mca_tomb;
+			im->mca_sources = pmc->mca_sources;
+			for (psf = im->mca_sources; psf; psf = psf->sf_next)
+				psf->sf_crcount = im->mca_crcount;
 		}
 		in6_dev_put(pmc->idev);
-		kfree(pmc);
 	}
+	spin_unlock_bh(&im->mca_lock);
 }
 
 static void mld_clear_delrec(struct inet6_dev *idev)
@@ -904,7 +909,7 @@ int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr)
 	mca_get(mc);
 	write_unlock_bh(&idev->lock);
 
-	mld_del_delrec(idev, &mc->mca_addr);
+	mld_del_delrec(idev, mc);
 	igmp6_group_added(mc);
 	ma_put(mc);
 	return 0;
@@ -927,6 +932,7 @@ int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 				write_unlock_bh(&idev->lock);
 
 				igmp6_group_dropped(ma);
+				ip6_mc_clear_src(ma);
 
 				ma_put(ma);
 				return 0;
@@ -2501,15 +2507,17 @@ void ipv6_mc_down(struct inet6_dev *idev)
 	/* Withdraw multicast list */
 
 	read_lock_bh(&idev->lock);
-	mld_ifc_stop_timer(idev);
-	mld_gq_stop_timer(idev);
-	mld_dad_stop_timer(idev);
 
 	for (i = idev->mc_list; i; i = i->next)
 		igmp6_group_dropped(i);
-	read_unlock_bh(&idev->lock);
 
-	mld_clear_delrec(idev);
+	/* Should stop timer after group drop. or we will
+	 * start timer again in mld_ifc_event()
+	 */
+	mld_ifc_stop_timer(idev);
+	mld_gq_stop_timer(idev);
+	mld_dad_stop_timer(idev);
+	read_unlock_bh(&idev->lock);
 }
 
 static void ipv6_mc_reset(struct inet6_dev *idev)
@@ -2531,8 +2539,10 @@ void ipv6_mc_up(struct inet6_dev *idev)
 
 	read_lock_bh(&idev->lock);
 	ipv6_mc_reset(idev);
-	for (i = idev->mc_list; i; i = i->next)
+	for (i = idev->mc_list; i; i = i->next) {
+		mld_del_delrec(idev, i);
 		igmp6_group_added(i);
+	}
 	read_unlock_bh(&idev->lock);
 }
 
@@ -2565,6 +2575,7 @@ void ipv6_mc_destroy_dev(struct inet6_dev *idev)
 
 	/* Deactivate timers */
 	ipv6_mc_down(idev);
+	mld_clear_delrec(idev);
 
 	/* Delete all-nodes address. */
 	/* We cannot call ipv6_dev_mc_dec() directly, our caller in
@@ -2579,11 +2590,9 @@ void ipv6_mc_destroy_dev(struct inet6_dev *idev)
 	write_lock_bh(&idev->lock);
 	while ((i = idev->mc_list) != NULL) {
 		idev->mc_list = i->next;
-		write_unlock_bh(&idev->lock);
 
-		igmp6_group_dropped(i);
+		write_unlock_bh(&idev->lock);
 		ma_put(i);
-
 		write_lock_bh(&idev->lock);
 	}
 	write_unlock_bh(&idev->lock);
-- 
2.5.5
