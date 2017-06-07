From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net] net: ipv6: Release route when device is unregistering
Date: Wed,  7 Jun 2017 12:26:23 -0600
Message-ID: <20170607182623.20734-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36522 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdFGS0b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 14:26:31 -0400
Received: by mail-pg0-f67.google.com with SMTP id v18so2122753pgb.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 11:26:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa reported attempts to delete a bond device that is referenced in a
multipath route is hanging:

$ ifdown bond2    # ifupdown2 command that deletes virtual devices
unregister_netdevice: waiting for bond2 to become free. Usage count = 2

Steps to reproduce:
    echo 1 > /proc/sys/net/ipv6/conf/all/ignore_routes_with_linkdown
    ip link add dev bond12 type bond
    ip link add dev bond13 type bond
    ip addr add 2001:db8:2::0/64 dev bond12
    ip addr add 2001:db8:3::0/64 dev bond13
    ip route add 2001:db8:33::0/64 nexthop via 2001:db8:2::2 nexthop via 2001:db8:3::2
    ip link del dev bond12
    ip link del dev bond13

The root cause is the recent change to keep routes on a linkdown. Update
the check to detect when the device is unregistering and release the
route for that case.

Fixes: a1a22c12060e4 ("net: ipv6: Keep nexthop of multipath route on admin down")
Reported-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h | 5 +++++
 net/ipv6/route.c          | 1 +
 2 files changed, 6 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3f39d27decf4..c06d93cfd719 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4261,6 +4261,11 @@ static inline const char *netdev_name(const struct net_device *dev)
 	return dev->name;
 }
 
+static inline bool netdev_unregistering(const struct net_device *dev)
+{
+	return dev->reg_state == NETREG_UNREGISTERING;
+}
+
 static inline const char *netdev_reg_state(const struct net_device *dev)
 {
 	switch (dev->reg_state) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dc61b0b5e64e..7cebd954d5bb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2804,6 +2804,7 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
 	if ((rt->dst.dev == dev || !dev) &&
 	    rt != adn->net->ipv6.ip6_null_entry &&
 	    (rt->rt6i_nsiblings == 0 ||
+	     (dev && netdev_unregistering(dev)) ||
 	     !rt->rt6i_idev->cnf.ignore_routes_with_linkdown))
 		return -1;
 
-- 
2.11.0 (Apple Git-81)
