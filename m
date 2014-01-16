From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: simplify detection of first operational link-local address on interface
Date: Thu, 16 Jan 2014 20:13:04 +0100
Message-ID: <20140116191304.GC17529@order.stressinduktion.org>
References: <20140116135323.GA7961@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43475 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaAPTNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:13:06 -0500
Content-Disposition: inline
In-Reply-To: <20140116135323.GA7961@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 1ec047eb4751e3 ("ipv6: introduce per-interface counter for
dad-completed ipv6 addresses") I build the detection of the first
operational link-local address much to complex. Additionally this code
now has a race condition.

Replace it with a much simpler variant, which just scans the address
list when duplicate address detection completes, to check if this is
the first valid link local address and send RS and MLD reports then.

Fixes: 1ec047eb4751e3 ("ipv6: introduce per-interface counter for dad-completed ipv6 addresses")
Reported-by: Jiri Pirko <jiri@resnulli.us>
Cc: Flavio Leitner <fbl@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/if_inet6.h |  1 -
 net/ipv6/addrconf.c    | 38 +++++++++++++++++---------------------
 2 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b58c36c..9650a3f 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -165,7 +165,6 @@ struct inet6_dev {
 	struct net_device	*dev;
 
 	struct list_head	addr_list;
-	int			valid_ll_addr_cnt;
 
 	struct ifmcaddr6	*mc_list;
 	struct ifmcaddr6	*mc_tomb;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6913a82..f91e107 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3233,6 +3233,22 @@ out:
 	in6_ifa_put(ifp);
 }
 
+/* ifp->idev must be at least read locked */
+static bool ipv6_lonely_lladdr(struct inet6_ifaddr *ifp)
+{
+	struct inet6_ifaddr *ifpiter;
+	struct inet6_dev *idev = ifp->idev;
+
+	list_for_each_entry(ifpiter, &idev->addr_list, if_list) {
+		if (ifp != ifpiter && ifpiter->scope == IFA_LINK &&
+		    (ifpiter->flags & (IFA_F_PERMANENT|IFA_F_TENTATIVE|
+				       IFA_F_OPTIMISTIC|IFA_F_DADFAILED)) ==
+		    IFA_F_PERMANENT)
+			return false;
+	}
+	return true;
+}
+
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 {
 	struct net_device *dev = ifp->idev->dev;
@@ -3252,14 +3268,11 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	 */
 
 	read_lock_bh(&ifp->idev->lock);
-	spin_lock(&ifp->lock);
-	send_mld = ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL &&
-		   ifp->idev->valid_ll_addr_cnt == 1;
+	send_mld = ifp->scope == IFA_LINK && ipv6_lonely_lladdr(ifp);
 	send_rs = send_mld &&
 		  ipv6_accept_ra(ifp->idev) &&
 		  ifp->idev->cnf.rtr_solicits > 0 &&
 		  (dev->flags&IFF_LOOPBACK) == 0;
-	spin_unlock(&ifp->lock);
 	read_unlock_bh(&ifp->idev->lock);
 
 	/* While dad is in progress mld report's source address is in6_addrany.
@@ -4598,19 +4611,6 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_PREFIX, err);
 }
 
-static void update_valid_ll_addr_cnt(struct inet6_ifaddr *ifp, int count)
-{
-	write_lock_bh(&ifp->idev->lock);
-	spin_lock(&ifp->lock);
-	if (((ifp->flags & (IFA_F_PERMANENT|IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|
-			    IFA_F_DADFAILED)) == IFA_F_PERMANENT) &&
-	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL))
-		ifp->idev->valid_ll_addr_cnt += count;
-	WARN_ON(ifp->idev->valid_ll_addr_cnt < 0);
-	spin_unlock(&ifp->lock);
-	write_unlock_bh(&ifp->idev->lock);
-}
-
 static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 {
 	struct net *net = dev_net(ifp->idev->dev);
@@ -4619,8 +4619,6 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 
 	switch (event) {
 	case RTM_NEWADDR:
-		update_valid_ll_addr_cnt(ifp, 1);
-
 		/*
 		 * If the address was optimistic
 		 * we inserted the route at the start of
@@ -4636,8 +4634,6 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 					      ifp->idev->dev, 0, 0);
 		break;
 	case RTM_DELADDR:
-		update_valid_ll_addr_cnt(ifp, -1);
-
 		if (ifp->idev->cnf.forwarding)
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
-- 
1.8.4.2
