From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] net: avoid a full fib lookup when rp_filter is disabled.
Date: Wed, 20 Sep 2017 18:26:53 +0200
Message-ID: <597db26b5e57eb89d2ff27454cce997fa6c0f5aa.1505924560.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53446 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751845AbdITQ2H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 12:28:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 1dced6a85482 ("ipv4: Restore accept_local behaviour
in fib_validate_source()") a full fib lookup is needed even if
the rp_filter is disabled, if accept_local is false - which is
the default.

What we really need in the above scenario is just checking
that the source IP address is not local, and in most case we
can do that is a cheaper way looking up the ifaddr hash table.

This commit adds a helper for such lookup, and uses it to
validate the src address when rp_filter is disabled and no
'local' routes are created by the user space in the relevant
namespace.

A new ipv4 netns flag is added to account for such routes.
We need that to preserve the same behavior we had before this
patch.

It also drops the checks to bail early from __fib_validate_source,
added by the commit 1dced6a85482 ("ipv4: Restore accept_local
behaviour in fib_validate_source()") they do not give any
measurable performance improvement: if we do the lookup with are
on a slower path.

This improves UDP performances for unconnected sockets
when rp_filter is disabled by 5% and also gives small but
measurable performance improvement for TCP flood scenarios.

v1 -> v2:
 - use the ifaddr lookup helper in __ip_dev_find(), as suggested
   by Eric
 - fall-back to full lookup if custom local routes are present

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/inetdevice.h |  1 +
 include/net/netns/ipv4.h   |  1 +
 net/ipv4/devinet.c         | 30 ++++++++++++++++++------------
 net/ipv4/fib_frontend.c    | 22 +++++++++++++++++-----
 4 files changed, 37 insertions(+), 17 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index fb3f809e34e4..751d051f0bc7 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -179,6 +179,7 @@ __be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
 			 __be32 local, int scope);
 struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
 				    __be32 mask);
+struct in_ifaddr *inet_lookup_ifaddr_rcu(struct net *net, __be32 addr);
 static __inline__ bool inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
 {
 	return !((addr^ifa->ifa_address)&ifa->ifa_mask);
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 20d061c805e3..20720721da4b 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -49,6 +49,7 @@ struct netns_ipv4 {
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_rules_ops	*rules_ops;
 	bool			fib_has_custom_rules;
+	bool			fib_has_custom_local_routes;
 	struct fib_table __rcu	*fib_main;
 	struct fib_table __rcu	*fib_default;
 #endif
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index d7adc0616599..7ce22a2c07ce 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -137,22 +137,12 @@ static void inet_hash_remove(struct in_ifaddr *ifa)
  */
 struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 {
-	u32 hash = inet_addr_hash(net, addr);
 	struct net_device *result = NULL;
 	struct in_ifaddr *ifa;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(ifa, &inet_addr_lst[hash], hash) {
-		if (ifa->ifa_local == addr) {
-			struct net_device *dev = ifa->ifa_dev->dev;
-
-			if (!net_eq(dev_net(dev), net))
-				continue;
-			result = dev;
-			break;
-		}
-	}
-	if (!result) {
+	ifa = inet_lookup_ifaddr_rcu(net, addr);
+	if (!ifa) {
 		struct flowi4 fl4 = { .daddr = addr };
 		struct fib_result res = { 0 };
 		struct fib_table *local;
@@ -165,6 +155,8 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 		    !fib_table_lookup(local, &fl4, &res, FIB_LOOKUP_NOREF) &&
 		    res.type == RTN_LOCAL)
 			result = FIB_RES_DEV(res);
+	} else {
+		result = ifa->ifa_dev->dev;
 	}
 	if (result && devref)
 		dev_hold(result);
@@ -173,6 +165,20 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 }
 EXPORT_SYMBOL(__ip_dev_find);
 
+/* called under RCU lock */
+struct in_ifaddr *inet_lookup_ifaddr_rcu(struct net *net, __be32 addr)
+{
+	u32 hash = inet_addr_hash(net, addr);
+	struct in_ifaddr *ifa;
+
+	hlist_for_each_entry_rcu(ifa, &inet_addr_lst[hash], hash)
+		if (ifa->ifa_local == addr &&
+		    net_eq(dev_net(ifa->ifa_dev->dev), net))
+			return ifa;
+
+	return NULL;
+}
+
 static void rtmsg_ifa(int event, struct in_ifaddr *, struct nlmsghdr *, u32);
 
 static BLOCKING_NOTIFIER_HEAD(inetaddr_chain);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 37819ab4cc74..f02819134ba2 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -345,9 +345,6 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	if (res.type != RTN_UNICAST &&
 	    (res.type != RTN_LOCAL || !IN_DEV_ACCEPT_LOCAL(idev)))
 		goto e_inval;
-	if (!rpf && !fib_num_tclassid_users(net) &&
-	    (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev)))
-		goto last_resort;
 	fib_combine_itag(itag, &res);
 	dev_match = false;
 
@@ -402,13 +399,26 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			struct in_device *idev, u32 *itag)
 {
 	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
+	struct net *net = dev_net(dev);
 
-	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
-	    IN_DEV_ACCEPT_LOCAL(idev) &&
+	if (!r && !fib_num_tclassid_users(net) &&
 	    (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))) {
+		if (IN_DEV_ACCEPT_LOCAL(idev))
+			goto ok;
+		/* if no local routes are added from user space we can check
+		 * for local addresses looking-up the ifaddr table
+		 */
+		if (net->ipv4.fib_has_custom_local_routes)
+			goto full_check;
+		if (inet_lookup_ifaddr_rcu(net, src))
+			return -EINVAL;
+
+ok:
 		*itag = 0;
 		return 0;
 	}
+
+full_check:
 	return __fib_validate_source(skb, src, dst, tos, oif, dev, r, idev, itag);
 }
 
@@ -759,6 +769,8 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	err = fib_table_insert(net, tb, &cfg, extack);
+	if (!err && cfg.fc_type == RTN_LOCAL)
+		net->ipv4.fib_has_custom_local_routes = true;
 errout:
 	return err;
 }
-- 
2.13.5
