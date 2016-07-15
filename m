From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] bnxt_en: Fix potential race condition in bnxt_tx_enable()
Date: Fri, 15 Jul 2016 16:42:01 -0700
Message-ID: <1468626125-31732-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Michael Chan <michael.chan@broadcom.com>,
	Jeffrey Huang <huangjw@broadcom.com>,
	linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

txr->dev_state is always manipulated after acquiring the transmit queue
lock, except in bnxt_tx_enable(), which seems suspicious here, so also
acquire the transmit queue lock before changing the value.

Reported-by: coverity (CID 1339583)
Fixes: c0c050c58d840 ("bnxt_en: New Broadcom ethernet driver.")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c777cde85ce4..904c2a8ece12 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4599,7 +4599,9 @@ static void bnxt_tx_enable(struct bnxt *bp)
 	for (i = 0; i < bp->tx_nr_rings; i++) {
 		txr = &bp->tx_ring[i];
 		txq = netdev_get_tx_queue(bp->dev, i);
+		__netif_tx_lock(txq, smp_processor_id());
 		txr->dev_state = 0;
+		__netif_tx_unlock(txq);
 	}
 	netif_tx_wake_all_queues(bp->dev);
 	if (bp->link_info.link_up)
-- 
2.7.4
