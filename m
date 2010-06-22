From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 5/8] qlcnic: dont free host resources during fw recovery
Date: Tue, 22 Jun 2010 06:19:02 -0700
Message-ID: <1277212745-26857-6-git-send-email-amit.salecha@qlogic.com>
References: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:52374 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754974Ab0FVNTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 09:19:08 -0400
In-Reply-To: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

There is no need to free/alloc host resources during firmware
recovery.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   32 +++-----------------------------
 1 files changed, 3 insertions(+), 29 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 38d8fe0..c4602fa 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1392,8 +1392,6 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 
 	cancel_work_sync(&adapter->tx_timeout_task);
 
-	qlcnic_detach(adapter);
-
 	qlcnic_clr_all_drv_state(adapter);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
@@ -1454,28 +1452,16 @@ qlcnic_resume(struct pci_dev *pdev)
 	}
 
 	if (netif_running(netdev)) {
-		err = qlcnic_attach(adapter);
-		if (err)
-			goto err_out;
-
 		err = qlcnic_up(adapter, netdev);
 		if (err)
-			goto err_out_detach;
-
+			goto done;
 
 		qlcnic_config_indev_addr(netdev, NETDEV_UP);
 	}
-
+done:
 	netif_device_attach(netdev);
 	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
 	return 0;
-
-err_out_detach:
-	qlcnic_detach(adapter);
-err_out:
-	qlcnic_clr_all_drv_state(adapter);
-	netif_device_attach(netdev);
-	return err;
 }
 #endif
 
@@ -2426,10 +2412,6 @@ qlcnic_detach_work(struct work_struct *work)
 
 	qlcnic_down(adapter, netdev);
 
-	rtnl_lock();
-	qlcnic_detach(adapter);
-	rtnl_unlock();
-
 	status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
 
 	if (status & QLCNIC_RCODE_FATAL_ERROR)
@@ -2518,18 +2500,10 @@ qlcnic_attach_work(struct work_struct *work)
 	struct qlcnic_adapter *adapter = container_of(work,
 				struct qlcnic_adapter, fw_work.work);
 	struct net_device *netdev = adapter->netdev;
-	int err;
 
 	if (netif_running(netdev)) {
-		err = qlcnic_attach(adapter);
-		if (err)
-			goto done;
-
-		err = qlcnic_up(adapter, netdev);
-		if (err) {
-			qlcnic_detach(adapter);
+		if (qlcnic_up(adapter, netdev))
 			goto done;
-		}
 
 		qlcnic_config_indev_addr(netdev, NETDEV_UP);
 	}
-- 
1.6.0.2

