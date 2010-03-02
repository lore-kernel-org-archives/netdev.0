From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/12] IPv6: addrconf dad timer unnecessary bh_disable
Date: Tue, 02 Mar 2010 15:32:44 -0800
Message-ID: <20100302234002.893332269@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58927 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757920Ab0CBXqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:46:43 -0500
Content-Disposition: inline; filename=addrconf-dad-bh.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timer code runs in bottom half, so there is no need for
using _bh form of locking.  Also check if device is not ready
to avoid race with address that is no longer active.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv6/addrconf.c	2010-02-26 20:00:39.967484383 -0800
+++ b/net/ipv6/addrconf.c	2010-02-27 08:29:44.544108734 -0800
@@ -2850,9 +2850,9 @@ static void addrconf_dad_timer(unsigned 
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr mcaddr;
 
-	read_lock_bh(&idev->lock);
-	if (idev->dead) {
-		read_unlock_bh(&idev->lock);
+	read_lock(&idev->lock);
+	if (idev->dead || !(idev->if_flags & IF_READY)) {
+		read_unlock(&idev->lock);
 		goto out;
 	}
 
@@ -2864,7 +2864,7 @@ static void addrconf_dad_timer(unsigned 
 
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
 		spin_unlock(&ifp->lock);
-		read_unlock_bh(&idev->lock);
+		read_unlock(&idev->lock);
 
 		addrconf_dad_completed(ifp);
 
@@ -2874,7 +2874,7 @@ static void addrconf_dad_timer(unsigned 
 	ifp->probes--;
 	addrconf_mod_timer(ifp, AC_DAD, ifp->idev->nd_parms->retrans_time);
 	spin_unlock(&ifp->lock);
-	read_unlock_bh(&idev->lock);
+	read_unlock(&idev->lock);
 
 	/* send a neighbour solicitation for our addr */
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);

-- 

