From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] qlge: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 18:16:09 +0530
Message-ID: <20091007124600.GA30144@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:39322 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932888AbZJGMq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 08:46:29 -0400
Received: by mail-fx0-f227.google.com with SMTP id 27so4552575fxm.17
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 05:46:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the private adapter structure.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/qlge/qlge.h      |    1 -
 drivers/net/qlge/qlge_main.c |   12 ++++++------
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 3ec6e85..9e53ca9 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1516,7 +1516,6 @@ struct ql_adapter {
 
 	union flash_params flash;
 
-	struct net_device_stats stats;
 	struct workqueue_struct *workqueue;
 	struct delayed_work asic_reset_work;
 	struct delayed_work mpi_reset_work;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 6168071..fde5af0 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1644,8 +1644,8 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 		}
 	}
 
-	qdev->stats.rx_packets++;
-	qdev->stats.rx_bytes += skb->len;
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += skb->len;
 	skb_record_rx_queue(skb, rx_ring->cq_id);
 	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		if (qdev->vlgrp &&
@@ -1669,6 +1669,7 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 				   struct ob_mac_iocb_rsp *mac_rsp)
 {
+	struct net_device *ndev = qdev->ndev;
 	struct tx_ring *tx_ring;
 	struct tx_ring_desc *tx_ring_desc;
 
@@ -1676,8 +1677,8 @@ static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 	tx_ring = &qdev->tx_ring[mac_rsp->txq_idx];
 	tx_ring_desc = &tx_ring->q[mac_rsp->tid];
 	ql_unmap_send(qdev, tx_ring_desc, tx_ring_desc->map_cnt);
-	qdev->stats.tx_bytes += (tx_ring_desc->skb)->len;
-	qdev->stats.tx_packets++;
+	ndev->stats.tx_bytes += (tx_ring_desc->skb)->len;
+	ndev->stats.tx_packets++;
 	dev_kfree_skb(tx_ring_desc->skb);
 	tx_ring_desc->skb = NULL;
 
@@ -3569,8 +3570,7 @@ static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 static struct net_device_stats *qlge_get_stats(struct net_device
 					       *ndev)
 {
-	struct ql_adapter *qdev = netdev_priv(ndev);
-	return &qdev->stats;
+	return &ndev->stats;
 }
 
 static void qlge_set_multicast_list(struct net_device *ndev)
-- 
1.6.0.4

