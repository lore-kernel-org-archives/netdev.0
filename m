From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6: Keep nexthop of multipath route on admin down
Date: Wed, 18 Jan 2017 07:40:36 -0800
Message-ID: <1484754036-26807-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33897 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752560AbdARPtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 10:49:16 -0500
Received: by mail-pg0-f54.google.com with SMTP id 14so5549733pgg.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 07:49:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 deletes route entries associated with multipath routes on an
admin down where IPv4 does not. For example:
    $ ip ro ls vrf red
    unreachable default metric 8192
    1.1.1.0/24 metric 64
            nexthop via 10.100.1.254  dev eth1 weight 1
            nexthop via 10.100.2.254  dev eth2 weight 1
    10.100.1.0/24 dev eth1 proto kernel scope link src 10.100.1.4
    10.100.2.0/24 dev eth2 proto kernel scope link src 10.100.2.4

    $ ip -6 ro ls vrf red
    2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
    2001:db8:2:: dev red proto none metric 0  pref medium
    2001:db8:2::/120 dev eth2 proto kernel metric 256  pref medium
    2001:db8:11::/120 via 2001:db8:1::16 dev eth1 metric 1024  pref medium
    2001:db8:11::/120 via 2001:db8:2::17 dev eth2 metric 1024  pref medium
    ...

Set link down:
    $ ip li set eth1 down

IPv4 retains the multihop route but flags eth1 route as dead:

    $ ip ro ls vrf red
    unreachable default metric 8192
    1.1.1.0/24
            nexthop via 10.100.1.16  dev eth1 weight 1 dead linkdown
            nexthop via 10.100.2.16  dev eth2 weight 1
    10.100.2.0/24 dev eth2 proto kernel scope link src 10.100.2.4

and IPv6 deletes the route as part of flushing all routes for the device:

    $ ip -6 ro ls vrf red
    2001:db8:2:: dev red proto none metric 0  pref medium
    2001:db8:2::/120 dev eth2 proto kernel metric 256  pref medium
    2001:db8:11::/120 via 2001:db8:2::17 dev eth2 metric 1024  pref medium
    ...

Worse, on admin up of the device the multipath route has to be deleted
to get this leg of the route re-added.

This patch keeps routes that are part of a multipath route if
ignore_routes_with_linkdown is set with the dead and linkdown flags
enabling consistency between IPv4 and IPv6:

    $ ip -6 ro ls vrf red
    2001:db8:2:: dev red proto none metric 0  pref medium
    2001:db8:2::/120 dev eth2 proto kernel metric 256  pref medium
    2001:db8:11::/120 via 2001:db8:1::16 dev eth1 metric 1024 dead linkdown  pref medium
    2001:db8:11::/120 via 2001:db8:2::17 dev eth2 metric 1024  pref medium
    ...

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Sending this one outside of the other ipv6 multipath patches
since the user api (ignore_routes_with_linkdown) already exists

 net/ipv6/route.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5585c501a540..4b1f0f98a0e9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2711,13 +2711,16 @@ struct arg_dev_net {
 	struct net *net;
 };
 
+/* called with write lock held for table with rt */
 static int fib6_ifdown(struct rt6_info *rt, void *arg)
 {
 	const struct arg_dev_net *adn = arg;
 	const struct net_device *dev = adn->dev;
 
 	if ((rt->dst.dev == dev || !dev) &&
-	    rt != adn->net->ipv6.ip6_null_entry)
+	    rt != adn->net->ipv6.ip6_null_entry &&
+	    (rt->rt6i_nsiblings == 0 ||
+	     !rt->rt6i_idev->cnf.ignore_routes_with_linkdown))
 		return -1;
 
 	return 0;
@@ -3223,7 +3226,7 @@ static int rt6_fill_node(struct net *net,
 	else
 		rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
-	if (!netif_carrier_ok(rt->dst.dev)) {
+	if (!netif_running(rt->dst.dev) || !netif_carrier_ok(rt->dst.dev)) {
 		rtm->rtm_flags |= RTNH_F_LINKDOWN;
 		if (rt->rt6i_idev->cnf.ignore_routes_with_linkdown)
 			rtm->rtm_flags |= RTNH_F_DEAD;
-- 
2.1.4
