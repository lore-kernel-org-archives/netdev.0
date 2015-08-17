From: Noam Camus <noamc@ezchip.com>
Subject: [v1 3/6] NET: nps_enet: TX done race condition
Date: Mon, 17 Aug 2015 08:58:36 +0300
Message-ID: <1439791119-26892-4-git-send-email-noamc@ezchip.com>
References: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
 <1439791119-26892-2-git-send-email-noamc@ezchip.com>
 <1439791119-26892-3-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Alexey.Brodkin@synopsys.com>,
	<vgupta@synopsys.com>, <talz@ezchip.com>,
	Noam Camus <noamc@ezchip.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439791119-26892-3-git-send-email-noamc@ezchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>

We need to set tx_skb pointer before send frame.
If we receive interrupt before we set pointer we will try
to free SKB with wrong pointer.
Now we are sure that SKB pointer will never be NULL during
handling TX done and check is removed.

Signed-off-by: Noam Camus <noamc@ezchip.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index af72181..f78ad3d 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -158,11 +158,7 @@ static void nps_enet_tx_handler(struct net_device *ndev)
 		ndev->stats.tx_bytes += tx_ctrl.nt;
 	}
 
-	if (priv->tx_skb) {
-		dev_kfree_skb_irq(priv->tx_skb);
-		priv->tx_skb = NULL;
-	}
-
+	dev_kfree_skb_irq(priv->tx_skb);
 	priv->tx_packet_sent = false;
 
 	if (netif_queue_stopped(ndev))
@@ -531,10 +527,10 @@ static netdev_tx_t nps_enet_start_xmit(struct sk_buff *skb,
 	/* This driver handles one frame at a time  */
 	netif_stop_queue(ndev);
 
-	nps_enet_send_frame(ndev, skb);
-
 	priv->tx_skb = skb;
 
+	nps_enet_send_frame(ndev, skb);
+
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.1
