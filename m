From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net] ipv6: Fix traffic triggered IPsec connections.
Date: Mon, 9 Oct 2017 08:39:43 +0200
Message-ID: <20171009063943.GG3149@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tobias Brunner <tobias@strongswan.org>,
        Wei Wang <weiwan@google.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48020 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751636AbdJIGjp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 02:39:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent patch removed the dst_free() on the allocated
dst_entry in ipv6_blackhole_route(). The dst_free() marked
the dst_entry as dead and added it to the gc list. I.e. it
was setup for a one time usage. As a result we may now have
a blackhole route cached at a socket on some IPsec scenarios.
This makes the connection unusable.

Fix this by marking the dst_entry directly at allocation time
as 'dead', so it is used only once.

Fixes: 587fea741134 ("ipv6: mark DST_NOGC and remove the operation of dst_free()")
Reported-by: Tobias Brunner <tobias@strongswan.org>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 26cc9f4..a96d5b3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1325,7 +1325,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 	struct dst_entry *new = NULL;
 
 	rt = dst_alloc(&ip6_dst_blackhole_ops, loopback_dev, 1,
-		       DST_OBSOLETE_NONE, 0);
+		       DST_OBSOLETE_DEAD, 0);
 	if (rt) {
 		rt6_info_init(rt);
 
-- 
2.7.4
