From: Krister Johansen <kjlx@templeofstupid.com>
Subject: [PATCH] Ipvlan should return an error when an address is already in
 use.
Date: Fri, 30 Dec 2016 20:10:58 -0800
Message-ID: <20161231041058.GC2448@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mahesh Bandewar <maheshb@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:33149 "EHLO
        homiemail-a124.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754470AbcLaELB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 23:11:01 -0500
Received: from homiemail-a124.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a124.g.dreamhost.com (Postfix) with ESMTP id 9094960000D02
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2016 20:10:59 -0800 (PST)
Received: from kmjvbox (c-73-70-90-212.hsd1.ca.comcast.net [73.70.90.212])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a124.g.dreamhost.com (Postfix) with ESMTPSA id 7701A60000D01
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2016 20:10:59 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipvlan code already knows how to detect when a duplicate address is
about to be assigned to an ipvlan device.  However, that failure is not
propogated outward and leads to a silent failure.  This teaches the ip
address addition functions how to report this error to the user
applications so that a notifier chain failure during ip address addition
will not appear to succeed when it actually has not.

This can be especially useful if it is necessary to provision many
ipvlans in containers.  The provisioning software (or operator) can use
this to detect situations where an ip address is unexpectedly in use.

Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 12 ++++++++----
 net/ipv4/devinet.c               |  8 +++++++-
 net/ipv6/addrconf.c              | 23 ++++++++++++++++++-----
 3 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 975f9dd..3bd2506 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -739,6 +739,7 @@ static int ipvlan_addr6_event(struct notifier_block *unused,
 	struct inet6_ifaddr *if6 = (struct inet6_ifaddr *)ptr;
 	struct net_device *dev = (struct net_device *)if6->idev->dev;
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
+	int err;
 
 	/* FIXME IPv6 autoconf calls us from bh without RTNL */
 	if (in_softirq())
@@ -752,8 +753,9 @@ static int ipvlan_addr6_event(struct notifier_block *unused,
 
 	switch (event) {
 	case NETDEV_UP:
-		if (ipvlan_add_addr6(ipvlan, &if6->addr))
-			return NOTIFY_BAD;
+		err = ipvlan_add_addr6(ipvlan, &if6->addr);
+		if (err)
+			return notifier_from_errno(err);
 		break;
 
 	case NETDEV_DOWN:
@@ -788,6 +790,7 @@ static int ipvlan_addr4_event(struct notifier_block *unused,
 	struct net_device *dev = (struct net_device *)if4->ifa_dev->dev;
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct in_addr ip4_addr;
+	int err;
 
 	if (!netif_is_ipvlan(dev))
 		return NOTIFY_DONE;
@@ -798,8 +801,9 @@ static int ipvlan_addr4_event(struct notifier_block *unused,
 	switch (event) {
 	case NETDEV_UP:
 		ip4_addr.s_addr = if4->ifa_address;
-		if (ipvlan_add_addr4(ipvlan, &ip4_addr))
-			return NOTIFY_BAD;
+		err = ipvlan_add_addr4(ipvlan, &ip4_addr);
+		if (err)
+			return notifier_from_errno(err);
 		break;
 
 	case NETDEV_DOWN:
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 4cd2ee8..5bc26f8e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -442,6 +442,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 {
 	struct in_device *in_dev = ifa->ifa_dev;
 	struct in_ifaddr *ifa1, **ifap, **last_primary;
+	int ret;
 
 	ASSERT_RTNL();
 
@@ -489,7 +490,12 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	   Notifier will trigger FIB update, so that
 	   listeners of netlink will know about new ifaddr */
 	rtmsg_ifa(RTM_NEWADDR, ifa, nlh, portid);
-	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
+	ret = blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
+	ret = notifier_to_errno(ret);
+	if (ret) {
+		__inet_del_ifa(in_dev, ifap, 1, NULL, portid);
+		return ret;
+	}
 
 	return 0;
 }
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c1e124b..24d89f3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -149,6 +149,7 @@ static inline void addrconf_sysctl_unregister(struct inet6_dev *idev)
 
 static void ipv6_regen_rndid(struct inet6_dev *idev);
 static void ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr);
+static void __ipv6_del_addr(struct inet6_ifaddr *ifp, bool notify);
 
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
 static int ipv6_count_addresses(struct inet6_dev *idev);
@@ -1031,9 +1032,15 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 out2:
 	rcu_read_unlock_bh();
 
-	if (likely(err == 0))
-		inet6addr_notifier_call_chain(NETDEV_UP, ifa);
-	else {
+	if (likely(err == 0)) {
+		err = inet6addr_notifier_call_chain(NETDEV_UP, ifa);
+		err = notifier_to_errno(err);
+		if (err) {
+			__ipv6_del_addr(ifa, false);
+			ifa = ERR_PTR(err);
+			return ifa;
+		}
+	} else {
 		kfree(ifa);
 		ifa = ERR_PTR(err);
 	}
@@ -1128,7 +1135,7 @@ cleanup_prefix_route(struct inet6_ifaddr *ifp, unsigned long expires, bool del_r
 
 /* This function wants to get referenced ifp and releases it before return */
 
-static void ipv6_del_addr(struct inet6_ifaddr *ifp)
+static void __ipv6_del_addr(struct inet6_ifaddr *ifp, bool notify)
 {
 	int state;
 	enum cleanup_prefix_rt_t action = CLEANUP_PREFIX_RT_NOP;
@@ -1169,7 +1176,8 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 
 	addrconf_del_dad_work(ifp);
 
-	ipv6_ifa_notify(RTM_DELADDR, ifp);
+	if (notify)
+		ipv6_ifa_notify(RTM_DELADDR, ifp);
 
 	inet6addr_notifier_call_chain(NETDEV_DOWN, ifp);
 
@@ -1184,6 +1192,11 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	in6_ifa_put(ifp);
 }
 
+static void ipv6_del_addr(struct inet6_ifaddr *ifp)
+{
+	__ipv6_del_addr(ifp, true);
+}
+
 static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *ift)
 {
 	struct inet6_dev *idev = ifp->idev;
-- 
2.7.4
