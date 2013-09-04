From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH] ethernet/arc/arc_emac: optimize the Tx/Tx-reclaim paths a bit
Date: Wed, 4 Sep 2013 18:33:11 +0530
Message-ID: <1378299791-24598-1-git-send-email-vgupta@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	<linux-kernel@vger.kernel.org>, <arc-linux-dev@synopsys.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This came out of staring at code due to recent performance fix.

* TX BD reclaim can call netif_wake_queue() once, outside the loop if
  one/more BDs were freed, NO need to do this each iteration.

* TX need not look at next BD to stop the netif queue. It rather be done
  in the next tx call, when it actually fails as the queue seldom gets
  full but the check nevertheless needs to be done for each packet Tx.
  Profiled this under heavy traffic (big tar file cp, LMBench betworking
  tests) and saw not a single hit to that code.

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
Cc: Alexey Brodkin <abrodkin@synopsys.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: arc-linux-dev@synopsys.com
---
 drivers/net/ethernet/arc/emac_main.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 9e16014..a3dd048 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -179,10 +179,10 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		txbd->info = 0;
 
 		*txbd_dirty = (*txbd_dirty + 1) % TX_BD_NUM;
-
-		if (netif_queue_stopped(ndev))
-			netif_wake_queue(ndev);
 	}
+
+	if (i && netif_queue_stopped(ndev))
+		netif_wake_queue(ndev);
 }
 
 /**
@@ -570,13 +570,6 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	/* Increment index to point to the next BD */
 	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
 
-	/* Get "info" of the next BD */
-	info = &priv->txbd[*txbd_curr].info;
-
-	/* Check if if Tx BD ring is full - next BD is still owned by EMAC */
-	if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC))
-		netif_stop_queue(ndev);
-
 	arc_reg_set(priv, R_STATUS, TXPL_MASK);
 
 	skb_tx_timestamp(skb);
-- 
1.8.1.2
