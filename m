From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] hp100: fix an skb->len race
Date: Mon, 20 Jun 2011 00:43:33 +0200
Message-ID: <1308523413.3539.97.camel@edumazet-laptop>
References: <1b5632e5cd90ed390245f3d1264e42fdd760dd7e.1308481492.git.richard.cochran@omicron.at>
	 <20110619181740.GC3594@riccoc20.at.omicron.at>
	 <1308508398.3539.80.camel@edumazet-laptop>
	 <20110619.120536.1593516819440469613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38251 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754901Ab1FSWnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 18:43:41 -0400
Received: by wyb38 with SMTP id 38so1300521wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 15:43:40 -0700 (PDT)
In-Reply-To: <20110619.120536.1593516819440469613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As soon as skb is given to hardware and spinlock released, TX completion
can free skb under us. Therefore, we should update netdev stats before
spinlock release.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/hp100.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 8e10d2f..c3ecb11 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -1580,12 +1580,12 @@ static netdev_tx_t hp100_start_xmit_bm(struct sk_buff *skb,
 	hp100_outl(ringptr->pdl_paddr, TX_PDA_L);	/* Low Prio. Queue */
 
 	lp->txrcommit++;
-	spin_unlock_irqrestore(&lp->lock, flags);
 
-	/* Update statistics */
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
+	spin_unlock_irqrestore(&lp->lock, flags);
+
 	return NETDEV_TX_OK;
 
 drop:


