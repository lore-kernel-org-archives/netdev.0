From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/2] qlge: Fix EEH handling.
Date: Wed, 28 Oct 2009 11:39:20 -0700
Message-ID: <1256755161-29606-2-git-send-email-ron.mercer@qlogic.com>
References: <1256755161-29606-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:53983 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbZJ1Spd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 14:45:33 -0400
In-Reply-To: <1256755161-29606-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up driver resources without touch the hardware. Add pci
save/restore state.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   78 ++++++++++++++++++++++++++++--------------
 1 files changed, 52 insertions(+), 26 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 48b45df..cea7531 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3916,6 +3916,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 		goto err_out;
 	}
 
+	pci_save_state(pdev);
 	qdev->reg_base =
 	    ioremap_nocache(pci_resource_start(pdev, 1),
 			    pci_resource_len(pdev, 1));
@@ -4070,6 +4071,33 @@ static void __devexit qlge_remove(struct pci_dev *pdev)
 	free_netdev(ndev);
 }
 
+/* Clean up resources without touching hardware. */
+static void ql_eeh_close(struct net_device *ndev)
+{
+	int i;
+	struct ql_adapter *qdev = netdev_priv(ndev);
+
+	if (netif_carrier_ok(ndev)) {
+		netif_carrier_off(ndev);
+		netif_stop_queue(ndev);
+	}
+
+	if (test_bit(QL_ADAPTER_UP, &qdev->flags))
+		cancel_delayed_work_sync(&qdev->asic_reset_work);
+	cancel_delayed_work_sync(&qdev->mpi_reset_work);
+	cancel_delayed_work_sync(&qdev->mpi_work);
+	cancel_delayed_work_sync(&qdev->mpi_idc_work);
+	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
+
+	for (i = 0; i < qdev->rss_ring_count; i++)
+		netif_napi_del(&qdev->rx_ring[i].napi);
+
+	clear_bit(QL_ADAPTER_UP, &qdev->flags);
+	ql_tx_ring_clean(qdev);
+	ql_free_rx_buffers(qdev);
+	ql_release_adapter_resources(qdev);
+}
+
 /*
  * This callback is called by the PCI subsystem whenever
  * a PCI bus error is detected.
@@ -4078,17 +4106,21 @@ static pci_ers_result_t qlge_io_error_detected(struct pci_dev *pdev,
 					       enum pci_channel_state state)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	struct ql_adapter *qdev = netdev_priv(ndev);
-
-	netif_device_detach(ndev);
 
-	if (state == pci_channel_io_perm_failure)
+	switch (state) {
+	case pci_channel_io_normal:
+		return PCI_ERS_RESULT_CAN_RECOVER;
+	case pci_channel_io_frozen:
+		netif_device_detach(ndev);
+		if (netif_running(ndev))
+			ql_eeh_close(ndev);
+		pci_disable_device(pdev);
+		return PCI_ERS_RESULT_NEED_RESET;
+	case pci_channel_io_perm_failure:
+		dev_err(&pdev->dev,
+			"%s: pci_channel_io_perm_failure.\n", __func__);
 		return PCI_ERS_RESULT_DISCONNECT;
-
-	if (netif_running(ndev))
-		ql_adapter_down(qdev);
-
-	pci_disable_device(pdev);
+	}
 
 	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
@@ -4105,25 +4137,15 @@ static pci_ers_result_t qlge_io_slot_reset(struct pci_dev *pdev)
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
+	pdev->error_state = pci_channel_io_normal;
+
+	pci_restore_state(pdev);
 	if (pci_enable_device(pdev)) {
 		QPRINTK(qdev, IFUP, ERR,
 			"Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
-
 	pci_set_master(pdev);
-
-	netif_carrier_off(ndev);
-	ql_adapter_reset(qdev);
-
-	/* Make sure the EEPROM is good */
-	memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
-
-	if (!is_valid_ether_addr(ndev->perm_addr)) {
-		QPRINTK(qdev, IFUP, ERR, "After reset, invalid MAC address.\n");
-		return PCI_ERS_RESULT_DISCONNECT;
-	}
-
 	return PCI_ERS_RESULT_RECOVERED;
 }
 
@@ -4131,17 +4153,21 @@ static void qlge_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct ql_adapter *qdev = netdev_priv(ndev);
+	int err = 0;
 
-	pci_set_master(pdev);
-
+	if (ql_adapter_reset(qdev))
+		QPRINTK(qdev, DRV, ERR, "reset FAILED!\n");
 	if (netif_running(ndev)) {
-		if (ql_adapter_up(qdev)) {
+		err = qlge_open(ndev);
+		if (err) {
 			QPRINTK(qdev, IFUP, ERR,
 				"Device initialization failed after reset.\n");
 			return;
 		}
+	} else {
+		QPRINTK(qdev, IFUP, ERR,
+			"Device was not running prior to EEH.\n");
 	}
-
 	netif_device_attach(ndev);
 }
 
-- 
1.6.0.2

