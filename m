From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net v2] tg3: Fix for disallow tx coalescing time to be 0
Date: Thu,  1 Sep 2016 11:28:59 +0200
Message-ID: <1472722139-22806-1-git-send-email-ivecera@redhat.com>
Cc: satish.baddipadige@broadcom.com, siva.kallam@broadcom.com,
        michael.chan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38218 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750813AbcIAJ3C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 05:29:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent commit 087d7a8c9174 "tg3: Fix for diasllow rx coalescing
time to be 0" disallow to set Rx coalescing time to be 0 as this stops
generating interrupts for the incoming packets. I found the zero
Tx coalescing time stops generating interrupts for outgoing packets
as well and fires Tx watchdog later. To avoid this, don't allow to set
Tx coalescing time to 0 and also remove subsequent checks that become
senseless.

Cc: satish.baddipadige@broadcom.com
Cc: siva.kallam@broadcom.com
Cc: michael.chan@broadcom.com
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6592612..a2551bc 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14012,6 +14012,7 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	if ((ec->rx_coalesce_usecs > MAX_RXCOL_TICKS) ||
 	    (!ec->rx_coalesce_usecs) ||
 	    (ec->tx_coalesce_usecs > MAX_TXCOL_TICKS) ||
+	    (!ec->tx_coalesce_usecs) ||
 	    (ec->rx_max_coalesced_frames > MAX_RXMAX_FRAMES) ||
 	    (ec->tx_max_coalesced_frames > MAX_TXMAX_FRAMES) ||
 	    (ec->rx_coalesce_usecs_irq > max_rxcoal_tick_int) ||
@@ -14022,16 +14023,6 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	    (ec->stats_block_coalesce_usecs < min_stat_coal_ticks))
 		return -EINVAL;
 
-	/* No rx interrupts will be generated if both are zero */
-	if ((ec->rx_coalesce_usecs == 0) &&
-	    (ec->rx_max_coalesced_frames == 0))
-		return -EINVAL;
-
-	/* No tx interrupts will be generated if both are zero */
-	if ((ec->tx_coalesce_usecs == 0) &&
-	    (ec->tx_max_coalesced_frames == 0))
-		return -EINVAL;
-
 	/* Only copy relevant parameters, ignore all others. */
 	tp->coal.rx_coalesce_usecs = ec->rx_coalesce_usecs;
 	tp->coal.tx_coalesce_usecs = ec->tx_coalesce_usecs;
-- 
2.7.3
