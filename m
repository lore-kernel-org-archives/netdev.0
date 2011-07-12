From: Andre Heider <a.heider@gmail.com>
Subject: [PATCH 2/3] ps3_gelic: Fix start_xmit kick error path
Date: Tue, 12 Jul 2011 22:13:25 +0200
Message-ID: <1310501606-829-3-git-send-email-a.heider@gmail.com>
References: <1310501606-829-1-git-send-email-a.heider@gmail.com>
Cc: netdev@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org,
	Andre Heider <a.heider@gmail.com>
To: Geoff Levand <geoff@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45807 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147Ab1GLUNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 16:13:50 -0400
Received: by mail-bw0-f46.google.com with SMTP id 5so4318012bwd.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 13:13:50 -0700 (PDT)
In-Reply-To: <1310501606-829-1-git-send-email-a.heider@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Revert to a proper state when gelic_card_kick_txdma() fails:
- Don't trigger BUG_ON when releasing the unsent tx descriptor
- Reset the tx chain head since the tail was not modified and
  hence not in sync
- Unlink the released descriptor bus address from its predecessor

Signed-off-by: Andre Heider <a.heider@gmail.com>
---
 drivers/net/ps3_gelic_net.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 9652d10..94422fc 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -897,12 +897,16 @@ int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (gelic_card_kick_txdma(card, descr)) {
 		/*
 		 * kick failed.
-		 * release descriptors which were just prepared
+		 * release descriptor which was just prepared
 		 */
 		netdev->stats.tx_dropped++;
+		/* don't trigger BUG_ON() in gelic_descr_release_tx */
+		descr->data_status = cpu_to_be32(GELIC_DESCR_TX_TAIL);
 		gelic_descr_release_tx(card, descr);
-		gelic_descr_release_tx(card, descr->next);
-		card->tx_chain.tail = descr->next->next;
+		/* reset head */
+		card->tx_chain.head = descr;
+		/* reset hw termination */
+		descr->prev->next_descr_addr = 0;
 		dev_info(ctodev(card), "%s: kick failure\n", __func__);
 	}
 
-- 
1.7.5.4

