From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 12/13] netxen: simplify dma mask setting
Date: Mon, 12 Jan 2009 11:23:10 -0800
Message-ID: <1231788191-23794-13-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:56010 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754661AbZALTew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:34:52 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Raise consistent dma_mask for NX3031 to 39 bit.
o Keep dma_mask for NX2031 35 bit.
o Very old chip revisions of NX2031 have 32 bit dma_mask.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    2 -
 drivers/net/netxen/netxen_nic_main.c |   51 +++++++++++----------------------
 2 files changed, 17 insertions(+), 36 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e028735..1fb60a5 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1208,8 +1208,6 @@ struct netxen_adapter {
 	u32 crb_win;
 	rwlock_t adapter_lock;
 
-	uint64_t dma_mask;
-
 	u32 cmd_producer;
 	__le32 *cmd_consumer;
 	u32 last_cmd_consumer;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index fc49459..706722d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -162,51 +162,34 @@ static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
 static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 {
 	struct pci_dev *pdev = adapter->pdev;
-	int err;
-	uint64_t mask;
+	uint64_t mask, consistent_mask;
 
 #ifdef CONFIG_IA64
-	adapter->dma_mask = DMA_32BIT_MASK;
+	mask = DMA_32BIT_MASK;
+	consistent_mask = DMA_32BIT_MASK;
+	adapter->pci_using_dac = 0;
 #else
-	if (revision_id >= NX_P3_B0) {
-		/* should go to DMA_64BIT_MASK */
-		adapter->dma_mask = DMA_39BIT_MASK;
-		mask = DMA_39BIT_MASK;
-	} else if (revision_id == NX_P3_A2) {
-		adapter->dma_mask = DMA_39BIT_MASK;
+	mask = DMA_35BIT_MASK;
+	consistent_mask = DMA_32BIT_MASK;
+	adapter->pci_using_dac = 1;
+
+	if (NX_IS_REVISION_P3(revision_id)) {
+		/* Should go to 64-bit when firmware will support */
 		mask = DMA_39BIT_MASK;
-	} else if (revision_id == NX_P2_C1) {
-		adapter->dma_mask = DMA_35BIT_MASK;
-		mask = DMA_35BIT_MASK;
-	} else {
-		adapter->dma_mask = DMA_32BIT_MASK;
+		consistent_mask = DMA_39BIT_MASK;
+	} else if (revision_id < NX_P2_C1) {
 		mask = DMA_32BIT_MASK;
-		goto set_32_bit_mask;
+		consistent_mask = DMA_32BIT_MASK;
+		adapter->pci_using_dac = 0;
 	}
+#endif /* CONFIG_IA64 */
 
-	/*
-	 * Consistent DMA mask is set to 32 bit because it cannot be set to
-	 * 35 bits. For P3 also leave it at 32 bits for now. Only the rings
-	 * come off this pool.
-	 */
 	if (pci_set_dma_mask(pdev, mask) == 0 &&
-		pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK) == 0) {
-		adapter->pci_using_dac = 1;
+		pci_set_consistent_dma_mask(pdev, consistent_mask) == 0) {
 		return 0;
 	}
-#endif /* CONFIG_IA64 */
 
-set_32_bit_mask:
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
-	if (!err)
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
-	if (err) {
-		DPRINTK(ERR, "No usable DMA configuration, aborting:%d\n", err);
-		return err;
-	}
-
-	adapter->pci_using_dac = 0;
-	return 0;
+	return -EIO;
 }
 
 static void netxen_check_options(struct netxen_adapter *adapter)
-- 
1.6.0.2

