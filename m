From: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Subject: [RFC PATCH 1/2] ipv6: select oif corresponding to source address
Date: Fri, 1 Nov 2013 18:17:36 +0100
Message-ID: <06F9072B-27A3-4A21-ADE2-A5B3FE817A1F@telecom-bretagne.eu>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zproxy210.enst-bretagne.fr ([192.108.117.8]:48495 "EHLO
	zproxy210.enst-bretagne.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754391Ab3KARZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 13:25:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When selecting the next hop, prefer the interface to which the
source address is associated. This preference fixes problems for
IPv6 hosts in multi-interfaces setup.

In the case where a host has:
* multiple links, each providing internet connectivity
* both links advertising prefix and default route via Router
Advertisements

The current route selection process completly ignores whether or
not the next hop is consistent with the source address. This may
lead to packets being sent with a specific source address on the
wrong link, then dropped by a router enforcing reverse path
filtering.

This fix pre-selects the output interface corresponding to the
source address bound to the socket. The fl6->flowi6_oif
attribute gives to the route selection algorithm an hint about
what interface to choose in case of a tie between several routes
of equal preferences (equal netmask, equal metrics and equal
RFC 4191 preference values).

Signed-off-by: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
---
 net/ipv6/ip6_output.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 91fb4e8..1a05395 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -848,8 +848,14 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 #endif
 	int err;
 
-	if (*dst == NULL)
+	if (*dst == NULL) {
+		struct inet6_ifaddr *ifp;
+		if (!ipv6_addr_any(&fl6->saddr)) {
+			ifp = ipv6_get_ifaddr(net, &fl6->saddr, NULL, 1);
+			fl6->flowi6_oif = ifp->idev->dev->ifindex;
+		}
 		*dst = ip6_route_output(net, sk, fl6);
+	}
 
 	if ((err = (*dst)->error))
 		goto out_err_release;
-- 
1.7.9.5
