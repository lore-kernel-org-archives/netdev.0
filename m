From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/3] qlcnic: Return proper error codes from probe failure paths
Date: Tue, 21 May 2013 15:26:59 -0400
Message-ID: <1369164421-20996-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1369164421-20996-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:29305
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751639Ab3EUTxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 15:53:08 -0400
In-Reply-To: <1369164421-20996-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Fix error paths in probe to assign proper error codes to probe return value.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8fb836d..9a7519f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2016,8 +2016,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_enable_pcie_error_reporting(pdev);
 
 	ahw = kzalloc(sizeof(struct qlcnic_hardware_context), GFP_KERNEL);
-	if (!ahw)
+	if (!ahw) {
+		err = -ENOMEM;
 		goto err_out_free_res;
+	}
 
 	switch (ent->device) {
 	case PCI_DEVICE_ID_QLOGIC_QLE824X:
@@ -2053,6 +2055,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	adapter->qlcnic_wq = create_singlethread_workqueue("qlcnic");
 	if (adapter->qlcnic_wq == NULL) {
+		err = -ENOMEM;
 		dev_err(&pdev->dev, "Failed to create workqueue\n");
 		goto err_out_free_netdev;
 	}
@@ -2133,6 +2136,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			goto err_out_disable_msi;
 	}
 
+	err = qlcnic_get_act_pci_func(adapter);
+	if (err)
+		goto err_out_disable_mbx_intr;
+
 	err = qlcnic_setup_netdev(adapter, netdev, pci_using_dac);
 	if (err)
 		goto err_out_disable_mbx_intr;
@@ -2162,9 +2169,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
-	if (qlcnic_get_act_pci_func(adapter))
-		goto err_out_disable_mbx_intr;
-
 	if (adapter->drv_mac_learn)
 		qlcnic_alloc_lb_filters_mem(adapter);
 
-- 
1.5.6
