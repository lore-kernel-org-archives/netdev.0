From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/8] xfrm: Clear RX SKB secpath xfrm_offload
Date: Mon, 21 Aug 2017 07:49:31 +0200
Message-ID: <1503294573-10206-7-git-send-email-steffen.klassert@secunet.com>
References: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34942 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751347AbdHUFtn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 01:49:43 -0400
In-Reply-To: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

If an incoming packet undergoes XFRM crypto-offload, its secpath is
filled with xfrm_offload struct denoting offload information.

If the SKB is then forwarded to a device which supports crypto-
offload, the stack wrongfully attempts to offload it (even though
the output SA may not exist on the device) due to the leftover
secpath xo.

Clear the ingress xo by zeroizing secpath->olen just before
delivering the decapsulated packet to the network stack.

Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 923205e..f07eec5 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -424,6 +424,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	nf_reset(skb);
 
 	if (decaps) {
+		skb->sp->olen = 0;
 		skb_dst_drop(skb);
 		gro_cells_receive(&gro_cells, skb);
 		return 0;
@@ -434,6 +435,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		err = x->inner_mode->afinfo->transport_finish(skb, xfrm_gro || async);
 		if (xfrm_gro) {
+			skb->sp->olen = 0;
 			skb_dst_drop(skb);
 			gro_cells_receive(&gro_cells, skb);
 			return err;
-- 
2.7.4
