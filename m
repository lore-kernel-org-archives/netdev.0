From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 3/5] net: Add extack to validator_info structs used for address notifier
Date: Fri, 13 Oct 2017 16:02:11 -0700
Message-ID: <1507935733-18950-4-git-send-email-dsahern@gmail.com>
References: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, kjlx@templeofstupid.com,
        davem@davemloft.net, yoshfuji@linux-ipv6.org,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:56919 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753156AbdJMXC0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 19:02:26 -0400
Received: by mail-pg0-f66.google.com with SMTP id m18so2289649pgd.13
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 16:02:26 -0700 (PDT)
In-Reply-To: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extack to in_validator_info and in6_validator_info. Update the one
user of each, ipvlan, to return an error message for failures.

Only manual configuration of an address is plumbed in the IPv6 code path.

Signed-off-by: David Ahern <dsahern@gmail.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 10 ++++++++--
 include/linux/inetdevice.h       |  1 +
 include/net/addrconf.h           |  1 +
 net/ipv4/devinet.c               |  8 +++++---
 net/ipv6/addrconf.c              | 22 ++++++++++++----------
 5 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 6842739b6679..f0ab55df57f1 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -847,8 +847,11 @@ static int ipvlan_addr6_validator_event(struct notifier_block *unused,
 
 	switch (event) {
 	case NETDEV_UP:
-		if (ipvlan_addr_busy(ipvlan->port, &i6vi->i6vi_addr, true))
+		if (ipvlan_addr_busy(ipvlan->port, &i6vi->i6vi_addr, true)) {
+			NL_SET_ERR_MSG(i6vi->extack,
+				       "Address already assigned to an ipvlan device");
 			return notifier_from_errno(-EADDRINUSE);
+		}
 		break;
 	}
 
@@ -917,8 +920,11 @@ static int ipvlan_addr4_validator_event(struct notifier_block *unused,
 
 	switch (event) {
 	case NETDEV_UP:
-		if (ipvlan_addr_busy(ipvlan->port, &ivi->ivi_addr, false))
+		if (ipvlan_addr_busy(ipvlan->port, &ivi->ivi_addr, false)) {
+			NL_SET_ERR_MSG(ivi->extack,
+				       "Address already assigned to an ipvlan device");
 			return notifier_from_errno(-EADDRINUSE);
+		}
 		break;
 	}
 
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 751d051f0bc7..681dff30940b 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -154,6 +154,7 @@ struct in_ifaddr {
 struct in_validator_info {
 	__be32			ivi_addr;
 	struct in_device	*ivi_dev;
+	struct netlink_ext_ack	*extack;
 };
 
 int register_inetaddr_notifier(struct notifier_block *nb);
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 87981cd63180..b8b16437c6d5 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -55,6 +55,7 @@ struct prefix_info {
 struct in6_validator_info {
 	struct in6_addr		i6vi_addr;
 	struct inet6_dev	*i6vi_dev;
+	struct netlink_ext_ack	*extack;
 };
 
 #define IN6_ADDR_HSIZE_SHIFT	4
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7ce22a2c07ce..93773e5a80c7 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -444,7 +444,7 @@ static void check_lifetime(struct work_struct *work);
 static DECLARE_DELAYED_WORK(check_lifetime_work, check_lifetime);
 
 static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
-			     u32 portid)
+			     u32 portid, struct netlink_ext_ack *extack)
 {
 	struct in_device *in_dev = ifa->ifa_dev;
 	struct in_ifaddr *ifa1, **ifap, **last_primary;
@@ -489,6 +489,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	 */
 	ivi.ivi_addr = ifa->ifa_address;
 	ivi.ivi_dev = ifa->ifa_dev;
+	ivi.extack = extack;
 	ret = blocking_notifier_call_chain(&inetaddr_validator_chain,
 					   NETDEV_UP, &ivi);
 	ret = notifier_to_errno(ret);
@@ -521,7 +522,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 
 static int inet_insert_ifa(struct in_ifaddr *ifa)
 {
-	return __inet_insert_ifa(ifa, NULL, 0);
+	return __inet_insert_ifa(ifa, NULL, 0, NULL);
 }
 
 static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
@@ -902,7 +903,8 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh,
 				return ret;
 			}
 		}
-		return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid);
+		return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid,
+					 extack);
 	} else {
 		inet_free_ifa(ifa);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 31ff12277bcf..0075dd3fdc57 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -987,7 +987,7 @@ static struct inet6_ifaddr *
 ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	      const struct in6_addr *peer_addr, int pfxlen,
 	      int scope, u32 flags, u32 valid_lft, u32 prefered_lft,
-	      bool can_block)
+	      bool can_block, struct netlink_ext_ack *extack)
 {
 	gfp_t gfp_flags = can_block ? GFP_KERNEL : GFP_ATOMIC;
 	struct net *net = dev_net(idev->dev);
@@ -1019,6 +1019,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 		struct in6_validator_info i6vi = {
 			.i6vi_addr = *addr,
 			.i6vi_dev = idev,
+			.extack = extack,
 		};
 
 		err = inet6addr_validator_notifier_call_chain(NETDEV_UP, &i6vi);
@@ -1351,7 +1352,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 
 	ift = ipv6_add_addr(idev, &addr, NULL, tmp_plen,
 			    ipv6_addr_scope(&addr), addr_flags,
-			    tmp_valid_lft, tmp_prefered_lft, true);
+			    tmp_valid_lft, tmp_prefered_lft, true, NULL);
 	if (IS_ERR(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
@@ -2035,7 +2036,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 
 		ifp2 = ipv6_add_addr(idev, &new_addr, NULL, pfxlen,
 				     scope, flags, valid_lft,
-				     preferred_lft, false);
+				     preferred_lft, false, NULL);
 		if (IS_ERR(ifp2))
 			goto lock_errdad;
 
@@ -2493,7 +2494,7 @@ int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
 					    pinfo->prefix_len,
 					    addr_type&IPV6_ADDR_SCOPE_MASK,
 					    addr_flags, valid_lft,
-					    prefered_lft, false);
+					    prefered_lft, false, NULL);
 
 		if (IS_ERR_OR_NULL(ifp))
 			return -1;
@@ -2803,7 +2804,8 @@ static int inet6_addr_add(struct net *net, int ifindex,
 			  const struct in6_addr *pfx,
 			  const struct in6_addr *peer_pfx,
 			  unsigned int plen, __u32 ifa_flags,
-			  __u32 prefered_lft, __u32 valid_lft)
+			  __u32 prefered_lft, __u32 valid_lft,
+			  struct netlink_ext_ack *extack)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
@@ -2862,7 +2864,7 @@ static int inet6_addr_add(struct net *net, int ifindex,
 	}
 
 	ifp = ipv6_add_addr(idev, pfx, peer_pfx, plen, scope, ifa_flags,
-			    valid_lft, prefered_lft, true);
+			    valid_lft, prefered_lft, true, extack);
 
 	if (!IS_ERR(ifp)) {
 		if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
@@ -2947,7 +2949,7 @@ int addrconf_add_ifaddr(struct net *net, void __user *arg)
 	rtnl_lock();
 	err = inet6_addr_add(net, ireq.ifr6_ifindex, &ireq.ifr6_addr, NULL,
 			     ireq.ifr6_prefixlen, IFA_F_PERMANENT,
-			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
+			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME, NULL);
 	rtnl_unlock();
 	return err;
 }
@@ -2978,7 +2980,7 @@ static void add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifp = ipv6_add_addr(idev, addr, NULL, plen,
 			    scope, IFA_F_PERMANENT,
 			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME,
-			    true);
+			    true, NULL);
 	if (!IS_ERR(ifp)) {
 		spin_lock_bh(&ifp->lock);
 		ifp->flags &= ~IFA_F_TENTATIVE;
@@ -3078,7 +3080,7 @@ void addrconf_add_linklocal(struct inet6_dev *idev,
 #endif
 
 	ifp = ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags,
-			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME, true);
+			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME, true, NULL);
 	if (!IS_ERR(ifp)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
 		addrconf_dad_start(ifp);
@@ -4581,7 +4583,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh,
 		 */
 		return inet6_addr_add(net, ifm->ifa_index, pfx, peer_pfx,
 				      ifm->ifa_prefixlen, ifa_flags,
-				      preferred_lft, valid_lft);
+				      preferred_lft, valid_lft, extack);
 	}
 
 	if (nlh->nlmsg_flags & NLM_F_EXCL ||
-- 
2.1.4
