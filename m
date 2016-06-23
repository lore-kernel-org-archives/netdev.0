From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net v2] ipv6: enforce egress device match in per table nexthop lookups
Date: Thu, 23 Jun 2016 15:25:09 +0200
Message-ID: <5257997d95ca10b106fd44bcb754233d18587f63.1466687942.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Beniamino Galvani <bgalvani@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026AbcFWNZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 09:25:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

with the commit 8c14586fc320 ("net: ipv6: Use passed in table for
nexthop lookups"), net hop lookup is first performed on route creation
in the passed-in table.
However device match is not enforced in table lookup, so the found
route can be later discarded due to egress device mismatch and no
global lookup will be performed.
This cause the following to fail:

ip link add dummy1 type dummy
ip link add dummy2 type dummy
ip link set dummy1 up
ip link set dummy2 up
ip route add 2001:db8:8086::/48 dev dummy1 metric 20
ip route add 2001:db8:d34d::/64 via 2001:db8:8086::2 dev dummy1 metric 20
ip route add 2001:db8:8086::/48 dev dummy2 metric 21
ip route add 2001:db8:d34d::/64 via 2001:db8:8086::2 dev dummy2 metric 21
RTNETLINK answers: No route to host

This change fixes the issue enforcing device lookup in
ip6_nh_lookup_table()

v1->v2: updated commit message title

Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")
Reported-and-tested-by: Beniamino Galvani <bgalvani@redhat.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 969913d..520b788 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1782,7 +1782,7 @@ static struct rt6_info *ip6_nh_lookup_table(struct net *net,
 	};
 	struct fib6_table *table;
 	struct rt6_info *rt;
-	int flags = 0;
+	int flags = RT6_LOOKUP_F_IFACE;
 
 	table = fib6_get_table(net, cfg->fc_table);
 	if (!table)
-- 
1.8.3.1
