From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 20/20] ixgbe: rewrite ethtool test to use
	standard config functions
Date: Thu, 19 Aug 2010 16:40:54 -0700
Message-ID: <20100819234052.10335.57519.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:51303
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751598Ab0HSXlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:41:15 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that the ethtool loopback test uses the standard
ring configuration and allocation functions.  As a result the loopback test
will be much more effective at testing core driver functionality.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |   11 +
 drivers/net/ixgbe/ixgbe_ethtool.c |  362 +++++++++++++------------------------
 drivers/net/ixgbe/ixgbe_main.c    |   49 +++--
 3 files changed, 169 insertions(+), 253 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index ac4b90e..5cebc37 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -453,9 +453,20 @@ extern int ixgbe_setup_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *)
 extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
 extern void ixgbe_free_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
 extern void ixgbe_free_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
+extern void ixgbe_configure_rx_ring(struct ixgbe_adapter *,struct ixgbe_ring *);
+extern void ixgbe_configure_tx_ring(struct ixgbe_adapter *,struct ixgbe_ring *);
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
+extern netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *,
+					 struct net_device *,
+					 struct ixgbe_adapter *,
+					 struct ixgbe_ring *);
+extern void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *,
+                                             struct ixgbe_tx_buffer *);
+extern void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
+                                   struct ixgbe_ring *rx_ring,
+                                   int cleaned_count);
 extern void ixgbe_write_eitr(struct ixgbe_q_vector *);
 extern int ethtool_ioctl(struct ifreq *ifr);
 extern s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw);
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 4d74f4b..25ef8b1 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1438,9 +1438,7 @@ static void ixgbe_free_desc_rings(struct ixgbe_adapter *adapter)
 	struct ixgbe_ring *tx_ring = &adapter->test_tx_ring;
 	struct ixgbe_ring *rx_ring = &adapter->test_rx_ring;
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct pci_dev *pdev = adapter->pdev;
 	u32 reg_ctl;
-	int i;
 
 	/* shut down the DMA engines now so they can be reinitialized later */
 
@@ -1448,14 +1446,15 @@ static void ixgbe_free_desc_rings(struct ixgbe_adapter *adapter)
 	reg_ctl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	reg_ctl &= ~IXGBE_RXCTRL_RXEN;
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, reg_ctl);
-	reg_ctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(0));
+	reg_ctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(rx_ring->reg_idx));
 	reg_ctl &= ~IXGBE_RXDCTL_ENABLE;
-	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(0), reg_ctl);
+	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(rx_ring->reg_idx), reg_ctl);
 
 	/* now Tx */
-	reg_ctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(0));
+	reg_ctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(tx_ring->reg_idx));
 	reg_ctl &= ~IXGBE_TXDCTL_ENABLE;
-	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(0), reg_ctl);
+	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(tx_ring->reg_idx), reg_ctl);
+
 	if (hw->mac.type == ixgbe_mac_82599EB) {
 		reg_ctl = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
 		reg_ctl &= ~IXGBE_DMATXCTL_TE;
@@ -1464,221 +1463,57 @@ static void ixgbe_free_desc_rings(struct ixgbe_adapter *adapter)
 
 	ixgbe_reset(adapter);
 
-	if (tx_ring->desc && tx_ring->tx_buffer_info) {
-		for (i = 0; i < tx_ring->count; i++) {
-			struct ixgbe_tx_buffer *buf =
-					&(tx_ring->tx_buffer_info[i]);
-			if (buf->dma)
-				dma_unmap_single(&pdev->dev, buf->dma,
-						 buf->length, DMA_TO_DEVICE);
-			if (buf->skb)
-				dev_kfree_skb(buf->skb);
-		}
-	}
-
-	if (rx_ring->desc && rx_ring->rx_buffer_info) {
-		for (i = 0; i < rx_ring->count; i++) {
-			struct ixgbe_rx_buffer *buf =
-					&(rx_ring->rx_buffer_info[i]);
-			if (buf->dma)
-				dma_unmap_single(&pdev->dev, buf->dma,
-						 IXGBE_RXBUFFER_2048,
-						 DMA_FROM_DEVICE);
-			if (buf->skb)
-				dev_kfree_skb(buf->skb);
-		}
-	}
-
-	if (tx_ring->desc) {
-		dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
-				  tx_ring->dma);
-		tx_ring->desc = NULL;
-	}
-	if (rx_ring->desc) {
-		dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
-				  rx_ring->dma);
-		rx_ring->desc = NULL;
-	}
-
-	kfree(tx_ring->tx_buffer_info);
-	tx_ring->tx_buffer_info = NULL;
-	kfree(rx_ring->rx_buffer_info);
-	rx_ring->rx_buffer_info = NULL;
+	ixgbe_free_tx_resources(adapter, &adapter->test_tx_ring);
+	ixgbe_free_rx_resources(adapter, &adapter->test_rx_ring);
 }
 
 static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_ring *tx_ring = &adapter->test_tx_ring;
 	struct ixgbe_ring *rx_ring = &adapter->test_rx_ring;
-	struct pci_dev *pdev = adapter->pdev;
 	u32 rctl, reg_data;
-	int i, ret_val;
+	int ret_val;
+	int err;
 
 	/* Setup Tx descriptor ring and Tx buffers */
+	tx_ring->count = IXGBE_DEFAULT_TXD;
+	tx_ring->queue_index = 0;
+	tx_ring->reg_idx = adapter->tx_ring[0]->reg_idx;
+	tx_ring->numa_node = adapter->node;
 
-	if (!tx_ring->count)
-		tx_ring->count = IXGBE_DEFAULT_TXD;
-
-	tx_ring->tx_buffer_info = kcalloc(tx_ring->count,
-	                                  sizeof(struct ixgbe_tx_buffer),
-	                                  GFP_KERNEL);
-	if (!(tx_ring->tx_buffer_info)) {
-		ret_val = 1;
-		goto err_nomem;
-	}
-
-	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
-	tx_ring->size = ALIGN(tx_ring->size, 4096);
-	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
-					   &tx_ring->dma, GFP_KERNEL);
-	if (!(tx_ring->desc)) {
-		ret_val = 2;
-		goto err_nomem;
-	}
-	tx_ring->next_to_use = tx_ring->next_to_clean = 0;
-
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDBAL(0),
-			((u64) tx_ring->dma & 0x00000000FFFFFFFF));
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDBAH(0),
-			((u64) tx_ring->dma >> 32));
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDLEN(0),
-			tx_ring->count * sizeof(union ixgbe_adv_tx_desc));
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDH(0), 0);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDT(0), 0);
-
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_HLREG0);
-	reg_data |= IXGBE_HLREG0_TXPADEN;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_HLREG0, reg_data);
+	err = ixgbe_setup_tx_resources(adapter, tx_ring);
+	if (err)
+		return 1;
 
 	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
 		reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_DMATXCTL);
 		reg_data |= IXGBE_DMATXCTL_TE;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DMATXCTL, reg_data);
 	}
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_TXDCTL(0));
-	reg_data |= IXGBE_TXDCTL_ENABLE;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TXDCTL(0), reg_data);
-
-	for (i = 0; i < tx_ring->count; i++) {
-		union ixgbe_adv_tx_desc *desc = IXGBE_TX_DESC_ADV(tx_ring, i);
-		struct sk_buff *skb;
-		unsigned int size = 1024;
-
-		skb = alloc_skb(size, GFP_KERNEL);
-		if (!skb) {
-			ret_val = 3;
-			goto err_nomem;
-		}
-		skb_put(skb, size);
-		tx_ring->tx_buffer_info[i].skb = skb;
-		tx_ring->tx_buffer_info[i].length = skb->len;
-		tx_ring->tx_buffer_info[i].dma =
-			dma_map_single(&pdev->dev, skb->data, skb->len,
-				       DMA_TO_DEVICE);
-		desc->read.buffer_addr =
-		                    cpu_to_le64(tx_ring->tx_buffer_info[i].dma);
-		desc->read.cmd_type_len = cpu_to_le32(skb->len);
-		desc->read.cmd_type_len |= cpu_to_le32(IXGBE_TXD_CMD_EOP |
-		                                       IXGBE_TXD_CMD_IFCS |
-		                                       IXGBE_TXD_CMD_RS);
-		desc->read.olinfo_status = 0;
-		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
-			desc->read.olinfo_status |=
-			                (skb->len << IXGBE_ADVTXD_PAYLEN_SHIFT);
 
-	}
+	ixgbe_configure_tx_ring(adapter, tx_ring);
 
 	/* Setup Rx Descriptor ring and Rx buffers */
-
-	if (!rx_ring->count)
-		rx_ring->count = IXGBE_DEFAULT_RXD;
-
-	rx_ring->rx_buffer_info = kcalloc(rx_ring->count,
-	                                  sizeof(struct ixgbe_rx_buffer),
-	                                  GFP_KERNEL);
-	if (!(rx_ring->rx_buffer_info)) {
+	rx_ring->count = IXGBE_DEFAULT_RXD;
+	rx_ring->queue_index = 0;
+	rx_ring->reg_idx = adapter->rx_ring[0]->reg_idx;
+	rx_ring->rx_buf_len = IXGBE_RXBUFFER_2048;
+	rx_ring->numa_node = adapter->node;
+
+	err = ixgbe_setup_rx_resources(adapter, rx_ring);
+	if (err) {
 		ret_val = 4;
 		goto err_nomem;
 	}
 
-	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
-	rx_ring->size = ALIGN(rx_ring->size, 4096);
-	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
-					   &rx_ring->dma, GFP_KERNEL);
-	if (!(rx_ring->desc)) {
-		ret_val = 5;
-		goto err_nomem;
-	}
-	rx_ring->next_to_use = rx_ring->next_to_clean = 0;
-
 	rctl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXCTRL, rctl & ~IXGBE_RXCTRL_RXEN);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDBAL(0),
-			((u64)rx_ring->dma & 0xFFFFFFFF));
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDBAH(0),
-			((u64) rx_ring->dma >> 32));
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDLEN(0), rx_ring->size);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDH(0), 0);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDT(0), 0);
 
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
-	reg_data |= IXGBE_FCTRL_BAM | IXGBE_FCTRL_SBP | IXGBE_FCTRL_MPE;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCTRL, reg_data);
-
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_HLREG0);
-	reg_data &= ~IXGBE_HLREG0_LPBK;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_HLREG0, reg_data);
-
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_RDRXCTL);
-#define IXGBE_RDRXCTL_RDMTS_MASK    0x00000003 /* Receive Descriptor Minimum
-                                                  Threshold Size mask */
-	reg_data &= ~IXGBE_RDRXCTL_RDMTS_MASK;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDRXCTL, reg_data);
-
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_MCSTCTRL);
-#define IXGBE_MCSTCTRL_MO_MASK      0x00000003 /* Multicast Offset mask */
-	reg_data &= ~IXGBE_MCSTCTRL_MO_MASK;
-	reg_data |= adapter->hw.mac.mc_filter_type;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_MCSTCTRL, reg_data);
-
-	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_RXDCTL(0));
-	reg_data |= IXGBE_RXDCTL_ENABLE;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXDCTL(0), reg_data);
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-		int j = adapter->rx_ring[0]->reg_idx;
-		u32 k;
-		for (k = 0; k < 10; k++) {
-			if (IXGBE_READ_REG(&adapter->hw,
-			                   IXGBE_RXDCTL(j)) & IXGBE_RXDCTL_ENABLE)
-				break;
-			else
-				msleep(1);
-		}
-	}
+	ixgbe_configure_rx_ring(adapter, rx_ring);
 
 	rctl |= IXGBE_RXCTRL_RXEN | IXGBE_RXCTRL_DMBYPS;
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXCTRL, rctl);
 
-	for (i = 0; i < rx_ring->count; i++) {
-		union ixgbe_adv_rx_desc *rx_desc =
-		                                 IXGBE_RX_DESC_ADV(rx_ring, i);
-		struct sk_buff *skb;
-
-		skb = alloc_skb(IXGBE_RXBUFFER_2048 + NET_IP_ALIGN, GFP_KERNEL);
-		if (!skb) {
-			ret_val = 6;
-			goto err_nomem;
-		}
-		skb_reserve(skb, NET_IP_ALIGN);
-		rx_ring->rx_buffer_info[i].skb = skb;
-		rx_ring->rx_buffer_info[i].dma =
-			dma_map_single(&pdev->dev, skb->data,
-				       IXGBE_RXBUFFER_2048, DMA_FROM_DEVICE);
-		rx_desc->read.pkt_addr =
-				cpu_to_le64(rx_ring->rx_buffer_info[i].dma);
-		memset(skb->data, 0x00, skb->len);
-	}
-
 	return 0;
 
 err_nomem:
@@ -1692,16 +1527,21 @@ static int ixgbe_setup_loopback_test(struct ixgbe_adapter *adapter)
 	u32 reg_data;
 
 	/* right now we only support MAC loopback in the driver */
-
-	/* Setup MAC loopback */
 	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_HLREG0);
+	/* Setup MAC loopback */
 	reg_data |= IXGBE_HLREG0_LPBK;
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_HLREG0, reg_data);
 
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
+	reg_data |= IXGBE_FCTRL_BAM | IXGBE_FCTRL_SBP | IXGBE_FCTRL_MPE;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCTRL, reg_data);
+
 	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_AUTOC);
 	reg_data &= ~IXGBE_AUTOC_LMS_MASK;
 	reg_data |= IXGBE_AUTOC_LMS_10G_LINK_NO_AN | IXGBE_AUTOC_FLU;
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_AUTOC, reg_data);
+	IXGBE_WRITE_FLUSH(&adapter->hw);
+	msleep(10);
 
 	/* Disable Atlas Tx lanes; re-enabled in reset path */
 	if (hw->mac.type == ixgbe_mac_82598EB) {
@@ -1759,15 +1599,81 @@ static int ixgbe_check_lbtest_frame(struct sk_buff *skb,
 	return 13;
 }
 
+static u16 ixgbe_clean_test_rings(struct ixgbe_adapter *adapter,
+                                  struct ixgbe_ring *rx_ring,
+                                  struct ixgbe_ring *tx_ring,
+                                  unsigned int size)
+{
+	union ixgbe_adv_rx_desc *rx_desc;
+	struct ixgbe_rx_buffer *rx_buffer_info;
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	const int bufsz = rx_ring->rx_buf_len;
+	u32 staterr;
+	u16 rx_ntc, tx_ntc, count = 0;
+
+	/* initialize next to clean and descriptor values */
+	rx_ntc = rx_ring->next_to_clean;
+	tx_ntc = tx_ring->next_to_clean;
+	rx_desc = IXGBE_RX_DESC_ADV(rx_ring, rx_ntc);
+	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+
+	while (staterr & IXGBE_RXD_STAT_DD) {
+		/* check Rx buffer */
+		rx_buffer_info = &rx_ring->rx_buffer_info[rx_ntc];
+
+		/* unmap Rx buffer, will be remapped by alloc_rx_buffers */
+		dma_unmap_single(&adapter->pdev->dev,
+		                 rx_buffer_info->dma,
+				 bufsz,
+				 DMA_FROM_DEVICE);
+		rx_buffer_info->dma = 0;
+
+		/* verify contents of skb */
+		if (!ixgbe_check_lbtest_frame(rx_buffer_info->skb, size))
+			count++;
+
+		/* unmap buffer on Tx side */
+		tx_buffer_info = &tx_ring->tx_buffer_info[tx_ntc];
+		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
+
+		/* increment Rx/Tx next to clean counters */
+		rx_ntc++;
+		if (rx_ntc == rx_ring->count)
+			rx_ntc = 0;
+		tx_ntc++;
+		if (tx_ntc == tx_ring->count)
+			tx_ntc = 0;
+
+		/* fetch next descriptor */
+		rx_desc = IXGBE_RX_DESC_ADV(rx_ring, rx_ntc);
+		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+	}
+
+	/* re-map buffers to ring, store next to clean values */
+	ixgbe_alloc_rx_buffers(adapter, rx_ring, count);
+	rx_ring->next_to_clean = rx_ntc;
+	tx_ring->next_to_clean = tx_ntc;
+
+	return count;
+}
+
 static int ixgbe_run_loopback_test(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_ring *tx_ring = &adapter->test_tx_ring;
 	struct ixgbe_ring *rx_ring = &adapter->test_rx_ring;
-	struct pci_dev *pdev = adapter->pdev;
-	int i, j, k, l, lc, good_cnt, ret_val = 0;
-	unsigned long time;
+	int i, j, lc, good_cnt, ret_val = 0;
+	unsigned int size = 1024;
+	netdev_tx_t tx_ret_val;
+	struct sk_buff *skb;
+
+	/* allocate test skb */
+	skb = alloc_skb(size, GFP_KERNEL);
+	if (!skb)
+		return 11;
 
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDT(0), rx_ring->count - 1);
+	/* place data into test skb */
+	ixgbe_create_lbtest_frame(skb, size);
+	skb_put(skb, size);
 
 	/*
 	 * Calculate the loop count based on the largest descriptor ring
@@ -1780,54 +1686,40 @@ static int ixgbe_run_loopback_test(struct ixgbe_adapter *adapter)
 	else
 		lc = ((rx_ring->count / 64) * 2) + 1;
 
-	k = l = 0;
 	for (j = 0; j <= lc; j++) {
-		for (i = 0; i < 64; i++) {
-			ixgbe_create_lbtest_frame(
-					tx_ring->tx_buffer_info[k].skb,
-					1024);
-			dma_sync_single_for_device(&pdev->dev,
-				tx_ring->tx_buffer_info[k].dma,
-				tx_ring->tx_buffer_info[k].length,
-				DMA_TO_DEVICE);
-			if (unlikely(++k == tx_ring->count))
-				k = 0;
-		}
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDT(0), k);
-		msleep(200);
-		/* set the start time for the receive */
-		time = jiffies;
+		/* reset count of good packets */
 		good_cnt = 0;
-		do {
-			/* receive the sent packets */
-			dma_sync_single_for_cpu(&pdev->dev,
-					rx_ring->rx_buffer_info[l].dma,
-					IXGBE_RXBUFFER_2048,
-					DMA_FROM_DEVICE);
-			ret_val = ixgbe_check_lbtest_frame(
-					rx_ring->rx_buffer_info[l].skb, 1024);
-			if (!ret_val)
+
+		/* place 64 packets on the transmit queue*/
+		for (i = 0; i < 64; i++) {
+			skb_get(skb);
+			tx_ret_val = ixgbe_xmit_frame_ring(skb,
+							   adapter->netdev,
+							   adapter,
+							   tx_ring);
+			if (tx_ret_val == NETDEV_TX_OK)
 				good_cnt++;
-			if (++l == rx_ring->count)
-				l = 0;
-			/*
-			 * time + 20 msecs (200 msecs on 2.4) is more than
-			 * enough time to complete the receives, if it's
-			 * exceeded, break and error off
-			 */
-		} while (good_cnt < 64 && jiffies < (time + 20));
+		}
+
 		if (good_cnt != 64) {
-			/* ret_val is the same as mis-compare */
-			ret_val = 13;
+			ret_val = 12;
 			break;
 		}
-		if (jiffies >= (time + 20)) {
-			/* Error code for time out error */
-			ret_val = 14;
+
+		/* allow 200 milliseconds for packets to go from Tx to Rx */
+		msleep(200);
+
+		good_cnt = ixgbe_clean_test_rings(adapter, rx_ring,
+						  tx_ring, size);
+		if (good_cnt != 64) {
+			ret_val = 13;
 			break;
 		}
 	}
 
+	/* free the original skb */
+	kfree_skb(skb);
+
 	return ret_val;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 85ecf0e..18163e3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -601,9 +601,9 @@ static inline void ixgbe_irq_rearm_queues(struct ixgbe_adapter *adapter,
 	}
 }
 
-static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
-                                             struct ixgbe_tx_buffer
-                                             *tx_buffer_info)
+void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
+                                      struct ixgbe_tx_buffer
+                                      *tx_buffer_info)
 {
 	if (tx_buffer_info->dma) {
 		if (tx_buffer_info->mapped_as_page)
@@ -1032,9 +1032,9 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
  * ixgbe_alloc_rx_buffers - Replace used receive buffers; packet split
  * @adapter: address of board private structure
  **/
-static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
-                                   struct ixgbe_ring *rx_ring,
-                                   int cleaned_count)
+void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
+                            struct ixgbe_ring *rx_ring,
+                            int cleaned_count)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1095,6 +1095,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
 		} else {
 			rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
+			rx_desc->read.hdr_addr = 0;
 		}
 
 		i++;
@@ -2431,8 +2432,8 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
  *
  * Configure the Tx descriptor ring after a reset.
  **/
- static void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
-				     struct ixgbe_ring *ring)
+void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
+			     struct ixgbe_ring *ring)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 tdba = ring->dma;
@@ -2759,8 +2760,8 @@ static void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 	}
 }
 
-static void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
-				    struct ixgbe_ring *ring)
+void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
+			     struct ixgbe_ring *ring)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 rdba = ring->dma;
@@ -3671,8 +3672,11 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 	unsigned long size;
 	unsigned int i;
 
-	/* Free all the Rx ring sk_buffs */
+	/* ring already cleared, nothing to do */
+	if (!rx_ring->rx_buffer_info)
+		return;
 
+	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		struct ixgbe_rx_buffer *rx_buffer_info;
 
@@ -3739,8 +3743,11 @@ static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
 	unsigned long size;
 	unsigned int i;
 
-	/* Free all the Tx ring sk_buffs */
+	/* ring already cleared, nothing to do */
+	if (!tx_ring->tx_buffer_info)
+		return;
 
+	/* Free all the Tx ring sk_buffs */
 	for (i = 0; i < tx_ring->count; i++) {
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
 		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
@@ -6239,11 +6246,10 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 	return skb_tx_hash(dev, skb);
 }
 
-static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
-				    struct net_device *netdev)
+netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev,
+			  struct ixgbe_adapter *adapter,
+			  struct ixgbe_ring *tx_ring)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_ring *tx_ring;
 	struct netdev_queue *txq;
 	unsigned int first;
 	unsigned int tx_flags = 0;
@@ -6267,8 +6273,6 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
 
-	tx_ring = adapter->tx_ring[skb->queue_mapping];
-
 #ifdef IXGBE_FCOE
 	/* for FCoE with DCB, we force the priority to what
 	 * was specified by the switch */
@@ -6362,6 +6366,15 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_ring *tx_ring;
+
+	tx_ring = adapter->tx_ring[skb->queue_mapping];
+	return ixgbe_xmit_frame_ring(skb, netdev, adapter, tx_ring);
+}
+
 /**
  * ixgbe_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure

