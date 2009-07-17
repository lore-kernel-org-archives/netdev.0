From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/4] ixgbe: Remove legacy descriptor support
Date: Thu, 16 Jul 2009 18:50:12 -0700
Message-ID: <20090717014951.24074.75893.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:48511
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751593AbZGQBuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:50:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

The ethtool offline test is the only consumer of the legacy descriptors.
Update that path to only use advanced descriptors, and remove all support
for legacy descriptors.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    4 ----
 drivers/net/ixgbe/ixgbe_ethtool.c |   33 +++++++++++++++++++--------------
 drivers/net/ixgbe/ixgbe_type.h    |   31 -------------------------------
 3 files changed, 19 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index cd22323..2a93e11 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -229,10 +229,6 @@ struct ixgbe_q_vector {
 #define IXGBE_TX_CTXTDESC_ADV(R, i)	    \
 	(&(((struct ixgbe_adv_tx_context_desc *)((R).desc))[i]))
 
-#define IXGBE_GET_DESC(R, i, type)	(&(((struct type *)((R).desc))[i]))
-#define IXGBE_TX_DESC(R, i)	IXGBE_GET_DESC(R, i, ixgbe_legacy_tx_desc)
-#define IXGBE_RX_DESC(R, i)	IXGBE_GET_DESC(R, i, ixgbe_legacy_rx_desc)
-
 #define IXGBE_MAX_JUMBO_FRAME_SIZE        16128
 #ifdef IXGBE_FCOE
 /* Use 3K as the baby jumbo frame size for FCoE */
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 2a97800..1464b33 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1440,7 +1440,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 		goto err_nomem;
 	}
 
-	tx_ring->size = tx_ring->count * sizeof(struct ixgbe_legacy_tx_desc);
+	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 	if (!(tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,
 						   &tx_ring->dma))) {
@@ -1454,7 +1454,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDBAH(0),
 			((u64) tx_ring->dma >> 32));
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDLEN(0),
-			tx_ring->count * sizeof(struct ixgbe_legacy_tx_desc));
+			tx_ring->count * sizeof(union ixgbe_adv_tx_desc));
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDH(0), 0);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDT(0), 0);
 
@@ -1472,7 +1472,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TXDCTL(0), reg_data);
 
 	for (i = 0; i < tx_ring->count; i++) {
-		struct ixgbe_legacy_tx_desc *desc = IXGBE_TX_DESC(*tx_ring, i);
+		union ixgbe_adv_tx_desc *desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
 		struct sk_buff *skb;
 		unsigned int size = 1024;
 
@@ -1486,13 +1486,18 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 		tx_ring->tx_buffer_info[i].length = skb->len;
 		tx_ring->tx_buffer_info[i].dma =
 			pci_map_single(pdev, skb->data, skb->len,
-					PCI_DMA_TODEVICE);
-		desc->buffer_addr = cpu_to_le64(tx_ring->tx_buffer_info[i].dma);
-		desc->lower.data = cpu_to_le32(skb->len);
-		desc->lower.data |= cpu_to_le32(IXGBE_TXD_CMD_EOP |
-		                                IXGBE_TXD_CMD_IFCS |
-		                                IXGBE_TXD_CMD_RS);
-		desc->upper.data = 0;
+			               PCI_DMA_TODEVICE);
+		desc->read.buffer_addr =
+		                    cpu_to_le64(tx_ring->tx_buffer_info[i].dma);
+		desc->read.cmd_type_len = cpu_to_le32(skb->len);
+		desc->read.cmd_type_len |= cpu_to_le32(IXGBE_TXD_CMD_EOP |
+		                                       IXGBE_TXD_CMD_IFCS |
+		                                       IXGBE_TXD_CMD_RS);
+		desc->read.olinfo_status = 0;
+		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+			desc->read.olinfo_status |=
+			                (skb->len << IXGBE_ADVTXD_PAYLEN_SHIFT);
+
 	}
 
 	/* Setup Rx Descriptor ring and Rx buffers */
@@ -1508,7 +1513,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 		goto err_nomem;
 	}
 
-	rx_ring->size = rx_ring->count * sizeof(struct ixgbe_legacy_rx_desc);
+	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
 	if (!(rx_ring->desc = pci_alloc_consistent(pdev, rx_ring->size,
 						   &rx_ring->dma))) {
@@ -1566,8 +1571,8 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXCTRL, rctl);
 
 	for (i = 0; i < rx_ring->count; i++) {
-		struct ixgbe_legacy_rx_desc *rx_desc =
-					IXGBE_RX_DESC(*rx_ring, i);
+		union ixgbe_adv_rx_desc *rx_desc =
+		                                 IXGBE_RX_DESC_ADV(*rx_ring, i);
 		struct sk_buff *skb;
 
 		skb = alloc_skb(IXGBE_RXBUFFER_2048 + NET_IP_ALIGN, GFP_KERNEL);
@@ -1580,7 +1585,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 		rx_ring->rx_buffer_info[i].dma =
 			pci_map_single(pdev, skb->data, IXGBE_RXBUFFER_2048,
 			               PCI_DMA_FROMDEVICE);
-		rx_desc->buffer_addr =
+		rx_desc->read.pkt_addr =
 				cpu_to_le64(rx_ring->rx_buffer_info[i].dma);
 		memset(skb->data, 0x00, skb->len);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index fa87309..8fb6ade 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1893,27 +1893,6 @@ enum ixgbe_fdir_pballoc_type {
 #define IXGBE_FDIR_INIT_DONE_POLL               10
 #define IXGBE_FDIRCMD_CMD_POLL                  10
 
-/* Transmit Descriptor - Legacy */
-struct ixgbe_legacy_tx_desc {
-	u64 buffer_addr;       /* Address of the descriptor's data buffer */
-	union {
-		__le32 data;
-		struct {
-			__le16 length;    /* Data buffer length */
-			u8 cso;           /* Checksum offset */
-			u8 cmd;           /* Descriptor control */
-		} flags;
-	} lower;
-	union {
-		__le32 data;
-		struct {
-			u8 status;        /* Descriptor status */
-			u8 css;           /* Checksum start */
-			__le16 vlan;
-		} fields;
-	} upper;
-};
-
 /* Transmit Descriptor - Advanced */
 union ixgbe_adv_tx_desc {
 	struct {
@@ -1928,16 +1907,6 @@ union ixgbe_adv_tx_desc {
 	} wb;
 };
 
-/* Receive Descriptor - Legacy */
-struct ixgbe_legacy_rx_desc {
-	__le64 buffer_addr; /* Address of the descriptor's data buffer */
-	__le16 length;      /* Length of data DMAed into data buffer */
-	__le16 csum;        /* Packet checksum */
-	u8 status;          /* Descriptor status */
-	u8 errors;          /* Descriptor Errors */
-	__le16 vlan;
-};
-
 /* Receive Descriptor - Advanced */
 union ixgbe_adv_rx_desc {
 	struct {

