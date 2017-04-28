From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] xfrm: fix GRO for !CONFIG_NETFILTER
Date: Fri, 28 Apr 2017 11:14:33 +0200
Message-ID: <1493370873-30836-3-git-send-email-steffen.klassert@secunet.com>
References: <1493370873-30836-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58340 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164565AbdD1Jty (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 05:49:54 -0400
In-Reply-To: <1493370873-30836-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>

In xfrm_input() when called from GRO, async == 0, and we end up
skipping the processing in xfrm4_transport_finish(). GRO path will
always skip the NF_HOOK, so we don't need the special-case for
!NETFILTER during GRO processing.

Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 46bdb4f..e23570b 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -395,7 +395,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		if (xo)
 			xfrm_gro = xo->flags & XFRM_GRO;
 
-		err = x->inner_mode->afinfo->transport_finish(skb, async);
+		err = x->inner_mode->afinfo->transport_finish(skb, xfrm_gro || async);
 		if (xfrm_gro) {
 			skb_dst_drop(skb);
 			gro_cells_receive(&gro_cells, skb);
-- 
2.7.4
