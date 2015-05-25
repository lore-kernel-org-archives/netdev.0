From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net 3/3] net: dp83640: fix improper double spin locking.
Date: Mon, 25 May 2015 11:55:45 +0200
Message-ID: <7b36ba2c7b54eb99bc5f879e17c17e1f9550bc10.1432547381.git.richardcochran@gmail.com>
References: <cover.1432547381.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Christian Riesch <christian.riesch@omicron.at>,
	Stefan Sorensen <stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36773 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbbEYJzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 05:55:54 -0400
Received: by wizk4 with SMTP id k4so43252687wiz.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 02:55:53 -0700 (PDT)
In-Reply-To: <cover.1432547381.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pair of nested spin locks was introduced in commit 63502b8d0
"dp83640: Fix receive timestamp race condition".

Unfortunately the 'flags' parameter was reused for the inner lock,
clobbering the originally saved IRQ state.  This patch fixes the issue
by changing the inner lock to plain spin_lock without irqsave.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index e570036..00cb41e 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -846,7 +846,7 @@ static void decode_rxts(struct dp83640_private *dp83640,
 	list_del_init(&rxts->list);
 	phy2rxts(phy_rxts, rxts);
 
-	spin_lock_irqsave(&dp83640->rx_queue.lock, flags);
+	spin_lock(&dp83640->rx_queue.lock);
 	skb_queue_walk(&dp83640->rx_queue, skb) {
 		struct dp83640_skb_info *skb_info;
 
@@ -861,7 +861,7 @@ static void decode_rxts(struct dp83640_private *dp83640,
 			break;
 		}
 	}
-	spin_unlock_irqrestore(&dp83640->rx_queue.lock, flags);
+	spin_unlock(&dp83640->rx_queue.lock);
 
 	if (!shhwtstamps)
 		list_add_tail(&rxts->list, &dp83640->rxts);
-- 
2.1.4
