From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH 2/2][IPV6] addrconf: fix addrconf_del_timer locking etc.
Date: Thu, 5 Jul 2007 13:37:42 +0200
Message-ID: <20070705113742.GC1569@ff.dom.local>
References: <20070705111246.GB1569@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S\. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:58625 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751639AbXGEL3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 07:29:14 -0400
Content-Disposition: inline
In-Reply-To: <20070705111246.GB1569@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

addrconf_del_timer() is sometimes done without a lock.
IMHO it could be racy e.g. when between del_timer() and
__in6_ifa_put() some other in6_ifa_put() is done.

addrconf_dad_kick() also runs unlocked in one place. 

BTW, I changed a bit one printk to be more precise, I hope.

PS: this patch was prepared on 2.6.22-rc7 with my neighbouring
PATCH 1/2, but they could be applied independently too.


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp 2.6.22-rc7-1_2/net/ipv6/addrconf.c 2.6.22-rc7-2_2/net/ipv6/addrconf.c
--- 2.6.22-rc7-1_2/net/ipv6/addrconf.c	2007-07-05 12:33:34.000000000 +0200
+++ 2.6.22-rc7-2_2/net/ipv6/addrconf.c	2007-07-05 12:39:51.000000000 +0200
@@ -477,7 +477,7 @@ void inet6_ifa_finish_destroy(struct ine
 	in6_dev_put(ifp->idev);
 
 	if (del_timer(&ifp->timer))
-		printk("Timer is still running, when freeing ifa=%p\n", ifp);
+		printk("Timer is still pending, when freeing ifa=%p\n", ifp);
 
 	if (!ifp->dead) {
 		printk("Freeing alive inet6 address %p\n", ifp);
@@ -698,7 +698,9 @@ static void ipv6_del_addr(struct inet6_i
 
 	atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifp);
 
+	spin_lock_bh(&ifp->lock);
 	addrconf_del_timer(ifp);
+	spin_unlock_bh(&ifp->lock);
 
 	/*
 	 * Purge or update corresponding prefix
@@ -2427,7 +2429,9 @@ static int addrconf_ifdown(struct net_de
 			if (ifa->idev == idev) {
 				*bifa = ifa->lst_next;
 				ifa->lst_next = NULL;
+				spin_lock_bh(&ifa->lock);
 				addrconf_del_timer(ifa);
+				spin_unlock_bh(&ifa->lock);
 				in6_ifa_put(ifa);
 				continue;
 			}
@@ -2468,9 +2472,11 @@ static int addrconf_ifdown(struct net_de
 		idev->addr_list = ifa->if_next;
 		ifa->if_next = NULL;
 		ifa->dead = 1;
-		addrconf_del_timer(ifa);
 		write_unlock_bh(&idev->lock);
 
+		spin_lock_bh(&ifa->lock);
+		addrconf_del_timer(ifa);
+		spin_unlock_bh(&ifa->lock);
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
 		in6_ifa_put(ifa);
 
@@ -2701,8 +2707,8 @@ static void addrconf_dad_run(struct inet
 			spin_unlock_bh(&ifp->lock);
 			continue;
 		}
-		spin_unlock_bh(&ifp->lock);
 		addrconf_dad_kick(ifp);
+		spin_unlock_bh(&ifp->lock);
 	}
 	read_unlock_bh(&idev->lock);
 }
