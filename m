From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/6] xfrm6: Fix IPv6 payload_len in xfrm6_transport_finish
Date: Fri, 23 Jun 2017 09:06:33 +0200
Message-ID: <1498201594-10835-6-git-send-email-steffen.klassert@secunet.com>
References: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47080 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751240AbdFWHGn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 03:06:43 -0400
In-Reply-To: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yossi Kuperman <yossiku@mellanox.com>

IPv6 payload length indicates the size of the payload, including any
extension headers.

In xfrm6_transport_finish, ipv6_hdr(skb)->payload_len is set to the
payload size only, regardless of the presence of any extension headers.
After ESP GRO transport mode decapsulation, ipv6_rcv trims the packet
according to the wrong payload_len, thus corrupting the packet.

Set payload_len to account for extension headers as well.

Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 08a807b..3ef5d91 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -43,8 +43,8 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 		return 1;
 #endif
 
-	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
+	ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 
 	if (xo && (xo->flags & XFRM_GRO)) {
 		skb_mac_header_rebuild(skb);
-- 
2.7.4
