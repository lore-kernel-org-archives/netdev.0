From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 6/9] qlcnic: Add AER support for 83xx adapter
Date: Fri, 30 Aug 2013 13:51:21 -0400
Message-ID: <1377885084-6441-7-git-send-email-shahed.shaikh@qlogic.com>
References: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Pratik Pujar <pratik.pujar@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:9859 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756925Ab3H3SU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:20:29 -0400
In-Reply-To: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pratik Pujar <pratik.pujar@qlogic.com>

Signed-off-by: Pratik Pujar <pratik.pujar@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   59 ++++++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    7 ++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   56 ++++++++++++++++++-
 3 files changed, 121 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 36223a9..3ef5437 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -11,6 +11,7 @@
 #include <linux/ipv6.h>
 #include <linux/ethtool.h>
 #include <linux/interrupt.h>
+#include <linux/aer.h>
 
 #define QLCNIC_MAX_TX_QUEUES		1
 #define RSS_HASHTYPE_IP_TCP		0x3
@@ -177,6 +178,10 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.get_board_info			= qlcnic_83xx_get_port_info,
 	.set_mac_filter_count		= qlcnic_83xx_set_mac_filter_count,
 	.free_mac_list			= qlcnic_82xx_free_mac_list,
+	.io_error_detected		= qlcnic_83xx_io_error_detected,
+	.io_slot_reset			= qlcnic_83xx_io_slot_reset,
+	.io_resume			= qlcnic_83xx_io_resume,
+
 };
 
 static struct qlcnic_nic_template qlcnic_83xx_ops = {
@@ -3819,3 +3824,57 @@ int qlcnic_83xx_init_mailbox_work(struct qlcnic_adapter *adapter)
 	set_bit(QLC_83XX_MBX_READY, &mbx->status);
 	return 0;
 }
+
+pci_ers_result_t qlcnic_83xx_io_error_detected(struct pci_dev *pdev,
+					       pci_channel_state_t state)
+{
+	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	if (state == pci_channel_io_normal)
+		return PCI_ERS_RESULT_RECOVERED;
+
+	set_bit(__QLCNIC_AER, &adapter->state);
+	set_bit(__QLCNIC_RESETTING, &adapter->state);
+
+	qlcnic_83xx_aer_stop_poll_work(adapter);
+
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+pci_ers_result_t qlcnic_83xx_io_slot_reset(struct pci_dev *pdev)
+{
+	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+	int err = 0;
+
+	pdev->error_state = pci_channel_io_normal;
+	err = pci_enable_device(pdev);
+	if (err)
+		goto disconnect;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+
+	err = qlcnic_83xx_aer_reset(adapter);
+	if (err == 0)
+		return PCI_ERS_RESULT_RECOVERED;
+disconnect:
+	clear_bit(__QLCNIC_AER, &adapter->state);
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	return PCI_ERS_RESULT_DISCONNECT;
+}
+
+void qlcnic_83xx_io_resume(struct pci_dev *pdev)
+{
+	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
+
+	pci_cleanup_aer_uncorrect_error_status(pdev);
+	if (test_and_clear_bit(__QLCNIC_AER, &adapter->state))
+		qlcnic_83xx_aer_start_poll_work(adapter);
+}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 053a3a1..6752d58 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -657,4 +657,11 @@ int qlcnic_83xx_idc_init(struct qlcnic_adapter *);
 int qlcnic_83xx_idc_reattach_driver(struct qlcnic_adapter *);
 int qlcnic_83xx_set_vnic_opmode(struct qlcnic_adapter *);
 int qlcnic_83xx_check_vnic_state(struct qlcnic_adapter *);
+void qlcnic_83xx_aer_stop_poll_work(struct qlcnic_adapter *);
+int qlcnic_83xx_aer_reset(struct qlcnic_adapter *);
+void qlcnic_83xx_aer_start_poll_work(struct qlcnic_adapter *);
+pci_ers_result_t qlcnic_83xx_io_error_detected(struct pci_dev *,
+					       pci_channel_state_t);
+pci_ers_result_t qlcnic_83xx_io_slot_reset(struct pci_dev *);
+void qlcnic_83xx_io_resume(struct pci_dev *);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 6fac393..b7eddfe 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -797,7 +797,6 @@ static int qlcnic_83xx_idc_init_state(struct qlcnic_adapter *adapter)
 			ret = qlcnic_83xx_idc_restart_hw(adapter, 1);
 	} else {
 		ret = qlcnic_83xx_idc_check_timeout(adapter, timeout);
-		return ret;
 	}
 
 	return ret;
@@ -2249,3 +2248,58 @@ detach_mbx:
 exit:
 	return err;
 }
+
+void qlcnic_83xx_aer_stop_poll_work(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlc_83xx_idc *idc = &ahw->idc;
+
+	clear_bit(QLC_83XX_MBX_READY, &idc->status);
+	cancel_delayed_work_sync(&adapter->fw_work);
+
+	if (ahw->nic_mode == QLC_83XX_VIRTUAL_NIC_MODE)
+		qlcnic_83xx_disable_vnic_mode(adapter, 1);
+
+	qlcnic_83xx_idc_detach_driver(adapter);
+	qlcnic_83xx_register_nic_idc_func(adapter, 0);
+
+	cancel_delayed_work_sync(&adapter->idc_aen_work);
+}
+
+int qlcnic_83xx_aer_reset(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlc_83xx_idc *idc = &ahw->idc;
+	int ret = 0;
+	u32 owner;
+
+	/* Mark the previous IDC state as NEED_RESET so
+	 * that state_entry() will perform the reattachment
+	 * and bringup the device
+	 */
+	idc->prev_state = QLC_83XX_IDC_DEV_NEED_RESET;
+	owner = qlcnic_83xx_idc_find_reset_owner_id(adapter);
+	if (ahw->pci_func == owner) {
+		ret = qlcnic_83xx_restart_hw(adapter);
+		if (ret < 0)
+			return ret;
+		qlcnic_83xx_idc_clear_registers(adapter, 0);
+	}
+
+	ret = idc->state_entry(adapter);
+	return ret;
+}
+
+void qlcnic_83xx_aer_start_poll_work(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct qlc_83xx_idc *idc = &ahw->idc;
+	u32 owner;
+
+	idc->prev_state = QLC_83XX_IDC_DEV_READY;
+	owner = qlcnic_83xx_idc_find_reset_owner_id(adapter);
+	if (ahw->pci_func == owner)
+		qlcnic_83xx_idc_enter_ready_state(adapter, 0);
+
+	qlcnic_schedule_work(adapter, qlcnic_83xx_idc_poll_dev_state, 0);
+}
-- 
1.5.6
