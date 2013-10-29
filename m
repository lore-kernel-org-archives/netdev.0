From: Alistair Popple <alistair@popple.id.au>
Subject: [PATCH 2/2] ibm emac: Fix locking for enable/disable eob irq
Date: Wed, 30 Oct 2013 10:50:38 +1100
Message-ID: <1383090638-21526-2-git-send-email-alistair@popple.id.au>
References: <1383090638-21526-1-git-send-email-alistair@popple.id.au>
Cc: benh@kernel.crashing.org, Alistair Popple <alistair@popple.id.au>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:41639 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752054Ab3J2X5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 19:57:20 -0400
In-Reply-To: <1383090638-21526-1-git-send-email-alistair@popple.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calls to mal_enable_eob_irq perform a read-write-modify of a dcr to
enable device irqs which is protected by a spin lock. However calls to
mal_disable_eob_irq do not take the corresponding lock.

This patch resolves the problem by ensuring that calls to
mal_disable_eob_irq also take the lock.

Signed-off-by: Alistair Popple <alistair@popple.id.au>
---
 drivers/net/ethernet/ibm/emac/mal.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index dcb623a..2d2e1dd 100644
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
@@ -445,7 +447,9 @@ static int mal_poll(struct napi_struct *napi, int budget)
 			if (!napi_reschedule(napi))
 				goto more_work;
 
+			spin_lock_irqsave(&mal->lock, flags);
 			mal_disable_eob_irq(mal);
+			spin_unlock_irqrestore(&mal->lock, flags);
 			goto again;
 		}
 		mc->ops->poll_tx(mc->dev);
-- 
1.7.10.4
