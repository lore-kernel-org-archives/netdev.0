From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] net/mlx4_core: pass pci_device_id.driver_data to __mlx4_init_one during reset
Date: Thu, 27 Mar 2014 09:28:31 +0800
Message-ID: <1395883711-23607-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>
To: jackm@dev.mellanox.co.il, ogerlitz@mellanox.com,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:47336 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbaC0B2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:28:38 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 27 Mar 2014 06:58:36 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 37BD73940048
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 06:58:34 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2R1SIl457081882
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 06:58:18 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2R1SWj9015342
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 06:58:33 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The second parameter of __mlx4_init_one() is used to identify whether the
pci_dev is a PF or VF. Currently, when it is invoked in mlx4_pci_slot_reset()
this information is missed.

This patch match the pci_dev with mlx4_pci_table and passes the
pci_device_id.driver_data to __mlx4_init_one() in mlx4_pci_slot_reset().

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index d711158..aa54ef7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2670,7 +2670,11 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
 
 static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 {
-	int ret = __mlx4_init_one(pdev, 0);
+	const struct pci_device_id *id;
+	int ret;
+
+	id = pci_match_id(mlx4_pci_table, pdev);
+	ret = __mlx4_init_one(pdev, id->driver_data);
 
 	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
 }
-- 
1.7.9.5
