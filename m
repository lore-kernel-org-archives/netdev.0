From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] IPv6: remove trivial nested _bh suffix
Date: Mon, 8 Feb 2010 21:48:52 -0800
Message-ID: <20100208214852.017349dd@nehalam>
References: <20100208214805.1f8f2c6d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ?=
	 =?UTF-8?B?6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35815 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297Ab0BIFtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 00:49:05 -0500
In-Reply-To: <20100208214805.1f8f2c6d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't need to disable bottom half it is already down in the
previous lock. Move some blank lines to group locking in same
context.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2010-02-08 21:37:31.589584963 -0800
+++ b/net/ipv6/addrconf.c	2010-02-08 21:37:41.114027790 -0800
@@ -2802,14 +2802,14 @@ static void addrconf_dad_start(struct in
 	read_lock_bh(&idev->lock);
 	if (ifp->dead)
 		goto out;
-	spin_lock_bh(&ifp->lock);
 
+	spin_lock(&ifp->lock);
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    idev->cnf.accept_dad < 1 ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
-		spin_unlock_bh(&ifp->lock);
+		spin_unlock(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
 		addrconf_dad_completed(ifp);
@@ -2817,7 +2817,7 @@ static void addrconf_dad_start(struct in
 	}
 
 	if (!(idev->if_flags & IF_READY)) {
-		spin_unlock_bh(&ifp->lock);
+		spin_unlock(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 		/*
 		 * If the device is not ready:
@@ -2837,7 +2837,7 @@ static void addrconf_dad_start(struct in
 		ip6_ins_rt(ifp->rt);
 
 	addrconf_dad_kick(ifp);
-	spin_unlock_bh(&ifp->lock);
+	spin_unlock(&ifp->lock);
 out:
 	read_unlock_bh(&idev->lock);
 }
@@ -2853,14 +2853,15 @@ static void addrconf_dad_timer(unsigned 
 		read_unlock_bh(&idev->lock);
 		goto out;
 	}
-	spin_lock_bh(&ifp->lock);
+
+	spin_lock(&ifp->lock);
 	if (ifp->probes == 0) {
 		/*
 		 * DAD was successful
 		 */
 
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
-		spin_unlock_bh(&ifp->lock);
+		spin_unlock(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
 		addrconf_dad_completed(ifp);
@@ -2870,7 +2871,7 @@ static void addrconf_dad_timer(unsigned 
 
 	ifp->probes--;
 	addrconf_mod_timer(ifp, AC_DAD, ifp->idev->nd_parms->retrans_time);
-	spin_unlock_bh(&ifp->lock);
+	spin_unlock(&ifp->lock);
 	read_unlock_bh(&idev->lock);
 
 	/* send a neighbour solicitation for our addr */
@@ -2918,12 +2919,12 @@ static void addrconf_dad_run(struct inet
 
 	read_lock_bh(&idev->lock);
 	for (ifp = idev->addr_list; ifp; ifp = ifp->if_next) {
-		spin_lock_bh(&ifp->lock);
+		spin_lock(&ifp->lock);
 		if (!(ifp->flags & IFA_F_TENTATIVE)) {
-			spin_unlock_bh(&ifp->lock);
+			spin_unlock(&ifp->lock);
 			continue;
 		}
-		spin_unlock_bh(&ifp->lock);
+		spin_unlock(&ifp->lock);
 		addrconf_dad_kick(ifp);
 	}
 	read_unlock_bh(&idev->lock);


-- 
