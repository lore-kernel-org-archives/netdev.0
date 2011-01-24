From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Revert 'administrative down' address handling
 changes.
Date: Sun, 23 Jan 2011 23:41:01 -0800 (PST)
Message-ID: <20110123.234101.71098533.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, ebiederm@xmission.com, brian.haley@hp.com,
	lorenzo@google.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761Ab1AXHk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 02:40:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This reverts the following set of commits:

d1ed113f1669390da9898da3beddcc058d938587 ("ipv6: remove duplicate neigh_ifdown")
29ba5fed1bbd09c2cba890798c8f9eaab251401d ("ipv6: don't flush routes when setting loopback down")
9d82ca98f71fd686ef2f3017c5e3e6a4871b6e46 ("ipv6: fix missing in6_ifa_put in addrconf")
2de795707294972f6c34bae9de713e502c431296 ("ipv6: addrconf: don't remove address state on ifdown if the address is being kept")
8595805aafc8b077e01804c9a3668e9aa3510e89 ("IPv6: only notify protocols if address is compeletely gone")
27bdb2abcc5edb3526e25407b74bf17d1872c329 ("IPv6: keep tentative addresses in hash table")
93fa159abe50d3c55c7f83622d3f5c09b6e06f4b ("IPv6: keep route for tentative address")
8f37ada5b5f6bfb4d251a7f510f249cb855b77b3 ("IPv6: fix race between cleanup and add/delete address")
84e8b803f1e16f3a2b8b80f80a63fa2f2f8a9be6 ("IPv6: addrconf notify when address is unavailable")
dc2b99f71ef477a31020511876ab4403fb7c4420 ("IPv6: keep permanent addresses on admin down")

because the core semantic change to ipv6 address handling on ifdown
has broken some things, in particular "disable_ipv6" sysctl handling.

Stephen has made several attempts to get things back in working order,
but nothing has restored disable_ipv6 fully yet.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Ok, this is what I came up with.  I tried to avoid stupid things like
reverting cleanups and the list_head/hlist/RCU conversions of the
various ipv6 address lists and hash tables.

Herbert, would you please make sure I didn't accidently undo your DAD
handling fixes.

Eric B. and co., please do some testing to make sure all of your
disable_ipv6 cases are functioning properly with this applied.

Thanks!

 net/ipv6/addrconf.c |   81 +++++++++++++++++++++------------------------------
 1 files changed, 33 insertions(+), 48 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 24a1cf1..fd6782e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2661,14 +2661,12 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa;
-	LIST_HEAD(keep_list);
-	int state;
+	int state, i;
 
 	ASSERT_RTNL();
 
-	/* Flush routes if device is being removed or it is not loopback */
-	if (how || !(dev->flags & IFF_LOOPBACK))
-		rt6_ifdown(net, dev);
+	rt6_ifdown(net, dev);
+	neigh_ifdown(&nd_tbl, dev);
 
 	idev = __in6_dev_get(dev);
 	if (idev == NULL)
@@ -2689,6 +2687,23 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 	}
 
+	/* Step 2: clear hash table */
+	for (i = 0; i < IN6_ADDR_HSIZE; i++) {
+		struct hlist_head *h = &inet6_addr_lst[i];
+		struct hlist_node *n;
+
+		spin_lock_bh(&addrconf_hash_lock);
+	restart:
+		hlist_for_each_entry_rcu(ifa, n, h, addr_lst) {
+			if (ifa->idev == idev) {
+				hlist_del_init_rcu(&ifa->addr_lst);
+				addrconf_del_timer(ifa);
+				goto restart;
+			}
+		}
+		spin_unlock_bh(&addrconf_hash_lock);
+	}
+
 	write_lock_bh(&idev->lock);
 
 	/* Step 2: clear flags for stateless addrconf */
@@ -2722,52 +2737,23 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 				       struct inet6_ifaddr, if_list);
 		addrconf_del_timer(ifa);
 
-		/* If just doing link down, and address is permanent
-		   and not link-local, then retain it. */
-		if (!how &&
-		    (ifa->flags&IFA_F_PERMANENT) &&
-		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
-			list_move_tail(&ifa->if_list, &keep_list);
-
-			/* If not doing DAD on this address, just keep it. */
-			if ((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
-			    idev->cnf.accept_dad <= 0 ||
-			    (ifa->flags & IFA_F_NODAD))
-				continue;
+		list_del(&ifa->if_list);
 
-			/* If it was tentative already, no need to notify */
-			if (ifa->flags & IFA_F_TENTATIVE)
-				continue;
+		write_unlock_bh(&idev->lock);
 
-			/* Flag it for later restoration when link comes up */
-			ifa->flags |= IFA_F_TENTATIVE;
-			ifa->state = INET6_IFADDR_STATE_DAD;
-		} else {
-			list_del(&ifa->if_list);
-
-			/* clear hash table */
-			spin_lock_bh(&addrconf_hash_lock);
-			hlist_del_init_rcu(&ifa->addr_lst);
-			spin_unlock_bh(&addrconf_hash_lock);
-
-			write_unlock_bh(&idev->lock);
-			spin_lock_bh(&ifa->state_lock);
-			state = ifa->state;
-			ifa->state = INET6_IFADDR_STATE_DEAD;
-			spin_unlock_bh(&ifa->state_lock);
-
-			if (state != INET6_IFADDR_STATE_DEAD) {
-				__ipv6_ifa_notify(RTM_DELADDR, ifa);
-				atomic_notifier_call_chain(&inet6addr_chain,
-							   NETDEV_DOWN, ifa);
-			}
+		spin_lock_bh(&ifa->state_lock);
+		state = ifa->state;
+		ifa->state = INET6_IFADDR_STATE_DEAD;
+		spin_unlock_bh(&ifa->state_lock);
 
-			in6_ifa_put(ifa);
-			write_lock_bh(&idev->lock);
+		if (state != INET6_IFADDR_STATE_DEAD) {
+			__ipv6_ifa_notify(RTM_DELADDR, ifa);
+			atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
 		}
-	}
+		in6_ifa_put(ifa);
 
-	list_splice(&keep_list, &idev->addr_list);
+		write_lock_bh(&idev->lock);
+	}
 
 	write_unlock_bh(&idev->lock);
 
@@ -4156,8 +4142,7 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
 		dst_hold(&ifp->rt->dst);
 
-		if (ifp->state == INET6_IFADDR_STATE_DEAD &&
-		    ip6_del_rt(ifp->rt))
+		if (ip6_del_rt(ifp->rt))
 			dst_free(&ifp->rt->dst);
 		break;
 	}
-- 
1.7.3.4

