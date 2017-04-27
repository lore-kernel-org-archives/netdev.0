From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] xfrm: fix GRO for !CONFIG_NETFILTER
Date: Thu, 27 Apr 2017 12:03:37 +0200
Message-ID: <f04ee7d4593b4eaf3f7fe19fddbf111da81261c7.1493287089.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39532 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751209AbdD0KDw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 06:03:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In xfrm_input() when called from GRO, async == 0, and we end up
skipping the processing in xfrm4_transport_finish(). GRO path will
always skip the NF_HOOK, so we don't need the special-case for
!NETFILTER during GRO processing.

Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/xfrm/xfrm_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 46bdb4fbed0b..e23570b647ae 100644
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
2.12.2
