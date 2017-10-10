From: David Ahern <dsahern@gmail.com>
Subject: [RFC net-next 1/4] net: ipv6: Make inet6addr_validator a blocking notifier
Date: Tue, 10 Oct 2017 09:41:02 -0700
Message-ID: <1507653665-20540-2-git-send-email-dsahern@gmail.com>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, kjlx@templeofstupid.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38780 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932391AbdJJQlL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 12:41:11 -0400
Received: by mail-pf0-f195.google.com with SMTP id a7so36889586pfj.5
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 09:41:11 -0700 (PDT)
In-Reply-To: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
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
 net/ipv6/addrconf.c      | 24 +++++++++++++++---------
 net/ipv6/addrconf_core.c |  9 +++++----
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d9f6226694eb..632cf4b26277 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -963,7 +963,6 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	struct net *net = dev_net(idev->dev);
 	struct inet6_ifaddr *ifa = NULL;
 	struct rt6_info *rt;
-	struct in6_validator_info i6vi;
 	unsigned int hash;
 	int err = 0;
 	int addr_type = ipv6_addr_type(addr);
@@ -988,16 +987,23 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 		goto out2;
 	}
 
-	i6vi.i6vi_addr = *addr;
-	i6vi.i6vi_dev = idev;
-	rcu_read_unlock_bh();
+	/* validator notifier needs to be blocking;
+	 * do not call in softirq context
+	 */
+	if (!in_softirq()) {
+		struct in6_validator_info i6vi = {
+			.i6vi_addr = *addr,
+			.i6vi_dev = idev,
+		};
 
-	err = inet6addr_validator_notifier_call_chain(NETDEV_UP, &i6vi);
+		rcu_read_unlock_bh();
+		err = inet6addr_validator_notifier_call_chain(NETDEV_UP, &i6vi);
+		rcu_read_lock_bh();
 
-	rcu_read_lock_bh();
-	err = notifier_to_errno(err);
-	if (err)
-		goto out2;
+		err = notifier_to_errno(err);
+		if (err)
+			goto out2;
+	}
 
 	spin_lock(&addrconf_hash_lock);
 
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
