From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 7/8] qlcnic: fix interface attach sequence
Date: Wed, 31 Mar 2010 05:03:45 -0700
Message-ID: <1270037026-9062-8-git-send-email-amit.salecha@qlogic.com>
References: <1270037026-9062-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:19748 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932204Ab0CaMDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 08:03:48 -0400
In-Reply-To: <1270037026-9062-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interface should be visible even if resource allocation fails.
netif_device_attach should be called for every netif_device_detach.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 87511f1..6faabf4 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -952,11 +952,11 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 	adapter->max_sds_rings = max_sds_rings;
 
 	if (qlcnic_attach(adapter))
-		return;
+		goto out;
 
 	if (netif_running(netdev))
 		__qlcnic_up(adapter, netdev);
-
+out:
 	netif_device_attach(netdev);
 }
 
@@ -978,8 +978,10 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	adapter->diag_test = test;
 
 	ret = qlcnic_attach(adapter);
-	if (ret)
+	if (ret) {
+		netif_device_attach(netdev);
 		return ret;
+	}
 
 	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
@@ -1012,16 +1014,12 @@ qlcnic_reset_context(struct qlcnic_adapter *adapter)
 		if (netif_running(netdev)) {
 			err = qlcnic_attach(adapter);
 			if (!err)
-				err = __qlcnic_up(adapter, netdev);
-
-			if (err)
-				goto done;
+				__qlcnic_up(adapter, netdev);
 		}
 
 		netif_device_attach(netdev);
 	}
 
-done:
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	return err;
 }
@@ -1337,6 +1335,7 @@ err_out_detach:
 	qlcnic_detach(adapter);
 err_out:
 	qlcnic_clr_all_drv_state(adapter);
+	netif_device_attach(netdev);
 	return err;
 }
 #endif
@@ -2152,6 +2151,7 @@ qlcnic_fwinit_work(struct work_struct *work)
 	}
 
 err_ret:
+	netif_device_attach(adapter->netdev);
 	qlcnic_clr_all_drv_state(adapter);
 }
 
@@ -2190,6 +2190,7 @@ qlcnic_detach_work(struct work_struct *work)
 err_ret:
 	dev_err(&adapter->pdev->dev, "detach failed; status=%d temp=%d\n",
 			status, adapter->temp);
+	netif_device_attach(netdev);
 	qlcnic_clr_all_drv_state(adapter);
 
 }
@@ -2252,9 +2253,8 @@ qlcnic_attach_work(struct work_struct *work)
 		qlcnic_config_indev_addr(netdev, NETDEV_UP);
 	}
 
-	netif_device_attach(netdev);
-
 done:
+	netif_device_attach(netdev);
 	adapter->fw_fail_cnt = 0;
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
-- 
1.6.0.2

