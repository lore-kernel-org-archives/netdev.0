From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net 1/5] dwc_eth_qos: fix race condition in dwceqos_start_xmit
Date: Mon, 29 Feb 2016 16:22:30 +0100
Message-ID: <1ac5ce059532da7c90fc9dc93fab96d01a9765bf.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Cc: linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>,
	Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rabin Vincent <rabinv@axis.com>

The xmit handler and the tx_reclaim tasklet had a race on the tx_free
variable which could lead to a tx timeout if tx_free was updated after
the tx complete interrupt.

Signed-off-by: Rabin Vincent <rabinv@axis.com>
Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index fc8bbff..926db2d 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2178,12 +2178,10 @@ static int dwceqos_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		((trans.initial_descriptor + trans.nr_descriptors) %
 		 DWCEQOS_TX_DCNT));
 
-	dwceqos_tx_finalize(skb, lp, &trans);
-
-	netdev_sent_queue(ndev, skb->len);
-
 	spin_lock_bh(&lp->tx_lock);
 	lp->tx_free -= trans.nr_descriptors;
+	dwceqos_tx_finalize(skb, lp, &trans);
+	netdev_sent_queue(ndev, skb->len);
 	spin_unlock_bh(&lp->tx_lock);
 
 	ndev->trans_start = jiffies;
-- 
2.1.4
