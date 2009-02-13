From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 6/6] igb: transition driver to only using advanced
	descriptors
Date: Thu, 12 Feb 2009 20:18:48 -0800
Message-ID: <20090213041847.3848.53705.stgit@lost.foo-projects.org>
References: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:42678
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759534AbZBMETL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 23:19:11 -0500
In-Reply-To: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Currently the driver uses advanced descriptors for its main functionality,
but then uses legacy when testing.  This patch changes this so that
advanced descriptors are used throughout and all mentions of legacy
descriptors are removed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_hw.h    |  138 -----------------------------------------
 drivers/net/igb/igb.h         |    3 -
 drivers/net/igb/igb_ethtool.c |   51 +++++++++------
 drivers/net/igb/igb_main.c    |    6 +-
 4 files changed, 32 insertions(+), 166 deletions(-)

diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index bd86ceb..10b872d 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -144,144 +144,6 @@ enum e1000_fc_type {
 	e1000_fc_default = 0xFF
 };
 
-
-/* Receive Descriptor */
-struct e1000_rx_desc {
-	__le64 buffer_addr; /* Address of the descriptor's data buffer */
-	__le16 length;      /* Length of data DMAed into data buffer */
-	__le16 csum;        /* Packet checksum */
-	u8  status;      /* Descriptor status */
-	u8  errors;      /* Descriptor Errors */
-	__le16 special;
-};
-
-/* Receive Descriptor - Extended */
-union e1000_rx_desc_extended {
-	struct {
-		__le64 buffer_addr;
-		__le64 reserved;
-	} read;
-	struct {
-		struct {
-			__le32 mrq;              /* Multiple Rx Queues */
-			union {
-				__le32 rss;            /* RSS Hash */
-				struct {
-					__le16 ip_id;  /* IP id */
-					__le16 csum;   /* Packet Checksum */
-				} csum_ip;
-			} hi_dword;
-		} lower;
-		struct {
-			__le32 status_error;     /* ext status/error */
-			__le16 length;
-			__le16 vlan;             /* VLAN tag */
-		} upper;
-	} wb;  /* writeback */
-};
-
-#define MAX_PS_BUFFERS 4
-/* Receive Descriptor - Packet Split */
-union e1000_rx_desc_packet_split {
-	struct {
-		/* one buffer for protocol header(s), three data buffers */
-		__le64 buffer_addr[MAX_PS_BUFFERS];
-	} read;
-	struct {
-		struct {
-			__le32 mrq;              /* Multiple Rx Queues */
-			union {
-				__le32 rss;              /* RSS Hash */
-				struct {
-					__le16 ip_id;    /* IP id */
-					__le16 csum;     /* Packet Checksum */
-				} csum_ip;
-			} hi_dword;
-		} lower;
-		struct {
-			__le32 status_error;     /* ext status/error */
-			__le16 length0;          /* length of buffer 0 */
-			__le16 vlan;             /* VLAN tag */
-		} middle;
-		struct {
-			__le16 header_status;
-			__le16 length[3];        /* length of buffers 1-3 */
-		} upper;
-		__le64 reserved;
-	} wb; /* writeback */
-};
-
-/* Transmit Descriptor */
-struct e1000_tx_desc {
-	__le64 buffer_addr;      /* Address of the descriptor's data buffer */
-	union {
-		__le32 data;
-		struct {
-			__le16 length;    /* Data buffer length */
-			u8 cso;        /* Checksum offset */
-			u8 cmd;        /* Descriptor control */
-		} flags;
-	} lower;
-	union {
-		__le32 data;
-		struct {
-			u8 status;     /* Descriptor status */
-			u8 css;        /* Checksum start */
-			__le16 special;
-		} fields;
-	} upper;
-};
-
-/* Offload Context Descriptor */
-struct e1000_context_desc {
-	union {
-		__le32 ip_config;
-		struct {
-			u8 ipcss;      /* IP checksum start */
-			u8 ipcso;      /* IP checksum offset */
-			__le16 ipcse;     /* IP checksum end */
-		} ip_fields;
-	} lower_setup;
-	union {
-		__le32 tcp_config;
-		struct {
-			u8 tucss;      /* TCP checksum start */
-			u8 tucso;      /* TCP checksum offset */
-			__le16 tucse;     /* TCP checksum end */
-		} tcp_fields;
-	} upper_setup;
-	__le32 cmd_and_length;
-	union {
-		__le32 data;
-		struct {
-			u8 status;     /* Descriptor status */
-			u8 hdr_len;    /* Header length */
-			__le16 mss;       /* Maximum segment size */
-		} fields;
-	} tcp_seg_setup;
-};
-
-/* Offload data descriptor */
-struct e1000_data_desc {
-	__le64 buffer_addr;   /* Address of the descriptor's buffer address */
-	union {
-		__le32 data;
-		struct {
-			__le16 length;    /* Data buffer length */
-			u8 typ_len_ext;
-			u8 cmd;
-		} flags;
-	} lower;
-	union {
-		__le32 data;
-		struct {
-			u8 status;     /* Descriptor status */
-			u8 popts;      /* Packet Options */
-			__le16 special;
-		} fields;
-	} upper;
-};
-
 /* Statistics counters collected by the MAC */
 struct e1000_hw_stats {
 	u64 crcerrs;
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index a07d809..5deecc5 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -176,9 +176,6 @@ struct igb_ring {
 	(&(((union e1000_adv_tx_desc *)((R).desc))[i]))
 #define E1000_TX_CTXTDESC_ADV(R, i)	    \
 	(&(((struct e1000_adv_tx_context_desc *)((R).desc))[i]))
-#define E1000_GET_DESC(R, i, type)	(&(((struct type *)((R).desc))[i]))
-#define E1000_TX_DESC(R, i)		E1000_GET_DESC(R, i, e1000_tx_desc)
-#define E1000_RX_DESC(R, i)		E1000_GET_DESC(R, i, e1000_rx_desc)
 
 /* board specific private data structure */
 
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 30b7bc0..31f9a64 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1272,6 +1272,7 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 	struct igb_ring *tx_ring = &adapter->test_tx_ring;
 	struct igb_ring *rx_ring = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
+	struct igb_buffer *buffer_info;
 	u32 rctl;
 	int i, ret_val;
 
@@ -1288,7 +1289,7 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 		goto err_nomem;
 	}
 
-	tx_ring->size = tx_ring->count * sizeof(struct e1000_tx_desc);
+	tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 	tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,
 					     &tx_ring->dma);
@@ -1302,7 +1303,7 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 			((u64) tx_ring->dma & 0x00000000FFFFFFFF));
 	wr32(E1000_TDBAH(0), ((u64) tx_ring->dma >> 32));
 	wr32(E1000_TDLEN(0),
-			tx_ring->count * sizeof(struct e1000_tx_desc));
+			tx_ring->count * sizeof(union e1000_adv_tx_desc));
 	wr32(E1000_TDH(0), 0);
 	wr32(E1000_TDT(0), 0);
 	wr32(E1000_TCTL,
@@ -1311,27 +1312,31 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 			E1000_COLLISION_DISTANCE << E1000_COLD_SHIFT);
 
 	for (i = 0; i < tx_ring->count; i++) {
-		struct e1000_tx_desc *tx_desc = E1000_TX_DESC(*tx_ring, i);
+		union e1000_adv_tx_desc *tx_desc;
 		struct sk_buff *skb;
 		unsigned int size = 1024;
 
+		tx_desc = E1000_TX_DESC_ADV(*tx_ring, i);
 		skb = alloc_skb(size, GFP_KERNEL);
 		if (!skb) {
 			ret_val = 3;
 			goto err_nomem;
 		}
 		skb_put(skb, size);
-		tx_ring->buffer_info[i].skb = skb;
-		tx_ring->buffer_info[i].length = skb->len;
-		tx_ring->buffer_info[i].dma =
-			pci_map_single(pdev, skb->data, skb->len,
-				       PCI_DMA_TODEVICE);
-		tx_desc->buffer_addr = cpu_to_le64(tx_ring->buffer_info[i].dma);
-		tx_desc->lower.data = cpu_to_le32(skb->len);
-		tx_desc->lower.data |= cpu_to_le32(E1000_TXD_CMD_EOP |
-						   E1000_TXD_CMD_IFCS |
-						   E1000_TXD_CMD_RS);
-		tx_desc->upper.data = 0;
+		buffer_info = &tx_ring->buffer_info[i];
+		buffer_info->skb = skb;
+		buffer_info->length = skb->len;
+		buffer_info->dma = pci_map_single(pdev, skb->data, skb->len,
+		                                  PCI_DMA_TODEVICE);
+		tx_desc->read.buffer_addr = cpu_to_le64(buffer_info->dma);
+		tx_desc->read.olinfo_status = cpu_to_le32(skb->len) <<
+		                              E1000_ADVTXD_PAYLEN_SHIFT;
+		tx_desc->read.cmd_type_len = cpu_to_le32(skb->len);
+		tx_desc->read.cmd_type_len |= cpu_to_le32(E1000_TXD_CMD_EOP |
+		                                          E1000_TXD_CMD_IFCS |
+		                                          E1000_TXD_CMD_RS |
+		                                          E1000_ADVTXD_DTYP_DATA |
+		                                          E1000_ADVTXD_DCMD_DEXT);
 	}
 
 	/* Setup Rx descriptor ring and Rx buffers */
@@ -1347,7 +1352,7 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 		goto err_nomem;
 	}
 
-	rx_ring->size = rx_ring->count * sizeof(struct e1000_rx_desc);
+	rx_ring->size = rx_ring->count * sizeof(union e1000_adv_rx_desc);
 	rx_ring->desc = pci_alloc_consistent(pdev, rx_ring->size,
 					     &rx_ring->dma);
 	if (!rx_ring->desc) {
@@ -1369,12 +1374,14 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 	rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 	wr32(E1000_RCTL, rctl);
-	wr32(E1000_SRRCTL(0), 0);
+	wr32(E1000_SRRCTL(0), E1000_SRRCTL_DESCTYPE_ADV_ONEBUF);
 
 	for (i = 0; i < rx_ring->count; i++) {
-		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rx_ring, i);
+		union e1000_adv_rx_desc *rx_desc;
 		struct sk_buff *skb;
 
+		buffer_info = &rx_ring->buffer_info[i];
+		rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
 		skb = alloc_skb(IGB_RXBUFFER_2048 + NET_IP_ALIGN,
 				GFP_KERNEL);
 		if (!skb) {
@@ -1382,11 +1389,11 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 			goto err_nomem;
 		}
 		skb_reserve(skb, NET_IP_ALIGN);
-		rx_ring->buffer_info[i].skb = skb;
-		rx_ring->buffer_info[i].dma =
-			pci_map_single(pdev, skb->data, IGB_RXBUFFER_2048,
-				       PCI_DMA_FROMDEVICE);
-		rx_desc->buffer_addr = cpu_to_le64(rx_ring->buffer_info[i].dma);
+		buffer_info->skb = skb;
+		buffer_info->dma = pci_map_single(pdev, skb->data,
+		                                  IGB_RXBUFFER_2048,
+		                                  PCI_DMA_FROMDEVICE);
+		rx_desc->read.pkt_addr = cpu_to_le64(buffer_info->dma);
 		memset(skb->data, 0x00, skb->len);
 	}
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c188371..3d02473 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -921,7 +921,7 @@ void igb_reset(struct igb_adapter *adapter)
 		/* the tx fifo also stores 16 bytes of information about the tx
 		 * but don't include ethernet FCS because hardware appends it */
 		min_tx_space = (adapter->max_frame_size +
-				sizeof(struct e1000_tx_desc) -
+				sizeof(union e1000_adv_tx_desc) -
 				ETH_FCS_LEN) * 2;
 		min_tx_space = ALIGN(min_tx_space, 1024);
 		min_tx_space >>= 10;
@@ -1579,7 +1579,7 @@ int igb_setup_tx_resources(struct igb_adapter *adapter,
 	memset(tx_ring->buffer_info, 0, size);
 
 	/* round up to nearest 4K */
-	tx_ring->size = tx_ring->count * sizeof(struct e1000_tx_desc);
+	tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
 	tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,
@@ -1648,7 +1648,7 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 		struct igb_ring *ring = &adapter->tx_ring[i];
 		j = ring->reg_idx;
 		wr32(E1000_TDLEN(j),
-		     ring->count * sizeof(struct e1000_tx_desc));
+		     ring->count * sizeof(union e1000_adv_tx_desc));
 		tdba = ring->dma;
 		wr32(E1000_TDBAL(j),
 		     tdba & 0x00000000ffffffffULL);

