From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 2/5] net: ipv6: Make inet6addr_validator a blocking notifier
Date: Fri, 13 Oct 2017 16:02:10 -0700
Message-ID: <1507935733-18950-3-git-send-email-dsahern@gmail.com>
References: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, kjlx@templeofstupid.com,
        davem@davemloft.net, yoshfuji@linux-ipv6.org,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:55452 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751571AbdJMXCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 19:02:25 -0400
Received: by mail-pf0-f195.google.com with SMTP id 17so11448849pfn.12
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 16:02:25 -0700 (PDT)
In-Reply-To: <1507935733-18950-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet6addr_validator chain was added by commit 3ad7d2468f79f ("Ipvlan
should return an error when an address is already in use") to allow
address validation before changes are committed and to be able to
fail the address change with an error back to the user. The address
validation is not done for addresses received from router
advertisements.

Handling RAs in softirq context is the only reason for the notifier
chain to be atomic versus blocking. Since the only current user, ipvlan,
of the validator chain ignores softirq context, the notifier can be made
blocking and simply not invoked for softirq path.

The blocking option is needed by spectrum for example to validate
resources for an adding an address to an interface.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/ipvlan/ipvlan_main.c |  4 ----
 net/ipv6/addrconf.c              | 21 ++++++++++++++-------
 net/ipv6/addrconf_core.c         |  9 +++++----
 3 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 3cf67db513e2..6842739b6679 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -808,10 +808,6 @@ static int ipvlan_addr6_event(struct notifier_block *unused,
 	struct net_device *dev = (struct net_device *)if6->idev->dev;
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 
-	/* FIXME IPv6 autoconf calls us from bh without RTNL */
-	if (in_softirq())
-		return NOTIFY_DONE;
-
 	if (!netif_is_ipvlan(dev))
 		return NOTIFY_DONE;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 80f5fc74f0c4..31ff12277bcf 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -993,7 +993,6 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	struct net *net = dev_net(idev->dev);
 	struct inet6_ifaddr *ifa = NULL;
 	struct rt6_info *rt = NULL;
-	struct in6_validator_info i6vi;
 	int err = 0;
 	int addr_type = ipv6_addr_type(addr);
 
@@ -1013,12 +1012,20 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 		goto out;
 	}
 
-	i6vi.i6vi_addr = *addr;
-	i6vi.i6vi_dev = idev;
-	err = inet6addr_validator_notifier_call_chain(NETDEV_UP, &i6vi);
-	err = notifier_to_errno(err);
-	if (err < 0)
-		goto out;
+	/* validator notifier needs to be blocking;
+	 * do not call in atomic context
+	 */
+	if (can_block) {
+		struct in6_validator_info i6vi = {
+			.i6vi_addr = *addr,
+			.i6vi_dev = idev,
+		};
+
+		err = inet6addr_validator_notifier_call_chain(NETDEV_UP, &i6vi);
+		err = notifier_to_errno(err);
+		if (err < 0)
+			goto out;
+	}
 
 	ifa = kzalloc(sizeof(*ifa), gfp_flags);
 	if (!ifa) {
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 9e3488d50b15..32b564dfd02a 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -88,7 +88,7 @@ int __ipv6_addr_type(const struct in6_addr *addr)
 EXPORT_SYMBOL(__ipv6_addr_type);
 
 static ATOMIC_NOTIFIER_HEAD(inet6addr_chain);
-static ATOMIC_NOTIFIER_HEAD(inet6addr_validator_chain);
+static BLOCKING_NOTIFIER_HEAD(inet6addr_validator_chain);
 
 int register_inet6addr_notifier(struct notifier_block *nb)
 {
@@ -110,19 +110,20 @@ EXPORT_SYMBOL(inet6addr_notifier_call_chain);
 
 int register_inet6addr_validator_notifier(struct notifier_block *nb)
 {
-	return atomic_notifier_chain_register(&inet6addr_validator_chain, nb);
+	return blocking_notifier_chain_register(&inet6addr_validator_chain, nb);
 }
 EXPORT_SYMBOL(register_inet6addr_validator_notifier);
 
 int unregister_inet6addr_validator_notifier(struct notifier_block *nb)
 {
-	return atomic_notifier_chain_unregister(&inet6addr_validator_chain, nb);
+	return blocking_notifier_chain_unregister(&inet6addr_validator_chain,
+						  nb);
 }
 EXPORT_SYMBOL(unregister_inet6addr_validator_notifier);
 
 int inet6addr_validator_notifier_call_chain(unsigned long val, void *v)
 {
-	return atomic_notifier_call_chain(&inet6addr_validator_chain, val, v);
+	return blocking_notifier_call_chain(&inet6addr_validator_chain, val, v);
 }
 EXPORT_SYMBOL(inet6addr_validator_notifier_call_chain);
 
-- 
2.1.4
