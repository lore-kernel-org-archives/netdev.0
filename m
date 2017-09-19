From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] net: avoid a full fib lookup when rp_filter is disabled.
Date: Tue, 19 Sep 2017 12:46:16 +0200
Message-ID: <1967ebaa528c626ebd9682e927fd33770a396a0a.1505817863.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57408 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751284AbdISKqx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 06:46:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 1dced6a85482 ("ipv4: Restore accept_local
behaviour in fib_validate_source()") a full fib lookup
is needed even if the rp_filter is disabled, if
accept_local is false - which is the default.

What we really need in the above scenario is just checking
that the source IP address is not local, and we can do
that is a cheaper way looking up the ifaddr hash table.

This commit adds an helper for such lookup and uses it
to validate the src address when rp_filter is disabled.
It also drops the checks to bail early from
__fib_validate_source, added by the commit 1dced6a85482
("ipv4: Restore accept_local behaviour in fib_validate_source()")
and now unneeded.

This improves UDP performances for unconnected sockets
when rp_filter is disabled by 5% and also gives small but
measurable performance improvement for TCP flood scenarios.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/inetdevice.h |  1 +
 net/ipv4/devinet.c         | 14 ++++++++++++++
 net/ipv4/fib_frontend.c    | 11 +++++++----
 3 files changed, 22 insertions(+), 4 deletions(-)

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
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index d7adc0616599..73bf09bcfe43 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -173,6 +173,20 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
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
index 37819ab4cc74..1470d265a357 100644
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
 
@@ -404,8 +401,14 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
 
 	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
-	    IN_DEV_ACCEPT_LOCAL(idev) &&
 	    (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))) {
+		/* we need only to ensure that the src address is not a
+		 * local one
+		 */
+		if (!IN_DEV_ACCEPT_LOCAL(idev) &&
+		    inet_lookup_ifaddr_rcu(dev_net(dev), src))
+			return -EINVAL;
+
 		*itag = 0;
 		return 0;
 	}
-- 
2.13.5
