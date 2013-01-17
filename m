From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: check if dereference of ipv6 header is safe
Date: Thu, 17 Jan 2013 04:56:52 +0100
Message-ID: <20130117035652.GB23782@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:32968 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758341Ab3AQD4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 22:56:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ipip6_rcv gets called we are sure that we have a full blown
ipv4 packet header in the linear skb buffer (this is checked by
xfrm4_mode_tunnel_input). Because we dereference fields of the inner
ipv6 header we should actually check for the length of the sum of the
ipv4 and ipv6 header.

If the skb is too short this packet could very well be destined for
another tunnel. So we should notify the caller accordingly (albeit
currently xfrm4_mode_tunnel_input does not care; this could need another
patch).

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/sit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 2b4c15a..389d6e3 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -612,8 +612,8 @@ static int ipip6_rcv(struct sk_buff *skb)
 	struct ip_tunnel *tunnel;
 	int err;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-		goto out;
+	if (!pskb_may_pull(skb, sizeof(struct iphdr) + sizeof(struct ipv6hdr)))
+		return 1;
 
 	iph = ip_hdr(skb);
 
-- 
1.7.11.7
