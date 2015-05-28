From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/7] xfrm: slightly optimise xfrm_input
Date: Thu, 28 May 2015 08:25:51 +0200
Message-ID: <1432794354-19391-5-git-send-email-steffen.klassert@secunet.com>
References: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50001 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751871AbbE1G0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 02:26:24 -0400
In-Reply-To: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Check x->km.state with XFRM_STATE_ACQ only when state is not
XFRM_STAT_VALID, not everytime

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 459796a..1858a45f 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -239,13 +239,13 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		skb->sp->xvec[skb->sp->len++] = x;
 
 		spin_lock(&x->lock);
-		if (unlikely(x->km.state == XFRM_STATE_ACQ)) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMACQUIREERROR);
-			goto drop_unlock;
-		}
 
 		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEINVALID);
+			if (x->km.state == XFRM_STATE_ACQ)
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMACQUIREERROR);
+			else
+				XFRM_INC_STATS(net,
+					       LINUX_MIB_XFRMINSTATEINVALID);
 			goto drop_unlock;
 		}
 
-- 
1.9.1
