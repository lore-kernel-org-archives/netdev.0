From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] IPv6:  fix race between cleanup and add/delete address
Date: Wed, 3 Mar 2010 10:19:59 -0800
Message-ID: <20100303101959.481d76fe@nehalam>
References: <20100302233243.259794027@vyatta.com>
	<20100303.011605.225992271.davem@davemloft.net>
	<20100303101449.2ae6a4ca@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46564 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755462Ab0CCSUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 13:20:24 -0500
In-Reply-To: <20100303101449.2ae6a4ca@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This solves a potential race problem during the cleanup process.
The issue is that addrconf_ifdown() needs to traverse address list,
but then drop lock to call the notifier. The version in -next
could get confused if add/delete happened during this window.
Original code (2.6.32 and earlier) was okay because all addresses
were always deleted.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Apply after earlier bug fixes.
  1 IPv6: addrconf dad timer unnecessary bh_disable
  2 IPv6: addrconf timer race
  3 IPv6: addrconf notify when address is unavailable

 net/ipv6/addrconf.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

--- a/net/ipv6/addrconf.c	2010-03-03 08:47:07.157300818 -0800
+++ b/net/ipv6/addrconf.c	2010-03-03 09:31:20.213022628 -0800
@@ -2615,7 +2615,7 @@ static void addrconf_bonding_change(stru
 static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa, **bifa;
+	struct inet6_ifaddr *ifa, *keep_list, **bifa;
 	struct net *net = dev_net(dev);
 	int i;
 
@@ -2689,8 +2689,12 @@ static int addrconf_ifdown(struct net_de
 		write_lock_bh(&idev->lock);
 	}
 #endif
-	bifa = &idev->addr_list;
-	while ((ifa = *bifa) != NULL) {
+	keep_list = NULL;
+	bifa = &keep_list;
+	while ((ifa = idev->addr_list) != NULL) {
+		idev->addr_list = ifa->if_next;
+		ifa->if_next = NULL;
+
 		addrconf_del_timer(ifa);
 
 		/* If just doing link down, and address is permanent
@@ -2698,6 +2702,9 @@ static int addrconf_ifdown(struct net_de
 		if (how == 0 &&
 		    (ifa->flags&IFA_F_PERMANENT) &&
 		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
+
+			/* Move to holding list */
+			*bifa = ifa;
 			bifa = &ifa->if_next;
 
 			/* If not doing DAD on this address, just keep it. */
@@ -2714,8 +2721,6 @@ static int addrconf_ifdown(struct net_de
 			ifa->flags |= IFA_F_TENTATIVE;
 			in6_ifa_hold(ifa);
 		} else {
-			*bifa = ifa->if_next;
-			ifa->if_next = NULL;
 			ifa->dead = 1;
 		}
 		write_unlock_bh(&idev->lock);
@@ -2726,6 +2731,9 @@ static int addrconf_ifdown(struct net_de
 
 		write_lock_bh(&idev->lock);
 	}
+
+	idev->addr_list = keep_list;
+
 	write_unlock_bh(&idev->lock);
 
 	/* Step 5: Discard multicast list */
