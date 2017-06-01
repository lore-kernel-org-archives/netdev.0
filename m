From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net] bnx2x: Fix Multi-Cos
Date: Thu, 1 Jun 2017 15:57:56 +0300
Message-ID: <20170601125756.25019-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0042.outbound.protection.outlook.com ([104.47.37.42]:27835
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750952AbdFAM6U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:58:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apparently multi-cos isn't working for bnx2x quite some time -
driver implements ndo_select_queue() to allow queue-selection
for FCoE, but the regular L2 flow would cause it to modulo the
fallback's result by the number of queues.
The fallback would return a queue matching the needed tc
[via __skb_tx_hash()], but since the modulo is by the number of TSS
queues where number of TCs is not accounted, transmission would always
be done by a queue configured into using TC0.

Fixes: ada7c19e6d27 ("bnx2x: use XPS if possible for bnx2x_select_queue instead of pure hash")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index eccb3d1..5f49334 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1926,7 +1926,7 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb,
 	}
 
 	/* select a non-FCoE queue */
-	return fallback(dev, skb) % BNX2X_NUM_ETH_QUEUES(bp);
+	return fallback(dev, skb) % (BNX2X_NUM_ETH_QUEUES(bp) * bp->max_cos);
 }
 
 void bnx2x_set_num_queues(struct bnx2x *bp)
-- 
2.7.4
