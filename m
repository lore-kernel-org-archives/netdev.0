From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6: Use passed in table for nexthop lookups
Date: Thu,  7 Apr 2016 11:11:14 -0700
Message-ID: <1460052674-1204-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33566 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757089AbcDGSLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 14:11:22 -0400
Received: by mail-pf0-f180.google.com with SMTP id 184so60255503pff.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 11:11:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to 3bfd847203c6 ("net: Use passed in table for nexthop lookups")
for IPv4, if the route spec contains a table id use that to lookup the
next hop first and fall back to a full lookup if it fails (per the fix
4c9bcd117918b ("net: Fix nexthop lookups")).

Example:

    root@kenny:~# ip -6 ro ls table red
    local 2100:1::1 dev lo  proto none  metric 0  pref medium
    2100:1::/120 dev eth1  proto kernel  metric 256  pref medium
    local 2100:2::1 dev lo  proto none  metric 0  pref medium
    2100:2::/120 dev eth2  proto kernel  metric 256  pref medium
    local fe80::e0:f9ff:fe09:3cac dev lo  proto none  metric 0  pref medium
    local fe80::e0:f9ff:fe1c:b974 dev lo  proto none  metric 0  pref medium
    fe80::/64 dev eth1  proto kernel  metric 256  pref medium
    fe80::/64 dev eth2  proto kernel  metric 256  pref medium
    ff00::/8 dev red  metric 256  pref medium
    ff00::/8 dev eth1  metric 256  pref medium
    ff00::/8 dev eth2  metric 256  pref medium
    unreachable default dev lo  metric 240  error -113 pref medium

    root@kenny:~# ip -6 ro add table red 2100:3::/64 via 2100:1::64
    RTNETLINK answers: No route to host

Route add fails even though 2100:1::64 is a reachable next hop:
    root@kenny:~# ping6 -I red  2100:1::64
    ping6: Warning: source address might be selected on device other than red.
    PING 2100:1::64(2100:1::64) from 2100:1::1 red: 56 data bytes
    64 bytes from 2100:1::64: icmp_seq=1 ttl=64 time=1.33 ms

With this patch:
    root@kenny:~# ip -6 ro add table red 2100:3::/64 via 2100:1::64
    root@kenny:~# ip -6 ro ls table red
    local 2100:1::1 dev lo  proto none  metric 0  pref medium
    2100:1::/120 dev eth1  proto kernel  metric 256  pref medium
    local 2100:2::1 dev lo  proto none  metric 0  pref medium
    2100:2::/120 dev eth2  proto kernel  metric 256  pref medium
    2100:3::/64 via 2100:1::64 dev eth1  metric 1024  pref medium
    local fe80::e0:f9ff:fe09:3cac dev lo  proto none  metric 0  pref medium
    local fe80::e0:f9ff:fe1c:b974 dev lo  proto none  metric 0  pref medium
    fe80::/64 dev eth1  proto kernel  metric 256  pref medium
    fe80::/64 dev eth2  proto kernel  metric 256  pref medium
    ff00::/8 dev red  metric 256  pref medium
    ff00::/8 dev eth1  metric 256  pref medium
    ff00::/8 dev eth2  metric 256  pref medium
    unreachable default dev lo  metric 240  error -113 pref medium

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 35 +++++++++++++++++++++++++++++++++--
 1 file changed, 33 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1d8871a5ed20..3e699dc199f3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1928,7 +1928,7 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 		rt->rt6i_gateway = *gw_addr;
 
 		if (gwa_type != (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST)) {
-			struct rt6_info *grt;
+			struct rt6_info *grt = NULL;
 
 			/* IPv6 strictly inhibits using not link-local
 			   addresses as nexthop address.
@@ -1940,7 +1940,38 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 			if (!(gwa_type & IPV6_ADDR_UNICAST))
 				goto out;
 
-			grt = rt6_lookup(net, gw_addr, NULL, cfg->fc_ifindex, 1);
+			if (cfg->fc_table) {
+				struct flowi6 fl6 = {
+					.flowi6_oif = cfg->fc_ifindex,
+					.daddr = *gw_addr,
+					.saddr = cfg->fc_prefsrc,
+				};
+				struct fib6_table *table;
+				int flags = 0;
+
+				err = -EHOSTUNREACH;
+				table = fib6_get_table(net, cfg->fc_table);
+				if (!table)
+					goto out;
+
+				if (!ipv6_addr_any(&cfg->fc_prefsrc))
+					flags |= RT6_LOOKUP_F_HAS_SADDR;
+
+				grt = ip6_pol_route(net, table, cfg->fc_ifindex,
+						    &fl6, flags);
+
+				/* if table lookup failed, fall back
+				 * to full lookup
+				 */
+				if (grt == net->ipv6.ip6_null_entry) {
+					ip6_rt_put(grt);
+					grt = NULL;
+				}
+			}
+
+			if (!grt)
+				grt = rt6_lookup(net, gw_addr, NULL,
+						 cfg->fc_ifindex, 1);
 
 			err = -EHOSTUNREACH;
 			if (!grt)
-- 
2.1.4
