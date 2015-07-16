From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH] net: netcp: fix improper initialization in netcp_ndo_open()
Date: Thu, 16 Jul 2015 15:32:14 -0400
Message-ID: <1437075134-24423-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The keystone qmss will raise interrupt when packet arrive at the
receive queue. Only control available to avoid interrupt from happening
is to keep the free descriptor queue (FDQ) empty in the receive side.
So the filling of descriptors into the FDQ has to happen after
request_irq() call is made as part of knav_queue_enable_notify(). So
move the function netcp_rxpool_refill() after this call.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 5ec4ed3..ec8ed30 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1617,11 +1617,11 @@ static int netcp_ndo_open(struct net_device *ndev)
 	}
 	mutex_unlock(&netcp_modules_lock);
 
-	netcp_rxpool_refill(netcp);
 	napi_enable(&netcp->rx_napi);
 	napi_enable(&netcp->tx_napi);
 	knav_queue_enable_notify(netcp->tx_compl_q);
 	knav_queue_enable_notify(netcp->rx_queue);
+	netcp_rxpool_refill(netcp);
 	netif_tx_wake_all_queues(ndev);
 	dev_dbg(netcp->ndev_dev, "netcp device %s opened\n", ndev->name);
 	return 0;
-- 
1.9.1
