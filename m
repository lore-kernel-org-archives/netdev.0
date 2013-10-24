From: Alistair Popple <alistair@popple.id.au>
Subject: [PATCH] ibm emac: Don't call napi_complete if napi_reschedule failed
Date: Thu, 24 Oct 2013 14:36:20 +1100
Message-ID: <1382585780-13244-1-git-send-email-alistair@popple.id.au>
Cc: benh@kernel.crashing.org, Alistair Popple <alistair@popple.id.au>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:52891 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753672Ab3JXDia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:38:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug which would trigger the BUG_ON() at
net/core/dev.c:4156. It was found that this was due to napi_complete
being called even when the corresponding call to napi_reschedule had
failed.

This patch ensures that we only contine processing rotting packets in
the current mal_poll call if we are not already on the polling list.
It also adds locking calls to protect the read-write-modify of the
MAL_CFG DCR.

Signed-off-by: Alistair Popple <alistair@popple.id.au>
---
 drivers/net/ethernet/ibm/emac/mal.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 856ea66..b10ad5d 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -263,7 +263,9 @@ static inline void mal_schedule_poll(struct mal_instance *mal)
 {
 	if (likely(napi_schedule_prep(&mal->napi))) {
 		MAL_DBG2(mal, "schedule_poll" NL);
+		spin_lock(&mal->lock);
 		mal_disable_eob_irq(mal);
+		spin_unlock(&mal->lock);
 		__napi_schedule(&mal->napi);
 	} else
 		MAL_DBG2(mal, "already in poll" NL);
@@ -442,17 +444,14 @@ static int mal_poll(struct napi_struct *napi, int budget)
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
+			spin_lock_irqsave(&mal->lock, flags);
+			mal_disable_eob_irq(mal);
+			spin_unlock_irqrestore(&mal->lock, flags);
+			goto again;
 		}
-		mc->ops->poll_tx(mc->dev);
 	}
 
  more_work:
-- 
1.7.10.4
