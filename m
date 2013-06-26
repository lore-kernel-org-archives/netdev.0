From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/2] ipv6: introduce per-interface counter for dad-completed ipv6 addresses
Date: Thu, 27 Jun 2013 00:06:56 +0200
Message-ID: <20130626220656.GA20845@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fbl@redhat.com, yoshfuji@linux-ipv6.org, dlstevens@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40026 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018Ab3FZWG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:06:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To reduce the number of unnecessary router solicitations, MLDv2 and IGMPv3
messages we need to track the number of valid (as in non-optimistic,
no-dad-failed and non-tentative) link-local addresses. Therefore, this
patch implements a valid_ll_addr_cnt in struct inet6_dev.

We now only emit router solicitations if the first link-local address
finishes duplicate address detection.

The changes for MLDv2 and IGMPv3 are in a follow-up patch.

While there, also simplify one if statement(one minor nit I made in one
of my previous patches):

if (!...)
	do();
else
	return;

<<into>>

if (...)
	return;
do();

Cc: Flavio Leitner <fbl@redhat.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: David Stevens <dlstevens@us.ibm.com>
Suggested-by: David Stevens <dlstevens@us.ibm.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/if_inet6.h |  1 +
 net/ipv6/addrconf.c    | 39 +++++++++++++++++++++++++++++++--------
 2 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index e4c5a2d..1628b8f 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -166,6 +166,7 @@ struct inet6_dev {
 	struct net_device	*dev;
 
 	struct list_head	addr_list;
+	int			valid_ll_addr_cnt;
 
 	struct ifmcaddr6	*mc_list;
 	struct ifmcaddr6	*mc_tomb;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index afaf3cd..7044785 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3277,6 +3277,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 {
 	struct net_device *dev = ifp->idev->dev;
 	struct in6_addr lladdr;
+	bool send_rs;
 
 	addrconf_del_dad_timer(ifp);
 
@@ -3290,20 +3291,25 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	   router advertisements, start sending router solicitations.
 	 */
 
-	if (ipv6_accept_ra(ifp->idev) &&
-	    ifp->idev->cnf.rtr_solicits > 0 &&
-	    (dev->flags&IFF_LOOPBACK) == 0 &&
-	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
+	read_lock_bh(&ifp->idev->lock);
+	spin_lock(&ifp->lock);
+	send_rs = ipv6_accept_ra(ifp->idev) &&
+		  ifp->idev->cnf.rtr_solicits > 0 &&
+		  (dev->flags&IFF_LOOPBACK) == 0 &&
+		  ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL &&
+		  ifp->idev->valid_ll_addr_cnt == 1;
+	spin_unlock(&ifp->lock);
+	read_unlock_bh(&ifp->idev->lock);
+
+	if (send_rs) {
 		/*
 		 *	If a host as already performed a random delay
 		 *	[...] as part of DAD [...] there is no need
 		 *	to delay again before sending the first RS
 		 */
-		if (!ipv6_get_lladdr(dev, &lladdr, IFA_F_TENTATIVE))
-			ndisc_send_rs(dev, &lladdr,
-				      &in6addr_linklocal_allrouters);
-		else
+		if (ipv6_get_lladdr(dev, &lladdr, IFA_F_TENTATIVE))
 			return;
+		ndisc_send_rs(dev, &lladdr, &in6addr_linklocal_allrouters);
 
 		write_lock_bh(&ifp->idev->lock);
 		spin_lock(&ifp->lock);
@@ -4573,6 +4579,19 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_PREFIX, err);
 }
 
+static void update_valid_ll_addr_cnt(struct inet6_ifaddr *ifp, int count)
+{
+	write_lock_bh(&ifp->idev->lock);
+	spin_lock(&ifp->lock);
+	if (((ifp->flags & (IFA_F_PERMANENT|IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|
+			    IFA_F_DADFAILED)) == IFA_F_PERMANENT) &&
+	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL))
+		ifp->idev->valid_ll_addr_cnt += count;
+	WARN_ON(ifp->idev->valid_ll_addr_cnt < 0);
+	spin_unlock(&ifp->lock);
+	write_unlock_bh(&ifp->idev->lock);
+}
+
 static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 {
 	struct net *net = dev_net(ifp->idev->dev);
@@ -4581,6 +4600,8 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 
 	switch (event) {
 	case RTM_NEWADDR:
+		update_valid_ll_addr_cnt(ifp, 1);
+
 		/*
 		 * If the address was optimistic
 		 * we inserted the route at the start of
@@ -4596,6 +4617,8 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 					      ifp->idev->dev, 0, 0);
 		break;
 	case RTM_DELADDR:
+		update_valid_ll_addr_cnt(ifp, -1);
+
 		if (ifp->idev->cnf.forwarding)
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
-- 
1.8.1.4
