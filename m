From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Remove a wrong netif_wake_queue() call which triggers BUG_ON
Date: Sat, 20 Feb 2010 00:13:58 +0900
Message-ID: <1266592438-10772-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defer-dn01.ocn.ad.jp ([125.170.100.155]:43490 "EHLO
	defer-dn01.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab0BSP4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 10:56:17 -0500
Received: from mv-drv-hcb003.ocn.ad.jp (mv-drv-hcb003.ocn.ad.jp [118.23.109.133])
	by defer-dn01.ocn.ad.jp (Postfix) with ESMTP id 14C6C812A8
	for <netdev@vger.kernel.org>; Sat, 20 Feb 2010 00:15:41 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netif_wake_queue() is called correctly (i.e. only on !txfull
condition) from txdone routine.  So Unconditional call to the
netif_wake_queue() here is wrong.  This might cause calling of
start_xmit routine on txfull state and trigger BUG_ON.

This bug does not happen when NAPI disabled.  After txdone there
must be at least one free tx slot.  But with NAPI, this is not
true anymore and the BUG_ON can hits on heavy load.

In this driver NAPI was enabled on 2.6.33-rc1 so this is
regression from 2.6.32 kernel.

Reported-by: Ralf Roesch <ralf.roesch@rw-gmbh.de>
Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 75a669d..d71c197 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1437,7 +1437,6 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status, int limit)
 		/* Transmit complete. */
 		lp->lstats.tx_ints++;
 		tc35815_txdone(dev);
-		netif_wake_queue(dev);
 		if (ret < 0)
 			ret = 0;
 	}
-- 
1.5.6.5

