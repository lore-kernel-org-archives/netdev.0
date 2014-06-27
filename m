From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 12/30] net: fec: ensure fec_enet_free_buffers() properly
 cleans the rings
Date: Fri, 27 Jun 2014 16:19:54 +0100
Message-ID: <E1X0XwQ-0001Na-Kg@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45210 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754150AbaF0PT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:19:56 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that we do not double-free any allocations, and that any transmit
skbuffs are properly freed when we clean up the rings.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9c5570a3e32e..8024b7a8e7f4 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2079,8 +2079,14 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 	}
 
 	bdp = fep->tx_bd_base;
-	for (i = 0; i < fep->tx_ring_size; i++)
+	for (i = 0; i < fep->tx_ring_size; i++) {
 		kfree(fep->tx_bounce[i]);
+		fep->tx_bounce[i] = NULL;
+		skb = fep->tx_skbuff[i];
+		fep->tx_skbuff[i] = NULL;
+		if (skb)
+			dev_kfree_skb(skb);
+	}
 }
 
 static int fec_enet_alloc_buffers(struct net_device *ndev)
-- 
1.8.3.1
