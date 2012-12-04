From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 1/7] qlcnic: add 82xx adapter specific checks
Date: Tue,  4 Dec 2012 08:33:52 -0500
Message-ID: <1354628038-2234-2-git-send-email-sony.chacko@qlogic.com>
References: <1354628038-2234-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:5572 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753165Ab2LDNwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 08:52:41 -0500
In-Reply-To: <1354628038-2234-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Add 82xx adapter ID check before 82xx specific operations as part of
refactoring the driver to enable support for new adapter.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    7 ++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   23 ++++++++++++++-------
 2 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 082eecb..ebc5b06 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1515,4 +1515,11 @@ struct qlcnic_nic_template {
 			__func__, ##_args);		\
 	} while (0)
 
+#define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
+static inline bool qlcnic_82xx_check(struct qlcnic_adapter *adapter)
+{
+	unsigned short device = adapter->pdev->device;
+	return (device == PCI_DEVICE_ID_QLOGIC_QLE824X) ? true : false;
+}
+
 #endif				/* __QLCNIC_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1eef0bf..5fad56e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1561,7 +1561,9 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, adapter);
 
-	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
+	if (qlcnic_82xx_check(adapter))
+		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
+				     FW_POLL_DELAY);
 
 	switch (adapter->ahw->port_type) {
 	case QLCNIC_GBE:
@@ -1640,7 +1642,8 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 	if (adapter->eswitch != NULL)
 		kfree(adapter->eswitch);
 
-	qlcnic_clr_all_drv_state(adapter, 0);
+	if (qlcnic_82xx_check(adapter))
+		qlcnic_clr_all_drv_state(adapter, 0);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
@@ -1676,7 +1679,8 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	if (netif_running(netdev))
 		qlcnic_down(adapter, netdev);
 
-	qlcnic_clr_all_drv_state(adapter, 0);
+	if (qlcnic_82xx_check(adapter))
+		qlcnic_clr_all_drv_state(adapter, 0);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
@@ -1684,9 +1688,11 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	if (retval)
 		return retval;
 
-	if (qlcnic_wol_supported(adapter)) {
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
+	if (qlcnic_82xx_check(adapter)) {
+		if (qlcnic_wol_supported(adapter)) {
+			pci_enable_wake(pdev, PCI_D3cold, 1);
+			pci_enable_wake(pdev, PCI_D3hot, 1);
+		}
 	}
 
 	return 0;
@@ -1824,10 +1830,11 @@ static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter)
 static int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	u32 temp, temp_state, temp_val;
+	u32 temp_state, temp_val, temp = 0;
 	int rv = 0;
 
-	temp = QLCRD32(adapter, CRB_TEMP_STATE);
+	if (qlcnic_82xx_check(adapter))
+		temp = QLCRD32(adapter, CRB_TEMP_STATE);
 
 	temp_state = qlcnic_get_temp_state(temp);
 	temp_val = qlcnic_get_temp_val(temp);
-- 
1.7.1
