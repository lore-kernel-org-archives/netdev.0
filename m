From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/6] qlcnic: Fix to send INIT_NIC_FUNC as first mailbox.
Date: Mon, 14 Apr 2014 10:02:19 -0400
Message-ID: <1397484143-9708-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:32674 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753114AbaDNOj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 10:39:59 -0400
In-Reply-To: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o INIT_NIC_FUNC should be first mailbox sent. Sending DCB capability and
  parameter query commands after that command.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c       | 2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      | 5 +++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index d211af7..3ca3118 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2355,7 +2355,9 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 		goto disable_mbx_intr;
 
 	qlcnic_83xx_clear_function_resources(adapter);
+	qlcnic_dcb_enable(adapter->dcb);
 	qlcnic_83xx_initialize_nic(adapter, 1);
+	qlcnic_dcb_get_info(adapter->dcb);
 
 	/* Configure default, SR-IOV or Virtual NIC mode of operation */
 	err = qlcnic_83xx_configure_opmode(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
index 7d4f549..a51fe18 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
@@ -330,8 +330,6 @@ static int __qlcnic_dcb_attach(struct qlcnic_dcb *dcb)
 		goto out_free_cfg;
 	}
 
-	qlcnic_dcb_get_info(dcb);
-
 	return 0;
 out_free_cfg:
 	kfree(dcb->cfg);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 309d056..84d011e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2528,8 +2528,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_hw;
 	}
 
-	qlcnic_dcb_enable(adapter->dcb);
-
 	if (qlcnic_read_mac_addr(adapter))
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
@@ -2549,7 +2547,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			 "Device does not support MSI interrupts\n");
 
 	if (qlcnic_82xx_check(adapter)) {
+		qlcnic_dcb_enable(adapter->dcb);
+		qlcnic_dcb_get_info(adapter->dcb);
 		err = qlcnic_setup_intr(adapter);
+
 		if (err) {
 			dev_err(&pdev->dev, "Failed to setup interrupt\n");
 			goto err_out_disable_msi;
-- 
1.8.1.4
