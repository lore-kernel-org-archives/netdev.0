From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/8] xfrm6: Fix CHECKSUM_COMPLETE after IPv6 header push
Date: Mon, 21 Aug 2017 07:49:28 +0200
Message-ID: <1503294573-10206-4-git-send-email-steffen.klassert@secunet.com>
References: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34906 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751081AbdHUFtm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 01:49:42 -0400
In-Reply-To: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yossi Kuperman <yossiku@mellanox.com>

xfrm6_transport_finish rebuilds the IPv6 header based on the
original one and pushes it back without fixing skb->csum.
Therefore, CHECKSUM_COMPLETE is no longer valid and the packet
gets dropped.

Fix skb->csum by calling skb_postpush_rcsum.

Note: A valid IPv4 header has checksum 0, unlike IPv6. Thus,
the change is not needed in the sibling xfrm4_transport_finish
function.

Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_input.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 3ef5d91..f95943a 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -34,6 +34,7 @@ EXPORT_SYMBOL(xfrm6_rcv_spi);
 int xfrm6_transport_finish(struct sk_buff *skb, int async)
 {
 	struct xfrm_offload *xo = xfrm_offload(skb);
+	int nhlen = skb->data - skb_network_header(skb);
 
 	skb_network_header(skb)[IP6CB(skb)->nhoff] =
 		XFRM_MODE_SKB_CB(skb)->protocol;
@@ -43,8 +44,9 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 		return 1;
 #endif
 
-	__skb_push(skb, skb->data - skb_network_header(skb));
+	__skb_push(skb, nhlen);
 	ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
+	skb_postpush_rcsum(skb, skb_network_header(skb), nhlen);
 
 	if (xo && (xo->flags & XFRM_GRO)) {
 		skb_mac_header_rebuild(skb);
-- 
2.7.4
