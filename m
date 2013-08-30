From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 5/9] qlcnic: Add AER callback handlers.
Date: Fri, 30 Aug 2013 13:51:20 -0400
Message-ID: <1377885084-6441-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Pratik Pujar <pratik.pujar@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37831 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756827Ab3H3SU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:20:29 -0400
In-Reply-To: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pratik Pujar <pratik.pujar@qlogic.com>

o Generic AER callback handlers will make use of qlcnic_hardware_ops structure
  to call adapter specific handlers.

Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    8 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   71 ++++++++++++++-------
 2 files changed, 55 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 8ae725f..27e34a5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1479,6 +1479,10 @@ void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
 int qlcnic_dump_fw(struct qlcnic_adapter *);
 int qlcnic_enable_fw_dump_state(struct qlcnic_adapter *);
 bool qlcnic_check_fw_dump_state(struct qlcnic_adapter *);
+pci_ers_result_t qlcnic_82xx_io_error_detected(struct pci_dev *,
+					       pci_channel_state_t);
+pci_ers_result_t qlcnic_82xx_io_slot_reset(struct pci_dev *);
+void qlcnic_82xx_io_resume(struct pci_dev *);
 
 /* Functions from qlcnic_init.c */
 void qlcnic_schedule_work(struct qlcnic_adapter *, work_func_t, int);
@@ -1724,6 +1728,10 @@ struct qlcnic_hardware_ops {
 	void (*set_mac_filter_count) (struct qlcnic_adapter *);
 	void (*free_mac_list) (struct qlcnic_adapter *);
 	int (*read_phys_port_id) (struct qlcnic_adapter *);
+	pci_ers_result_t (*io_error_detected) (struct pci_dev *,
+					       pci_channel_state_t);
+	pci_ers_result_t (*io_slot_reset) (struct pci_dev *);
+	void (*io_resume) (struct pci_dev *);
 };
 
 extern struct qlcnic_nic_template qlcnic_vf_ops;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 9fe6a2d..33dcb81 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -540,6 +540,9 @@ static struct qlcnic_hardware_ops qlcnic_hw_ops = {
 	.set_mac_filter_count		= qlcnic_82xx_set_mac_filter_count,
 	.free_mac_list			= qlcnic_82xx_free_mac_list,
 	.read_phys_port_id		= qlcnic_82xx_read_phys_port_id,
+	.io_error_detected		= qlcnic_82xx_io_error_detected,
+	.io_slot_reset			= qlcnic_82xx_io_slot_reset,
+	.io_resume			= qlcnic_82xx_io_resume,
 };
 
 static void qlcnic_get_multiq_capability(struct qlcnic_adapter *adapter)
@@ -3431,19 +3434,6 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 		return err;
 	}
 
-	if (qlcnic_83xx_check(adapter)) {
-		/* register for NIC IDC AEN Events */
-		qlcnic_83xx_register_nic_idc_func(adapter, 1);
-		err = qlcnic_83xx_setup_mbx_intr(adapter);
-		if (err) {
-			dev_err(&adapter->pdev->dev,
-				"failed to setup mbx interrupt\n");
-			qlcnic_clr_all_drv_state(adapter, 1);
-			clear_bit(__QLCNIC_AER, &adapter->state);
-			goto done;
-		}
-	}
-
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
 		if (err) {
@@ -3464,8 +3454,8 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	return err;
 }
 
-static pci_ers_result_t qlcnic_io_error_detected(struct pci_dev *pdev,
-						pci_channel_state_t state)
+pci_ers_result_t qlcnic_82xx_io_error_detected(struct pci_dev *pdev,
+					       pci_channel_state_t state)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
@@ -3484,12 +3474,6 @@ static pci_ers_result_t qlcnic_io_error_detected(struct pci_dev *pdev,
 	if (netif_running(netdev))
 		qlcnic_down(adapter, netdev);
 
-	if (qlcnic_83xx_check(adapter)) {
-		qlcnic_83xx_free_mbx_intr(adapter);
-		qlcnic_83xx_register_nic_idc_func(adapter, 0);
-		cancel_delayed_work_sync(&adapter->idc_aen_work);
-	}
-
 	qlcnic_detach(adapter);
 	qlcnic_teardown_intr(adapter);
 
@@ -3501,13 +3485,13 @@ static pci_ers_result_t qlcnic_io_error_detected(struct pci_dev *pdev,
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
-static pci_ers_result_t qlcnic_io_slot_reset(struct pci_dev *pdev)
+pci_ers_result_t qlcnic_82xx_io_slot_reset(struct pci_dev *pdev)
 {
 	return qlcnic_attach_func(pdev) ? PCI_ERS_RESULT_DISCONNECT :
 				PCI_ERS_RESULT_RECOVERED;
 }
 
-static void qlcnic_io_resume(struct pci_dev *pdev)
+void qlcnic_82xx_io_resume(struct pci_dev *pdev)
 {
 	u32 state;
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
@@ -3517,9 +3501,48 @@ static void qlcnic_io_resume(struct pci_dev *pdev)
 	if (state == QLCNIC_DEV_READY && test_and_clear_bit(__QLCNIC_AER,
 							    &adapter->state))
 		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
-						FW_POLL_DELAY);
+				     FW_POLL_DELAY);
 }
 
+static pci_ers_result_t qlcnic_io_error_detected(struct pci_dev *pdev,
+						 pci_channel_state_t state)
+{
+	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+	struct qlcnic_hardware_ops *hw_ops = adapter->ahw->hw_ops;
+
+	if (hw_ops->io_error_detected) {
+		return hw_ops->io_error_detected(pdev, state);
+	} else {
+		dev_err(&pdev->dev, "AER error_detected handler not registered.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+}
+
+static pci_ers_result_t qlcnic_io_slot_reset(struct pci_dev *pdev)
+{
+	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+	struct qlcnic_hardware_ops *hw_ops = adapter->ahw->hw_ops;
+
+	if (hw_ops->io_slot_reset) {
+		return hw_ops->io_slot_reset(pdev);
+	} else {
+		dev_err(&pdev->dev, "AER slot_reset handler not registered.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+}
+
+static void qlcnic_io_resume(struct pci_dev *pdev)
+{
+	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+	struct qlcnic_hardware_ops *hw_ops = adapter->ahw->hw_ops;
+
+	if (hw_ops->io_resume)
+		hw_ops->io_resume(pdev);
+	else
+		dev_err(&pdev->dev, "AER resume handler not registered.\n");
+}
+
+
 static int
 qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
 {
-- 
1.5.6
