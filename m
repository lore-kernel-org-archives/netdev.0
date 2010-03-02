From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/12] IPv6: addrconf notify when address is unavailable
Date: Tue, 02 Mar 2010 15:32:46 -0800
Message-ID: <20100302234003.046022988@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58935 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756126Ab0CBXqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:46:54 -0500
Content-Disposition: inline; filename=addrconf-anycast-notify.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My recent change in net-next to retain permanent addresses caused regression.
Device refcount would not go to zero when device was unregistered because
left over anycast reference would hold ipv6 dev reference which would hold
device references...

The correct procedure is to call notify chain when address is no longer
available for use.  When interface comes back DAD timer will notify
back that address is available.


Also, link local addresses should be purged when interface is brought
down. The address might be changed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/ipv6/addrconf.c |   37 ++++++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 15 deletions(-)

--- a/net/ipv6/addrconf.c	2010-02-27 08:56:23.955450341 -0800
+++ b/net/ipv6/addrconf.c	2010-02-27 08:57:02.271199959 -0800
@@ -2649,11 +2649,11 @@ static int addrconf_ifdown(struct net_de
 		write_lock_bh(&addrconf_hash_lock);
 		while ((ifa = *bifa) != NULL) {
 			if (ifa->idev == idev &&
-			    (how || !(ifa->flags&IFA_F_PERMANENT))) {
+			    (how || !(ifa->flags&IFA_F_PERMANENT) ||
+			     ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
 				*bifa = ifa->lst_next;
 				ifa->lst_next = NULL;
-				addrconf_del_timer(ifa);
-				in6_ifa_put(ifa);
+				__in6_ifa_put(ifa);
 				continue;
 			}
 			bifa = &ifa->lst_next;
@@ -2691,28 +2691,40 @@ static int addrconf_ifdown(struct net_de
 #endif
 	bifa = &idev->addr_list;
 	while ((ifa = *bifa) != NULL) {
-		if (how == 0 && (ifa->flags&IFA_F_PERMANENT)) {
-			/* Retain permanent address on admin down */
+		addrconf_del_timer(ifa);
+
+		/* If just doing link down, and address is permanent
+		   and not link-local, then retain it. */
+		if (how == 0 &&
+		    (ifa->flags&IFA_F_PERMANENT) &&
+		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
 			bifa = &ifa->if_next;
 
-			/* Restart DAD if needed when link comes back up */
-			if ( !((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
-			       idev->cnf.accept_dad <= 0 ||
-			       (ifa->flags & IFA_F_NODAD)))
-				ifa->flags |= IFA_F_TENTATIVE;
+			/* If not doing DAD on this address, just keep it. */
+			if ((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
+			    idev->cnf.accept_dad <= 0 ||
+			    (ifa->flags & IFA_F_NODAD))
+				continue;
+
+			/* If it was tentative already, no need to notify */
+			if (ifa->flags & IFA_F_TENTATIVE)
+				continue;
+
+			/* Flag it for later restoration when link comes up */
+			ifa->flags |= IFA_F_TENTATIVE;
+			in6_ifa_hold(ifa);
 		} else {
 			*bifa = ifa->if_next;
 			ifa->if_next = NULL;
-
 			ifa->dead = 1;
-			write_unlock_bh(&idev->lock);
+		}
+		write_unlock_bh(&idev->lock);
 
-			__ipv6_ifa_notify(RTM_DELADDR, ifa);
-			atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
-			in6_ifa_put(ifa);
+		__ipv6_ifa_notify(RTM_DELADDR, ifa);
+		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+		in6_ifa_put(ifa);
 
-			write_lock_bh(&idev->lock);
-		}
+		write_lock_bh(&idev->lock);
 	}
 	write_unlock_bh(&idev->lock);
 

-- 

