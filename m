From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH] net/mlx4: Fix EEH recovery failure
Date: Sat, 22 Nov 2014 21:56:47 +1100
Message-ID: <1416653807-4859-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: amirv@mellanox.com, davem@davemloft.net,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:32834 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbaKVK5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 05:57:05 -0500
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Sat, 22 Nov 2014 16:27:02 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 3C83F125804B
	for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 16:27:10 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAMAuWIE56361140
	for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 16:26:32 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAMAuxgu030960
	for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 16:26:59 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch fixes couple of EEH recovery failures on PPC PowerNV
platform:

   * Release reserved memory regions in mlx4_pci_err_detected().
     Otherwise, __mlx4_init_one() fails because of reserving
     same memory regions recursively.
   * Disable PCI device in mlx4_pci_err_detected(). Otherwise,
     pci_enable_device() in __mlx4_init_one() doesn't enable
     the PCI device because it's already in enabled state indicated
     by struct pci_dev::enable_cnt.
   * Don't clear struct mlx4_priv instance in mlx4_pci_err_detected().
     Otherwise, __mlx4_init_one() runs into kernel crash because
     of dereferencing to NULL pointer.

With the patch applied, EEH recovery for mlx4 adapter succeeds on PPC
PowerNV platform.

   # lspci
   0003:0f:00.0 Network controller: Mellanox Technologies \
   MT27500 Family [ConnectX-3]

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 90de6e1..e118ac9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2809,7 +2809,6 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 	kfree(dev->caps.qp1_proxy);
 	kfree(dev->dev_vfs);
 
-	memset(priv, 0, sizeof(*priv));
 	priv->pci_dev_data = pci_dev_data;
 	priv->removed = 1;
 }
@@ -2900,6 +2899,8 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
 					      pci_channel_state_t state)
 {
 	mlx4_unload_one(pdev);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
 
 	return state == pci_channel_io_perm_failure ?
 		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
-- 
1.8.3.2
