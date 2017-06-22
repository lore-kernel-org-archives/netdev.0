From: ilant@mellanox.com
Subject: [PATCH net-next 3/4] xfrm6: Fix CHECKSUM_COMPLETE after IPv6 header push
Date: Thu, 22 Jun 2017 15:31:58 +0300
Message-ID: <20170622123159.8348-4-ilant@mellanox.com>
References: <20170622123159.8348-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Yossi Kuperman <yossiku@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10041.outbound.protection.outlook.com ([40.107.1.41]:36016
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751835AbdFVMc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 08:32:26 -0400
In-Reply-To: <20170622123159.8348-1-ilant@mellanox.com>
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
---
 net/ipv6/xfrm6_input.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 3ef5d913e7a3..f95943a13abc 100644
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
2.11.0
