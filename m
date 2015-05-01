From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: ipv4: route: Fix sending IGMP messages with link address
Date: Fri,  1 May 2015 16:39:54 +0200
Message-ID: <1430491194-16615-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45318 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345AbbEAOoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2015 10:44:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In setups with a global scope address on an interface, and a lesser
scope address on an interface sending IGMP reports, the reports can be
sent using the other interfaces global scope address rather than the
local interface address. RFC 2236 suggests:

     Ignore the Report if you cannot identify the source address of
     the packet as belonging to a subnet assigned to the interface on
     which the packet was received.

since such reports could be forged.

Look at the protocol when deciding if a RT_SCOPE_LINK address should
be used for the packet.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

Not sure what to use for a Fixes: tag. All 3.x kernels have this
problem, and it seems to go back a long way.


 net/ipv4/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a78540f28276..9aa43c4dc2a7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2096,7 +2096,8 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 			goto out;
 		}
 		if (ipv4_is_local_multicast(fl4->daddr) ||
-		    ipv4_is_lbcast(fl4->daddr)) {
+		    ipv4_is_lbcast(fl4->daddr) ||
+		    fl4->flowi4_proto == IPPROTO_IGMP) {
 			if (!fl4->saddr)
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_LINK);
-- 
2.1.4
