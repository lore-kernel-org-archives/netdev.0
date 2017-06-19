From: yossiku@mellanox.com
Subject: [PATCH net 1/2] xfrm6: Fix IPv6 payload_len in xfrm6_transport_finish
Date: Mon, 19 Jun 2017 11:33:20 +0300
Message-ID: <1497861201-30262-1-git-send-email-yossiku@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0071.outbound.protection.outlook.com ([104.47.0.71]:6976
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750952AbdFSIdo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 04:33:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yossi Kuperman <yossiku@mellanox.com>

IPv6 payload length indicates the size of the payload, including any
extension headers. In xfrm6_transport_finish, ipv6_hdr(skb)->payload_len
is set to the payload size only, regardless of the presence of any
extension headers.

After ESP GRO transport mode decapsulation, ipv6_rcv trims the packet
according to the wrong payload_len, thus corrupting the packet.

Set payload_len to account for extension headers as well.

Fixes: 716062fd4c2f ("[IPSEC]: Merge most of the input path")
Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
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
2.8.1
