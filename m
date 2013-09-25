From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in ip_tunnel_xmit
Date: Wed, 25 Sep 2013 07:54:19 +0200
Message-ID: <20130925055418.GV7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49284 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107Ab3IYFyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 01:54:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We might extend the used aera of a skb beyond the total
headroom when we install the ipip header. Fix this by
calling skb_cow_head() unconditionally.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_tunnel.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index ac9fabe..b8ce640 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -641,13 +641,13 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	max_headroom = LL_RESERVED_SPACE(rt->dst.dev) + sizeof(struct iphdr)
 			+ rt->dst.header_len;
-	if (max_headroom > dev->needed_headroom) {
+	if (max_headroom > dev->needed_headroom)
 		dev->needed_headroom = max_headroom;
-		if (skb_cow_head(skb, dev->needed_headroom)) {
-			dev->stats.tx_dropped++;
-			dev_kfree_skb(skb);
-			return;
-		}
+
+	if (skb_cow_head(skb, dev->needed_headroom)) {
+		dev->stats.tx_dropped++;
+		dev_kfree_skb(skb);
+		return;
 	}
 
 	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, protocol,
-- 
1.7.9.5
