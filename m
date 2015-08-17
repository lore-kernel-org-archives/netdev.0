From: Andrew Lunn <andrew@lunn.ch>
Subject: [net-next RFC] net: ipv4: Send IGMP messages from highest scoped address
Date: Mon, 17 Aug 2015 18:09:24 +0200
Message-ID: <1439827764-29129-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60703 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755498AbbHQQQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 12:16:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 6a21165480a0 ("net: ipv4: route: Fix sending IGMP messages with
link address") changed the way the source address of an IGMP message
was determined. Before that patch, a global scope addresses would be
used from another interface, if there was no global scope address on
the outgoing interface. That patch fixes this so a source address from
the outgoing interface was picked. However, in complex configurations,
it is not picking the best address, for example:

7: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 1000
    link/ether 02:00:00:20:12:01 brd ff:ff:ff:ff:ff:ff
    inet 10.81.0.42/24 brd 10.81.0.255 scope link eth2
       valid_lft forever preferred_lft forever
    inet 10.81.100.42/24 brd 10.81.100.255 scope link eth2:2
       valid_lft forever preferred_lft forever
    inet 10.81.200.42/24 brd 10.81.200.255 scope global eth2:1
       valid_lft forever preferred_lft forever
    inet6 fe80::ff:fe20:1201/64 scope link
       valid_lft forever preferred_lft forever

The first address is used, which has scope link. Before the previous
patch, the global scope address would of been used.

This patch adds a new function to find the highest scope address on an
interface, and this is then used for IGMP messages in the routing
code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

This is RFC because i personally don't know if this is the best fix.
The patch restores previous behavior, while still keeping the bug fix.

It is not obvious what is the correct source address for an IGMP
message when an interface has multiple addresses. IGMP messages are
sent either spontaneously, or as a result of a query. It could be
argued that when replying to a query, an address take from the same
subnet as the querier should be used. Doing this adds complexity for a
corner case which does not seem to effect people. In the spontaneous
case, there is no such hint, so an address has to be picked some other
way. Taking the highest scope address seems reasonable, and works for
me.

	Andrew


include/linux/inetdevice.h |  1 +
 net/ipv4/devinet.c         | 33 +++++++++++++++++++++++++++++++++
 net/ipv4/route.c           | 10 +++++++---
 3 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index a4328cea376a..351f6feb92bb 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -167,6 +167,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
 void devinet_init(void);
 struct in_device *inetdev_by_index(struct net *, int);
 __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
+__be32 inet_select_highest_scope(const struct net_device *dev);
 __be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
 			 __be32 local, int scope);
 struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 2d9cb1748f81..6419356f2893 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1238,6 +1238,39 @@ out_unlock:
 }
 EXPORT_SYMBOL(inet_select_addr);
 
+__be32 inet_select_highest_scope(const struct net_device *dev)
+{
+	__be32 addr = 0;
+	struct in_device *in_dev;
+	struct net *net = dev_net(dev);
+	int best_scope = RT_SCOPE_NOWHERE;
+
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(dev);
+	if (!in_dev)
+		goto no_in_dev;
+
+	for_ifa(in_dev) {
+		if (ifa->ifa_scope > best_scope)
+			continue;
+		addr = ifa->ifa_local;
+		best_scope = ifa->ifa_scope;
+	} endfor_ifa(in_dev);
+
+	if (addr)
+		goto out_unlock;
+no_in_dev:
+	/* Not loopback addresses on loopback should be preferred in
+	 * this case.
+	 */
+	addr = inet_select_addr_lo(net, dev, RT_SCOPE_UNIVERSE);
+
+out_unlock:
+	rcu_read_unlock();
+	return addr;
+}
+EXPORT_SYMBOL(inet_select_highest_scope);
+
 static __be32 confirm_addr_indev(struct in_device *in_dev, __be32 dst,
 			      __be32 local, int scope)
 {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2c89d294b669..955c24f221ef 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2116,11 +2116,15 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 			goto out;
 		}
 		if (ipv4_is_local_multicast(fl4->daddr) ||
-		    ipv4_is_lbcast(fl4->daddr) ||
-		    fl4->flowi4_proto == IPPROTO_IGMP) {
+		    ipv4_is_lbcast(fl4->daddr)) {
 			if (!fl4->saddr)
 				fl4->saddr = inet_select_addr(dev_out, 0,
-							      RT_SCOPE_LINK);
+							      RT_SCOPE_HOST);
+			goto make_route;
+		}
+		if (fl4->flowi4_proto == IPPROTO_IGMP) {
+			if (!fl4->saddr)
+				fl4->saddr = inet_select_highest_scope(dev_out);
 			goto make_route;
 		}
 		if (!fl4->saddr) {
-- 
2.5.0
