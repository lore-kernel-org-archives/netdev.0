From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/4] IPv6: keep tentative addresses in hash table
Date: Mon, 12 Apr 2010 08:41:32 -0700
Message-ID: <20100412154255.722417369@vyatta.com>
References: <20100412154130.397252857@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47330 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388Ab0DLPql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 11:46:41 -0400
Content-Disposition: inline; filename=ipv6-addrconf2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When link goes down, want address to be preserved but in a tentative
state, therefore it has to stay in hash list.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2010-04-11 12:25:05.349309074 -0700
+++ b/net/ipv6/addrconf.c	2010-04-11 12:25:10.408996382 -0700
@@ -2703,17 +2703,18 @@ static int addrconf_ifdown(struct net_de
 			/* Flag it for later restoration when link comes up */
 			ifa->flags |= IFA_F_TENTATIVE;
 			in6_ifa_hold(ifa);
+			write_unlock_bh(&idev->lock);
 		} else {
 			list_del(&ifa->if_list);
 			ifa->dead = 1;
-		}
-		write_unlock_bh(&idev->lock);
+			write_unlock_bh(&idev->lock);
 
-		/* clear hash table */
-		spin_lock_bh(&addrconf_hash_lock);
-		hlist_del_init_rcu(&ifa->addr_lst);
-		__in6_ifa_put(ifa);
-		spin_unlock_bh(&addrconf_hash_lock);
+			/* clear hash table */
+			spin_lock_bh(&addrconf_hash_lock);
+			hlist_del_init_rcu(&ifa->addr_lst);
+			__in6_ifa_put(ifa);
+			spin_unlock_bh(&addrconf_hash_lock);
+		}
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
 		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);

-- 

