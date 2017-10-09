From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net] ipv4: Fix traffic triggered IPsec connections.
Date: Mon, 9 Oct 2017 08:43:55 +0200
Message-ID: <20171009064355.GI3149@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tobias Brunner <tobias@strongswan.org>,
        Wei Wang <weiwan@google.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:48092 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753823AbdJIGn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 02:43:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent patch removed the dst_free() on the allocated
dst_entry in ipv4_blackhole_route(). The dst_free() marked the
dst_entry as dead and added it to the gc list. I.e. it was setup
for a one time usage. As a result we may now have a blackhole
route cached at a socket on some IPsec scenarios. This makes the
connection unusable.

Fix this by marking the dst_entry directly at allocation time
as 'dead', so it is used only once.

Fixes: b838d5e1c5b6 ("ipv4: mark DST_NOGC and remove the operation of dst_free()")
Reported-by: Tobias Brunner <tobias@strongswan.org>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ac6fde5..3d9f1c2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2513,7 +2513,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 	struct rtable *ort = (struct rtable *) dst_orig;
 	struct rtable *rt;
 
-	rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, DST_OBSOLETE_NONE, 0);
+	rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, DST_OBSOLETE_DEAD, 0);
 	if (rt) {
 		struct dst_entry *new = &rt->dst;
 
-- 
2.7.4
