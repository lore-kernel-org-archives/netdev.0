From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/6] ipv6: prepare RCU lookups for idev->addr_list
Date: Sat,  7 Oct 2017 19:30:23 -0700
Message-ID: <20171008023028.32071-2-edumazet@google.com>
References: <20171008023028.32071-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:57343 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdJHCaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 22:30:39 -0400
Received: by mail-pf0-f179.google.com with SMTP id b85so47146pfj.13
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2017 19:30:39 -0700 (PDT)
In-Reply-To: <20171008023028.32071-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet6_ifa_finish_destroy() already uses kfree_rcu() to free
inet6_ifaddr structs.

We need to use proper list additions/deletions in order
to allow readers to use RCU instead of idev->lock rwlock.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9854d93e45bb5ca919d55e6b875f7dc392a5dae5..d1ff0955b709eaa6b5d94bd8d740334eb1eed6d7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -945,7 +945,7 @@ ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
 			break;
 	}
 
-	list_add_tail(&ifp->if_list, p);
+	list_add_tail_rcu(&ifp->if_list, p);
 }
 
 static u32 inet6_addr_hash(const struct in6_addr *addr)
@@ -1204,7 +1204,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	if (ifp->flags & IFA_F_PERMANENT && !(ifp->flags & IFA_F_NOPREFIXROUTE))
 		action = check_cleanup_prefix_route(ifp, &expires);
 
-	list_del_init(&ifp->if_list);
+	list_del_rcu(&ifp->if_list);
 	__in6_ifa_put(ifp);
 
 	write_unlock_bh(&ifp->idev->lock);
@@ -3562,7 +3562,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa, *tmp;
-	struct list_head del_list;
 	int _keep_addr;
 	bool keep_addr;
 	int state, i;
@@ -3654,7 +3653,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	 */
 	keep_addr = (!how && _keep_addr > 0 && !idev->cnf.disable_ipv6);
 
-	INIT_LIST_HEAD(&del_list);
 	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
 		struct rt6_info *rt = NULL;
 		bool keep;
@@ -3663,8 +3661,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 		keep = keep_addr && (ifa->flags & IFA_F_PERMANENT) &&
 			!addr_is_local(&ifa->addr);
-		if (!keep)
-			list_move(&ifa->if_list, &del_list);
 
 		write_unlock_bh(&idev->lock);
 		spin_lock_bh(&ifa->lock);
@@ -3698,19 +3694,14 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		}
 
 		write_lock_bh(&idev->lock);
+		if (!keep) {
+			list_del_rcu(&ifa->if_list);
+			in6_ifa_put(ifa);
+		}
 	}
 
 	write_unlock_bh(&idev->lock);
 
-	/* now clean up addresses to be removed */
-	while (!list_empty(&del_list)) {
-		ifa = list_first_entry(&del_list,
-				       struct inet6_ifaddr, if_list);
-		list_del(&ifa->if_list);
-
-		in6_ifa_put(ifa);
-	}
-
 	/* Step 5: Discard anycast and multicast list */
 	if (how) {
 		ipv6_ac_destroy_dev(idev);
-- 
2.14.2.920.gcf0c67979c-goog
