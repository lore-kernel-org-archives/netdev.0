From: Thomas Haller <thaller@redhat.com>
Subject: [PATCH v2 2/2] ipv6 addrconf: don't cleanup route prefix for IFA_F_NOPREFIXROUTE
Date: Tue,  7 Jan 2014 15:39:13 +0100
Message-ID: <1389105553-21230-3-git-send-email-thaller@redhat.com>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com>
 <1389105553-21230-1-git-send-email-thaller@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com,
	Thomas Haller <thaller@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515AbaAGOjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 09:39:42 -0500
In-Reply-To: <1389105553-21230-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor the deletion/update of route prefixes when removing an
address. Now, consider IFA_F_NOPREFIXROUTE and if there is an address
present with this flag, to not cleanup the prefix. Instead, assume
that userspace is taking care of this prefix.

Also, when adding the NOPREFIXROUTE flag to an already existing address,
check if there there is a prefix that was likly added by the kernel
and delete it.

Signed-off-by: Thomas Haller <thaller@redhat.com>
---
 net/ipv6/addrconf.c | 188 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 112 insertions(+), 76 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1bc575f..1293a27 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -900,15 +900,106 @@ out:
 	goto out2;
 }
 
+/*
+ * Check, whether the prefix route without ifp is still valid.
+ * The function returns:
+ *   -1 route valid, update lifetimes (returns expires time).
+ *    0 route invalid, delete
+ *    1 route valid, don't update lifetimes.
+ *
+ * 1) we don't purge prefix here if address was not permanent.
+ *    prefix is managed by its own lifetime.
+ * 2) we also don't purge, if the address was IFA_F_NOPREFIXROUTE.
+ * 3) if there're no addresses, delete prefix.
+ * 4) if there're still other permanent address(es),
+ *    corresponding prefix is still permanent.
+ * 5) if there are still other addresses with IFA_F_NOPREFIXROUTE,
+ *    don't purge the prefix, assume user space is
+ *    managing it.
+ * 6) otherwise, update prefix lifetime to the
+ *    longest valid lifetime among the corresponding
+ *    addresses on the device.
+ *    Note: subsequent RA will update lifetime.
+ *
+ * --yoshfuji
+ **/
+static int
+check_cleanup_prefix_routes(struct inet6_ifaddr *ifp, u32 ifa_flags, unsigned long *expires)
+{
+	struct inet6_ifaddr *ifa;
+	struct inet6_dev *idev = ifp->idev;
+	unsigned long lifetime;
+	int onlink = 0;
+
+	*expires = jiffies;
+
+
+	if (!(ifa_flags & IFA_F_PERMANENT))
+		return 1;
+	if (ifa_flags & IFA_F_NOPREFIXROUTE)
+		return 1;
+
+	list_for_each_entry(ifa, &idev->addr_list, if_list) {
+		if (ifa == ifp)
+			continue;
+		if (!ipv6_prefix_equal(&ifa->addr, &ifp->addr,
+				       ifp->prefix_len))
+			continue;
+		if (ifa->flags & IFA_F_PERMANENT)
+			return 1;
+		if (ifa->flags & IFA_F_NOPREFIXROUTE)
+			return 1; /* user space is managing this prefix. */
+
+		onlink = -1;
+
+		spin_lock(&ifa->lock);
+
+		lifetime = addrconf_timeout_fixup(ifa->valid_lft, HZ);
+		/*
+		 * Note: Because this address is
+		 * not permanent, lifetime <
+		 * LONG_MAX / HZ here.
+		 */
+		if (time_before(*expires, ifa->tstamp + lifetime * HZ))
+			*expires = ifa->tstamp + lifetime * HZ;
+		spin_unlock(&ifa->lock);
+	}
+
+	return onlink;
+}
+
+static void
+cleanup_prefix_route(struct inet6_ifaddr *ifp, unsigned long expires, int onlink)
+{
+	struct rt6_info *rt;
+
+	if (onlink >= 1)
+		return;
+
+	rt = addrconf_get_prefix_route(&ifp->addr,
+				       ifp->prefix_len,
+				       ifp->idev->dev,
+				       0, RTF_GATEWAY | RTF_DEFAULT);
+
+	if (rt) {
+		if (onlink == 0) {
+			ip6_del_rt(rt);
+			rt = NULL;
+		} else if (!(rt->rt6i_flags & RTF_EXPIRES)) {
+			rt6_set_expires(rt, expires);
+		}
+	}
+	ip6_rt_put(rt);
+}
+
+
 /* This function wants to get referenced ifp and releases it before return */
 
 static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 {
-	struct inet6_ifaddr *ifa, *ifn;
-	struct inet6_dev *idev = ifp->idev;
 	int state;
-	int deleted = 0, onlink = 0;
-	unsigned long expires = jiffies;
+	int onlink;
+	unsigned long expires;
 
 	spin_lock_bh(&ifp->state_lock);
 	state = ifp->state;
@@ -922,7 +1013,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	hlist_del_init_rcu(&ifp->addr_lst);
 	spin_unlock_bh(&addrconf_hash_lock);
 
-	write_lock_bh(&idev->lock);
+	write_lock_bh(&ifp->idev->lock);
 
 	if (ifp->flags&IFA_F_TEMPORARY) {
 		list_del(&ifp->tmp_list);
@@ -933,45 +1024,11 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		__in6_ifa_put(ifp);
 	}
 
-	list_for_each_entry_safe(ifa, ifn, &idev->addr_list, if_list) {
-		if (ifa == ifp) {
-			list_del_init(&ifp->if_list);
-			__in6_ifa_put(ifp);
+	onlink = check_cleanup_prefix_routes(ifp, ifp->flags, &expires);
+	list_del_init(&ifp->if_list);
+	__in6_ifa_put(ifp);
 
-			if (!(ifp->flags & IFA_F_PERMANENT) || onlink > 0)
-				break;
-			deleted = 1;
-			continue;
-		} else if (ifp->flags & IFA_F_PERMANENT) {
-			if (ipv6_prefix_equal(&ifa->addr, &ifp->addr,
-					      ifp->prefix_len)) {
-				if (ifa->flags & IFA_F_PERMANENT) {
-					onlink = 1;
-					if (deleted)
-						break;
-				} else {
-					unsigned long lifetime;
-
-					if (!onlink)
-						onlink = -1;
-
-					spin_lock(&ifa->lock);
-
-					lifetime = addrconf_timeout_fixup(ifa->valid_lft, HZ);
-					/*
-					 * Note: Because this address is
-					 * not permanent, lifetime <
-					 * LONG_MAX / HZ here.
-					 */
-					if (time_before(expires,
-							ifa->tstamp + lifetime * HZ))
-						expires = ifa->tstamp + lifetime * HZ;
-					spin_unlock(&ifa->lock);
-				}
-			}
-		}
-	}
-	write_unlock_bh(&idev->lock);
+	write_unlock_bh(&ifp->idev->lock);
 
 	addrconf_del_dad_timer(ifp);
 
@@ -979,39 +1036,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 
 	inet6addr_notifier_call_chain(NETDEV_DOWN, ifp);
 
-	/*
-	 * Purge or update corresponding prefix
-	 *
-	 * 1) we don't purge prefix here if address was not permanent.
-	 *    prefix is managed by its own lifetime.
-	 * 2) if there're no addresses, delete prefix.
-	 * 3) if there're still other permanent address(es),
-	 *    corresponding prefix is still permanent.
-	 * 4) otherwise, update prefix lifetime to the
-	 *    longest valid lifetime among the corresponding
-	 *    addresses on the device.
-	 *    Note: subsequent RA will update lifetime.
-	 *
-	 * --yoshfuji
-	 */
-	if ((ifp->flags & IFA_F_PERMANENT) && onlink < 1) {
-		struct rt6_info *rt;
-
-		rt = addrconf_get_prefix_route(&ifp->addr,
-					       ifp->prefix_len,
-					       ifp->idev->dev,
-					       0, RTF_GATEWAY | RTF_DEFAULT);
-
-		if (rt) {
-			if (onlink == 0) {
-				ip6_del_rt(rt);
-				rt = NULL;
-			} else if (!(rt->rt6i_flags & RTF_EXPIRES)) {
-				rt6_set_expires(rt, expires);
-			}
-		}
-		ip6_rt_put(rt);
-	}
+	cleanup_prefix_route(ifp, expires, onlink);
 
 	/* clean up prefsrc entries */
 	rt6_remove_prefsrc(ifp);
@@ -3632,6 +3657,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	clock_t expires;
 	unsigned long timeout;
 	bool was_managetempaddr;
+	bool was_noprefixroute;
 
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
@@ -3660,6 +3686,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 
 	spin_lock_bh(&ifp->lock);
 	was_managetempaddr = ifp->flags & IFA_F_MANAGETEMPADDR;
+	was_noprefixroute = ifp->flags & IFA_F_NOPREFIXROUTE;
 	ifp->flags &= ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD |
 			IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR | IFA_F_NOPREFIXROUTE);
 	ifp->flags |= ifa_flags;
@@ -3674,6 +3701,15 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
 				      expires, flags);
+	} else if (was_noprefixroute) {
+		int onlink;
+		unsigned long expires;
+
+		write_lock_bh(&ifp->idev->lock);
+		onlink = check_cleanup_prefix_routes(ifp, ifp->flags & ~IFA_F_NOPREFIXROUTE, &expires);
+		write_unlock_bh(&ifp->idev->lock);
+
+		cleanup_prefix_route(ifp, expires, onlink);
 	}
 
 	if (was_managetempaddr || ifp->flags & IFA_F_MANAGETEMPADDR) {
-- 
1.8.4.2
