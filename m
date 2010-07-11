From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 2/5] cxgb4: avoid duplicating some resource freeing code
Date: Sun, 11 Jul 2010 15:01:16 -0700
Message-ID: <1278885679-3738-3-git-send-email-dm@chelsio.com>
References: <1278885679-3738-1-git-send-email-dm@chelsio.com>
 <1278885679-3738-2-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6128 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170Ab0GKWBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 18:01:20 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6BM1JNP021624
	for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 15:01:19 -0700
In-Reply-To: <1278885679-3738-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there are two copies of some resource freeing code, turn it into
a function and call it.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   42 +++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 743dc6f..653bb54 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3364,6 +3364,29 @@ static void __devinit print_port_info(struct adapter *adap)
 	}
 }
 
+/*
+ * Free the following resources:
+ * - memory used for tables
+ * - MSI/MSI-X
+ * - net devices
+ * - resources FW is holding for us
+ */
+static void free_some_resources(struct adapter *adapter)
+{
+	unsigned int i;
+
+	t4_free_mem(adapter->l2t);
+	t4_free_mem(adapter->tids.tid_tab);
+	disable_msi(adapter);
+
+	for_each_port(adapter, i)
+		if (adapter->port[i])
+			free_netdev(adapter->port[i]);
+
+	if (adapter->flags & FW_OK)
+		t4_fw_bye(adapter, 0);
+}
+
 #define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO | NETIF_F_TSO6 |\
 		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
 
@@ -3564,14 +3587,7 @@ sriov:
 	return 0;
 
  out_free_dev:
-	t4_free_mem(adapter->tids.tid_tab);
-	t4_free_mem(adapter->l2t);
-	for_each_port(adapter, i)
-		if (adapter->port[i])
-			free_netdev(adapter->port[i]);
-	if (adapter->flags & FW_OK)
-		t4_fw_bye(adapter, 0);
-	disable_msi(adapter);
+	free_some_resources(adapter);
  out_unmap_bar:
 	iounmap(adapter->regs);
  out_free_adapter:
@@ -3606,16 +3622,8 @@ static void __devexit remove_one(struct pci_dev *pdev)
 
 		if (adapter->flags & FULL_INIT_DONE)
 			cxgb_down(adapter);
-		t4_free_mem(adapter->l2t);
-		t4_free_mem(adapter->tids.tid_tab);
-		disable_msi(adapter);
-
-		for_each_port(adapter, i)
-			if (adapter->port[i])
-				free_netdev(adapter->port[i]);
 
-		if (adapter->flags & FW_OK)
-			t4_fw_bye(adapter, 0);
+		free_some_resources(adapter);
 		iounmap(adapter->regs);
 		kfree(adapter);
 		pci_disable_pcie_error_reporting(pdev);
-- 
1.5.4

