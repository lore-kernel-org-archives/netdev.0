From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 3/4] qlge: bugfix: Move netif_napi_del() to common call point.
Date: Wed, 11 Mar 2009 14:55:42 -0700
Message-ID: <1236808543-11165-4-git-send-email-ron.mercer@qlogic.com>
References: <1236808543-11165-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:2059 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754978AbZCKV7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 17:59:38 -0400
In-Reply-To: <1236808543-11165-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving netif_napi_del() up the call chain so it will get called from all
exit points.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 54d54ea..00c37c0 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3163,6 +3163,11 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	ql_tx_ring_clean(qdev);
 
+	/* Call netif_napi_del() from common point.
+	 */
+	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++)
+		netif_napi_del(&qdev->rx_ring[i].napi);
+
 	spin_lock(&qdev->hw_lock);
 	status = ql_adapter_reset(qdev);
 	if (status)
@@ -3867,7 +3872,7 @@ static int qlge_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	int err, i;
+	int err;
 
 	netif_device_detach(ndev);
 
@@ -3877,9 +3882,6 @@ static int qlge_suspend(struct pci_dev *pdev, pm_message_t state)
 			return err;
 	}
 
-	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++)
-		netif_napi_del(&qdev->rx_ring[i].napi);
-
 	err = pci_save_state(pdev);
 	if (err)
 		return err;
-- 
1.6.0.2

