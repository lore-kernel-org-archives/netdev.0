From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 1/5] ipv6: addrconf: cleanup locking in ipv6_add_addr
Date: Fri, 13 Oct 2017 16:02:09 -0700
Message-ID: <1507935733-18950-2-git-send-email-dsahern@gmail.com>
References: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, kjlx@templeofstupid.com,
        davem@davemloft.net, yoshfuji@linux-ipv6.org,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:51731 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752250AbdJMXCY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 19:02:24 -0400
Received: by mail-pg0-f68.google.com with SMTP id k70so1264183pgc.8
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 16:02:24 -0700 (PDT)
In-Reply-To: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_add_addr is called in process context with rtnl lock held
(e.g., manual config of an address) or during softirq processing
(e.g., autoconf and address from a router advertisement).

Currently, ipv6_add_addr calls rcu_read_lock_bh shortly after entry
and does not call unlock until exit, minus the call around the address
validator notifier. Similarly, addrconf_hash_lock is taken after the
validator notifier and held until exit. This forces the allocation of
inet6_ifaddr to always be atomic.

Refactor ipv6_add_addr as follows:
1. add an input boolean to discriminate the call path (process context
   or softirq). This new flag controls whether the alloc can be done
   with GFP_KERNEL or GFP_ATOMIC.

2. Move the rcu_read_lock_bh and unlock calls only around functions that
   do rcu updates.

3. Remove the in6_dev_hold and put added by 3ad7d2468f79f ("Ipvlan should
   return an error when an address is already in use."). This was done
   presumably because rcu_read_unlock_bh needs to be called before calling
   the validator. Since rcu_read_lock is not needed before the validator
   runs revert the hold and put added by 3ad7d2468f79f and only do the
   hold when setting ifp->idev.

4. move duplicate address check and insertion of new address in the global
   address hash into a helper. The helper is called after an ifa is
   allocated and filled in.

This allows the ifa for manually configured addresses to be done with
GFP_KERNEL and reduces the overall amount of time with rcu_read_lock held
and hash table spinlock held.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv6/addrconf.c | 97 +++++++++++++++++++++++++++++------------------------
 1 file changed, 54 insertions(+), 43 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4603aa488f4f..80f5fc74f0c4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -957,18 +957,43 @@ static u32 inet6_addr_hash(const struct in6_addr *addr)
 	return hash_32(ipv6_addr_hash(addr), IN6_ADDR_HSIZE_SHIFT);
 }
 
+static int ipv6_add_addr_hash(struct net_device *dev, struct inet6_ifaddr *ifa)
+{
+	unsigned int hash;
+	int err = 0;
+
+	spin_lock(&addrconf_hash_lock);
+
+	/* Ignore adding duplicate addresses on an interface */
+	if (ipv6_chk_same_addr(dev_net(dev), &ifa->addr, dev)) {
+		ADBG("ipv6_add_addr: already assigned\n");
+		err = -EEXIST;
+		goto out;
+	}
+
+	/* Add to big hash table */
+	hash = inet6_addr_hash(&ifa->addr);
+	hlist_add_head_rcu(&ifa->addr_lst, &inet6_addr_lst[hash]);
+
+out:
+	spin_unlock(&addrconf_hash_lock);
+
+	return err;
+}
+
 /* On success it returns ifp with increased reference count */
 
 static struct inet6_ifaddr *
 ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	      const struct in6_addr *peer_addr, int pfxlen,
-	      int scope, u32 flags, u32 valid_lft, u32 prefered_lft)
+	      int scope, u32 flags, u32 valid_lft, u32 prefered_lft,
+	      bool can_block)
 {
+	gfp_t gfp_flags = can_block ? GFP_KERNEL : GFP_ATOMIC;
 	struct net *net = dev_net(idev->dev);
 	struct inet6_ifaddr *ifa = NULL;
-	struct rt6_info *rt;
+	struct rt6_info *rt = NULL;
 	struct in6_validator_info i6vi;
-	unsigned int hash;
 	int err = 0;
 	int addr_type = ipv6_addr_type(addr);
 
@@ -978,42 +1003,24 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	     addr_type & IPV6_ADDR_LOOPBACK))
 		return ERR_PTR(-EADDRNOTAVAIL);
 
-	rcu_read_lock_bh();
-
-	in6_dev_hold(idev);
-
 	if (idev->dead) {
 		err = -ENODEV;			/*XXX*/
-		goto out2;
+		goto out;
 	}
 
 	if (idev->cnf.disable_ipv6) {
 		err = -EACCES;
-		goto out2;
+		goto out;
 	}
 
 	i6vi.i6vi_addr = *addr;
 	i6vi.i6vi_dev = idev;
-	rcu_read_unlock_bh();
-
 	err = inet6addr_validator_notifier_call_chain(NETDEV_UP, &i6vi);
-
-	rcu_read_lock_bh();
 	err = notifier_to_errno(err);
-	if (err)
-		goto out2;
-
-	spin_lock(&addrconf_hash_lock);
-
-	/* Ignore adding duplicate addresses on an interface */
-	if (ipv6_chk_same_addr(dev_net(idev->dev), addr, idev->dev)) {
-		ADBG("ipv6_add_addr: already assigned\n");
-		err = -EEXIST;
+	if (err < 0)
 		goto out;
-	}
-
-	ifa = kzalloc(sizeof(struct inet6_ifaddr), GFP_ATOMIC);
 
+	ifa = kzalloc(sizeof(*ifa), gfp_flags);
 	if (!ifa) {
 		ADBG("ipv6_add_addr: malloc failed\n");
 		err = -ENOBUFS;
@@ -1053,16 +1060,21 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa->rt = rt;
 
 	ifa->idev = idev;
+	in6_dev_hold(idev);
+
 	/* For caller */
 	refcount_set(&ifa->refcnt, 1);
 
-	/* Add to big hash table */
-	hash = inet6_addr_hash(addr);
+	rcu_read_lock_bh();
 
-	hlist_add_head_rcu(&ifa->addr_lst, &inet6_addr_lst[hash]);
-	spin_unlock(&addrconf_hash_lock);
+	err = ipv6_add_addr_hash(idev->dev, ifa);
+	if (err < 0) {
+		rcu_read_unlock_bh();
+		goto out;
+	}
 
 	write_lock(&idev->lock);
+
 	/* Add to inet6_dev unicast addr list. */
 	ipv6_link_dev_addr(idev, ifa);
 
@@ -1073,21 +1085,19 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 
 	in6_ifa_hold(ifa);
 	write_unlock(&idev->lock);
-out2:
+
 	rcu_read_unlock_bh();
 
-	if (likely(err == 0))
-		inet6addr_notifier_call_chain(NETDEV_UP, ifa);
-	else {
+	inet6addr_notifier_call_chain(NETDEV_UP, ifa);
+out:
+	if (unlikely(err < 0)) {
+		if (rt)
+			ip6_rt_put(rt);
 		kfree(ifa);
-		in6_dev_put(idev);
 		ifa = ERR_PTR(err);
 	}
 
 	return ifa;
-out:
-	spin_unlock(&addrconf_hash_lock);
-	goto out2;
 }
 
 enum cleanup_prefix_rt_t {
@@ -1334,7 +1344,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 
 	ift = ipv6_add_addr(idev, &addr, NULL, tmp_plen,
 			    ipv6_addr_scope(&addr), addr_flags,
-			    tmp_valid_lft, tmp_prefered_lft);
+			    tmp_valid_lft, tmp_prefered_lft, true);
 	if (IS_ERR(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
@@ -2018,7 +2028,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 
 		ifp2 = ipv6_add_addr(idev, &new_addr, NULL, pfxlen,
 				     scope, flags, valid_lft,
-				     preferred_lft);
+				     preferred_lft, false);
 		if (IS_ERR(ifp2))
 			goto lock_errdad;
 
@@ -2476,7 +2486,7 @@ int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
 					    pinfo->prefix_len,
 					    addr_type&IPV6_ADDR_SCOPE_MASK,
 					    addr_flags, valid_lft,
-					    prefered_lft);
+					    prefered_lft, false);
 
 		if (IS_ERR_OR_NULL(ifp))
 			return -1;
@@ -2845,7 +2855,7 @@ static int inet6_addr_add(struct net *net, int ifindex,
 	}
 
 	ifp = ipv6_add_addr(idev, pfx, peer_pfx, plen, scope, ifa_flags,
-			    valid_lft, prefered_lft);
+			    valid_lft, prefered_lft, true);
 
 	if (!IS_ERR(ifp)) {
 		if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
@@ -2960,7 +2970,8 @@ static void add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 
 	ifp = ipv6_add_addr(idev, addr, NULL, plen,
 			    scope, IFA_F_PERMANENT,
-			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
+			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME,
+			    true);
 	if (!IS_ERR(ifp)) {
 		spin_lock_bh(&ifp->lock);
 		ifp->flags &= ~IFA_F_TENTATIVE;
@@ -3060,7 +3071,7 @@ void addrconf_add_linklocal(struct inet6_dev *idev,
 #endif
 
 	ifp = ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags,
-			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
+			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME, true);
 	if (!IS_ERR(ifp)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
 		addrconf_dad_start(ifp);
-- 
2.1.4
