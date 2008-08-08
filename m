From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 4/7] netxen: fix dma watchdog
Date: Fri,  8 Aug 2008 00:08:42 -0700
Message-ID: <1218179325-32493-5-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:60716 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752573AbYHHHIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 03:08:47 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NX3031 does not require driver to kill dma watchdog.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_init.c |   28 +++++++++++++++-------------
 1 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 519fc86..5bba675 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1079,10 +1079,12 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 
 void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 {
-	int i;
+	int i = 100;
+
+	if (!adapter->dummy_dma.addr)
+		return;
 
-	if (adapter->dummy_dma.addr) {
-		i = 100;
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		do {
 			if (dma_watchdog_shutdown_request(adapter) == 1)
 				break;
@@ -1090,17 +1092,17 @@ void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 			if (dma_watchdog_shutdown_poll_result(adapter) == 1)
 				break;
 		} while (--i);
+	}
 
-		if (i) {
-			pci_free_consistent(adapter->pdev,
-				    NETXEN_HOST_DUMMY_DMA_SIZE,
-				    adapter->dummy_dma.addr,
-				    adapter->dummy_dma.phys_addr);
-			adapter->dummy_dma.addr = NULL;
-		} else {
-			printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
-					adapter->netdev->name);
-		}
+	if (i) {
+		pci_free_consistent(adapter->pdev,
+			    NETXEN_HOST_DUMMY_DMA_SIZE,
+			    adapter->dummy_dma.addr,
+			    adapter->dummy_dma.phys_addr);
+		adapter->dummy_dma.addr = NULL;
+	} else {
+		printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
+				adapter->netdev->name);
 	}
 }
 
-- 
1.5.4.3

