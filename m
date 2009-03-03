From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 1/2] netxen: support larger dma addressing
Date: Mon,  2 Mar 2009 18:02:16 -0800
Message-ID: <1236045737-482-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:49843 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752524AbZCCCCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 21:02:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support larger dma mask if firmware indicates capability
to handle larger addresses.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h          |    2 -
 drivers/net/netxen/netxen_nic_main.c     |   76 ++++++++++++++++++------------
 drivers/net/netxen/netxen_nic_phan_reg.h |    1 +
 3 files changed, 46 insertions(+), 33 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index bbdd8f2..bd5fbb4 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1256,8 +1256,6 @@ struct netxen_adapter {
 	u32 crb_win;
 	rwlock_t adapter_lock;
 
-	uint64_t dma_mask;
-
 	u32 cmd_producer;
 	__le32 *cmd_consumer;
 	u32 last_cmd_consumer;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 02f5240..0ce7cf0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -166,50 +166,61 @@ static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
 static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 {
 	struct pci_dev *pdev = adapter->pdev;
-	int err;
-	uint64_t mask;
-
-#ifdef CONFIG_IA64
-	adapter->dma_mask = DMA_32BIT_MASK;
-#else
-	if (revision_id >= NX_P3_B0) {
-		/* should go to DMA_64BIT_MASK */
-		adapter->dma_mask = DMA_39BIT_MASK;
-		mask = DMA_39BIT_MASK;
-	} else if (revision_id == NX_P3_A2) {
-		adapter->dma_mask = DMA_39BIT_MASK;
-		mask = DMA_39BIT_MASK;
-	} else if (revision_id == NX_P2_C1) {
-		adapter->dma_mask = DMA_35BIT_MASK;
-		mask = DMA_35BIT_MASK;
-	} else {
-		adapter->dma_mask = DMA_32BIT_MASK;
-		mask = DMA_32BIT_MASK;
-		goto set_32_bit_mask;
-	}
+	uint64_t mask, cmask;
+
+	adapter->pci_using_dac = 0;
 
+	mask = DMA_32BIT_MASK;
 	/*
 	 * Consistent DMA mask is set to 32 bit because it cannot be set to
 	 * 35 bits. For P3 also leave it at 32 bits for now. Only the rings
 	 * come off this pool.
 	 */
+	cmask = DMA_32BIT_MASK;
+
+#ifndef CONFIG_IA64
+	if (revision_id >= NX_P3_B0)
+		mask = DMA_39BIT_MASK;
+	else if (revision_id == NX_P2_C1)
+		mask = DMA_35BIT_MASK;
+#endif
 	if (pci_set_dma_mask(pdev, mask) == 0 &&
-		pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK) == 0) {
+		pci_set_consistent_dma_mask(pdev, cmask) == 0) {
 		adapter->pci_using_dac = 1;
 		return 0;
 	}
-set_32_bit_mask:
-#endif /* CONFIG_IA64 */
 
-	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
-	if (!err)
-		err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
-	if (err) {
-		DPRINTK(ERR, "No usable DMA configuration, aborting:%d\n", err);
-		return err;
+	return -EIO;
+}
+
+/* Update addressable range if firmware supports it */
+static int
+nx_update_dma_mask(struct netxen_adapter *adapter)
+{
+	int change, shift, err;
+	uint64_t mask, old_mask;
+	struct pci_dev *pdev = adapter->pdev;
+
+	change = 0;
+
+	shift = netxen_nic_reg_read(adapter, CRB_DMA_SHIFT);
+	if (shift >= 32)
+		return 0;
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id) && (shift > 9))
+		change = 1;
+	else if ((adapter->ahw.revision_id == NX_P2_C1) && (shift <= 4))
+		change = 1;
+
+	if (change) {
+		old_mask = pdev->dma_mask;
+		mask = (1ULL<<(32+shift)) - 1;
+
+		err = pci_set_dma_mask(pdev, mask);
+		if (err)
+			return pci_set_dma_mask(pdev, old_mask);
 	}
 
-	adapter->pci_using_dac = 0;
 	return 0;
 }
 
@@ -674,6 +685,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 		netxen_pinit_from_rom(adapter, 0);
 		msleep(1);
 	}
+	netxen_nic_reg_write(adapter, CRB_DMA_SHIFT, 0x55555555);
 	netxen_load_firmware(adapter);
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
@@ -851,6 +863,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			goto err_out_iounmap;
 	}
 
+	nx_update_dma_mask(adapter);
+
 	netxen_nic_flash_print(adapter);
 
 	if (NX_IS_REVISION_P3(revision_id)) {
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 2a368f2..5018333 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -91,6 +91,7 @@
 #define CRB_RX_LRO_START_NUM        NETXEN_NIC_REG(0xc0)
 #define CRB_MPORT_MODE              NETXEN_NIC_REG(0xc4)	/* Multiport Mode */
 #define CRB_CMD_RING_SIZE           NETXEN_NIC_REG(0xc8)
+#define CRB_DMA_SHIFT               NETXEN_NIC_REG(0xcc)
 #define CRB_INT_VECTOR              NETXEN_NIC_REG(0xd4)
 #define CRB_CTX_RESET               NETXEN_NIC_REG(0xd8)
 #define CRB_HOST_STS_PROD           NETXEN_NIC_REG(0xdc)
-- 
1.6.0.2

