From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH net-next] net/mlx4_core: pass pci_device_id.driver_data to __mlx4_init_one during reset
Date: Tue, 25 Mar 2014 22:10:19 +0800
Message-ID: <1395756620-7719-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>
To: ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:57455 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbaCYOUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 10:20:41 -0400
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 26 Mar 2014 00:10:34 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 3D4262CE803F
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 01:10:33 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2PDo5QP54329344
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 00:50:06 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2PEAWG0013593
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 01:10:32 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The second parameter of __mlx4_init_one() is used to identify whether the
pci_dev is a PF or VF. Currently, when it is invoked in mlx4_pci_slot_reset()
this information is missed.

This patch match the pci_dev with mlx4_pci_table and passes the
pci_device_id.driver_data to __mlx4_init_one() in mlx4_pci_slot_reset().

Tested with Mellanox ConnectX-3.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index d711158..b083808 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2670,7 +2670,11 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
 
 static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 {
-	int ret = __mlx4_init_one(pdev, 0);
+	const struct pci_device_id*  id;
+	int ret;
+
+	id = pci_match_id(mlx4_pci_table, pdev);
+	ret = __mlx4_init_one(pdev, id->driver_data);
 
 	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
 }
-- 
1.7.9.5
