From: Romain KUNTZ <r.kuntz@ipflavors.com>
Subject: Re: [PATCH 1/2] ipv6: avoid blackhole and prohibited entries upon prefix purge [v2]
Date: Sat, 5 Jan 2013 22:44:03 +0100
Message-ID: <2A507F9D-3D53-475F-8FA9-9E6CFEE9C97A@ipflavors.com>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com> <1357415941.1678.4163.camel@edumazet-glaptop>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:44307 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755865Ab3AEVoG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 16:44:06 -0500
Received: by mail-wg0-f52.google.com with SMTP id 12so8540133wgh.19
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 13:44:04 -0800 (PST)
In-Reply-To: <1357415941.1678.4163.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mobile IPv6 provokes a kernel Oops since commit 64c6d08e (ipv6:
del unreachable route when an addr is deleted on lo), because
ip6_route_lookup() may also return blackhole and prohibited
entry. However, these entries have a NULL rt6i_table argument,
which provokes an Oops in __ip6_del_rt() when trying to lock
rt6i_table->tb6_lock.

Beside, when purging a prefix, blakhole and prohibited entries
should not be selected because they are not what we are looking
for.

We fix this by adding two new lookup flags (RT6_LOOKUP_F_NO_BLK_HOLE
and RT6_LOOKUP_F_NO_PROHIBIT) in order to ensure that such entries
are skipped during lookup and that the correct entry is returned.

[v2]: use 'goto out;' instead of 'goto again;' to avoid unnecessary
oprations on rt (as suggested by Eric Dumazet).

Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
---
 include/net/ip6_route.h |    2 ++
 net/ipv6/addrconf.c     |    4 +++-
 net/ipv6/fib6_rules.c   |    4 ++++
 3 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 27d8318..3c93743 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -30,6 +30,8 @@ struct route_info {
 #define RT6_LOOKUP_F_SRCPREF_TMP	0x00000008
 #define RT6_LOOKUP_F_SRCPREF_PUBLIC	0x00000010
 #define RT6_LOOKUP_F_SRCPREF_COA	0x00000020
+#define RT6_LOOKUP_F_NO_BLK_HOLE	0x00000040
+#define RT6_LOOKUP_F_NO_PROHIBIT	0x00000080
 
 /*
  * rt6_srcprefs2flags() and rt6_flags2srcprefs() translate
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 408cac4a..1891e23 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -948,7 +948,9 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		fl6.flowi6_oif = ifp->idev->dev->ifindex;
 		fl6.daddr = prefix;
 		rt = (struct rt6_info *)ip6_route_lookup(net, &fl6,
-							 RT6_LOOKUP_F_IFACE);
+						RT6_LOOKUP_F_IFACE |
+						RT6_LOOKUP_F_NO_BLK_HOLE |
+						RT6_LOOKUP_F_NO_PROHIBIT);
 
 		if (rt != net->ipv6.ip6_null_entry &&
 		    addrconf_is_prefix_route(rt)) {
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 2e1a432..9b48128 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -64,9 +64,13 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 		goto discard_pkt;
 	default:
 	case FR_ACT_BLACKHOLE:
+		if (flags & RT6_LOOKUP_F_NO_BLK_HOLE)
+			goto out;
 		rt = net->ipv6.ip6_blk_hole_entry;
 		goto discard_pkt;
 	case FR_ACT_PROHIBIT:
+		if (flags & RT6_LOOKUP_F_NO_PROHIBIT)
+			goto out;
 		rt = net->ipv6.ip6_prohibit_entry;
 		goto discard_pkt;
 	}
-- 
1.7.2.5
