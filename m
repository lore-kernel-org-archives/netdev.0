From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: slightly simplify keeping IPv6 addresses on link down
Date: Wed, 01 Dec 2010 12:54:58 -0800
Message-ID: <x6292jal238UZk1a8176sxAzj5hpyN+qSHd+6Jj+k_eO=@mail.gmail.com>
References: <20101201122253.2a8be2e0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Lorenzo Colitti <lorenzo@google.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:36651 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755553Ab0LAVAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 16:00:38 -0500
In-Reply-To: <20101201122253.2a8be2e0@nehalam>
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
@@ -2663,8 +2663,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa;
-	LIST_HEAD(keep_list);
+	struct inet6_ifaddr *ifa, *ifn;
 	int state;
 
 	ASSERT_RTNL();
@@ -2719,9 +2718,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	}
 #endif
 
-	while (!list_empty(&idev->addr_list)) {
-		ifa = list_first_entry(&idev->addr_list,
-				       struct inet6_ifaddr, if_list);
+	list_for_each_entry_safe(ifa, ifn, &idev->addr_list, if_list) {
 		addrconf_del_timer(ifa);
 
 		/* If just doing link down, and address is permanent
@@ -2729,15 +2726,13 @@ static int addrconf_ifdown(struct net_device *dev, int how)
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
+			/* If it was tentative already, dont do anything */
 			if (ifa->flags & IFA_F_TENTATIVE)
 				continue;
 
@@ -2769,8 +2764,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		}
 	}
 
-	list_splice(&keep_list, &idev->addr_list);
-
 	write_unlock_bh(&idev->lock);
 
 	/* Step 5: Discard multicast list */
