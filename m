From: "govindarajulu.v" <govindarajulu90@gmail.com>
Subject: [PATCH net-next] net: netdev_pick_tx: use get_xps_q if xps map is set
Date: Fri, 17 May 2013 14:18:48 +0530
Message-ID: <1368780528-15209-1-git-send-email-govindarajulu90@gmail.com>
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"govindarajulu.v" <govindarajulu90@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "govindarajulu.v" <govindarajulu90@gmail.com>

netdev_pick_tx ignores the xps map configuration if netdev->ndo_select_queue
is defined. Most of the drivers define ndo_select_queue. The problem with this
is, if admin wants kernel to pick tx queue based on xps map (instead of driver
defined ndo_select_queue), he has to netdev->ndo_select_queue = NULL, compile
and reload.

This patch fixes it by checking if dev->xps_maps is defined. If yes it
proceeds with get_xps_queue. If not it proceeds with netdev->ndo_select_queue
(if defined).

Compile test only.

Signed-off-by: govindarajulu.v <govindarajulu90@gmail.com>
---
 net/core/flow_dissector.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 00ee068..b2e3c81 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -368,10 +368,11 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 
 	if (dev->real_num_tx_queues != 1) {
 		const struct net_device_ops *ops = dev->netdev_ops;
-		if (ops->ndo_select_queue)
-			queue_index = ops->ndo_select_queue(dev, skb);
-		else
+		if (rcu_access_pointer(dev->xps_maps) ||
+		    !ops->ndo_select_queue)
 			queue_index = __netdev_pick_tx(dev, skb);
+		else
+			queue_index = ops->ndo_select_queue(dev, skb);
 		queue_index = dev_cap_txqueue(dev, queue_index);
 	}
 
-- 
1.8.2.3
