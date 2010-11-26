From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] ipv6: slightly simplify keeping IPv6 addresses on link down
Date: Fri, 26 Nov 2010 10:06:58 -0800
Message-ID: <AANLkTikvmRhkxB0WDUYeTj7qpsud0+qSHd+6Jj+k_eO=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:18105 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507Ab0KZSHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 13:07:20 -0500
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id oAQI7JVb022348
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 10:07:19 -0800
Received: from yxl31 (yxl31.prod.google.com [10.190.3.223])
	by wpaz13.hot.corp.google.com with ESMTP id oAQI7IC4000585
	for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 10:07:19 -0800
Received: by yxl31 with SMTP id 31so13724727yxl.0
        for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 10:07:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6: slightly simplify keeping IPv6 addresses on link down

When link goes down, all statically-configured (i.e.,
permanent and not link-local) IPv6 addresses are kept on
the interface. Instead of moving addresses to a temporary
keep list and then splicing that back on to the interface
address list, use list_for_each_entry_safe and delete the
ones we don't want.

Tested by configuring two static addresses on an interface
and verifying that pings from the addresses keep working
when bringing link down and up again and when disabling and
re-enabling IPv6 on the interface.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 23cc8e1..6dfd5c5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2663,8 +2663,7 @@ static int addrconf_ifdown(struct net_device
*dev, int how)
 {
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa;
-	LIST_HEAD(keep_list);
+	struct inet6_ifaddr *ifa, *ifn;
 	int state;

 	ASSERT_RTNL();
@@ -2719,9 +2718,7 @@ static int addrconf_ifdown(struct net_device
*dev, int how)
 	}
 #endif

-	while (!list_empty(&idev->addr_list)) {
-		ifa = list_first_entry(&idev->addr_list,
-				       struct inet6_ifaddr, if_list);
+	list_for_each_entry_safe(ifa, ifn, &idev->addr_list, if_list) {
 		addrconf_del_timer(ifa);

 		/* If just doing link down, and address is permanent
@@ -2729,15 +2726,13 @@ static int addrconf_ifdown(struct net_device
*dev, int how)
 		if (!how &&
 		    (ifa->flags&IFA_F_PERMANENT) &&
 		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
-			list_move_tail(&ifa->if_list, &keep_list);
-
 			/* If not doing DAD on this address, just keep it. */
 			if ((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
 			    idev->cnf.accept_dad <= 0 ||
 			    (ifa->flags & IFA_F_NODAD))
 				continue;

-			/* If it was tentative already, no need to notify */
+			/* If it was tentative already, no need to do anything */
 			if (ifa->flags & IFA_F_TENTATIVE)
 				continue;

@@ -2769,8 +2764,6 @@ static int addrconf_ifdown(struct net_device
*dev, int how)
 		}
 	}

-	list_splice(&keep_list, &idev->addr_list);
-
 	write_unlock_bh(&idev->lock);

 	/* Step 5: Discard multicast list */
