From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/12] IPv6: addrconf timer race
Date: Tue, 02 Mar 2010 15:32:45 -0800
Message-ID: <20100302234002.971992509@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58931 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757674Ab0CBXqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:46:49 -0500
Content-Disposition: inline; filename=addrconf-rstimer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Router Solicitation timer races with device state changes
because it doesn't lock the device. Use local variable to avoid
one repeated dereference.


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv6/addrconf.c	2010-02-26 20:00:43.703982448 -0800
+++ b/net/ipv6/addrconf.c	2010-02-27 08:29:41.727984521 -0800
@@ -2739,28 +2739,29 @@ static int addrconf_ifdown(struct net_de
 static void addrconf_rs_timer(unsigned long data)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *) data;
+	struct inet6_dev *idev = ifp->idev;
 
-	if (ifp->idev->cnf.forwarding)
+	read_lock(&idev->lock);
+	if (idev->dead || !(idev->if_flags & IF_READY))
 		goto out;
 
-	if (ifp->idev->if_flags & IF_RA_RCVD) {
-		/*
-		 *	Announcement received after solicitation
-		 *	was sent
-		 */
+	if (idev->cnf.forwarding)
+		goto out;
+
+	/* Announcement received after solicitation was sent */
+	if (idev->if_flags & IF_RA_RCVD)
 		goto out;
-	}
 
 	spin_lock(&ifp->lock);
-	if (ifp->probes++ < ifp->idev->cnf.rtr_solicits) {
+	if (ifp->probes++ < idev->cnf.rtr_solicits) {
 		/* The wait after the last probe can be shorter */
 		addrconf_mod_timer(ifp, AC_RS,
-				   (ifp->probes == ifp->idev->cnf.rtr_solicits) ?
-				   ifp->idev->cnf.rtr_solicit_delay :
-				   ifp->idev->cnf.rtr_solicit_interval);
+				   (ifp->probes == idev->cnf.rtr_solicits) ?
+				   idev->cnf.rtr_solicit_delay :
+				   idev->cnf.rtr_solicit_interval);
 		spin_unlock(&ifp->lock);
 
-		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &in6addr_linklocal_allrouters);
+		ndisc_send_rs(idev->dev, &ifp->addr, &in6addr_linklocal_allrouters);
 	} else {
 		spin_unlock(&ifp->lock);
 		/*
@@ -2768,10 +2769,11 @@ static void addrconf_rs_timer(unsigned l
 		 * assumption any longer.
 		 */
 		printk(KERN_DEBUG "%s: no IPv6 routers present\n",
-		       ifp->idev->dev->name);
+		       idev->dev->name);
 	}
 
 out:
+	read_unlock(&idev->lock);
 	in6_ifa_put(ifp);
 }
 

-- 

