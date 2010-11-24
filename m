From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 5/8] ethoc: Double check pending RX packet
Date: Wed, 24 Nov 2010 14:40:55 +0100
Message-ID: <1290606058-26703-6-git-send-email-jonas@southpole.se>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38150 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306Ab0KXOCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 09:02:49 -0500
In-Reply-To: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An interrupt may occur between checking bd.stat and clearing the
interrupt source register which would result in the packet going totally
unnoticed as the interrupt will be missed.  Double check bd.stat after
clearing the interrupt source register to guard against such an
occurrence.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 7d1b5d8..5afa934 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -417,8 +417,20 @@ static int ethoc_rx(struct net_device *dev, int limit)
 
 		entry = priv->num_tx + (priv->cur_rx % priv->num_rx);
 		ethoc_read_bd(priv, entry, &bd);
-		if (bd.stat & RX_BD_EMPTY)
-			break;
+		if (bd.stat & RX_BD_EMPTY) {
+			ethoc_ack_irq(priv, INT_MASK_RX);
+			/* If packet (interrupt) came in between checking
+			 * BD_EMTPY and clearing the interrupt source, then we
+			 * risk missing the packet as the RX interrupt won't
+			 * trigger right away when we reenable it; hence, check
+			 * BD_EMTPY here again to make sure there isn't such a
+			 * packet waiting for us...
+			 */
+			ethoc_read_bd(priv, entry, &bd);
+			if (bd.stat & RX_BD_EMPTY) 
+				break;
+
+		}
 
 		if (ethoc_update_rx_stats(priv, &bd) == 0) {
 			int size = bd.stat >> 16;
-- 
1.7.1

