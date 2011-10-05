From: lorenzo@google.com (Lorenzo Colitti)
Subject: [PATCH] net: ipv6: Allow netlink to set IPv6 address scope
Date: Wed,  5 Oct 2011 13:15:59 -0700 (PDT)
Message-ID: <20111005201559.E544016A599@drone1.mtv.corp.google.com>
Cc: c@google.com
To: maze@google.com, lorenzo@google.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:62855 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934686Ab1JEUQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 16:16:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: ipv6: Allow netlink to set IPv6 address scope

Currently, userspace cannot specify the scope of IPv6
addresses when creating or modifying them. Instead, the
scope is automatically determined from the address itself.
In IPv4, userspace can set whatever scope it likes.

Allow userspace to specify the scope of IPv6 addresses in
a backwards-compatible way: if the scope passed in is zero,
use the old behaviour of automatically determining the
scope based on the address.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 12368c5..b05892d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2109,17 +2109,44 @@ err_exit:
 	return err;
 }
 
+static inline int rt_scope(int ifa_scope)
+{
+	if (ifa_scope & IFA_HOST)
+		return RT_SCOPE_HOST;
+	else if (ifa_scope & IFA_LINK)
+		return RT_SCOPE_LINK;
+	else if (ifa_scope & IFA_SITE)
+		return RT_SCOPE_SITE;
+	else
+		return RT_SCOPE_UNIVERSE;
+}
+
+static inline int ifa_scope(u8 rt_scope)
+{
+	switch (rt_scope) {
+	case RT_SCOPE_UNIVERSE:
+		return IPV6_ADDR_ANY;
+	case RT_SCOPE_SITE:
+		return IPV6_ADDR_SITELOCAL;
+	case RT_SCOPE_LINK:
+		return IPV6_ADDR_LINKLOCAL;
+	case RT_SCOPE_HOST:
+		return IPV6_ADDR_LOOPBACK;
+	default:
+		return __IPV6_ADDR_SCOPE_INVALID;
+	}
+}
+
 /*
  *	Manual configuration of address on an interface
  */
 static int inet6_addr_add(struct net *net, int ifindex, const struct in6_addr *pfx,
-			  unsigned int plen, __u8 ifa_flags, __u32 prefered_lft,
-			  __u32 valid_lft)
+			  unsigned int plen, __u8 ifa_flags, __u8 scope,
+			  __u32 prefered_lft, __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
 	struct net_device *dev;
-	int scope;
 	u32 flags;
 	clock_t expires;
 	unsigned long timeout;
@@ -2141,8 +2168,6 @@ static int inet6_addr_add(struct net *net, int ifindex, const struct in6_addr *p
 	if (IS_ERR(idev))
 		return PTR_ERR(idev);
 
-	scope = ipv6_addr_scope(pfx);
-
 	timeout = addrconf_timeout_fixup(valid_lft, HZ);
 	if (addrconf_finite_timeout(timeout)) {
 		expires = jiffies_to_clock_t(timeout * HZ);
@@ -2239,7 +2264,8 @@ int addrconf_add_ifaddr(struct net *net, void __user *arg)
 	rtnl_lock();
 	err = inet6_addr_add(net, ireq.ifr6_ifindex, &ireq.ifr6_addr,
 			     ireq.ifr6_prefixlen, IFA_F_PERMANENT,
-			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
+			     IPV6_ADDR_ANY, INFINITY_LIFE_TIME,
+			     INFINITY_LIFE_TIME);
 	rtnl_unlock();
 	return err;
 }
@@ -3333,7 +3359,7 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	return inet6_addr_del(net, ifm->ifa_index, pfx, ifm->ifa_prefixlen);
 }
 
-static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
+static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags, u8 scope,
 			     u32 prefered_lft, u32 valid_lft)
 {
 	u32 flags;
@@ -3363,6 +3389,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 
 	spin_lock_bh(&ifp->lock);
 	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
+	ifp->scope = scope;
 	ifp->tstamp = jiffies;
 	ifp->valid_lft = valid_lft;
 	ifp->prefered_lft = prefered_lft;
@@ -3388,7 +3415,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct inet6_ifaddr *ifa;
 	struct net_device *dev;
 	u32 valid_lft = INFINITY_LIFE_TIME, preferred_lft = INFINITY_LIFE_TIME;
-	u8 ifa_flags;
+	u8 ifa_flags, scope;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
@@ -3418,6 +3445,13 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	/* We ignore other flags so far. */
 	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
 
+	if (ifm->ifa_scope == RT_SCOPE_UNIVERSE) {
+		/* Be backwards compatible with tools that don't set scope. */
+		scope = ipv6_addr_scope(pfx);
+	} else {
+		scope = ifa_scope(ifm->ifa_scope);
+	}
+
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {
 		/*
@@ -3425,7 +3459,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		 * userspace alreay relies on not having to provide this.
 		 */
 		return inet6_addr_add(net, ifm->ifa_index, pfx,
-				      ifm->ifa_prefixlen, ifa_flags,
+				      ifm->ifa_prefixlen, ifa_flags, scope,
 				      preferred_lft, valid_lft);
 	}
 
@@ -3433,7 +3467,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	    !(nlh->nlmsg_flags & NLM_F_REPLACE))
 		err = -EEXIST;
 	else
-		err = inet6_addr_modify(ifa, ifa_flags, preferred_lft, valid_lft);
+		err = inet6_addr_modify(ifa, ifa_flags, scope,
+					preferred_lft, valid_lft);
 
 	in6_ifa_put(ifa);
 
@@ -3466,18 +3501,6 @@ static int put_cacheinfo(struct sk_buff *skb, unsigned long cstamp,
 	return nla_put(skb, IFA_CACHEINFO, sizeof(ci), &ci);
 }
 
-static inline int rt_scope(int ifa_scope)
-{
-	if (ifa_scope & IFA_HOST)
-		return RT_SCOPE_HOST;
-	else if (ifa_scope & IFA_LINK)
-		return RT_SCOPE_LINK;
-	else if (ifa_scope & IFA_SITE)
-		return RT_SCOPE_SITE;
-	else
-		return RT_SCOPE_UNIVERSE;
-}
-
 static inline int inet6_ifaddr_msgsize(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
