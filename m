From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCH net-next 2/3] caif: use pskb_put() instead of reimplementing its functionality
Date: Tue,  5 Nov 2013 14:54:10 +0100
Message-ID: <65b1f53cc97c4052e2b0bdaa374267eeb9ec3ed2.1381923854.git.mathias.krause@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org,
	Mathias Krause <mathias.krause@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52547 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754733Ab3KENyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 08:54:24 -0500
In-Reply-To: <cover.1381923854.git.mathias.krause@secunet.com>
In-Reply-To: <cover.1381923854.git.mathias.krause@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com>
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
1.7.2.5
