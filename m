From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] bnxt_en: Remove locking around txr->dev_state
Date: Mon, 18 Jul 2016 13:02:47 -0700
Message-ID: <1468872171-10009-1-git-send-email-f.fainelli@gmail.com>
References: <1468626125-31732-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Michael Chan <michael.chan@broadcom.com>,
	Jeffrey Huang <huangjw@broadcom.com>,
	linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468626125-31732-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

txr->dev_state was not consistently manipulated with the acquisition of
the per-queue lock, after further inspection the lock does not seem
necessary, either the value is read as BNXT_DEV_STATE_CLOSING or 0.

Reported-by: coverity (CID 1339583)
Fixes: c0c050c58d840 ("bnxt_en: New Broadcom ethernet driver.")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- remove locking in bnxt_tx_disable() as recommended by Michael

 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c777cde85ce4..15e1d1885919 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4580,9 +4580,7 @@ static void bnxt_tx_disable(struct bnxt *bp)
 		for (i = 0; i < bp->tx_nr_rings; i++) {
 			txr = &bp->tx_ring[i];
 			txq = netdev_get_tx_queue(bp->dev, i);
-			__netif_tx_lock(txq, smp_processor_id());
 			txr->dev_state = BNXT_DEV_STATE_CLOSING;
-			__netif_tx_unlock(txq);
 		}
 	}
 	/* Stop all TX queues */
-- 
2.7.4
