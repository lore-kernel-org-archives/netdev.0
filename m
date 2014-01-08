From: Thomas Haller <thaller@redhat.com>
Subject: [PATCH v3 2/2] ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE
Date: Wed,  8 Jan 2014 01:41:28 +0100
Message-ID: <1389141688-25618-3-git-send-email-thaller@redhat.com>
References: <1389141688-25618-1-git-send-email-thaller@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com,
	Thomas Haller <thaller@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754211AbaAHAl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 19:41:59 -0500
In-Reply-To: <1389141688-25618-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor the deletion/update of prefix routes when removing an
address. Now also consider IFA_F_NOPREFIXROUTE and if there is an address
present with this flag, to not cleanup the route. Instead, assume
that userspace is taking care of this route.

Also perform the same cleanup, when userspace changes an existing address
to add NOPREFIXROUTE (to an address that didn't have this flag). This is
done because when the address was added, a prefix route was created for it.
Since the user now wants to handle this route by himself, we cleanup this
route.

This cleanup of the route is not totally robust. There is no guarantee,
that the route we are about to delete was really the one added by the
kernel. This behavior does not change by the patch, and in practice it
should work just fine.

Signed-off-by: Thomas Haller <thaller@redhat.com>
---
 net/ipv6/addrconf.c | 186 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 110 insertions(+), 76 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1bc575f..b3fcf9f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -900,15 +900,104 @@ out:
 	goto out2;
 }
 
+/*
+ * Check, whether the prefix for ifp would still need a prefix route
+ * after deleting ifp. The function returns:
+ *    -1 route valid, only update lifetimes (outputs expires).
+ *     0 route invalid, delete/purge
+ *     1 route valid, don't update lifetimes.
+ *
+ * 1) we don't purge prefix if address was not permanent.
+ *    prefix is managed by its own lifetime.
+ * 2) we also don't purge, if the address was IFA_F_NOPREFIXROUTE.
+ * 3) if there're no addresses, delete prefix.
+ * 4) if there're still other permanent address(es),
+ *    corresponding prefix is still permanent.
+ * 5) if there are still other addresses with IFA_F_NOPREFIXROUTE,
+ *    don't purge the prefix, assume user space is managing it.
+ * 6) otherwise, update prefix lifetime to the
+ *    longest valid lifetime among the corresponding
+ *    addresses on the device.
+ *    Note: subsequent RA will update lifetime.
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
+			return 1;
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
+	if (!rt)
+		return;
+
+	if (onlink == 0) {
+		ip6_del_rt(rt);
+		return;
+	}
+
+	if (!(rt->rt6i_flags & RTF_EXPIRES))
+		rt6_set_expires(rt, expires);
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
@@ -922,7 +1011,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	hlist_del_init_rcu(&ifp->addr_lst);
 	spin_unlock_bh(&addrconf_hash_lock);
 
-	write_lock_bh(&idev->lock);
+	write_lock_bh(&ifp->idev->lock);
 
 	if (ifp->flags&IFA_F_TEMPORARY) {
 		list_del(&ifp->tmp_list);
@@ -933,45 +1022,11 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
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
 
@@ -979,39 +1034,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 
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
@@ -3632,6 +3655,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	clock_t expires;
 	unsigned long timeout;
 	bool was_managetempaddr;
+	bool was_noprefixroute;
 
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
@@ -3660,6 +3684,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 
 	spin_lock_bh(&ifp->lock);
 	was_managetempaddr = ifp->flags & IFA_F_MANAGETEMPADDR;
+	was_noprefixroute = ifp->flags & IFA_F_NOPREFIXROUTE;
 	ifp->flags &= ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD |
 			IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR | IFA_F_NOPREFIXROUTE);
 	ifp->flags |= ifa_flags;
@@ -3674,6 +3699,15 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
 				      expires, flags);
+	} else if (was_noprefixroute) {
+		int onlink;
+		unsigned long rt_expires;
+
+		write_lock_bh(&ifp->idev->lock);
+		onlink = check_cleanup_prefix_routes(ifp, ifp->flags & ~IFA_F_NOPREFIXROUTE, &rt_expires);
+		write_unlock_bh(&ifp->idev->lock);
+
+		cleanup_prefix_route(ifp, rt_expires, onlink);
 	}
 
 	if (was_managetempaddr || ifp->flags & IFA_F_MANAGETEMPADDR) {
-- 
1.8.4.2
