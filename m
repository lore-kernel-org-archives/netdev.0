From: Alistair Popple <alistair@popple.id.au>
Subject: [PATCH 1/2] ibm emac: Don't call napi_complete if napi_reschedule failed
Date: Wed, 30 Oct 2013 10:50:37 +1100
Message-ID: <1383090638-21526-1-git-send-email-alistair@popple.id.au>
Cc: benh@kernel.crashing.org, Alistair Popple <alistair@popple.id.au>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:41488 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751369Ab3J2X5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 19:57:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug which would trigger the BUG_ON() at
net/core/dev.c:4156. It was found that this was due to continuing
processing in the current poll call even when the call to
napi_reschedule failed, indicating the device was already on the
polling list. This resulted in an extra call to napi_complete which
triggered the BUG_ON().

This patch ensures that we only contine processing rotting packets in
the current mal_poll call if we are not already on the polling list.

Signed-off-by: Alistair Popple <alistair@popple.id.au>
---
 drivers/net/ethernet/ibm/emac/mal.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 856ea66..dcb623a 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -442,15 +442,11 @@ static int mal_poll(struct napi_struct *napi, int budget)
 		if (unlikely(mc->ops->peek_rx(mc->dev) ||
 			     test_bit(MAL_COMMAC_RX_STOPPED, &mc->flags))) {
 			MAL_DBG2(mal, "rotting packet" NL);
-			if (napi_reschedule(napi))
-				mal_disable_eob_irq(mal);
-			else
-				MAL_DBG2(mal, "already in poll list" NL);
-
-			if (budget > 0)
-				goto again;
-			else
+			if (!napi_reschedule(napi))
 				goto more_work;
+
+			mal_disable_eob_irq(mal);
+			goto again;
 		}
 		mc->ops->poll_tx(mc->dev);
 	}
-- 
1.7.10.4
