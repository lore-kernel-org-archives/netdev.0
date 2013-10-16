From: Jimmy Perchet <jimmy.perchet@parrot.com>
Subject: [PATCH RFC 3/5] net:stmmac: ensure we reclaim all dirty descriptors.
Date: Wed, 16 Oct 2013 17:24:10 +0200
Message-ID: <1381937052-8999-4-git-send-email-jimmy.perchet@parrot.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jimmy Perchet <jimmy.perchet@parrot.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co202.xi-lite.net ([149.6.83.202]:60750 "EHLO co202.xi-lite.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760757Ab3JPPj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 11:39:27 -0400
In-Reply-To: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On low speed link (10MBit/s), some TX descriptors can remain dirty
if the tx coalescence timer expires before they were treated. Re-arm timer
in this case.

Signed-off-by: Jimmy Perchet <jimmy.perchet@parrot.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0015175..af04b5d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1284,8 +1284,12 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			p = priv->dma_tx + entry;
 
 		/* Check if the descriptor is owned by the DMA. */
-		if (priv->hw->desc->get_tx_owner(p))
+		if (priv->hw->desc->get_tx_owner(p)) {
+			/* Be sure to harvest remaining descriptor. */
+			mod_timer(&priv->txtimer,
+			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
 			break;
+		}
 
 		/* Verify tx error by looking at the last segment. */
 		last = priv->hw->desc->get_tx_ls(p);
-- 
1.8.1.2
