From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: dnet: fix dnet_poll()
Date: Sun, 11 Jan 2015 11:02:32 -0800
Message-ID: <1421002952.5947.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:59228 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbbAKTCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 14:02:34 -0500
Received: by mail-ie0-f174.google.com with SMTP id at20so22360154iec.5
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2015 11:02:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A NAPI poll() handler is supposed to return exactly the budget when/if
napi_complete() has not been called.

It is also supposed to return number of frames that were received, so
that netdev_budget can have a meaning.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note : Untested patch, but this driver seems pretty buggy, not sure if
anyone uses it.

 drivers/net/ethernet/dnet.c |   18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index a379c3e4b57f..13d00a38a5bd 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -398,13 +398,8 @@ static int dnet_poll(struct napi_struct *napi, int budget)
 		 * break out of while loop if there are no more
 		 * packets waiting
 		 */
-		if (!(dnet_readl(bp, RX_FIFO_WCNT) >> 16)) {
-			napi_complete(napi);
-			int_enable = dnet_readl(bp, INTR_ENB);
-			int_enable |= DNET_INTR_SRC_RX_CMDFIFOAF;
-			dnet_writel(bp, int_enable, INTR_ENB);
-			return 0;
-		}
+		if (!(dnet_readl(bp, RX_FIFO_WCNT) >> 16))
+			break;
 
 		cmd_word = dnet_readl(bp, RX_LEN_FIFO);
 		pkt_len = cmd_word & 0xFFFF;
@@ -433,20 +428,17 @@ static int dnet_poll(struct napi_struct *napi, int budget)
 			       "size %u.\n", dev->name, pkt_len);
 	}
 
-	budget -= npackets;
-
 	if (npackets < budget) {
 		/* We processed all packets available.  Tell NAPI it can
-		 * stop polling then re-enable rx interrupts */
+		 * stop polling then re-enable rx interrupts.
+		 */
 		napi_complete(napi);
 		int_enable = dnet_readl(bp, INTR_ENB);
 		int_enable |= DNET_INTR_SRC_RX_CMDFIFOAF;
 		dnet_writel(bp, int_enable, INTR_ENB);
-		return 0;
 	}
 
-	/* There are still packets waiting */
-	return 1;
+	return npackets;
 }
 
 static irqreturn_t dnet_interrupt(int irq, void *dev_id)
