From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/2] ipv6: resend MLD report if a link-local address completes DAD
Date: Thu, 27 Jun 2013 00:07:01 +0200
Message-ID: <20130626220701.GA26180@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fleitner@redhat.com, yoshfuji@linux-ipv6.org, dlstevens@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40032 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018Ab3FZWHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:07:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC3590/RFC3810 specifies we should resend MLD reports as soon as a
valid link-local address is available.

We now use the valid_ll_addr_cnt to check if it is necessary to resend
a new report.

Changes since Flavio Leitner's version:
a) adapt for valid_ll_addr_cnt
b) resend first reports directly in the path and just arm the timer for
   mc_qrv-1 resends.

Reported-by: Flavio Leitner <fleitner@redhat.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: David Stevens <dlstevens@us.ibm.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 include/net/addrconf.h |  1 +
 include/net/if_inet6.h |  2 ++
 net/ipv6/addrconf.c    | 17 ++++++++++++-----
 net/ipv6/mcast.c       | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 5 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 21f70270..f68eaf5 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -155,6 +155,7 @@ extern bool ipv6_chk_mcast_addr(struct net_device *dev,
 				const struct in6_addr *group,
 				const struct in6_addr *src_addr);
 
+extern void ipv6_mc_dad_complete(struct inet6_dev *idev);
 /*
  * identify MLD packets for MLD filter exceptions
  */
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 1628b8f..736b5fb 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -174,10 +174,12 @@ struct inet6_dev {
 	unsigned char		mc_qrv;
 	unsigned char		mc_gq_running;
 	unsigned char		mc_ifc_count;
+	unsigned char		mc_dad_count;
 	unsigned long		mc_v1_seen;
 	unsigned long		mc_maxdelay;
 	struct timer_list	mc_gq_timer;	/* general query timer */
 	struct timer_list	mc_ifc_timer;	/* interface change timer */
+	struct timer_list	mc_dad_timer;	/* dad complete mc timer */
 
 	struct ifacaddr6	*ac_list;
 	rwlock_t		lock;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7044785..d66da0b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3277,7 +3277,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 {
 	struct net_device *dev = ifp->idev->dev;
 	struct in6_addr lladdr;
-	bool send_rs;
+	bool send_rs, send_mld;
 
 	addrconf_del_dad_timer(ifp);
 
@@ -3293,14 +3293,21 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 
 	read_lock_bh(&ifp->idev->lock);
 	spin_lock(&ifp->lock);
-	send_rs = ipv6_accept_ra(ifp->idev) &&
+	send_mld = ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL &&
+		   ifp->idev->valid_ll_addr_cnt == 1;
+	send_rs = send_mld &&
+		  ipv6_accept_ra(ifp->idev) &&
 		  ifp->idev->cnf.rtr_solicits > 0 &&
-		  (dev->flags&IFF_LOOPBACK) == 0 &&
-		  ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL &&
-		  ifp->idev->valid_ll_addr_cnt == 1;
+		  (dev->flags&IFF_LOOPBACK) == 0;
 	spin_unlock(&ifp->lock);
 	read_unlock_bh(&ifp->idev->lock);
 
+	/* While dad is in progress mld report's source address is in6_addrany.
+	 * Resend with proper ll now.
+	 */
+	if (send_mld)
+		ipv6_mc_dad_complete(ifp->idev);
+
 	if (send_rs) {
 		/*
 		 *	If a host as already performed a random delay
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 72c8bfe..502c877 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -999,6 +999,14 @@ static void mld_ifc_start_timer(struct inet6_dev *idev, int delay)
 		in6_dev_hold(idev);
 }
 
+static void mld_dad_start_timer(struct inet6_dev *idev, int delay)
+{
+	int tv = net_random() % delay;
+
+	if (!mod_timer(&idev->mc_dad_timer, jiffies+tv+2))
+		in6_dev_hold(idev);
+}
+
 /*
  *	IGMP handling (alias multicast ICMPv6 messages)
  */
@@ -1815,6 +1823,46 @@ err_out:
 	goto out;
 }
 
+static void mld_resend_report(struct inet6_dev *idev)
+{
+	if (MLD_V1_SEEN(idev)) {
+		struct ifmcaddr6 *mcaddr;
+		read_lock_bh(&idev->lock);
+		for (mcaddr = idev->mc_list; mcaddr; mcaddr = mcaddr->next) {
+			if (!(mcaddr->mca_flags & MAF_NOREPORT))
+				igmp6_send(&mcaddr->mca_addr, idev->dev,
+					   ICMPV6_MGM_REPORT);
+		}
+		read_unlock_bh(&idev->lock);
+	} else {
+		mld_send_report(idev, NULL);
+	}
+}
+
+void ipv6_mc_dad_complete(struct inet6_dev *idev)
+{
+	idev->mc_dad_count = idev->mc_qrv;
+	if (idev->mc_dad_count) {
+		mld_resend_report(idev);
+		idev->mc_dad_count--;
+		if (idev->mc_dad_count)
+			mld_dad_start_timer(idev, idev->mc_maxdelay);
+	}
+}
+
+static void mld_dad_timer_expire(unsigned long data)
+{
+	struct inet6_dev *idev = (struct inet6_dev *)data;
+
+	mld_resend_report(idev);
+	if (idev->mc_dad_count) {
+		idev->mc_dad_count--;
+		if (idev->mc_dad_count)
+			mld_dad_start_timer(idev, idev->mc_maxdelay);
+	}
+	__in6_dev_put(idev);
+}
+
 static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
 	const struct in6_addr *psfsrc)
 {
@@ -2232,6 +2280,8 @@ void ipv6_mc_down(struct inet6_dev *idev)
 	idev->mc_gq_running = 0;
 	if (del_timer(&idev->mc_gq_timer))
 		__in6_dev_put(idev);
+	if (del_timer(&idev->mc_dad_timer))
+		__in6_dev_put(idev);
 
 	for (i = idev->mc_list; i; i=i->next)
 		igmp6_group_dropped(i);
@@ -2268,6 +2318,8 @@ void ipv6_mc_init_dev(struct inet6_dev *idev)
 	idev->mc_ifc_count = 0;
 	setup_timer(&idev->mc_ifc_timer, mld_ifc_timer_expire,
 			(unsigned long)idev);
+	setup_timer(&idev->mc_dad_timer, mld_dad_timer_expire,
+		    (unsigned long)idev);
 	idev->mc_qrv = MLD_QRV_DEFAULT;
 	idev->mc_maxdelay = IGMP6_UNSOLICITED_IVAL;
 	idev->mc_v1_seen = 0;
-- 
1.8.1.4
