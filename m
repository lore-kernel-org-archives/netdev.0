From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 08/13] ixgbe: Lock RSS seed,
	move rx_buf_len to the rx_ring
Date: Tue, 26 Aug 2008 04:27:16 -0700
Message-ID: <20080826112716.15787.77165.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755300AbYHZL1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:16 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099738rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:16 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This locks the seed down so loading/unloading the driver will present
predictable hashing from RSS.  Also move the rx_buf_len out of the adapter
struct, and into the Rx ring struct.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    2 -
 drivers/net/ixgbe/ixgbe_main.c |  102 ++++++++++++++++++++++------------------
 drivers/net/ixgbe/ixgbe_type.h |    9 ++--
 3 files changed, 64 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 496a91a..628f60c 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -166,6 +166,7 @@ struct ixgbe_ring {
 
 	char name[IFNAMSIZ + 5];
 	u16 work_limit;                /* max work per interrupt */
+	u16 rx_buf_len;
 };
 
 #define RING_F_VMDQ 1
@@ -228,7 +229,6 @@ struct ixgbe_adapter {
 	struct timer_list watchdog_timer;
 	struct vlan_group *vlgrp;
 	u16 bd_number;
-	u16 rx_buf_len;
 	struct work_struct reset_task;
 	struct ixgbe_q_vector q_vector[MAX_MSIX_Q_VECTORS];
 	char name[MAX_MSIX_COUNT][IFNAMSIZ + 5];
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 95d0041..b578099 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -474,15 +474,15 @@ static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
  * @adapter: address of board private structure
  **/
 static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
-				       struct ixgbe_ring *rx_ring,
-				       int cleaned_count)
+                                   struct ixgbe_ring *rx_ring,
+                                   int cleaned_count)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
-	unsigned int bufsz = adapter->rx_buf_len + NET_IP_ALIGN;
+	unsigned int bufsz = rx_ring->rx_buf_len + NET_IP_ALIGN;
 
 	i = rx_ring->next_to_use;
 	bi = &rx_ring->rx_buffer_info[i];
@@ -498,8 +498,8 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 				goto no_buffers;
 			}
 			bi->page_dma = pci_map_page(pdev, bi->page, 0,
-			                            PAGE_SIZE,
-			                            PCI_DMA_FROMDEVICE);
+	                                            PAGE_SIZE,
+	                                            PCI_DMA_FROMDEVICE);
 		}
 
 		if (!bi->skb) {
@@ -535,6 +535,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			i = 0;
 		bi = &rx_ring->rx_buffer_info[i];
 	}
+
 no_buffers:
 	if (rx_ring->next_to_use != i) {
 		rx_ring->next_to_use = i;
@@ -552,9 +553,19 @@ no_buffers:
 	}
 }
 
+static inline u16 ixgbe_get_hdr_info(union ixgbe_adv_rx_desc *rx_desc)
+{
+	return rx_desc->wb.lower.lo_dword.hs_rss.hdr_info;
+}
+
+static inline u16 ixgbe_get_pkt_info(union ixgbe_adv_rx_desc *rx_desc)
+{
+	return rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
+}
+
 static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
-			       struct ixgbe_ring *rx_ring,
-			       int *work_done, int work_to_do)
+	                       struct ixgbe_ring *rx_ring,
+	                       int *work_done, int work_to_do)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -562,36 +573,35 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
 	struct sk_buff *skb;
 	unsigned int i;
-	u32 upper_len, len, staterr;
+	u32 len, staterr;
 	u16 hdr_info;
 	bool cleaned = false;
 	int cleaned_count = 0;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 
 	i = rx_ring->next_to_clean;
-	upper_len = 0;
 	rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	rx_buffer_info = &rx_ring->rx_buffer_info[i];
 
 	while (staterr & IXGBE_RXD_STAT_DD) {
+		u32 upper_len = 0;
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
 
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-			hdr_info =
-			    le16_to_cpu(rx_desc->wb.lower.lo_dword.hdr_info);
-			len =
-			    ((hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
-			     IXGBE_RXDADV_HDRBUFLEN_SHIFT);
+			hdr_info = le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
+			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
+	                       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
 			if (hdr_info & IXGBE_RXDADV_SPH)
 				adapter->rx_hdr_split++;
 			if (len > IXGBE_RX_HDR_SIZE)
 				len = IXGBE_RX_HDR_SIZE;
 			upper_len = le16_to_cpu(rx_desc->wb.upper.length);
-		} else
+		} else {
 			len = le16_to_cpu(rx_desc->wb.upper.length);
+		}
 
 		cleaned = true;
 		skb = rx_buffer_info->skb;
@@ -600,8 +610,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 
 		if (len && !skb_shinfo(skb)->nr_frags) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-					 adapter->rx_buf_len + NET_IP_ALIGN,
-					 PCI_DMA_FROMDEVICE);
+	                                 rx_ring->rx_buf_len + NET_IP_ALIGN,
+	                                 PCI_DMA_FROMDEVICE);
 			skb_put(skb, len);
 		}
 
@@ -1415,7 +1425,7 @@ static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
 	union ixgbe_adv_rx_desc *rx_desc = priv;
 
 	/* Verify that this is a valid IPv4 TCP packet */
-	if (!(rx_desc->wb.lower.lo_dword.pkt_info &
+	if (!(ixgbe_get_pkt_info(rx_desc) &
 	    (IXGBE_RXDADV_PKTTYPE_IPV4 | IXGBE_RXDADV_PKTTYPE_TCP)))
 		return -1;
 
@@ -1442,10 +1452,13 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i, j;
 	u32 rdlen, rxctrl, rxcsum;
-	u32 random[10];
+	static const u32 seed[10] = { 0xE291D73D, 0x1805EC6C, 0x2A94B30D,
+	                  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
+	                  0x6A3E67EA, 0x14364D17, 0x3BED200D};
 	u32 fctrl, hlreg0;
 	u32 pages;
 	u32 reta = 0, mrqc, srrctl;
+	int rx_buf_len;
 
 	/* Decide whether to use packet split mode or not */
 	if (netdev->mtu > ETH_DATA_LEN)
@@ -1455,12 +1468,12 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-		adapter->rx_buf_len = IXGBE_RX_HDR_SIZE;
+		rx_buf_len = IXGBE_RX_HDR_SIZE;
 	} else {
 		if (netdev->mtu <= ETH_DATA_LEN)
-			adapter->rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
+			rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 		else
-			adapter->rx_buf_len = ALIGN(max_frame, 1024);
+			rx_buf_len = ALIGN(max_frame, 1024);
 	}
 
 	fctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
@@ -1490,12 +1503,11 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	} else {
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
 
-		if (adapter->rx_buf_len == MAXIMUM_ETHERNET_VLAN_SIZE)
+		if (rx_buf_len == MAXIMUM_ETHERNET_VLAN_SIZE)
 			srrctl |=
 			     IXGBE_RXBUFFER_2048 >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 		else
-			srrctl |=
-			     adapter->rx_buf_len >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+			srrctl |= rx_buf_len >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 	}
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(0), srrctl);
 
@@ -1508,13 +1520,15 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	 * the Base and Length of the Rx Descriptor Ring */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		rdba = adapter->rx_ring[i].dma;
-		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(i), (rdba & DMA_32BIT_MASK));
-		IXGBE_WRITE_REG(hw, IXGBE_RDBAH(i), (rdba >> 32));
-		IXGBE_WRITE_REG(hw, IXGBE_RDLEN(i), rdlen);
-		IXGBE_WRITE_REG(hw, IXGBE_RDH(i), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_RDT(i), 0);
-		adapter->rx_ring[i].head = IXGBE_RDH(i);
-		adapter->rx_ring[i].tail = IXGBE_RDT(i);
+		j = adapter->rx_ring[i].reg_idx;
+		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(j), (rdba & DMA_32BIT_MASK));
+		IXGBE_WRITE_REG(hw, IXGBE_RDBAH(j), (rdba >> 32));
+		IXGBE_WRITE_REG(hw, IXGBE_RDLEN(j), rdlen);
+		IXGBE_WRITE_REG(hw, IXGBE_RDH(j), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RDT(j), 0);
+		adapter->rx_ring[i].head = IXGBE_RDH(j);
+		adapter->rx_ring[i].tail = IXGBE_RDT(j);
+		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
 	}
 
 	/* Intitial LRO Settings */
@@ -1541,22 +1555,20 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		}
 
 		/* Fill out hash function seeds */
-		/* XXX use a random constant here to glue certain flows */
-		get_random_bytes(&random[0], 40);
 		for (i = 0; i < 10; i++)
-			IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), random[i]);
+			IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), seed[i]);
 
 		mrqc = IXGBE_MRQC_RSSEN
 		    /* Perform hash on these packet types */
-		    | IXGBE_MRQC_RSS_FIELD_IPV4
-		    | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
-		    | IXGBE_MRQC_RSS_FIELD_IPV4_UDP
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX_TCP
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX
-		    | IXGBE_MRQC_RSS_FIELD_IPV6
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_TCP
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_UDP
-		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP;
+		       | IXGBE_MRQC_RSS_FIELD_IPV4
+		       | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
+		       | IXGBE_MRQC_RSS_FIELD_IPV4_UDP
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_EX_TCP
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_EX
+		       | IXGBE_MRQC_RSS_FIELD_IPV6
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_TCP
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_UDP
+		       | IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP;
 		IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
 	}
 
@@ -1926,7 +1938,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
-					 adapter->rx_buf_len,
+					 rx_ring->rx_buf_len,
 					 PCI_DMA_FROMDEVICE);
 			rx_buffer_info->dma = 0;
 		}
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 2f4d34e..85eb03c 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1049,9 +1049,12 @@ union ixgbe_adv_rx_desc {
 	} read;
 	struct {
 		struct {
-			struct {
-				__le16 pkt_info; /* RSS type, Packet type */
-				__le16 hdr_info; /* Split Header, header len */
+			union {
+				__le32 data;
+				struct {
+					__le16 pkt_info; /* RSS type, Packet type */
+					__le16 hdr_info; /* Split Header, header len */
+				} hs_rss;
 			} lo_dword;
 			union {
 				__le32 rss; /* RSS Hash */

