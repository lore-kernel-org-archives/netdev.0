From: leitao@linux.vnet.ibm.com
Subject: [PATCH] qlge: Only free resources if they were allocated
Date: Mon, 25 Jan 2010 10:17:32 -0600
Message-ID: <1264436252-3740-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:42790 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908Ab0AYQSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 11:18:38 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp05.br.ibm.com (8.14.3/8.13.1) with ESMTP id o0PG7qpg018396
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 14:07:52 -0200
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0PGIOHs3743892
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 13:18:31 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0PGINbM012557
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 14:18:24 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently qlge tries to release regions even if they were not allocated.
This causes messages like the following in the kernel log

Trying to free nonexistent resource <00000000006af400-00000000006af4ff>
Trying to free nonexistent resource <00003c04ff9f4000-00003c04ff9f7fff>
Trying to free nonexistent resource <00003c04ffc00000-00003c04ffcfffff>

This patch fixes the goto logic in order to not release the resources
if they were not allocated.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/qlge/qlge_main.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 707b391..894a7c8 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4119,7 +4119,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	err = pcie_set_readrq(pdev, 4096);
 	if (err) {
 		dev_err(&pdev->dev, "Set readrq failed.\n");
-		goto err_out;
+		goto err_out1;
 	}
 
 	err = pci_request_regions(pdev, DRV_NAME);
@@ -4140,7 +4140,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 
 	if (err) {
 		dev_err(&pdev->dev, "No usable DMA configuration.\n");
-		goto err_out;
+		goto err_out2;
 	}
 
 	/* Set PCIe reset type for EEH to fundamental. */
@@ -4152,7 +4152,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	if (!qdev->reg_base) {
 		dev_err(&pdev->dev, "Register mapping failed.\n");
 		err = -ENOMEM;
-		goto err_out;
+		goto err_out2;
 	}
 
 	qdev->doorbell_area_size = pci_resource_len(pdev, 3);
@@ -4162,14 +4162,14 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	if (!qdev->doorbell_area) {
 		dev_err(&pdev->dev, "Doorbell register mapping failed.\n");
 		err = -ENOMEM;
-		goto err_out;
+		goto err_out2;
 	}
 
 	err = ql_get_board_info(qdev);
 	if (err) {
 		dev_err(&pdev->dev, "Register access failed.\n");
 		err = -EIO;
-		goto err_out;
+		goto err_out2;
 	}
 	qdev->msg_enable = netif_msg_init(debug, default_msg);
 	spin_lock_init(&qdev->hw_lock);
@@ -4179,7 +4179,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	err = qdev->nic_ops->get_flash(qdev);
 	if (err) {
 		dev_err(&pdev->dev, "Invalid FLASH.\n");
-		goto err_out;
+		goto err_out2;
 	}
 
 	memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
@@ -4212,8 +4212,9 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 			 DRV_NAME, DRV_VERSION);
 	}
 	return 0;
-err_out:
+err_out2:
 	ql_release_all(pdev);
+err_out1:
 	pci_disable_device(pdev);
 	return err;
 }
-- 
1.6.0.2

