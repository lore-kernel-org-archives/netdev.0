From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 6/12] drivers/net: Add missing unlock
Date: Mon, 29 Mar 2010 17:35:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1003291734460.21896@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:41497 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753779Ab0C2PfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 11:35:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Unlock the lock before leaving the function.

A simplified version of the semantic patch that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r exists@
expression E1;
identifier f;
@@

f (...) { <+...
* spin_lock_irqsave (E1,...);
... when != E1
* return ...;
...+> }
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/sgiseeq.c               |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index ed999d3..37f6a00 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -592,8 +592,10 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Setup... */
 	len = skb->len;
 	if (len < ETH_ZLEN) {
-		if (skb_padto(skb, ETH_ZLEN))
+		if (skb_padto(skb, ETH_ZLEN)) {
+			spin_unlock_irqrestore(&sp->tx_lock, flags);
 			return NETDEV_TX_OK;
+		}
 		len = ETH_ZLEN;
 	}
 
