From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 18/21] ntb_netdev: remove tx timeout
Date: Sat, 19 Jan 2013 02:02:32 -0700
Message-ID: <1358586155-23322-19-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a race between disabling and enabling the tx queue, resulting
in tx timeouts.  Since all the tx timeout does is re-enable the tx
queue, simple remove the start/stop of the queue and the tx timeout
routine.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/net/ntb_netdev.c |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ntb_netdev.c b/drivers/net/ntb_netdev.c
index 28d6fea..07c06cd 100644
--- a/drivers/net/ntb_netdev.c
+++ b/drivers/net/ntb_netdev.c
@@ -144,9 +144,6 @@ static void ntb_netdev_tx_handler(struct ntb_transport_qp *qp, void *qp_data,
 	}
 
 	dev_kfree_skb(skb);
-
-	if (netif_queue_stopped(ndev))
-		netif_wake_queue(ndev);
 }
 
 static netdev_tx_t ntb_netdev_start_xmit(struct sk_buff *skb,
@@ -166,7 +163,6 @@ static netdev_tx_t ntb_netdev_start_xmit(struct sk_buff *skb,
 err:
 	ndev->stats.tx_dropped++;
 	ndev->stats.tx_errors++;
-	netif_stop_queue(ndev);
 	return NETDEV_TX_BUSY;
 }
 
@@ -270,18 +266,11 @@ err:
 	return rc;
 }
 
-static void ntb_netdev_tx_timeout(struct net_device *ndev)
-{
-	if (netif_running(ndev))
-		netif_wake_queue(ndev);
-}
-
 static const struct net_device_ops ntb_netdev_ops = {
 	.ndo_open = ntb_netdev_open,
 	.ndo_stop = ntb_netdev_close,
 	.ndo_start_xmit = ntb_netdev_start_xmit,
 	.ndo_change_mtu = ntb_netdev_change_mtu,
-	.ndo_tx_timeout = ntb_netdev_tx_timeout,
 	.ndo_set_mac_address = eth_mac_addr,
 };
 
-- 
1.7.9.5
