From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] IPv6: convert mc_lock to spinlock
Date: Wed, 17 Feb 2010 18:28:59 -0800
Message-ID: <20100217182859.3a4f30de@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ?=
	 =?UTF-8?B?6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58016 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756663Ab0BRC3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 21:29:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only used for writing, so convert to spinlock

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/include/net/if_inet6.h	2010-02-17 17:31:40.353868234 -0800
+++ b/include/net/if_inet6.h	2010-02-17 17:31:57.069744558 -0800
@@ -156,7 +156,7 @@ struct inet6_dev {
 
 	struct ifmcaddr6	*mc_list;
 	struct ifmcaddr6	*mc_tomb;
-	rwlock_t		mc_lock;
+	spinlock_t		mc_lock;
 	unsigned char		mc_qrv;
 	unsigned char		mc_gq_running;
 	unsigned char		mc_ifc_count;
--- a/net/ipv6/mcast.c	2010-02-17 17:32:25.486242516 -0800
+++ b/net/ipv6/mcast.c	2010-02-17 17:36:08.025743316 -0800
@@ -793,10 +793,10 @@ static void mld_add_delrec(struct inet6_
 	}
 	spin_unlock_bh(&im->mca_lock);
 
-	write_lock_bh(&idev->mc_lock);
+	spin_lock_bh(&idev->mc_lock);
 	pmc->next = idev->mc_tomb;
 	idev->mc_tomb = pmc;
-	write_unlock_bh(&idev->mc_lock);
+	spin_unlock_bh(&idev->mc_lock);
 }
 
 static void mld_del_delrec(struct inet6_dev *idev, struct in6_addr *pmca)
@@ -804,7 +804,7 @@ static void mld_del_delrec(struct inet6_
 	struct ifmcaddr6 *pmc, *pmc_prev;
 	struct ip6_sf_list *psf, *psf_next;
 
-	write_lock_bh(&idev->mc_lock);
+	spin_lock_bh(&idev->mc_lock);
 	pmc_prev = NULL;
 	for (pmc=idev->mc_tomb; pmc; pmc=pmc->next) {
 		if (ipv6_addr_equal(&pmc->mca_addr, pmca))
@@ -817,7 +817,8 @@ static void mld_del_delrec(struct inet6_
 		else
 			idev->mc_tomb = pmc->next;
 	}
-	write_unlock_bh(&idev->mc_lock);
+	spin_unlock_bh(&idev->mc_lock);
+
 	if (pmc) {
 		for (psf=pmc->mca_tomb; psf; psf=psf_next) {
 			psf_next = psf->sf_next;
@@ -832,10 +833,10 @@ static void mld_clear_delrec(struct inet
 {
 	struct ifmcaddr6 *pmc, *nextpmc;
 
-	write_lock_bh(&idev->mc_lock);
+	spin_lock_bh(&idev->mc_lock);
 	pmc = idev->mc_tomb;
 	idev->mc_tomb = NULL;
-	write_unlock_bh(&idev->mc_lock);
+	spin_unlock_bh(&idev->mc_lock);
 
 	for (; pmc; pmc = nextpmc) {
 		nextpmc = pmc->next;
@@ -1696,7 +1697,7 @@ static void mld_send_cr(struct inet6_dev
 	int type, dtype;
 
 	read_lock_bh(&idev->lock);
-	write_lock_bh(&idev->mc_lock);
+	spin_lock(&idev->mc_lock);
 
 	/* deleted MCA's */
 	pmc_prev = NULL;
@@ -1730,7 +1731,7 @@ static void mld_send_cr(struct inet6_dev
 		} else
 			pmc_prev = pmc;
 	}
-	write_unlock_bh(&idev->mc_lock);
+	spin_unlock(&idev->mc_lock);
 
 	/* change recs */
 	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
@@ -2311,7 +2312,7 @@ void ipv6_mc_up(struct inet6_dev *idev)
 void ipv6_mc_init_dev(struct inet6_dev *idev)
 {
 	write_lock_bh(&idev->lock);
-	rwlock_init(&idev->mc_lock);
+	spin_lock_init(&idev->mc_lock);
 	idev->mc_gq_running = 0;
 	setup_timer(&idev->mc_gq_timer, mld_gq_timer_expire,
 			(unsigned long)idev);
