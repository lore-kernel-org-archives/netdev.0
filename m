From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] ipv6: Replace inet6_ifaddr->dead with state
Date: Tue, 18 May 2010 21:04:19 +1000
Message-ID: <E1OEKax-00022W-6K@gondolin.me.apana.org.au>
References: <20100518110243.GA7750@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42312 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756378Ab0ERLE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 07:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6: Replace inet6_ifaddr->dead with state

This patch replaces the boolean dead flag on inet6_ifaddr with
a state enum.  This allows us to roll back changes when deleting
an address according to whether DAD has completed or not.

This patch only adds the state field and does not change the logic.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/if_inet6.h |   12 ++++++++++--
 net/ipv6/addrconf.c    |   11 ++++++-----
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 545d8b0..421a1e8 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -30,6 +30,13 @@
 #define IF_PREFIX_ONLINK	0x01
 #define IF_PREFIX_AUTOCONF	0x02
 
+enum {
+	INET6_IFADDR_STATE_DAD,
+	INET6_IFADDR_STATE_POSTDAD,
+	INET6_IFADDR_STATE_UP,
+	INET6_IFADDR_STATE_DEAD,
+};
+
 #ifdef __KERNEL__
 
 struct inet6_ifaddr {
@@ -40,6 +47,9 @@ struct inet6_ifaddr {
 	__u32			prefered_lft;
 	atomic_t		refcnt;
 	spinlock_t		lock;
+	spinlock_t		state_lock;
+
+	int			state;
 
 	__u8			probes;
 	__u8			flags;
@@ -62,8 +72,6 @@ struct inet6_ifaddr {
 	struct inet6_ifaddr	*ifpub;
 	int			regen_count;
 #endif
-
-	int			dead;
 };
 
 struct ip6_sf_socklist {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 413054f..14b2ccf 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -539,7 +539,7 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 	if (del_timer(&ifp->timer))
 		printk("Timer is still running, when freeing ifa=%p\n", ifp);
 
-	if (!ifp->dead) {
+	if (ifp->state != INET6_IFADDR_STATE_DEAD) {
 		printk("Freeing alive inet6 address %p\n", ifp);
 		return;
 	}
@@ -642,6 +642,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	ipv6_addr_copy(&ifa->addr, addr);
 
 	spin_lock_init(&ifa->lock);
+	spin_lock_init(&ifa->state_lock);
 	init_timer(&ifa->timer);
 	ifa->timer.data = (unsigned long) ifa;
 	ifa->scope = scope;
@@ -716,7 +717,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 
 	hash = ipv6_addr_hash(&ifp->addr);
 
-	ifp->dead = 1;
+	ifp->state = INET6_IFADDR_STATE_DEAD;
 
 	write_lock_bh(&addrconf_hash_lock);
 	for (ifap = &inet6_addr_lst[hash]; (ifa=*ifap) != NULL;
@@ -2679,7 +2680,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	while ((ifa = idev->tempaddr_list) != NULL) {
 		idev->tempaddr_list = ifa->tmp_next;
 		ifa->tmp_next = NULL;
-		ifa->dead = 1;
+		ifa->state = INET6_IFADDR_STATE_DEAD;
 		write_unlock_bh(&idev->lock);
 		spin_lock_bh(&ifa->lock);
 
@@ -2724,7 +2725,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 			ifa->flags |= IFA_F_TENTATIVE;
 			in6_ifa_hold(ifa);
 		} else {
-			ifa->dead = 1;
+			ifa->state = INET6_IFADDR_STATE_DEAD;
 		}
 		write_unlock_bh(&idev->lock);
 
@@ -2827,7 +2828,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	net_srandom(ifp->addr.s6_addr32[3]);
 
 	read_lock_bh(&idev->lock);
-	if (ifp->dead)
+	if (ifp->state == INET6_IFADDR_STATE_DEAD)
 		goto out;
 
 	spin_lock(&ifp->lock);
