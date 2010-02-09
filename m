From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] IPv6: keep permanent addresses on admin down
Date: Mon, 8 Feb 2010 21:48:05 -0800
Message-ID: <20100208214805.1f8f2c6d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ?=
	 =?UTF-8?B?6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35820 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692Ab0BIFtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 00:49:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Permanent IPV6 addresses should not be removed when the link is
set to admin down, only when device is removed. 

When link is lost permanent addresses should be marked as tentative
so that when link comes back they are subject to duplicate address
detection (if DAD was enabled for that address).

Other routing systems keep manually configured IPv6 addresses
when link is set down.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
The logic here is getting long and twisted, doing some work
to use RCU here and refactor.

--- a/net/ipv6/addrconf.c	2010-02-08 21:05:04.798785751 -0800
+++ b/net/ipv6/addrconf.c	2010-02-08 21:38:58.734340743 -0800
@@ -2646,7 +2646,8 @@ static int addrconf_ifdown(struct net_de
 
 		write_lock_bh(&addrconf_hash_lock);
 		while ((ifa = *bifa) != NULL) {
-			if (ifa->idev == idev) {
+			if (ifa->idev == idev &&
+			    (how || !(ifa->flags&IFA_F_PERMANENT))) {
 				*bifa = ifa->lst_next;
 				ifa->lst_next = NULL;
 				addrconf_del_timer(ifa);
@@ -2686,18 +2687,30 @@ static int addrconf_ifdown(struct net_de
 		write_lock_bh(&idev->lock);
 	}
 #endif
-	while ((ifa = idev->addr_list) != NULL) {
-		idev->addr_list = ifa->if_next;
-		ifa->if_next = NULL;
-		ifa->dead = 1;
-		addrconf_del_timer(ifa);
-		write_unlock_bh(&idev->lock);
-
-		__ipv6_ifa_notify(RTM_DELADDR, ifa);
-		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
-		in6_ifa_put(ifa);
+	bifa = &idev->addr_list;
+	while ((ifa = *bifa) != NULL) {
+		if (how == 0 && (ifa->flags&IFA_F_PERMANENT)) {
+			/* Retain permanent address on admin down */
+			bifa = &ifa->if_next;
+
+			/* Restart DAD if needed when link comes back up */
+			if ( !((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
+			       idev->cnf.accept_dad <= 0 ||
+			       (ifa->flags & IFA_F_NODAD)))
+				ifa->flags |= IFA_F_TENTATIVE;
+		} else {
+			*bifa = ifa->if_next;
+			ifa->if_next = NULL;
+
+			ifa->dead = 1;
+			write_unlock_bh(&idev->lock);
+
+			__ipv6_ifa_notify(RTM_DELADDR, ifa);
+			atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+			in6_ifa_put(ifa);
 
-		write_lock_bh(&idev->lock);
+			write_lock_bh(&idev->lock);
+		}
 	}
 	write_unlock_bh(&idev->lock);
 
