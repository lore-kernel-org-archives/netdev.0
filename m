From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/9] ipv6: convert temporary address list to list macros
Date: Wed, 17 Mar 2010 23:31:09 -0700
Message-ID: <20100318063122.866367333@vyatta.com>
References: <20100318063108.109693694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:33110 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564Ab0CRGgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 02:36:03 -0400
Content-Disposition: inline; filename=ipv6-tmp-addrlist.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use list macros instead of open coded linked list.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/if_inet6.h |    4 ++--
 net/ipv6/addrconf.c    |   30 ++++++++++++------------------
 2 files changed, 14 insertions(+), 20 deletions(-)

--- a/include/net/if_inet6.h	2010-03-15 16:03:26.618586975 -0700
+++ b/include/net/if_inet6.h	2010-03-15 16:10:15.159524680 -0700
@@ -58,7 +58,7 @@ struct inet6_ifaddr {
 	struct inet6_ifaddr	*if_next;       /* next addr in inet6_dev */
 
 #ifdef CONFIG_IPV6_PRIVACY
-	struct inet6_ifaddr	*tmp_next;	/* next addr in tempaddr_lst */
+	struct list_head	tmp_list;
 	struct inet6_ifaddr	*ifpub;
 	int			regen_count;
 #endif
@@ -175,7 +175,7 @@ struct inet6_dev {
 #ifdef CONFIG_IPV6_PRIVACY
 	u8			rndid[8];
 	struct timer_list	regen_timer;
-	struct inet6_ifaddr	*tempaddr_list;
+	struct list_head	tempaddr_list;
 #endif
 
 	struct neigh_parms	*nd_parms;
--- a/net/ipv6/addrconf.c	2010-03-15 16:03:46.418964602 -0700
+++ b/net/ipv6/addrconf.c	2010-03-15 16:10:15.169524547 -0700
@@ -401,6 +401,7 @@ static struct inet6_dev * ipv6_add_dev(s
 #endif
 
 #ifdef CONFIG_IPV6_PRIVACY
+	INIT_LIST_HEAD(&ndev->tempaddr_list);
 	setup_timer(&ndev->regen_timer, ipv6_regen_rndid, (unsigned long)ndev);
 	if ((dev->flags&IFF_LOOPBACK) ||
 	    dev->type == ARPHRD_TUNNEL ||
@@ -679,8 +680,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 
 #ifdef CONFIG_IPV6_PRIVACY
 	if (ifa->flags&IFA_F_TEMPORARY) {
-		ifa->tmp_next = idev->tempaddr_list;
-		idev->tempaddr_list = ifa;
+		list_add(&ifa->tmp_list, &idev->tempaddr_list);
 		in6_ifa_hold(ifa);
 	}
 #endif
@@ -732,19 +732,12 @@ static void ipv6_del_addr(struct inet6_i
 	write_lock_bh(&idev->lock);
 #ifdef CONFIG_IPV6_PRIVACY
 	if (ifp->flags&IFA_F_TEMPORARY) {
-		for (ifap = &idev->tempaddr_list; (ifa=*ifap) != NULL;
-		     ifap = &ifa->tmp_next) {
-			if (ifa == ifp) {
-				*ifap = ifa->tmp_next;
-				if (ifp->ifpub) {
-					in6_ifa_put(ifp->ifpub);
-					ifp->ifpub = NULL;
-				}
-				__in6_ifa_put(ifp);
-				ifa->tmp_next = NULL;
-				break;
-			}
+		list_del(&ifp->tmp_list);
+		if (ifp->ifpub) {
+			in6_ifa_put(ifp->ifpub);
+			ifp->ifpub = NULL;
 		}
+		__in6_ifa_put(ifp);
 	}
 #endif
 
@@ -1970,7 +1963,7 @@ ok:
 #ifdef CONFIG_IPV6_PRIVACY
 			read_lock_bh(&in6_dev->lock);
 			/* update all temporary addresses in the list */
-			for (ift=in6_dev->tempaddr_list; ift; ift=ift->tmp_next) {
+			list_for_each_entry(ift, &in6_dev->tempaddr_list, tmp_list) {
 				/*
 				 * When adjusting the lifetimes of an existing
 				 * temporary address, only lower the lifetimes.
@@ -2675,9 +2668,10 @@ static int addrconf_ifdown(struct net_de
 		in6_dev_put(idev);
 
 	/* clear tempaddr list */
-	while ((ifa = idev->tempaddr_list) != NULL) {
-		idev->tempaddr_list = ifa->tmp_next;
-		ifa->tmp_next = NULL;
+	while (!list_empty(&idev->tempaddr_list)) {
+		ifa = list_first_entry(&idev->tempaddr_list,
+				       struct inet6_ifaddr, tmp_list);
+		list_del(&ifa->tmp_list);
 		ifa->dead = 1;
 		write_unlock_bh(&idev->lock);
 		spin_lock_bh(&ifa->lock);

-- 

