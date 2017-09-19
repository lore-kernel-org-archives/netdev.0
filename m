From: Christian Lamparter <chunkeey@googlemail.com>
Subject: [PATCH] net: emac: Fix napi poll list corruption
Date: Tue, 19 Sep 2017 19:35:18 +0200
Message-ID: <20170919173518.3694-1-chunkeey@googlemail.com>
Cc: "David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37252 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdISRfV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:35:21 -0400
Received: by mail-wm0-f65.google.com with SMTP id f4so278635wmh.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:35:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is pretty much a carbon copy of
commit 3079c652141f ("caif: Fix napi poll list corruption")
with "caif" replaced by "emac".

The commit d75b1ade567f ("net: less interrupt masking in NAPI")
breaks emac.

It is now required that if the entire budget is consumed when poll
returns, the napi poll_list must remain empty.  However, like some
other drivers emac tries to do a last-ditch check and if there is
more work it will call napi_reschedule and then immediately process
some of this new work.  Should the entire budget be consumed while
processing such new work then we will violate the new caller
contract.

This patch fixes this by not touching any work when we reschedule
in emac.

Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
---
 drivers/net/ethernet/ibm/emac/mal.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 2c74baa2398a..fff09dcf9e34 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -402,7 +402,7 @@ static int mal_poll(struct napi_struct *napi, int budget)
 	unsigned long flags;
 
 	MAL_DBG2(mal, "poll(%d)" NL, budget);
- again:
+
 	/* Process TX skbs */
 	list_for_each(l, &mal->poll_list) {
 		struct mal_commac *mc =
@@ -451,7 +451,6 @@ static int mal_poll(struct napi_struct *napi, int budget)
 			spin_lock_irqsave(&mal->lock, flags);
 			mal_disable_eob_irq(mal);
 			spin_unlock_irqrestore(&mal->lock, flags);
-			goto again;
 		}
 		mc->ops->poll_tx(mc->dev);
 	}
-- 
2.14.1
