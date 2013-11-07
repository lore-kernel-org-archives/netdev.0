From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCHv2 next-next 2/3] caif: use pskb_put() instead of reimplementing its functionality
Date: Thu,  7 Nov 2013 14:18:25 +0100
Message-ID: <1383830306-16697-3-git-send-email-mathias.krause@secunet.com>
References: <1383830306-16697-1-git-send-email-mathias.krause@secunet.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Mathias Krause <mathias.krause@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55189 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869Ab3KGNSg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 08:18:36 -0500
In-Reply-To: <1383830306-16697-1-git-send-email-mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove the warning for fragmented packets -- skb_cow_data() will
linearize the buffer, removing all fragments.

Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/caif/cfpkt_skbuff.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index 6493351..1be0b52 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -203,20 +203,10 @@ int cfpkt_add_body(struct cfpkt *pkt, const void *data, u16 len)
 			PKT_ERROR(pkt, "cow failed\n");
 			return -EPROTO;
 		}
-		/*
-		 * Is the SKB non-linear after skb_cow_data()? If so, we are
-		 * going to add data to the last SKB, so we need to adjust
-		 * lengths of the top SKB.
-		 */
-		if (lastskb != skb) {
-			pr_warn("Packet is non-linear\n");
-			skb->len += len;
-			skb->data_len += len;
-		}
 	}
 
 	/* All set to put the last SKB and optionally write data there. */
-	to = skb_put(lastskb, len);
+	to = pskb_put(skb, lastskb, len);
 	if (likely(data))
 		memcpy(to, data, len);
 	return 0;
-- 
1.7.2.3
