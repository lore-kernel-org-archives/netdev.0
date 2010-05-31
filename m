From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 1/2] be2net: cleanup in case of error in
 be_open()
Date: Mon, 31 May 2010 15:03:45 +0530
Message-ID: <20100531093345.GA2812@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:32172 "EHLO
	ubuntu.ubuntu-domain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751638Ab0EaLUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 07:20:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds cleanup code (things like unregistering irq,
disabling napi etc) to be_open() when an error occurs inside the
routine.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   95 ++++++++++++++++++++++---------------------
 1 files changed, 49 insertions(+), 46 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 54b1427..3225774 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1735,6 +1735,44 @@ done:
 	adapter->isr_registered = false;
 }
 
+static int be_close(struct net_device *netdev)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_eq_obj *rx_eq = &adapter->rx_eq;
+	struct be_eq_obj *tx_eq = &adapter->tx_eq;
+	int vec;
+
+	cancel_delayed_work_sync(&adapter->work);
+
+	be_async_mcc_disable(adapter);
+
+	netif_stop_queue(netdev);
+	netif_carrier_off(netdev);
+	adapter->link_up = false;
+
+	be_intr_set(adapter, false);
+
+	if (adapter->msix_enabled) {
+		vec = be_msix_vec_get(adapter, tx_eq->q.id);
+		synchronize_irq(vec);
+		vec = be_msix_vec_get(adapter, rx_eq->q.id);
+		synchronize_irq(vec);
+	} else {
+		synchronize_irq(netdev->irq);
+	}
+	be_irq_unregister(adapter);
+
+	napi_disable(&rx_eq->napi);
+	napi_disable(&tx_eq->napi);
+
+	/* Wait for all pending tx completions to arrive so that
+	 * all tx skbs are freed.
+	 */
+	be_tx_compl_clean(adapter);
+
+	return 0;
+}
+
 static int be_open(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -1765,27 +1803,29 @@ static int be_open(struct net_device *netdev)
 	/* Now that interrupts are on we can process async mcc */
 	be_async_mcc_enable(adapter);
 
+	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
+
 	status = be_cmd_link_status_query(adapter, &link_up, &mac_speed,
 			&link_speed);
 	if (status)
-		goto ret_sts;
+		goto err;
 	be_link_status_update(adapter, link_up);
 
-	if (be_physfn(adapter))
+	if (be_physfn(adapter)) {
 		status = be_vid_config(adapter);
-	if (status)
-		goto ret_sts;
+		if (status)
+			goto err;
 
-	if (be_physfn(adapter)) {
 		status = be_cmd_set_flow_control(adapter,
 				adapter->tx_fc, adapter->rx_fc);
 		if (status)
-			goto ret_sts;
+			goto err;
 	}
 
-	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
-ret_sts:
-	return status;
+	return 0;
+err:
+	be_close(adapter->netdev);
+	return -EIO;
 }
 
 static int be_setup_wol(struct be_adapter *adapter, bool enable)
@@ -1913,43 +1953,6 @@ static int be_clear(struct be_adapter *adapter)
 	return 0;
 }
 
-static int be_close(struct net_device *netdev)
-{
-	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_eq_obj *rx_eq = &adapter->rx_eq;
-	struct be_eq_obj *tx_eq = &adapter->tx_eq;
-	int vec;
-
-	cancel_delayed_work_sync(&adapter->work);
-
-	be_async_mcc_disable(adapter);
-
-	netif_stop_queue(netdev);
-	netif_carrier_off(netdev);
-	adapter->link_up = false;
-
-	be_intr_set(adapter, false);
-
-	if (adapter->msix_enabled) {
-		vec = be_msix_vec_get(adapter, tx_eq->q.id);
-		synchronize_irq(vec);
-		vec = be_msix_vec_get(adapter, rx_eq->q.id);
-		synchronize_irq(vec);
-	} else {
-		synchronize_irq(netdev->irq);
-	}
-	be_irq_unregister(adapter);
-
-	napi_disable(&rx_eq->napi);
-	napi_disable(&tx_eq->napi);
-
-	/* Wait for all pending tx completions to arrive so that
-	 * all tx skbs are freed.
-	 */
-	be_tx_compl_clean(adapter);
-
-	return 0;
-}
 
 #define FW_FILE_HDR_SIGN 	"ServerEngines Corp. "
 char flash_cookie[2][16] =	{"*** SE FLAS",
-- 
1.6.5.2

